


# Setup -------------------------------------------------------------------

setwd('data/Replaced_villages/')

pacman::p_load(dplyr, tidyverse, wrapr)
# done <- c()



# Changeable --------------------------------------------------------------



list.files(pattern = 'v1')

wave <- '34v1'




# Script ------------------------------------------------------------------



details <- list.files(pattern = wave,
                      full.names = T) %>% 
  file.info()

files <- details[with(details, order(as.POSIXct(mtime))), ] %>% 
  rownames()

files



l <- lapply(files, function(x) {

  x %>% 
  read_csv(skip_empty_rows = T, col_names = F) -> df
    
  }
) %>% 
  bind_rows()
  



# l <- if (wave == '27v1' & str_detect(l[1, 1], 'LIST OF')) { slice(l, 2:nrow(l)) } 
# l <- if (wave == '28v1' & str_detect(l[1, 4], 'Appendix B')) { slice(l, 2:nrow(l)) } 
# l <- if (wave == '28v1' & str_detect(l[1, 1], 'LIST OF')) { slice(l, 2:nrow(l)) } 
if (wave %in% c('30v1', '29v1', '31v1', '32v1', '34v1') & str_detect(l[1, 2], 'LIST OF')) { l <- slice(l, 2:nrow(l)) }
# l <- if (wave %in% c('30v1', '29v1') & str_detect(l[1, 1], 'LIST OF')) { slice(l, 2:nrow(l)) }

  
  # l[1, ] %>% 
  # str_remove_all(' |#|\n') 


l2 <- l %>% 
  filter(#SP == 'SP#' &
           # ProjectedVillage == 'Projected Village' &
           # ReplacementVillage == 'Replacement Village'
           Province == 'Provi\nnce'
           )
  

l <- l %>% 
  anti_join(., l2)
rm(l2)
    

# l[2, 2] <- '1. Kabul'
  
  
l <- l %>% 
    mutate(Province = zoo::na.locf(Province) %>% 
           str_remove('^\\d{1,2}\\.')) %>% 

    mutate_all(., funs(str_squish(.))) %>% 
  
  
    mutate(Province = ifelse(str_detect(Province, '^\\d{1,2}\\.$'),
                           lead(Province),
                           Province)) #%>% slice(2:nrow(.)) 






if (wave == '31v1' ) {
  
  l$filter <- NA
  
  for (i in 2:nrow(l)) {
    
    if ( str_detect(l$ReasonforReplacement[i], '^[:lower:]') & 
         str_detect(l$ReasonforReplacement[i - 1], ' [:upper:]{1}[:lower:]')) {
    
    l$ReasonforReplacement[i] <- str_extract(l$ReasonforReplacement[i - 1],
                                             ' [:upper:]{1}[:lower:].*') %p% 
                                          ' ' %p%
                                        l$ReasonforReplacement[i]
    }
    
    if ( str_detect(l$ReasonforReplacement[i], '^\\p{Lowercase}')) {
      
      l$ReasonforReplacement[i - 1] <- l$ReasonforReplacement[i - 1] %p% ' ' %p%
        l$ReasonforReplacement[i] 
      
      l$filter[i] <- 1
      
    }
    
  }
  
}
if (wave == '30v1') {
  
  
  shift <- which(l$ReasonforReplacement %>% 
                   is.na())
  
  l$ReasonforReplacement[shift] <- l$ReplacementVillage[shift] 
  
  l$ReasonforReplacement <- replace_na(l$ReasonforReplacement, '')
  
  l$ReplacementVillage[shift] <- l$ProjectedVillage[shift] 
  
  l$ProjectedVillage[shift] <- str_remove_all(l$SP[shift], '\\d{1,4}') %>% 
    str_squish()
  
  l$SP[shift] <- str_extract(l$SP[shift], '\\d{1,4}')
  
  
}




l$filter <- NA

l$ReasonforReplacement <- replace_na(l$ReasonforReplacement, '')

for (i in 2:nrow(l)) {
  
  if ( str_detect(l$ReasonforReplacement[i], '^\\p{Lowercase}')) {
    
    l$ReasonforReplacement[i - 1] <- l$ReasonforReplacement[i - 1] %p% ' ' %p%
      l$ReasonforReplacement[i] 
    
    l$filter[i] <- 1
    
    }
  
}




l <- l %>% 
  subset(is.na(filter)) %>% 
  select(-filter)


if (wave == '32v1') {
  
  l$Province[9:10] <- 'Faryab'
  l$Province[18] <- 'Sar-e Pul'
  l$Province[21:22] <- 'Balkh'
  l$Province[32:37] <- 'Baghlan'
  l$Province[48:52] <- 'Takhar'
  l$Province[74:76] <- 'Badakhshan'
  l$Province[80:82] <- 'Samangan'
  l$Province[87:93] <- 'Bamyan'
  l$Province[102:105] <- 'Ghazni'
  l$Province[102:105] <- 'Ghazni'
  l$Province[113] <- 'Laghman'
  l$Province[117] <- 'Kapisa'
  l$Province[119:121] <- 'Kunar'
  l$Province[125:127] <- 'Kandahar'
  l$Province[137] <- 'Zabul'
  l$Province[143] <- 'Herat'
  l$Province[164:165] <- 'Badghis'
  l$Province[169:171] <- 'Ghor'
  l$Province[179:183] <- 'Farah'
  
}
  

if (wave == '30v1') {
  
  l$ReasonforReplacement <- str_remove_all(l$ReasonforReplacement %>% 
               str_squish(), ' No village with$|The village is$|No transportation$|')
  
  l$Province[73] <- 'Takhar'
  l$Province[86] <- 'Badakhshan'
  l$Province[86] <- 'Badakhshan'
  l$Province[101] <- 'Bamyan'
  l$Province[111] <- 'Parwan'
  l$Province[130] <- 'Daykundi'
  l$Province[145] <- 'Ghor'
  
  l <- slice(l, -c(133, 119, 105))
}


if (wave == '30v1') {
  l$Province[21:27] <- 'Sar-e Pul'
  l$Province[29:36] <- 'Balkh'
  l$Province[38:47] <- 'Baghlan'
  l$Province[49:55] <- 'Takhar'
  l$Province[77:84] <- 'Badakhshan'
  l$Province[86:88] <- 'Samangan'
  l$Province[90:93] <- 'Bamyan'
  l$Province[98:99] <- 'Ghazni'
  l$Province[101] <- 'Paktika'
  l$Province[103:104] <- 'Parwan'
  l$Province[106:109] <- 'Nangarhar'
  l$Province[111:112] <- 'Laghman'
  l$Province[117:125] <- 'Kunar'
  l$Province[127] <- 'Panjshayr'
  l$Province[129] <- 'Daykundi'
  l$Province[131] <- 'Herat'
  l$Province[150] <- 'Badghis'
  l$Province[154:156] <- 'Farah'
  
  l$SP[156] <- '1639'
  l$ProjectedVillage[156] <- 'Nakhak'
  
  l$SP[152] <- '1571'
  l$ProjectedVillage[152] <- 'Meyan Koh Payen'
  
  l$ProjectedVillage[54] <- 'Hazara Qeshlaq' %p% ' ' %p% l$ProjectedVillage[54] 
  
  l <- slice(l, -53)
}


if (wave == '29v1') {
  l$Province[4:7] <- 'Sar-e Pul'
  l$Province[13:15] <- 'Balkh'
  l$Province[34] <- 'Baghlan'
  l$Province[45] <- 'Kunduz'
  l$Province[47:51] <- 'Takhar'
  l$Province[70:71] <- 'Badakhshan'
  l$Province[78] <- 'Samangan'
  l$Province[81:86] <- 'Bamyan'
  l$Province[99:100] <- 'Parwan'
  l$Province[104:105] <- 'Laghman'
  l$Province[109:110] <- 'Kunar'
  l$Province[117] <- 'Zabul'
  l$Province[121:125] <- 'Herat'
  l$Province[137:139] <- 'Badghis'
  l$Province[143:145] <- 'Ghor'
  l$Province[150:153] <- 'Farah' }


# Write -------------------------------------------------------------------


write_csv(l, 'Finale/' %p% wave %p% '.csv')

done <- append(done, wave)







# Other approaches --------------------------------------------------------

####### 38

wave <- '34v1'



page <- read_csv( wave %p% '.csv')



if (str_detect(page[1, 2], 'Appendix B')) { page <- slice(page, 2:nrow(page)) }
if (str_detect(page[1, 2], 'LIST OF')) { page <- slice(page, 2:nrow(page)) }


page <- page %>% 
  select(-X1)


colnames(page) <- 
  c('SP', 'Province', 'District', 'Projected', 'Reason', 
    'Projected2', 'Reason2', 'Projected3', 'Reason3')

# colnames(page) <- page[1, ] %>% 
#   str_remove_all(' |#|\n')



if (wave == '36v1') {
  colnames(page) <- c("1", "SP", "Province", "District", "Village1", "ReasonforReplacement", "Village2",
                      "ReasonforReplacement2", "Village3", "ReasonforReplacement3", "NA")
}


page2 <- page %>% 
  filter(#SP == 'SP#' &
    # ProjectedVillage == 'Projected Village' &
    # ReplacementVillage == 'Replacement Village'
    Province == 'Provi\nnce' |
      Province == 'nce'
  ) 

page <- page %>% 
  anti_join(., page2) %>% 
  # select(-'NA') %>% 
  mutate_all(., funs(replace_na(., ''))) %>% 
  mutate_all(., funs(str_squish(.)))
rm(page2)


page$filter <- 0



# by columns take all that starts with a lowercase letter and move up
# then also with all capital letter words












for (i in 2:nrow(page)) {
  
  
  if ( page$SP[i] == '' ) {
    
    page$Projected[i - 1] <- page$Projected[i - 1] %p% 
      ' ' %p%
      page$Projected[i]
    
    page$Province[i - 1] <- page$Province[i - 1] %p% 
      ' ' %p%
      page$Province[i]
    
    page$filter[i] <- 1
    
  }
  
}



page <- 
  page %>% 
  subset(filter == 0)


for (i in nrow(page):2) {
  
  if ( page$SP[i] == '' ) {
    
    
    page$Reason[i - 1] <- page$Reason[i - 1] %p% 
      ' ' %p%
      page$Reason[i]
    
    page$Reason2[i - 1] <- page$Reason2[i - 1] %p% 
      ' ' %p%
      page$Reason2[i]
    
    page$Reason3[i - 1] <- page$Reason3[i - 1] %p% 
      ' ' %p%
      page$Reason3[i]
    
    
    
    
    page$Projected[i - 1] <- page$Projected[i - 1] %p% 
      ' ' %p%
      page$Projected[i]
    
    page$Projected2[i - 1] <- page$Projected2[i - 1] %p% 
      ' ' %p%
      page$Projected2[i]
    
    page$Projected3[i - 1] <- page$Projected3[i - 1] %p% 
      ' ' %p%
      page$Projected3[i]
    
    
    
    
    page$District[i - 1] <- page$District[i - 1] %p% 
      ' ' %p%
      page$District[i]
    
    
    page$Province[i - 1] <- page$Province[i - 1] %p% 
      ' ' %p%
      page$Province[i]
    
    
    
    page$filter[i] <- 1
    
  }
  
  
  

}



page <- 
  page %>% 
  subset(filter == 0) %>% 
  select(-filter)


write_csv(page, 'Dropbox/Villages_test/Finale/' %p% wave %p% '.csv')








# Cashed ------------------------------------------------------------------




df %>% 
  mutate(SP = str_extract(X2, '\\d{3}'),
         
         ProjectedVillage = str_extract(X2, '\n.* \n') %>% 
           str_squish(),
         
         ReplacementReason = X2 %>% 
           str_remove_all(., '^.*\n.*\n.*\n') %>% 
           str_squish()) %>% 
  
  
  select(-c(X2))



 
  bind_rows() %>% 
  
  mutate(Province = zoo::na.locf(X1) %>% 
           str_remove('^.* ')) %>% 
  select(Province, SP, ProjectedVillage, ReplacementReason)

















