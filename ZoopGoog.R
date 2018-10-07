library(tidyverse)
library(googleway)
library(leaflet)

#Read in the data, saved earlier from the Zoopla.R script

load("data/data.Rdata")

glimpse(data)


#For the location field, let's try and get the lat long from Googleway
#I think it would be better to prefix "London" while searching for the coordinates

data$Location <- paste("London", data$Location)

#Let's also get rid of "-" in the location variable
data$Location <- gsub("-"," ", data$Location)

gkey <- "AIzaSyDXw8fbQMHg0JN0dr2fqq8XzfpZBtpBAMc"

###################################################################################################################
###################################################################################################################
#Get coordinates by looping through (I have commented out the code as I have already run it and got the lat long of the places
#and don't want to incur extra costs by running the Google Maps API!!)
#First create two new columns
# data$lat <- NA
# data$lng <- NA
# for(i in 1:nrow(data)){
#   df <- google_geocode(data$Location[i], key=gkey)
#   if(df$status != "ZERO_RESULTS"){
#     data$lat[i] <- geocode_coordinates(df)$lat
#     data$lng[i] <- geocode_coordinates(df)$lng
#   }
#   
# }
# 
# #At some places we get zero results; Hence let's just take non-NA values only
# #The complete.cases() function is useful for selecting all non-NA values
# 
# dataLatLng <- data[complete.cases(data),]
# 
# #I also realized that some of the  coordinates are wrong
# #So let's only look at the coordinates which are in the bounding
# #box of London (https://www.flickr.com/places/info/44418)
# 
# dataLatLng <- dataLatLng %>% filter(lng>-0.55 & lng < 0.4) %>% 
#   filter(lat>51.2 & lat < 51.7)
# 
# #Save the data as .Rdata or .Rds file; Using the latter to show you
# #different ways of saving R data
# 
# saveRDS(dataLatLng, "data/dataLatLng.Rds")

###################################################################################################################
###################################################################################################################

#We can now just load the saved file and start off with mapping

dataLL <- readRDS("data/dataLatLng.Rds")

#Let's try som maps now
# We will be using the Leaflet package for this
# Suggest go through this https://rstudio.github.io/leaflet/

#Just a fancy icon
icon.ion <- makeAwesomeIcon(icon = 'home', markerColor = 'green',
                            library='ion')

leaflet(dataLL) %>% addTiles() %>% 
  addAwesomeMarkers(lng = ~lng, lat = ~lat, icon=icon.ion)

#Looks quite crowded
#Let's look for a particular area_name

table(dataLL$area_name)

#Trim white space
dataLL$area_name <- trimws(dataLL$area_name)

HA4 <- dataLL %>% filter(area_name=="HA4")
leaflet(HA4) %>% addTiles() %>% 
  addAwesomeMarkers(lng = ~lng, lat = ~lat, icon=icon.ion)

#Let's add some labels to the icons
leaflet(HA4) %>% addTiles() %>% 
  addAwesomeMarkers(lng = ~lng, lat = ~lat, icon=icon.ion, label = ~Location)

#As an exercise can you add icons in different colours depending on the avg sold price in the last 3 years?

#We can also control the size of markers by a numeric value
#Let's see if we can use the number of sales in the last 7 years

#A custom function to scale a numeric value
myscale <- function(x) (x - min(x, na.rm=T))/(max(x, na.rm=T) - min(x, na.rm=T))

HA4$size <- myscale(as.numeric(HA4$number_of_sales_7year))
leaflet(HA4) %>% addTiles() %>% 
  addCircleMarkers(lng = ~lng, lat = ~lat,radius = ~size*20, label = ~Location)

#Try adding the location along with the number_of_sales_7year
