library(data.table)
library(zoo)
library(ggplot2)

robin <- read.csv('D://Documents/Stock Dashboard/Robinhood Transactions.csv')
stocks <- levels(factor(robin$Ticker[robin$Ticker != 'DEPOSIT']))
robin_buy <- robin[robin$Type == 'BUY',]
robin_sell <- robin[robin$Type == 'SELL',]
robin_sell$Shares <- robin_sell$Shares*-1 
robin_sell$Total <- robin_sell$Shares*robin_sell$AmtPerShare
robin_clean <- rbind(robin_buy,robin_sell)


singleStock <- function(stock, startDate = as.Date('2016-01-01'), endDate = Sys.Date() - 1) {
  #dates <- seq.Date(as.Date(startDate, '%B+%d+%Y'), as.Date(endDate, '%B+%d+%Y'), by='days')
  startDate <- format(startDate, '%B+%d+%Y')
  endDate <- format(endDate, '%B+%d+%Y')
  stock_url <- paste('http://finance.google.com/finance/historical?q=', stock
                     , '&startdate=', startDate
                     , '&enddate=', endDate
                     , '&output=csv'
                     , sep='')
  stock_data = tryCatch(
    suppressWarnings(
      fread(stock_url, sep = ",")),
    error = function(e) NULL
  )
  stock_data$Date <- as.Date(stock_data$Date, '%d-%b-%y')
  return(stock_data)
}

multipleStock <- function(stocks, startDate = as.Date('2016-01-01'), endDate = Sys.Date() - 1, fill.na = TRUE) {
  output <- data.frame(seq.Date(startDate, endDate, by='days'))
  colnames(output) <- 'Date'
  startDate <- format(startDate, '%B+%d+%Y')
  endDate <- format(endDate, '%B+%d+%Y')
  for(stock in stocks){
    stock_url <- paste('http://finance.google.com/finance/historical?q=', stock
                       , '&startdate=', startDate
                       , '&enddate=', endDate
                       , '&output=csv'
                       , sep='')
    stock_data = tryCatch(
      suppressWarnings(
        fread(stock_url, sep = ",")),
      error = function(e) NULL
    )
    stock_data$Date <- as.Date(stock_data$Date, '%d-%b-%y')
    output <- merge(x = output, y = stock_data[,c('Date', 'Close')], by = "Date", all.x = TRUE)
    names(output)[names(output) == 'Close'] <- stock
  }
  if(fill.na){
    output <- na.locf(output)
  }
  output$Date <- as.Date(output$Date)
  for(stock in stocks){
    output[,stock] <- as.numeric(output[,stock])
  }
  return(output)
}

robin_close_price <- multipleStock(stocks, startDate = as.Date('2016-06-01'))


library(tidyr)
robin_tran_day <- spread(robin_clean[,c('Date', 'Ticker', 'Shares')], Ticker, Shares)
robin_tran_day$Date <- as.Date(robin_tran_day$Date)
all_robin <- data.frame(seq.Date(as.Date('2016-06-01'), Sys.Date()-1, by='days'))
colnames(all_robin) <- 'Date'
all_robin <- merge(x=all_robin, y=robin_tran_day, by='Date', all.x=TRUE)
all_robin[is.na(all_robin)] <- 0

for(stock in stocks){
  all_robin[,stock] <- cumsum(all_robin[,stock])
}

all_robin <- merge(x=robin_close_price, y=all_robin, by='Date', suffixes = c('price', 'shares'))

for(stock in stocks){
  all_robin[,paste(stock,'AMT', sep='')] <- all_robin[,paste(stock,'price', sep='')] * all_robin[,paste(stock,'shares', sep='')]
  all_robin[,'Total'] <- all_robin[,'Total'] + all_robin[,paste(stock,'AMT', sep='')]
}
all_robin[,'Total'] <- 0
for(stock in stocks){
  all_robin[,'Total'] <- all_robin[,'Total'] + all_robin[,paste(stock,'AMT', sep='')]
}
qplot(x = all_robin$Date, y = all_robin$Total, geom = 'line')
