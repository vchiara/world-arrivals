library(plyr)
library(rgdal)
library(rvest)
library(viridis)
library(tmaptools)
library(dplyr)
library(readr)
library(leaflet)

#set working directory
setwd("~/R/world_arrivals")

#load data for int tourist arrivals
arrivals_2017 <- read_csv("world_arrivals.csv")
arrivals_2017 <- arrivals_2017[,3:5]
colnames(arrivals_2017) <- c("country", "code", "arrivals")


#download and open world .shp file
download.file("http://thematicmapping.org/downloads/TM_WORLD_BORDERS_SIMPL-0.3.zip" , destfile="world_shape_file.zip")
system("unzip world_shape_file.zip")

world = readOGR(dsn = getwd(), layer = "TM_WORLD_BORDERS_SIMPL-0.3")

#merge data
map_data <- append_data(world, arrivals_2017, key.shp = "ISO3", key.data = "code")

#set color palette
pal <- colorBin(palette = "viridis", domain = map_data@data[["arrivals"]], bins = 6)

#set labels
labels <- sprintf("<strong>%s</strong><br/>International Tourist Arrivals: %s",
                  map_data$NAME, prettyNum(map_data$arrivals, big.mark = ",")) %>% 
                  lapply(htmltools::HTML)

#create map
map <- leaflet(map_data) %>%
  addTiles() %>%
  setView(-96, 37.8, 4) %>% 
  addPolygons(
    fillColor = ~pal(arrivals),
    weight = 2,
    opacity = 1,
    color = "white",
    dashArray = "1",
    fillOpacity = 0.7,
    highlight = highlightOptions(color = "white", weight = 3, dashArray = "1",
                                 fillOpacity = 0.8, bringToFront = TRUE),
    label = labels) %>%
  addLegend(position = "bottomright", pal = pal, opacity = 0.7,
            values = ~arrivals, title = "International Tourist Arrivals")

map
