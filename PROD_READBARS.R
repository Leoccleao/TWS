
library(IBrokers)

# Trader Worksation must be open and logged in
twsConnect(clientId = 100,port = 7497)
tws <- twsConnect(clientId = 100,port = 7497)

isConnected(tws)

----#### USD.CAD FX pair *** DO NOT CHANGE***
     ccy <- reqContractDetails(tws, twsCurrency("USD", "CAD"))[[1]]$contract
----### 
     
#DO NOT CHANGE: WORKING!!!
fl <- file('teste.csv',open='a')
reqRealTimeBars(tws,ccy,file= fl, whatToShow ='BID')
close(fl)


