library(httr)
library(jsonlite)
#Check this page for guidance
#https://docs.rstudio.com/connect/1.7.6/cookbook/pagination.html


Comland <- GET("https://apps-st.fisheries.noaa.gov/ods/foss/landings/")

data <- NULL

TEMPdata = fromJSON(rawToChar(Comland$content))
                         
  data <- rbind(data,TEMPdata[["items"]])
  
  while(TEMPdata$hasMore) {
    Comland <- GET(TEMPdata[["links"]][["href"]][5])
    TEMPdata = fromJSON(rawToChar(Comland$content)) 
    # print the next 25
    data <- rbind(data,TEMPdata[["items"]])
  }