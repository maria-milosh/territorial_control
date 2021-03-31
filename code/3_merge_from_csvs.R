

# Setup -------------------------------------------------------------------

pacman::p_load(tidyverse, wrapr, stringr)
setwd('data/Extracted_tables_parts')
list.files(pattern = '.csv')


# 16 to 24 ------------------------------------------------

waves <- lapply( list.files(pattern = '.csv')[1:9], function(x)
  read_csv(x) %>% 
    mutate(Wave = str_remove_all(x, '.csv'))) %>%
  bind_rows() %>% 
  mutate(LocType = ifelse(LocType %>% is.na() &
                            str_detect(Reason, 'village'), 'Village',
                          LocType))

waves %>%  # DISTRICTS PART
  filter(LocType == 'District') %>% 
  rename('ProjectedDistrict' = `Projected District/Village`)
  # write_csv(., 'Output/Districts.csv')

vil <- waves %>% # VILLAGES PART
  filter(LocType == 'Village') %>% 
  select(-`Replaced with`)

colnames(vil) <- c('Province', 'SP', 'Projected', 'Reason',
                   'LocType', 'Wave')

rm(waves)


# 25 to 26  -------------------------------------------------------------------


waves <- lapply(list.files(pattern = '.csv')[10:11], 
            function(x)
              read_csv(x, col_names = c("Province", "SP", "Projected", "Replaced With",
                                        "Reason for Replacement") ) %>% 
              mutate(Wave = str_remove(x, '.csv') ) 
) %>% 
  bind_rows() %>%
  mutate(Province = zoo::na.locf(Province) ,
         LocType = 'Village') %>% 
  subset(Province != 'Province' &
           !str_detect(Province, 'LIST OF REPLACED') ) %>% 
  select(-`Replaced With`) %>% 
  rename("Reason" = "Reason for Replacement") %>% 
  rbind(vil)

rm(vil)


# 27 to 30 ----------------------------------------------------------------


waves_2 <- lapply(  list.files(pattern = '.csv')[12:15], 
                    function(x)
  read_csv(x) %>% 
    mutate(Wave = str_remove(x, '.csv') )) %>% 
  plyr::rbind.fill() %>% # no dist 
  mutate(LocType = 'Village') %>% 
  select(-ReplacementVillage) %>% 
  rename("Reason" = "ReasonforReplacement",
         'Projected' = 'ProjectedVillage')

waves <- 
  rbind(waves, waves_2)

rm(waves_2)



# 31 to 32 ----------------------------------------------------------------------

waves <- waves %>% 
  mutate(District = NA) %>% 
  rbind(., 
  lapply(list.files(pattern = '.csv')[16:17], function(x) 
    read_csv(x) %>% 
      mutate(Wave = str_remove(x, '.csv'))) %>% 
    bind_rows() %>% 
    select(-ReplacedVillage) %>% 
    rename("Reason" = "ReasonforReplacement",
           'Projected' = 'ProjectedVillage') %>% 
    mutate(LocType = 'Village') 
  )


# 33 to 37 ----------------------------------------------------------------------


waves_2 <- lapply( list.files(pattern = '.csv')[18:22], function(x)
  read_csv(x, col_types = cols(.default = 'c')) %>% 
    mutate(Wave = str_remove_all(x, '.csv')) %>% 
    rename_at(., vars(matches(' |#|\n')),
              funs(str_remove_all(., ' |\n|\t|#')))
)


waves_2[[1]] <- waves_2[[1]] %>% 
  select(-`1`)
waves_2[[4]] <- waves_2[[4]] %>% 
  select(-`1`)
waves_2[[5]] <- waves_2[[5]] %>% 
  mutate(`Distric\rt` = `Di\rs` %p% ' ' %p% `Distric\rt` %>% 
           str_replace_all('\r', ' ')) %>% 
  select(-`Di\rs`)


colnames(waves_2[[1]]) <- colnames(waves_2[[2]])
colnames(waves_2[[3]]) <- colnames(waves_2[[1]])
colnames(waves_2[[4]]) <- colnames(waves_2[[1]])
colnames(waves_2[[5]]) <- colnames(waves_2[[1]])


waves_2 <- 
  bind_rows(waves_2) %>% 
  mutate_all(funs(str_squish(.)))


# 3 draws at max. lets split by a draw and stitch them vertically in one dataframe

waves_2 <- waves_2 %>% 
  select(SP, Province, District, Projected1, Reason1, Wave) %>% 
  mutate(Projected1 = str_remove_all(Projected1, ' replaced.*| repalced.*| Replaced.*')) %>% 
  
  plyr::rbind.fill(.,
     waves_2 %>% 
       select(Province, District, Projected2, Reason2, Wave) %>% 
       filter(!is.na(Projected2) & !is.na(Reason2)) %>% 
       rename(Projected1 = Projected2, Reason1 = Reason2) ) %>% 
  
  plyr::rbind.fill(.,
       waves_2 %>% 
         select(Province, District, Projected3, Reason2, Wave) %>% 
         filter(!is.na(Projected3) & !is.na(Reason2)) %>% 
         rename(Projected1 = Projected3, Reason1 = Reason2) ) %>% 
  mutate(SP = str_remove_all(SP, ' '))


waves_2 <- waves_2 %>% 
  mutate(
    LocType = 'Village',
    Reason1 = str_replace(Reason1, 'transport ation|transporta tion|transportati on|transportatio n', 'transportation') %>% 
      str_replace(.,'ceremon y', 'ceremony') %>% 
      str_replace(.,'No transportation way for', 'No transportation way for vehicles') %>% 
      str_replace(.,'This village is related to Unaba', 'This village is related to Unaba district') %>% 
      str_replace(.,'No transportation way for vehicles vehicles', 'No transportation way for vehicles') %>% 
      str_remove(.,'\\.') 
  ) %>% 
  rename('Projected' = 'Projected1',
         "Reason" = 'Reason1') 

colnames(waves_2)
colnames(waves)

waves <- rbind(waves, waves_2)

rm(waves_2)


# 38 ----------------------------------------------------------------------


waves <- waves %>% 
  rbind(.,
    read_csv('38.csv') %>% 
      mutate_all(funs(str_squish(.))) %>% 
      mutate(LocType = 'Village',
             Wave = '38',
             ReplacedVillage = str_remove_all(ReplacedVillage, ' NA| NA NA'),
             Projected = str_remove(ReplacedVillage, ' Replaced.*'),
             Reason = ReasonforReplacement) %>% 
      select(- c(ReplacedVillage, ReasonforReplacement))
  )


# 39-42 ----------------------------------------------------------------------

waves_39 <- 
  lapply(list.files(pattern = '.csv')[24:26], 
         function(x)
          read_csv(x, col_names = c("X1", "SP", "Province", "District", "Projected",
                                     "Reason") ) %>% 
          mutate(Wave = str_remove(x, '.csv') ) %>% 
          select(-X1) %>% 
          slice(-c(1:3)) %>%
          mutate_all(funs(str_squish(.))) %>% 
          mutate(LocType = 'Village' ) 
  ) %>% 
  bind_rows() %>% 
  rbind(., read_csv('42.csv') )
  

for (i in 1:nrow(waves_39)) {
  if (waves_39$SP[i] %>% is.na()) {
    waves_39$Province[i-1] <- waves_39$Province[i-1] %p% ' ' %p% replace_na(waves_39$Province[i], '')
    waves_39$District[i-1] <- waves_39$District[i-1] %p% ' ' %p% replace_na(waves_39$District[i], '')
    waves_39$Projected[i-1] <- waves_39$Projected[i-1] %p% ' ' %p% replace_na(waves_39$Projected[i], '')
    waves_39$Reason[i-1] <- waves_39$Reason[i-1] %p% ' ' %p% replace_na(waves_39$Reason[i], '')
  }
}


waves_39 <- 
  waves_39 %>%
  filter(!is.na(SP)) %>% 
  filter(SP != 'SP#') %>% 
  mutate(Projected = str_remove(Projected, 'Replaced.*|/.*|Repaced.*') ) %>% 
  mutate_all(funs(str_squish(.)))

waves <- rbind(waves, waves_39)


# Check -------------------------------------------------------------------


all(str_remove(list.files(pattern = '.csv'),
               '.csv') %in% 
      waves$Wave)


waves <- waves %>% 
  mutate(Reason = str_replace(Reason, '^Because of heavy snow$',
                              'Because of heavy snow the way was blocked') %>% 
           str_replace(., '^No village with this name$|^No village with this$',
                       'No village with this name was found') %>% 
           
           str_replace(., '^No transportion$|^No transportation$|^No transportation way$|^No transport$|^No transpo rtation way for vehicles $',
                       'No transportation way for vehicles') %>% 
           
           str_replace(., '^The bridge tot the village is destroyed$',
                       'The bridge to the village is destroyed') %>% 
           
           str_replace(., '^The village is under$',
                        'The village is under control of Taliban') %>% 
           
           str_replace(., '^Malik of the area didn’t allow interviews$',
                       'The Malik of the area didn’t allow interviews') %>% 
           
           str_replace(., '^People didn’t$|^People didn’t cooperate$',
                       "People didn't cooperate") %>% 
           
           str_remove(., '\\.'),
         
         
         District = gsub('[0-9]', '', District) %>% 
           str_remove_all('\n|\t') %>% 
           trimws(),
         
         Province = gsub('[0-9]', '', Province) %>% 
           str_remove_all('\n|\t|\\.') %>% 
           trimws()
         ) 



# Write -------------------------------------------------------------------


write_csv(waves, '/Users/mariamilosh/Dropbox/territorial_control/data/replaced_villages_merged/Villages.csv')





