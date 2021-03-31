

# Setup -------------------------------------------------------------------

setwd('/Users/mmilosh/Dropbox/territorial_control')
pacman::p_load(tidyverse, wrapr, sf)

cleantext <- function(text) {
  tolower(text) %>% 
    str_remove_all("[:punct:]") %>% 
    str_remove_all('\n|\\s') %>% 
    str_squish()
}


# Data --------------------------------------------------------------------


# dates of each wave:
waves <- read_csv('data/waves_days.csv')


# villages extracted from the PDFs:
v <- data.table::fread('data/replaced_villages_merged/Villages.csv') %>% 
  mutate_at(c('Province', 'Projected', 'District'), cleantext) %>% 
  mutate(Wave = str_remove(Wave, 'v.')) %>% 
  select(Province, Village = Projected, Reason, Wave, District)

sum(is.na(v$District)) # 2807? now 2805

# some rearrangements in province spelling
provinces <-
        c('sarepul', 'sarepul', 'daykundi', 'daykundi', 'daykundi', 'hilmand', 'hirat', 'jawzjan', 'jawzjan', 'jawzjan', 'kandahar', 'nangarhar', 'nuristan', 'nuristan',  'paktya',  'paktya', 'panjsher',  'panjsher', 'takhar') %>%  # correct
set_names('saripul', 'pul',     'deykundi', 'daikondi', 'dehkundi', 'helmand', 'herat', 'jowzjan', 'jozjan',  'juzjan',  'kandaha',  'ningarhar', 'nooristan','noorestan', 'paktiya', 'paktia', 'panjshayr', 'panjshir', 'takha') # wrong

provinces[v$Province] %>% as.character()
v$Province <- dplyr::coalesce(provinces[v$Province], v$Province)
anyNA(v$Province)


# villages where they used intercept interviews; also from the PDFs:
inter <- lapply(list.files('data/intercept_interviews/', full.names = T),
                function(x)
                read_csv(x) %>%
                  select(Province, contains("District")) %>% 
                  mutate(Wave = str_extract(x, '\\d+'))
                ) %>% bind_rows() %>% 
  mutate_at(c('Province', 'District'), cleantext)

# will need to delete \\d+ and coalesce:
# inter$Province2 <- dplyr::coalesce(provinces[inter$Province], inter$Province)


# list of all villages:
settle <- st_read('data/ethnic_spatial', 
                  'afg_ppl_settlement_pnt') %>% 
  st_as_sf() %>% 
  st_drop_geometry() %>% 
  mutate_at(c('VILLAGE_NA', 'DIST_NA_EN', 'PROV_NA_EN'),
            cleantext ) %>%
  select(OBJECTID, VIL_UID, VILLAGE_NA, DIST_NA_EN, PROV_NA_EN,
         contains('MISTI'))


settle$PROV_NA_EN %>% table()
settle$DIST_NA_EN %>% table()
settle$VILLAGE_NA %>% n_distinct() # != nrow(settle)


# should be no difference
setdiff(v$Province %>% unique() %>% sort(),
        settle$PROV_NA_EN %>% unique() %>% sort())


# Assign districts to villages: Errors in the survey --------------------------------------------------

# sometimes they couldn't find the villages because they really were not there:
v$Reason[str_detect(v$Reason, regex('to .* district', ignore_case = T))] %>% unique()
v$Reason[str_detect(v$Reason, regex('province', ignore_case = T))] %>% unique()

v %>% 
  mutate(District_error = str_detect(Reason, regex('to .* district', ignore_case = T)),
         Province_error = str_detect(Reason, regex('province', ignore_case = T)) ) %>% 
  mutate(District_corrected =
           ifelse(District_error,
                  str_extract(Reason, regex('(?<=to ).*(?= district)', ignore_case = T)) %>%
                    str_remove('district') %>% cleantext() ,
                  District),
         Province_corrected = 
           ifelse(Province_error,
                  str_extract(Reason, regex('\\w+(?= province)', ignore_case = T)) %>% 
                    cleantext() %>% dplyr::coalesce(provinces[.], .),
                  Province)) %>% 
  select(-contains('error')) -> v


# NAs went down from 2805 to 2793:
sum(is.na(v$District_corrected))



# Assign districts to villages: Get districts from the village table --------------------------------------------------------


# make a table with provinces-districts-villages, only unique combinations:
vil_ref <- v %>% as_tibble() %>% 
  subset(!is.na(District_corrected)) %>% 
  select(District_expanded = District_corrected, Province_corrected, Village) %>% 
  distinct()

# only villages with a unique match, no risks
vil_ref[ !(duplicated(vil_ref$Village) |
          duplicated(vil_ref$Village, fromLast = T) ), ] -> vil_ref

# example: village named abdulrahman appears twice with different 
# provinces/districts; so it's not present in vil_ref

v <-
  left_join(v, vil_ref, 
            by = c('Village', 'Province_corrected')) %>% 
  mutate(District = dplyr::coalesce(District_corrected, District_expanded))


rm(vil_ref)

# NAs are down to 2049
sum(is.na(v$District))


# Assign disctricts to villages: Get districts from settlement file --------------------------------------

#take all unique village-province combinations that are left w/o districts:
v %>% 
  filter(is.na(District)) %>% 
  select(Village, Province_corrected) %>% # ignore the waves if spelling is the same
  distinct() -> vp_combinations

left_join(vp_combinations, settle %>% select(-contains('MISTI')),
          by = c('Province_corrected' = 'PROV_NA_EN', 'Village' = "VILLAGE_NA")
          ) -> vp_combinations


# store as csv to assign districts manually
write_csv(vp_combinations %>% cbind(District_man = ''),
          'cache/vp_combinations_nodistrict2.csv')


# % of resampled villages -------------------------------------------------

# after finding all districts: for each wave, merge it with settlement and calculate % of resampled

# that's all resampled, not resampled bc of taliban?

vw16 <- v %>% 
  filter(Wave == 16)

left_join(vw16, settle,
          by = c('Province' = 'PROV_NA_EN', 'Village' = "VILLAGE_NA")) %>% View()

# left_join(settle, v,
#           by = c('PROV_NA_EN' ='Province', "VILLAGE_NA" = 'Village'))


settle %>% 
  group_by(DIST_NA_EN) %>% 
  summarise(n_villages = n())



















