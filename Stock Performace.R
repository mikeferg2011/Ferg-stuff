library(data.table)
library('zoo')

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
  return(output)
}


