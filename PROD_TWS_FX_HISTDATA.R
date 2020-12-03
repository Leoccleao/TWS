library(twsInstrument)
library(IBrokers)

# Trader Worksation must be open and logged in
twsConnect(clientId = 100,port = 7497)
tws <- twsConnect(clientId = 100,port = 7497)

isConnected(twsconn = tws)

# accountInfo <- reqAccountUpdates(tws, acctCode = "DU2954859")
# head(accountInfo)

----#### USD.CAD FX pair
ccy <- reqContractDetails(tws, twsCurrency("USD", "CAD"))[[1]]$contract
----### 
#Sample S&P500 reqHistoricalData(tws, reqContractDetails(tws, twsIndex("SPX", "CBOE", "USD"))[[1]]$contract)

### Fetch Historical data
## data <- data <- reqHistoricalData(tws, ccy,barSize = "5 mins", endDateTime = "20200902 19:15:00",whatToShow='BID')

data <- data <- reqHistoricalData(tws, ccy,barSize = "5 mins", duration = "6 M" ,whatToShow='BID')     


### Data cleaning

data <- as.data.frame(data)
data$date = rownames(data)
rownames(data) = NULL
library("lubridate")
data$date <- ymd_hms(data$date)
col_order <- c(9, 1,2,3,4)
data <- data[, col_order]
View(data)
#------------
     
     