library(tidyverse)
library(leaflet)
library(htmlwidgets)
library(httr)
library(xml2)
library(jsonlite)
library(ggmap)
library(leaflet.extras)
library(mapview)
library(htmltools)
library(qdapRegex)

zkey <- "mwkjfa5y3emjy89tjtngqqxw"
zkey <- "fr6vnwdte67xr6yeevpt979e" #Latest
zkey <- "rs6br4vcc845e7qw6nvdqaxq"

zkey <- "aca49hyxjbnpjzkean63r6ay"
address <- "29 Richborne Terrace, London"
location <- geocode(address)

proplistings <-  "https://api.zoopla.co.uk/api/v1/property_listings.json"

pl <- GET(proplistings, query=list(api_key=zkey,
                         latitude=51.479,
                         longitude=-0.11964,
                         radius=5
                         ))


avgprice <- "http://api.zoopla.co.uk/api/v1/average_sold_prices.json"

ap <- GET(avgprice, query=list(api_key=zkey,postcode='SW81AS',
                               output_type='outcode',area_type='postcodes',
                               page_number=1,
                               page_size=20))
avgP <- content(ap, "text")

json_content <- avgP %>% fromJSON()
data <- json_content$areas
icon.ion <- makeAwesomeIcon(icon = 'home', markerColor = 'green',
                            library='ion')

leaflet() %>% addTiles() %>% addRectangles(lng1 = as.numeric(json_content$bounding_box$longitude_min),
                                          lat1 = as.numeric(json_content$bounding_box$latitude_min),
                                          lng2 = as.numeric(json_content$bounding_box$longitude_max),
                                          lat2 = as.numeric(json_content$bounding_box$latitude_max),
                                          fillColor = 'transparent') %>%
  addAwesomeMarkers(lng = json_content$lon,lat=json_content$lat,icon=icon.ion)

