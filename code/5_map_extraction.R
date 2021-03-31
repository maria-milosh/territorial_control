


# Setup -------------------------------------------------------------------


pacman::p_load(dplyr, wrapr, readr, stringr, raster, st, sf, foreach, 
               parallel, doParallel, png)



shp <- st_read('/Users/mariamilosh/Downloads/AFG_district_398/district398.shp') %>% 
  mutate(DIST_34_NA = as.character(DIST_34_NA))



# Mean color ------------------------------------------------------------------




for (wave in list.files('Maps', pattern = 'tif', full.names = T)) {
  
  cat(wave, '\n')
  
  
  if (file.exists('Maps/Districts_status/' %p%
                  str_extract(wave, '\\d{2}') %p% 'wave_districts.csv')) { next }
  
  
  img <- raster::stack(wave) %>% 
    raster::dropLayer(i = 4)
  names(img) <- c('R', 'G', 'B')
  
  img[(img$R < 50 & img$G < 50 & img$B < 50)] <- NA # remove black pixels
  img[(img$R > 210 & img$G > 210 & img$B > 210)] <- NA # white
  
  
  mean_color <- list()
  
  
  cl <- makeCluster(detectCores() - 6, 'FORK')
  registerDoParallel(cl)
  
  
  mean_color <- foreach( distr = unique(shp$DIST_34_NA) ) %dopar% {
    
    
    masked <- mask(mask = shp %>% 
                     subset(DIST_34_NA == distr), x = img)
    
    raster::extract(masked, shp %>% 
                      subset(DIST_34_NA == distr),
                    fun = median, df = T, na.rm = T) %>% 
      
      cbind(District = distr,
            Province = shp %>% 
              as.data.frame() %>% 
              filter(DIST_34_NA == distr) %>% 
              dplyr::select(PROV_34_NA) )
    
    
  }
  
  stopCluster(cl)
  
  
  cat('Cluster closed, now compiling dataframe\n\n')
  
  mean_color <- 
    mean_color %>% 
    bind_rows() %>%
    dplyr::select(-c(ID)) %>% 
    
    mutate(Status = 
             
             ifelse( abs(G - R) > 50 & abs(G - B) > 50 & abs(B - R) < 50, 'Accessible', # green
                     
                     ifelse( abs(R - B) > 50 & abs(R - G) > 50 & abs(B - G) < 50, 'Inaccessible_notsampled', # red
                             
                             ifelse( abs(R - G) < 50 & abs(R - B) > 50 & abs(G - B) > 50, 'Men_only', # yellow
                                     
                                     ifelse( abs(R - G) < 50 & abs(R - B) < 50 & abs(B - G) < 50, 'Inaccessible_intercepts', # grey
                                             
                                             ifelse(R > 85 & G > 85 & B == 0, 'Men_only', NA )))) ) # yellow
           
    )
  
  
  
  # Corrections
  
  if ( str_extract(wave, '\\d{2}') <= 32 ) {
    mean_color[mean_color$District == 'Nawa-I- Barak Zayi', 'Status'] <- NA } # doesn't match the shapefile
  
  if ( str_extract(wave, '\\d{2}') %in% c(33:37) ) {
    mean_color[mean_color$District == 'Nawa-I- Barak Zayi', 'Status'] <- 'Inaccessible_intercepts' } # doesn't match the shapefile
  
  if ( str_extract(wave, '\\d{2}') == 38 ) {
    mean_color[mean_color$District == 'Nawa-I- Barak Zayi', 'Status'] <- 'Inaccessible_notsampled' } # doesn't match the shapefile
  
  if ( str_extract(wave, '\\d{2}') > 32 & str_extract(wave, '\\d{2}') < 42 ) {
    mean_color[mean_color$District == 'Sayed Karam', 'Status'] <- NA } # doesn't match the shapefile
  
  if ( str_detect(wave, "39") ) {
    mean_color[mean_color$District == 'Wali Muhammadi Shahid', 'Status'] <- 'Inaccessible_intercepts' # I think it's grey, but hard to tell
    mean_color[mean_color$District == 'Dand Patan', 'Status'] <- 'Men_only'
    mean_color[mean_color$District == 'Sayed Karam', 'Status'] <- 'Accessible'
    mean_color[mean_color$District == 'Musayi', 'Status'] <- 'Inaccessible_intercepts' # I think it's grey, but hard to tell
    mean_color[mean_color$District == 'Laja Ahmad Khail', 'Status'] <- 'Men_only'
  }
  
  if ( str_detect(wave, "40") ) {
    mean_color[mean_color$District == 'Dand Patan', 'Status'] <- 'Men_only'
    mean_color[mean_color$District == 'Jani Khail', 'Status'] <- 'Men_only' # I think it's yellow, but hard to tell (grey)
    mean_color[mean_color$District == 'Laja Ahmad Khail', 'Status'] <- 'Men_only'
  }
  
  if ( str_detect(wave, "41") ) {
    mean_color[mean_color$District == 'Sayed Karam', 'Status'] <- 'Accessible'
    mean_color[mean_color$District == 'Dand Patan', 'Status'] <- 'Men_only'
    mean_color[mean_color$District == 'Musayi', 'Status'] <- 'Inaccessible_intercepts'
  }
  
  if ( str_detect(wave, "42") ) {
    mean_color[mean_color$District == 'Dand Patan', 'Status'] <- 'Men_only'
    mean_color[mean_color$District == 'Laja Ahmad Khail', 'Status'] <- 'Men_only'
  }
  
  if ( str_detect(wave, "44") ) {
    mean_color[mean_color$District == 'Musayi', 'Status'] <- 'Inaccessible_intercepts' # I think it's grey, but hard to tell
    mean_color[mean_color$District == 'Laja Ahmad Khail', 'Status'] <- 'Men_only'
    mean_color[mean_color$District == 'Nazyan', 'Status'] <- 'Inaccessible_intercepts'
    mean_color[mean_color$District == 'Chaparhar', 'Status'] <- 'Men_only'
  }
  
  
  write_csv(mean_color, 'Maps/Districts_status/' %p%
              str_extract(wave, '\\d{2}') %p% 'wave_districts.csv')
  
  
}




# Check that --------------------------------------------------------------


extracted <- lapply(list.files('Maps/Districts_status', full.names = T),
                    function(x)
                      
                      read_csv(x) %>% 
                      cbind(., wave = str_extract(x, '\\d{2}'))
)


extracted[[16]] %>% View()








