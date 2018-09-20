#Load the libraries

library(tidyverse)
library(leaflet)
library(htmlwidgets)
library(httr)
library(xml2)
library(XML)
library(jsonlite)
library(ggmap)
library(leaflet.extras)
library(mapview)
library(htmltools)
library(qdapRegex)

#API keys from Zoopla
#Use any one of them at a time
zkey <- "aca49hyxjbnpjzkean63r6ay"
zkey <- "em8twa73q73zrryaytbrg4jr" #Utpal's key which is not yet activated

#Read in the postcodes (source: https://data.london.gov.uk/dataset/mylondon)
#Usefule site: https://postcodes.io/
outcodes <- read_csv("data/MyLondon_postcode_OA.csv")

#Get all the unique outcodes in a vector
OC <- unique(outcodes$PC_DIST) #276 unique outcodes


#########################################################################################
#########################################################################################
#Zoopla estimates is only available on request

#########################################################################################
#########################################################################################
#Average Sold Prices; this appears to be our best bet
#Have a look at the details for this API: https://developer.zoopla.co.uk/docs/read/Average_Sold_Prices

avgprice <- "http://api.zoopla.co.uk/api/v1/average_sold_prices.json" #You can convert the URL to return data in json format

#Out of the 276 outcodes available, let's try it on the first one, OC[1], which is "BR1"
#Use the GET() function from the httr package

ap <- GET(avgprice, query=list(api_key=zkey,
                               postcode=OC[1],
                               output_type='outcode',
                               area_type='streets',
                               page_number=1,
                               page_size=20)) #page size can't be more than 20
avgP <- content(ap, "text")
json_content <- avgP %>% fromJSON() #Since the content is in json format

#Currently we got the data for only one page. Let's find out how many number of 
#pages will the API return

results <- json_content$result_count #484 results! 
#The API permits 100 calls per second and 100 calls per hour

#So we'll have to run this in a loop and store the information in a dataframe.
#I generally make an empty dataframe and then append the information there
#Since we've already made a call once, let's have a look at the data returned

data <- json_content$areas #It's a dataframe with 20 rows and 10 columns. Will append new data to this itself.

for (i in 2:results%/%20){
  ap <- GET(avgprice, query=list(api_key=zkey,
                                 postcode=OC[i],
                                 output_type='outcode',area_type='streets',
                                 page_number=i,
                                 page_size=20))
  avgP <- content(ap, "text")
  json_content <- avgP %>% fromJSON() 
  
  #And now bind the rows to our existing dataframe called data
  data <- bind_rows(data, json_content$areas)
}

#
#########################################################################################
#########################################################################################



icon.ion <- makeAwesomeIcon(icon = 'home', markerColor = 'green',
                            library='ion')

leaflet() %>% addTiles() %>% addRectangles(lng1 = as.numeric(json_content$bounding_box$longitude_min),
                                          lat1 = as.numeric(json_content$bounding_box$latitude_min),
                                          lng2 = as.numeric(json_content$bounding_box$longitude_max),
                                          lat2 = as.numeric(json_content$bounding_box$latitude_max),
                                          fillColor = 'transparent') %>%
  addAwesomeMarkers(lng = json_content$lon,lat=json_content$lat,icon=icon.ion)


#################################################################################
#Zed Index (Zed is Dead!) source: https://developer.zoopla.co.uk/docs/read/Zed_Index_API
#The Zed-Index is the average property value in a given area based on current Zoopla Estimates
#More information here: https://www.zoopla.co.uk/property/estimate/about/

zurl <- "https://api.zoopla.co.uk/api/v1/zed_index"

#Use the GET() function from httr package
zed <- GET(zurl, query = list(api_key = zkey,
                              area = OC[1],
                              output_type = 'outcode'))

zedContent <- content(zed, "text") 
doc <- xmlParse(zedContent) #since the content is in XML format

zedDF <- xmlToDataFrame(node=getNodeSet(doc, "/response"))#Convert it into a dataframe