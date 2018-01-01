library(data.table)
library(zoo)
library(ggplot2)
library(tidyr)


# Functions ----

singleStock <- function(stock, startDate = as.Date('2016-01-01'), endDate = Sys.Date() - 1) {
  #dates <- seq.Date(as.Date(startDate, '%B+%d+%Y'), as.Date(endDate, '%B+%d+%Y'), by='days')
  startDate <- format(startDate, '%B+%d+%Y')
  endDate <- format(endDate, '%B+%d+%Y')
  stock_url <- paste('https://finance.google.com/finance/historical?q=', stock
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

# Import and Clean Tranactions & Get Historical Prices ----

robin <- read.csv('D://Documents/Stock Dashboard/Robinhood Transactions.csv')
robin$Date <- as.Date(robin$Date)
robin <- robin[robin$Type == 'BUY' | robin$Type == 'SELL',]
robin_stocks <- levels(factor(robin$Ticker))
robin[robin$Type == 'SELL',c('Shares', 'Total')] <- robin[robin$Type == 'SELL',c('Shares', 'Total')]*(-1)

robin_close_price <- multipleStock(robin_stocks, startDate = as.Date('2016-06-01'))

# Uber Dataset for Robinhood ----

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

# Uber Dataset for Mu Sigma 401k ----
mu_sig <- read.csv('D://Documents/Stock Dashboard/Mu Sigma 401k Transactions.csv')
mu_sig$Date <- as.Date(mu_sig$Date)
mu_sig_stocks <- levels(factor(mu_sig$Ticker))
mu_sig[mu_sig$Type == 'SELL',c('Shares', 'Total')] <- mu_sig[mu_sig$Type == 'SELL',c('Shares', 'Total')]*(-1)

date_range <- data.frame(seq.Date(as.Date('2016-01-01'), Sys.Date()-1, by='days'))
colnames(date_range) <- 'Date'
mu_sig_close_price <- read.csv('D://Documents/Stock Dashboard/Mu Sigma 401k Close.csv')
mu_sig_close_price$Date <- as.Date(mu_sig_close_price$Date)

mu_sig_perf <- data.frame()
for(stock in mu_sig_stocks) {
  trans_dummy <- mu_sig[mu_sig$Ticker == stock,c("Date", "Shares")]
  trans_dummy <- aggregate(list(Shares = trans_dummy$Shares), by = list(Date = trans_dummy$Date), FUN = sum)
  trans_dummy$Shares <- round(cumsum(trans_dummy$Shares), 5)
  
  close_dummy <- mu_sig_close_price[mu_sig_close_price$Ticker == stock,c("Date", "Close")]
  
  dep_dummy <- mu_sig[mu_sig$Ticker == stock & mu_sig$Action == "Deposit",c("Date", "Total")]
  dep_dummy <- aggregate(list(Deposit = dep_dummy$Total), by = list(Date = dep_dummy$Date), FUN = sum)
  dep_dummy$Deposit <-cumsum(dep_dummy$Deposit)
  
  cumm_dummy <- na.locf(merge(merge(merge(date_range, trans_dummy, all.x = TRUE), close_dummy, all.x = TRUE), dep_dummy, all.x = TRUE))
  cumm_dummy$Date <- as.Date(cumm_dummy$Date)
  cumm_dummy$Shares <- as.numeric(cumm_dummy$Shares)
  cumm_dummy$Close <- as.numeric(cumm_dummy$Close)
  cumm_dummy$Deposit <- as.numeric(cumm_dummy$Deposit)
  cumm_dummy[is.na(cumm_dummy$Shares), "Shares"] <- 0
  cumm_dummy[is.na(cumm_dummy$Close), "Close"] <- 0
  cumm_dummy[is.na(cumm_dummy$Deposit), "Deposit"] <- 0
  cumm_dummy$Amt <- cumm_dummy$Shares * cumm_dummy$Close
  # cumm_dummy$Gain <- round(cumm_dummy$Amt - cumm_dummy$Deposit, 2)
  cumm_dummy$Ticker <- stock
  cumm_dummy <- cumm_dummy[cumm_dummy$Shares > 0,]

  mu_sig_perf <- rbind(mu_sig_perf, cumm_dummy)
  # plot(x = cumm_dummy$Date, y = cumm_dummy$Gain)
}

mu_sig_perf <- aggregate(list(Deposit = mu_sig_perf$Deposit, Amt = mu_sig_perf$Amt), by = list(Date = mu_sig_perf$Date), FUN = sum)
mu_sig_perf$Gain <- mu_sig_perf$Amt - mu_sig_perf$Deposit


qplot(x = mu_sig_perf$Date, y = mu_sig_perf$Amt, geom = 'line')
qplot(x = mu_sig_perf$Date, y = mu_sig_perf$Gain, geom = 'line')

# Uber Dataset for Betterment ----
betterment <- read.csv('D://Documents/Stock Dashboard/Betterment Transactions.csv')
betterment <- betterment[,c("Date",
                            "Goal.Account",
                            "Activity",
                            "Ticker",
                            "Price",
                            "Shares",
                            "Total")]
betterment$Date <- as.Date(betterment$Date)
betterment_stocks <- levels(betterment$Ticker)

betterment_perf <- data.frame()
for(stock in betterment_stocks) {
  close_dummy <- singleStock(stock)
  close_dummy <- close_dummy[, c("Date", "Close")]
  
  trans_dummy <- betterment[betterment$Ticker == stock, c("Date", "Shares")]
  trans_dummy <- aggregate(list(Shares = trans_dummy$Shares), by = list(Date = trans_dummy$Date), FUN = sum)
  trans_dummy$Shares <- cumsum(trans_dummy$Shares)
  
  # dep_dummy <- betterment[betterment$Ticker == stock & (betterment$Activity == "Deposit" | betterment$Activity == "401(k) Rollover"),c("Date", "Total")]
  dep_dummy <- betterment[betterment$Ticker == stock & betterment$Activity == "Deposit",c("Date", "Total")]
  dep_dummy <- aggregate(list(Deposit = dep_dummy$Total), by = list(Date = dep_dummy$Date), FUN = sum)
  dep_dummy$Deposit <-cumsum(dep_dummy$Deposit)
  
  cumm_dummy <- na.locf(merge(merge(merge(date_range, trans_dummy, all.x = TRUE), close_dummy, all.x = TRUE), dep_dummy, all.x = TRUE))
  cumm_dummy$Date <- as.Date(cumm_dummy$Date)
  cumm_dummy$Shares <- as.numeric(cumm_dummy$Shares)
  cumm_dummy$Close <- as.numeric(cumm_dummy$Close)
  cumm_dummy$Deposit <- as.numeric(cumm_dummy$Deposit)
  cumm_dummy[is.na(cumm_dummy$Shares), "Shares"] <- 0
  cumm_dummy[is.na(cumm_dummy$Close), "Close"] <- 0
  cumm_dummy[is.na(cumm_dummy$Deposit), "Deposit"] <- 0
  cumm_dummy$Amt <- cumm_dummy$Shares * cumm_dummy$Close
  # cumm_dummy$Gain <- round(cumm_dummy$Amt - cumm_dummy$Deposit, 2)
  cumm_dummy$Ticker <- stock
  cumm_dummy <- cumm_dummy[cumm_dummy$Shares > 0,]
  
  betterment_perf <- rbind(betterment_perf, cumm_dummy)
  # plot(x = cumm_dummy$Date, y = cumm_dummy$Gain)
}

betterment_perf <- aggregate(list(Deposit = betterment_perf$Deposit, Amt = betterment_perf$Amt), by = list(Date = betterment_perf$Date), FUN = sum)
betterment_perf$Gain <- betterment_perf$Amt - betterment_perf$Deposit


qplot(x = betterment_perf$Date, y = betterment_perf$Amt, geom = 'line')
qplot(x = betterment_perf$Date, y = betterment_perf$Gain, geom = 'line')

# Total Performance ----
portfolio_perf <- merge(merge(date_range, mu_sig_perf[, c("Date", "Amt", "Deposit")], by = "Date", all.x = TRUE), betterment_perf[, c("Date", "Amt", "Deposit")], by = "Date", all.x = TRUE, suffixes = c(".mu", ".better"))
portfolio_perf[is.na(portfolio_perf$Amt.mu),'Amt.mu'] <- 0
portfolio_perf <- na.locf(portfolio_perf)
portfolio_perf$Date <- as.Date(portfolio_perf$Date)
portfolio_perf$Amt.mu <- as.numeric(portfolio_perf$Amt.mu)
portfolio_perf$Deposit.mu <- as.numeric(portfolio_perf$Deposit.mu)
portfolio_perf$Amt.better <- as.numeric(portfolio_perf$Amt.better)
portfolio_perf$Deposit.better <- as.numeric(portfolio_perf$Deposit.better)
portfolio_perf[is.na(portfolio_perf$Deposit.mu),'Deposit.mu'] <- 0
portfolio_perf[is.na(portfolio_perf$Amt.better),'Amt.better'] <- 0
portfolio_perf[is.na(portfolio_perf$Deposit.better),'Deposit.better'] <- 0

portfolio_perf$Amt <- portfolio_perf$Amt.mu + portfolio_perf$Amt.better
portfolio_perf$Deposit <- portfolio_perf$Deposit.mu + portfolio_perf$Deposit.better
portfolio_perf$Gain <- portfolio_perf$Amt - portfolio_perf$Deposit

qplot(x = portfolio_perf$Date, y = portfolio_perf$Amt, geom = 'line')
qplot(x = portfolio_perf$Date, y = portfolio_perf$Gain, geom = 'line')