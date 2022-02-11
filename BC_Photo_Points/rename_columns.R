library(tidyr)
library(dplyr)

photos <- read.csv2("C:/Users/Matt/Resilio Sync/gis-data/Historic_Air_Photos/gpsPointsBC.csv", sep=",")
new_photos <- as.data.frame(photos) %>% 
  mutate('frame_number' = paste(frame_number, ".jpg", sep = "")) %>% 
  unite('PhotoNumb', "roll_number":"frame_number", sep = " ") %>%
  extract('flying_height', "Flight_Alt") %>%
  select(PhotoNumb, PointXDec = "X", PointYDec = "Y", Flight_Alt)



write.csv(new_photos, quote = FALSE, row.names = FALSE,
           "K:/git/HistoricalAirPhotos/BC_Photo_Points/gpsPoints.csv")
