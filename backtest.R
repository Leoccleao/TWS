setwd("/Users/leonardoleao/R/TWS")

historicalbase <- signal_function(base)
historicalbase <- entryprice_hist(historicalbase)



historicalbase$order <- 0

historicalbase$short <- ifelse(historicalbase$signal == -1 & historicalbase$entryprice >= historicalbase$Close,-1,0)
historicalbase$long <- ifelse(historicalbase$signal == 1 & historicalbase$entryprice <= historicalbase$Close,1,0)

historicalbase$order <- historicalbase$short + historicalbase$long

historicalbase$activesignal <- ifelse(historicalbase$signal == historicalbase$order,0,historicalbase$signal)




historicalbase$orders_activesignal <- 0
active_signal <- 0
active_trend <- 0
entry_price <- 0

for (i in 55:(nrow(historicalbase)-1)) {
     
     if (historicalbase$activesignal[i] != 0 & historicalbase$orders_activesignal[i] == 0){
          active_signal <- historicalbase$activesignal[i]
          active_trend <- historicalbase$trend[i]
          entry_price <- historicalbase$entryprice[i]
     }
     
     else if (historicalbase$orders_activesignal[i] != 0){
          active_signal <- 0
          active_trend <- historicalbase$trend[i]
          entry_price <- 0
     }
     
     else {active_signal <- 0
     active_trend <- 0
     entry_price <- 0
     }
     
     if (historicalbase$trend[i+1] == active_trend){
          historicalbase$activesignal[i+1] <- active_signal
          historicalbase$entryprice[i+1] <- entry_price
          short <- ifelse(historicalbase$activesignal[i+1] == -1 & entry_price >= historicalbase$Low[i+1],-1,0)
          long <- ifelse(historicalbase$activesignal[i+1] == 1 & entry_price <= historicalbase$High[i+1],1,0)
          historicalbase$orders_activesignal[i+1] <- short+long 
          }         
}

Overview <- data.frame(Short = sum(historicalbase$signal == -1),
                       Long = sum(historicalbase$signal == 1),
                       Signals = sum(abs(historicalbase$signal)),
                       Orders = sum(abs(historicalbase$order)),
                       Active_Signals = sum(abs(historicalbase$activesignal)),
                       Orders_ActSignals = sum(abs(historicalbase$orders_activesignal)))

Overview
