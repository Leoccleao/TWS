

library(chron)
library(lubridate)

###Pointing to file "teste.csv""

readbars <- function(y){
     
 
     mydate <- setClass("mydate", slots = "date")
     setAs("character","mydate", function(from) ymd(from) )
     
     myhour <- setClass("myhour", slots = "date")
     setAs("character","myhour", function(from) chron(times. = from) )
     
     mynumber <- setClass("mynumber", slots = "numeric")
     setAs("character","mynumber", function(from) as.numeric(sub('.*\\=', '', from)))
     
     y <- read.table("teste.csv",sep = " ", 
                     colClasses = c("character", "mydate","myhour", "mynumber",
                                    "mynumber", "mynumber","mynumber", rep("NULL", 4) ),
                     col.names = c("Asset","Date", "Time","Open","High","Low", "Close",rep("NULL", 4)))
     
}