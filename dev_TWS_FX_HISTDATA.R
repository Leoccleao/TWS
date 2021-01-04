library(data.table)
library(TTR)
library(IBrokers)
library(dplyr)

# Trader Worksation must be open and logged in
twsConnect(clientId = 100,port = 7497)
tws <- twsConnect(clientId = 100,port = 7497)

isConnected(tws)


# accountInfo <- reqAccountUpdates(tws, acctCode = "DU2954859")
# head(accountInfo)

#### USD.CAD FX pair
ccy <- reqContractDetails(tws, twsCurrency("USD", "CAD"))[[1]]$contract
### 
#Sample S&P500 reqHistoricalData(tws, reqContractDetails(tws, twsIndex("SPX", "CBOE", "USD"))[[1]]$contract)

### Fetch Historical data ### DO NOT TOUCH!!!!
## data <- data <- reqHistoricalData(tws, ccy,barSize = "5 mins", endDateTime = "20200902 19:15:00",whatToShow='BID')


data <- reqHistoricalData(tws, ccy,barSize = "5 mins", duration = "1 Y" ,whatToShow='BID')     
data <- data.frame(date = index(data), 
                  data, row.names=NULL)
base <- data.frame(Date = as.Date(data$date), Time = as.POSIXct(data$date, format = "%H:%M:%S"), 
                    Open = data$USD.CAD.Open,High = data$USD.CAD.High,
                   Low = data$USD.CAD.Low, Close = data$USD.CAD.Close,
                   EMA_9 = EMA(data$USD.CAD.Close,n=9),
                   EMA_21 = EMA(data$USD.CAD.Close,n=21),
                   EMA_55 = EMA(data$USD.CAD.Close,n=55))
base$trend <- ifelse (base$EMA_9 > base$EMA_21 & base$EMA_21 > base$EMA_55,1, 0)#UP 
base$trend <- ifelse (base$EMA_9 < base$EMA_21 & base$EMA_21 < base$EMA_55,-1, base$trend)#DOWN
base$lowhigh <- 0
base$lowhigh <- ifelse(base$Close> lag(base$Close) & 
                                      base$Close> lag(base$Close, n=2) & 
                                      base$Close> lead(base$Close) & 
                                      base$Close> lead(base$Close, n=2),1,base$lowhig)

base$lowhigh <- ifelse(base$Close< lag(base$Close) & 
                                      base$Close< lag(base$Close, n=2) & 
                                      base$Close< lead(base$Close) & 
                                      base$Close< lead(base$Close, n=2),-1,base$lowhig)



baserapida <- tail(base,200)
baserapida <- EMA_3(baserapida) #???
baserapida <- entryprice_hist(baserapida) 

     
     
     

     
     