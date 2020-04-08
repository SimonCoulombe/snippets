library(tidyverse)
library(rmapshaper)
library(sf)
canada <- read_rds("C:/Users/simon/Documents/git/canada2019.rds")
library(mapview)
# zz <- canada %>%
#   ms_simplify(keep_shapes = TRUE, explode = TRUE)
# 
# 
# damn_two <- canada %>% 
#   filter(FED_NUM  == 10003, EMRP_NAME %in% c(177, 178) )  
# 
# 
# damn_two %>% mapview(zcol = "EMRP_NAME")

poll_shp_bak <- read_sf("C:/Users/simon/git/polling_divisions_boundaries_2019.shp/PD_CA_2019_EN.shp") %>%
  
  mutate(pollid = 
           if_else(PDNUMSFX == 0, str_c(FEDNUM,PDNUM, sep= "_") , str_c(str_c(FEDNUM,PDNUM, sep= "_"), PDNUMSFX, sep= "-")))

poll_shp_agg <- aggregate(x = poll_shp_bak %>% select(),
                          by = list(poll_shp_bak %>% pull(pollid)),
                          FUN = function(x) x)

poll_shp <- poll_shp_agg %>% select(pollid = Group.1) %>%
    mutate(PR = str_sub(pollid, 1 , 2))  %>%
  st_transform(crs=4326) %>%
  st_cast( "MULTIPOLYGON") %>%
  st_cast("POLYGON") 

write_rds(poll_shp, "poll_shp.rds")

pr_east <-poll_shp%>%  
  filter(PR %in% c("10", "11", "12", "13", "24")) %>%
  ms_simplify(keep_shapes = TRUE, explode = TRUE)

pr35 <- poll_shp %>%  
  filter(PR == "35") %>%
  ms_simplify(keep_shapes = TRUE, explode = TRUE)

pr_west <- poll_shp %>%  
  filter(PR %in% c("46", "47", "48", "59", "60", "61", "62")) %>%
  ms_simplify(keep_shapes = TRUE, explode = TRUE)

simple_election <- sf::st_as_sf(data.table::rbindlist(list(pr_east, 
                                                 pr35, 
                                                 pr_west %>% st_cast("POLYGON"))))


print(object.size(poll_shp), units = "MB")
print(object.size(pr_east), units = "MB")
print(object.size(pr35), units = "MB")
print(object.size(pr_west), units = "MB")
print(object.size(simple_election), units = "MB")

mapview(pr_west)

st_write(simple_election, "simple_election.shp")
