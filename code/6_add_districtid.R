

pacman::p_load(tidyverse, sf, st)


shp <- read_sf('data/maps/AFG_district_398/')

districts_status <- lapply(list.files('data/maps/districts_status/',
                                      full.names = T), function(x) read_csv(x) %>% 
                             mutate(Wave = str_extract(x, '\\d+'))) %>% 
  bind_rows()



all(districts_status$PROV_34_NA %in% shp$PROV_34_NA)
all(districts_status$District %in% shp$DIST_34_NA)


left_join(districts_status, 
          shp %>%
            st_drop_geometry() %>% 
            distinct(PROV_34_NA, DIST_34_NA, .keep_all = T),
          
          by = c('PROV_34_NA', 'District' = 'DIST_34_NA')) -> districts_new

districts_new %>% 
  select(-OBJECTID, PROVID, PROV_34_NA, DISTID, District, Wave, Status, R, G, B) -> districts_new



write_csv(districts_new, 'Dropbox/State_Reach/DATA/ANQAR/Replaced_locations/Maps/Districts_status/All_districts.csv')
