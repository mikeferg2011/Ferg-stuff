library(data.table)
library(zoo)
library(ggplot2)
library(tidyr)


########### Functions

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

########### Import and Clean Tranactions & Get Historical Prices

robin <- read.csv('D://Documents/Stock Dashboard/Robinhood Transactions.csv')
robin$Date <- as.Date(robin$Date)
robin <- robin[robin$Type == 'BUY' | robin$Type == 'SELL',]
robin_stocks <- levels(factor(robin$Ticker))
robin[robin$Type == 'SELL',c('Shares', 'Total')] <- robin[robin$Type == 'SELL',c('Shares', 'Total')]*(-1)

robin_close_price <- multipleStock(robin_stocks, startDate = as.Date('2016-06-01'))

########### Uber Dataset for Robinhood

robin_tran_day <- spread(robin[,c('Date', 'Ticker', 'Shares')], Ticker, Shares)

robin_day <- data.frame(seq.Date(as.Date('2016-06-01'), Sys.Date()-1, by='days'))
colnames(robin_day) <- 'Date'
robin_day$Total <- 0

robin_day <- merge(x=robin_day, y=robin_tran_day, by='Date', all.x=TRUE)
robin_day[is.na(robin_day)] <- 0

robin_day <- merge(x=robin_day, y=robin_close_price, by='Date', suffixes = c('_shares', '_price'))

for(stock in robin_stocks){
  robin_day[,paste(stock,'shares', sep='_')] <- cumsum(robin_day[,paste(stock,'shares', sep='_')])
  robin_day[,paste(stock,'AMT', sep='_')] <- robin_day[,paste(stock,'price', sep='_')] * robin_day[,paste(stock,'shares', sep='_')]
  robin_day[,'Total'] <- robin_day[,'Total'] + robin_day[,paste(stock,'AMT', sep='_')]
}

qplot(x = robin_day$Date, y = robin_day$Total, geom = 'line')

########### Uber Dataset for Mu Sigma 401k

mu_sig <- read.csv('D://Documents/Stock Dashboard/Mu Sigma 401k Transactions.csv')
mu_sig$Date <- as.Date(mu_sig$Date)
mu_sig <- mu_sig[mu_sig$Type == 'BUY' | mu_sig$Type == 'SELL',]
mu_sig_stocks <- levels(factor(mu_sig$Ticker))
mu_sig[mu_sig$Type == 'SELL',c('Shares', 'Total')] <- mu_sig[mu_sig$Type == 'SELL',c('Shares', 'Total')]*(-1)

date_range <- data.frame(seq.Date(as.Date('2016-01-01'), Sys.Date()-1, by='days'))
colnames(date_range) <- 'Date'
mu_sig_close_price <- read.csv('D://Documents/Stock Dashboard/Mu Sigma 401k Close.csv')
mu_sig_close_price$Date <- as.Date(mu_sig_close_price$Date)
mu_sig_close_price <- na.locf(merge(x=date_range, y=mu_sig_close_price, by='Date', all.x = TRUE))
mu_sig_close_price$Date <- as.Date(mu_sig_close_price$Date)


mu_sig_trad <- mu_sig[mu_sig$Account == 'Pre-tax',]
mu_sig_roth <- mu_sig[mu_sig$Account == 'Roth',]
mu_sig_trad_tran_day <- spread(mu_sig_trad[,c('Date', 'Ticker', 'Shares')], Ticker, Shares)
mu_sig_roth_tran_day <- spread(mu_sig_roth[,c('Date', 'Ticker', 'Shares')], Ticker, Shares)



mu_sig_trad_day <- data.frame(seq.Date(as.Date('2016-01-01'), Sys.Date()-1, by='days'))
colnames(mu_sig_trad_day) <- 'Date'
mu_sig_trad_day$Total <- 0
mu_sig_trad_day <- merge(mu_sig_trad_day, mu_sig_trad_tran_day, by = 'Date', all.x = TRUE)
mu_sig_trad_day[is.na(mu_sig_trad_day)] <- 0


mu_sig_trad_day <- merge(x=mu_sig_trad_day, y=mu_sig_close_price, by='Date', suffixes = c('_shares', '_price'))

for(stock in mu_sig_stocks){
  mu_sig_trad_day[,paste(stock, 'price', sep='_')] <- as.numeric(mu_sig_trad_day[,paste(stock, 'price', sep='_')])
  mu_sig_trad_day[,paste(stock,'shares', sep='_')] <- cumsum(mu_sig_trad_day[,paste(stock,'shares', sep='_')])
  mu_sig_trad_day[,paste(stock,'AMT', sep='_')] <- mu_sig_trad_day[,paste(stock,'price', sep='_')] * mu_sig_trad_day[,paste(stock,'shares', sep='_')]
  mu_sig_trad_day[,'Total'] <- mu_sig_trad_day[,'Total'] + mu_sig_trad_day[,paste(stock,'AMT', sep='_')]
}




mu_sig_roth_day <- data.frame(seq.Date(as.Date('2016-01-01'), Sys.Date()-1, by='days'))
colnames(mu_sig_roth_day) <- 'Date'
mu_sig_roth_day$Total <- 0
mu_sig_roth_day <- merge(mu_sig_roth_day, mu_sig_roth_tran_day, by = 'Date', all.x = TRUE)
mu_sig_roth_day[is.na(mu_sig_roth_day)] <- 0


mu_sig_roth_day <- merge(x=mu_sig_roth_day, y=mu_sig_close_price, by='Date', suffixes = c('_shares', '_price'))

for(stock in mu_sig_stocks){
  mu_sig_roth_day[,paste(stock, 'price', sep='_')] <- as.numeric(mu_sig_roth_day[,paste(stock, 'price', sep='_')])
  mu_sig_roth_day[,paste(stock,'shares', sep='_')] <- cumsum(mu_sig_roth_day[,paste(stock,'shares', sep='_')])
  mu_sig_roth_day[,paste(stock,'AMT', sep='_')] <- mu_sig_roth_day[,paste(stock,'price', sep='_')] * mu_sig_roth_day[,paste(stock,'shares', sep='_')]
  mu_sig_roth_day[,'Total'] <- mu_sig_roth_day[,'Total'] + mu_sig_roth_day[,paste(stock,'AMT', sep='_')]
}

qplot(x = mu_sig_trad_day$Date, y = mu_sig_trad_day$Total, geom = 'line')
qplot(x = mu_sig_roth_day$Date, y = mu_sig_roth_day$Total, geom = 'line')
