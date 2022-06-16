# Code to get GDP deflator from St. Louis Fed and deflate a dataset either using quarterly data or yearly deflators.
# Deflates to tye year specified in base_year or to the year and quarter specified in base_year and base_quarter


rm(list=ls())
library("tidyverse")
library("data.table")


##############################################################################################
# PREAMBLE
# Make a fake table of revenue, parse the date in D-M-Y and Quarter.

id  <- c(1,2,3)
REVENUE  <- c(21000, 23400, 26800)
DATE <- as.Date(c('2010-11-1','2008-3-25','2007-3-14'))
REVENUEFILE<-data.frame(id, REVENUE,DATE, stringsAsFactors = FALSE)

# Rename REVENUE to nominal_revenue
REVENUEFILE <- REVENUEFILE %>%
  mutate(nominal_revenue = REVENUE)
# Parse the DATE variable
REVENUEFILE <- REVENUEFILE %>%
  mutate("DATE" = as.POSIXct(DATE, format="%m/%d/%Y", origin="1970-01-01", tz="America/New_York")) %>% as_tibble() %>%
  mutate(MONTH = as.integer(format(DATE,"%m"))) %>%
  mutate(DAY = as.integer(format(DATE,"%d"))) %>%
  mutate(YEAR = as.integer(format(DATE,"%Y")))
# Construct Quarter of Year
REVENUEFILE<-REVENUEFILE %>%
mutate(QUARTER = "") %>% # Create quarters column
  mutate(QUARTER = ifelse(MONTH %in% 1:3, "Q1", QUARTER)) %>%
  mutate(QUARTER = ifelse(MONTH %in% 4:6, "Q2", QUARTER)) %>%
  mutate(QUARTER = ifelse(MONTH %in% 7:9, "Q3", QUARTER)) %>%
  mutate(QUARTER = ifelse(MONTH %in% 10:12 , "Q4",QUARTER)) 
# END PREAMBLE
######################################################################################################



#Deflate by years
deflate_by<-"year"
# Or by quarters
#deflate_by<-"quarter"



#set the base year for deflating
base_year<-2020
# base quarter only used if deflating by  quarter.
base_quarter<-"Q1"


# A function to get the GDP deflator from a flat text file at FRED.

get_GDP_deflator <- function(time_period = "year", federal_reserve_url = "https://fred.stlouisfed.org/data/GDPDEF.txt"){
  message("Pulling GDP deflator data from Federal Reserve API..")
  temp <- tempfile()
  temp.connect <- url(federal_reserve_url)
  temp <- data.table(read.delim(temp.connect, fill=FALSE, stringsAsFactors=FALSE, skip = 15))
  temp <- temp %>%
    tidyr::separate(col= "DATE..........VALUE", into=c("DATE", "GDPDEF"), sep="  ", convert=TRUE)
  temp$DATE <- as.Date(temp$DATE)
  temp$GDPDEF <- as.double(temp$GDPDEF)
  message("Done.")

  temp<-temp %>%
    mutate("DATE" = as.POSIXct(DATE, format="%m/%d/%Y", origin="1970-01-01", tz="America/New_York")) %>% as_tibble() %>%
    mutate(MONTH = as.integer(format(DATE,"%m"))) %>%
    mutate(DAY = as.integer(format(DATE,"%d"))) %>%
    mutate(YEAR = as.integer(format(DATE,"%Y"))) %>%
    mutate(QUARTER = "") %>% # Create quarters column
    mutate(QUARTER = ifelse(MONTH %in% 1:3, "Q1", QUARTER)) %>%
    mutate(QUARTER = ifelse(MONTH %in% 4:6, "Q2", QUARTER)) %>%
    mutate(QUARTER = ifelse(MONTH %in% 7:9, "Q3", QUARTER)) %>%
    mutate(QUARTER = ifelse(MONTH %in% 10:12 , "Q4", QUARTER))
  
  if (time_period == "year") {
    GDPDEF <- temp %>%
      
      dplyr::select(GDPDEF, YEAR) %>%
      dplyr::group_by(YEAR) %>%
      dplyr::summarise(GDPDEF = mean(GDPDEF)) %>%
      ungroup() %>%
      as_tibble() #  reduce columns
  } else if(time_period == "quarter") {
    GDPDEF <- temp %>%
      
      dplyr::select(GDPDEF, YEAR, QUARTER) %>%
      dplyr::group_by(YEAR,QUARTER) %>%
      dplyr::summarise(GDPDEF = mean(GDPDEF)) %>%
      ungroup() %>%
      as_tibble() #  reduce columns()
  } else {
    stop("Time period not set or not specified as either 'year' or 'quarter' ")
  }
  return(GDPDEF)
}
# Look at the deflators if you want
#GDPDEF_annual <- get_GDP_deflator(time_period = "year")
#GDPDEF_quarterly <- get_GDP_deflator(time_period = "quarter")






#################################################################################################################

# Set deflator based on year ------
if(deflate_by=="year") {
  
  GDPDEF_annual <- get_GDP_deflator(time_period = "year")
  
  REVENUEFILE <- as_tibble(merge(REVENUEFILE, GDPDEF_annual, by="YEAR", all.x=TRUE))
  REVENUEFILE[["REVENUE"]] <- REVENUEFILE[["nominal_revenue"]]*
    unique(GDPDEF_annual$GDPDEF[GDPDEF_annual$YEAR==base_year])/REVENUEFILE$GDPDEF

}
# save(REVENUEFILE, file="REVENUEFILE.Rdata")

#####################################################################################################################
# Set deflator based on year and quarter

# REVENUEFILE[which(is.na(REVENUEFILE$MONTH)),] # months that are NAs

if(deflate_by=="quarter") {
  
  GDPDEF_quarterly <- get_GDP_deflator(time_period = "quarter")
  
  # Merge GDP series to data.
  REVENUEFILE <- as_tibble(merge(REVENUEFILE, GDPDEF_quarterly, by=c("YEAR", "QUARTER"),all.x=TRUE, all.y=FALSE))

  # Deflate revenue file using GPD deflator  
  REVENUEFILE[["REVENUE"]] <- REVENUEFILE[["nominal_revenue"]]*
    unique(GDPDEF_quarterly$GDPDEF[GDPDEF_quarterly$YEAR==base_year&GDPDEF_quarterly$QUARTER==base_quarter])/REVENUEFILE$GDPDEF # apply deflator to nominal revenue


}
