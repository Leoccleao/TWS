

library(chron)
library(lubridate)
library(dplyr)

###Pointing to file "teste.csv""

readbars <- function(y){
     
 
     mydate <- setClass("mydate", slots = "date")
     setAs("character","mydate", function(from) ymd(from) )
     
     myhour <- setClass("myhour", slots = "date")
     setAs("character","myhour", function(from) as.POSIXct(from, format = "%H:%M:%S") )
     
     mynumber <- setClass("mynumber", slots = "numeric")
     setAs("character","mynumber", function(from) as.numeric(sub('.*\\=', '', from)))
     
     y <- read.table("teste.csv",sep = " ", 
                     colClasses = c("character", "mydate","myhour", "mynumber",
                                    "mynumber", "mynumber","mynumber", rep("NULL", 4) ),
                     col.names = c("Asset","Date", "Time","Open","High","Low", "Close",rep("NULL", 4)))
     
}



next5minbar <- function(x){
        y <- nrow(x)
        x[y+1,1] <- x[nrow(x)-1,1]
        x[y+1,2] <- x[nrow(x)-1,2]+(300)
        x[y+1,3] <- filter(bars_5s,Time == x$Time[y]+(5))$Open ###No calc for next day
        x[y+1,4] <- max(filter(bars_5s,Time > x$Time[y] & Time <= x$Time[y]+300)$High)
        x[y+1,5] <- min(filter(bars_5s,Time > x$Time[y] & Time <= x$Time[y]+300)$Low)
        x[y+1,6] <- filter(bars_5s,Time == x$Time[y]+(300))$Close
        x[,7] <- EMA(x$Close,n=9)
        x[,8] <- EMA(x$Close,n=21)
        x[,9] <- EMA(x$Close,n=55)
        w <- (if(x$EMA_9[y+1] > x$EMA_21[y+1] & x$EMA_21[y+1] > x$EMA_55[y+1]){
                        1 } else if (x$EMA_9[y+1] < x$EMA_21[y+1] & x$EMA_21[y+1] < x$EMA_55[y+1]){
                                -1} else 0)
        x[y+1,10] <- w
        x[y+1,11] <- y+1
        
        peaks <- which(diff(diff(x$Close)>=0)<0)+1
        troughs <- which(diff(diff(x$Close)>0)>0)+1
        x[y+1,12] <- 0
        x[y+1,12] <- ifelse(x[y+1,11] %in% peaks, 1, x[y+1,12])
        x[y+1,12] <- ifelse(x[y+1,11] %in% troughs, -1, x[y+1,12])
        
        x[y+1,13] <- if(x$trend[y]==x$trend[y+1]){0}
                                else if (x$trend[y+1] == 1){1}
                                else if (x$trend[y+1] == 0){0}
                                else {-1}
                                
        x[y+1,14] <-  if(x$signal[y+1]==0){0}
                        else if (x$signal[y+1] == 1){tail(filter(x,minmax==1))$High}
                        else {tail(filter(x,minmax==-1))$Low}
        
        return(x)
}
        
EMA_3 <- function(x){
        
        x$row <- seq(1, nrow(x), 1)
        peaks <- which(diff(diff(x$Close)>=0)<0)+1
        troughs <- which(diff(diff(x$Close)>0)>0)+1
        x$minmax <- 0
        x$minmax <- ifelse(x$row %in% peaks, 1, x$minmax)
        x$minmax <- ifelse(x$row %in% troughs, -1, x$minmax)
        
        x$signal <- 0
        goshort <- which(diff(diff(x$trend)>=0)<0)+2
        golong <- which(diff(diff(x$trend)>0)>0)+2
        x$signal <- ifelse(x$row %in% golong & x$trend == 1, 1, x$signal)
        x$signal <- ifelse(x$row %in% goshort & x$trend == -1, -1, x$signal)
        
        return(x)
}

entryprice_hist <- function(x){
        x$entryprice <- 0
        #trend up
        y <- x %>%filter(minmax==1)%>%select(c("High","row"))
        vector <- c()
        for (i in 1:nrow(x)){
                z <- ifelse(x$signal[i] ==1 , tail(filter(y,row < x$row[i]),1)$High, x$entryprice[i])       
                vector <- c(vector,z) 
        }
        
        #trend down  
        y <- x %>%filter(minmax==-1)%>%select(c("Low","row"))
        vector2 <- c()
        for (i in 1:nrow(x)){
                z <- ifelse(x$signal[i] ==-1 , tail(filter(y,row < x$row[i]),1)$Low, x$entryprice[i])       
                vector2 <- c(vector2,z)
                
        }
        
        x$entryprice <- vector+vector2
        
        return(x)
}




