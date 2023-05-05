

library(tseries)
library(tidyverse)
library(ggplot2)
library(stats)
library(forecast)
library(TSA)
library(urca)
library(FinTS)



df = read_csv("E:\\Stevens institute\\SecondSem\\MA641 Time Series\\Project\\archive\\coin_Cardano.csv",show_col_types = FALSE)
df = select(df, Date, Close)

df$Date <- as.Date(df$Date, "%Y-%m-%d")

# Create a time series with daily data from 2017-10-02 to 2021-07-06
start_date <- as.Date("2017-10-02")
end_date <- as.Date(max(df$Date))
daily_data <- ts(df$Close, start = c(2017, 275), frequency = 365)
plot(daily_data, main = 'original_dataset')

######################################################################################
########################################################################################

# Select data from 2018 to 2020
start_date <- as.Date("2018-10-01")
end_date <- as.Date("2020-8-31")

########################

#for prediction purpose: ## just next 60 values
df2 =  df[df$Date >= end_date & df$Date <= as.Date("2020-10-31"),]
#############################

## for model fitting purpose
df <- df[df$Date >= start_date & df$Date < end_date,]

####################################################################

# Create a time series with daily data from 2018 to 2020
as.integer(format(as.Date("2018-10-01"), "%j"))

daily_data <- ts(df$Close, start = c(2018, 274), end = c(2020, 244), frequency = 365)
date_seq <- seq(from = start_date, to = end_date, by = "day")
plot(date_seq,daily_data, type='l',main='Data between October-2018 and August-2020')

#####################################################################


df3 <- data.frame(Date = seq(as.Date("2018-10-01"), as.Date("2020-08-31"), by = "day"),
                  Close = daily_data)

###############################################################################

data1 = df3$Close
acf(data1, main = 'ACF of original data')
## exponentially dying

pacf(data1,main = 'PACF of original data' )
## Seems like AR(1) model

## Performing dickey Fuller Test

adf_test = adf.test(data1)
print(adf_test)

## Since p value > 0.05: fail to reject H0: it means non-stationary

###################################################################

## Log differencing

close_diff = (diff(diff(log(data1))))^2

plot(close_diff, type = "l", xlab = "Date", ylab = "Value", main = "Line Graph for square of log-double differenced data")

adf_test = adf.test(close_diff)

print(adf_test)

## Means the data has become stationary


## acf and pacf plots

acf(close_diff, lag.max = 30, main = 'ACF of square of log-double differenced data')
pacf(close_diff, lag.max = 30, main = 'PACF of square of log-double differenced data')

eacf(close_diff)

####################################################################################################################

## suppose Models:
## ARIMA(3,2,2) ## actually from the model
## ARIMA(0,2,2) ## from the eacfs
## ARIMA(1,2,2)
## ARIMA(3,2,3)
## ARIMA(2,2,3)

#################################################################################################################
#####################################################################################################################


## Defining Function:

plot_arima_resid <- function(model) {
  # Extract the residuals from the model
  resid <- resid(model)
  
  # Create a time series of the residuals
  resid_ts <- ts(resid, start = c(2018, 274), end = c(2020, 365), frequency = 365)
  
  # Get the values of p, d, and q from the ARIMA model
  p <- model$arma[1]
  q <- model$arma[2]
  
  # Plot the residuals with custom x-axis labels and title with ARIMA values
  plot(resid_ts, xlab = "Year", ylab = "Residuals", main = paste("Residuals Plot (ARIMA(", p, ",", 2, ",", q, "))"))
  
  acf(resid_ts[1:length(resid_ts)],lag.max = 150,main = paste("Residuals ACF Plot (ARIMA(", p, ",", 2, ",", q, "))"))
  pacf(resid_ts[1:length(resid_ts)],lag.max = 150, main = paste("Residuals PACF Plot (ARIMA(", p, ",", 2, ",", q, "))"))
  
}


################################################################
# create an empty data frame with column names
# create an empty data frame with column names
my_df <- data.frame(model = character(),
                    AIC = numeric(),
                    BIC = numeric(),
                    Shapiro = round(numeric(),3),
                    Ljung = round(numeric(),3))

new_row <- data.frame(model = "", AIC = 0, BIC = 0, Shapiro = 0, Ljung = 0)


plot_arima_residuals <- function(arima_model, my_df) {
  # extract residuals and create time series
  resid <- residuals(arima_model)
  resid_ts <- ts(resid, start = c(2018, 274), end = c(2020, 365), frequency = 365)
  plot_arima_resid(arima_model)
  
  # normal Q-Q plot of residuals
  qqnorm(resid_ts, main = "Residuals plot ")
  qqline(resid_ts)
  
  # Shapiro-Wilk test of normality
  shap = shapiro.test(resid_ts)
  
  # Ljung-Box test of autocorrelation
  ljung = LB.test(arima_model)
  
  # AIC and BIC
  cat("AIC:", AIC(arima_model), "\n")
  cat("BIC:", BIC(arima_model), "\n")
  
  # create a new row for the data frame and append it
  new_row$model <- as.character(arima_model)
  new_row$AIC <- AIC(arima_model)
  new_row$BIC <- BIC(arima_model)
  new_row$Shapiro <- shap$p.value
  new_row$Ljung <- round(ljung$p.value,3)
  my_df <- rbind(my_df, new_row)
  
  # return the updated data frame
  return(my_df)
}

# call the function and update the data frame
arima322 <- arima(x = close_diff, order = c(3, 2, 2))
arima022 <- arima(x = close_diff, order = c(0, 2, 2))
arima122 <- arima(x = close_diff, order = c(1, 2, 2))
arima323 <- arima(x = close_diff, order = c(3, 2, 3))
arima223 <- arima(x = close_diff, order = c(2, 2, 3))



my_df <- plot_arima_residuals(arima322, my_df)
my_df <- plot_arima_residuals(arima022, my_df)
my_df <- plot_arima_residuals(arima122, my_df)
my_df <- plot_arima_residuals(arima323, my_df)
my_df <- plot_arima_residuals(arima223, my_df)


# view updated data frame
print(my_df)


###############################################################################
#####################################################################

cat("## Garch Model ")

return = diff(log(df3$Close))

ArchTest(return)
## No ARCH EFFECT is there

 ##############################################################################
###############################################################


## finding the GARCH order

garch(x=return,grad = 'numerical', trace = FALSE)

## a1 and b1: MEANS : alpha = 1 and beta = 1
## GARCH(1,1)

##############################################################################
###############################################################

## Garch Model - Normal
## Normal: Pearson value < 0.05: not good
## sstd: pearson > 0.05: good

library(rugarch) 

## A) using Normal distribution model

return = diff(log(df3$Close))

s_norm <- ugarchspec(mean.model = list(armaOrder = c(3,2)),variance.model = list(garchOrder = c(1,1)),
                     distribution.model = 'sstd')

m_norm <- ugarchfit(data = return, spec = s_norm, solver ='hybrid')
m_norm

resid_norm = residuals(m_norm)
qqnorm(resid_norm,  main = 'QQ plot for residuals from GARCH Normal')
qqline(resid_norm)

acf(resid_norm, main="ACf of garch residuals")
pacf(resid_norm, main = "PACF of garch residuals")

## Pearson goodness < 0.05: Normal is not a good model then

## impact of news:
## lets see whether the model is symmetric or not

news_norm = newsimpact(m_norm)
plot(news_norm$zx, news_norm$zy, ylab = news_norm$yexpr, xlab = news_norm$xexpr,main='News Impact')

## symmetric Curve: positive and negative news have the same impact


## Volatility Forecast for next 60 days
sfinal = s_norm
setfixed(sfinal) = as.list(coef(m_norm))
s_norm_forecast = ugarchforecast(data = return,n.ahead = 60,fitORspec = sfinal)
plot(sigma(s_norm_forecast))


sim <- ugarchpath(spec = sfinal, m.sim = 2, n.sim = 1*60, rseed = 123)
plot.zoo(fitted(sim))
plot.zoo(sigma(sim))


print(tail(df$Close))
last_value = tail(df$Close,1)

p <- last_value*apply(fitted(sim), 2, 'cumsum') + last_value
matplot(p, type = "l", lwd = 3)



matplot(cbind(df2$Close, p), type = "l", lwd = c(3, 1), col = c("darkblue", "red"), 
        xlab = paste("Time (", end_date, " to ", as.Date("2020-10-31"), ")", sep = ""), 
        ylab = "Price", main = "Actual Prices vs Simulated Price Paths with Simple GARCH Model")



##############################################################################
###############################################################

## Leverage effect is there: so apply the E-Garch Model
## gamma is the leverage variable
## if gamma positive: good news decreases the volatility

plot(return, type="l", col="red", xlab="", ylab="", axes=FALSE)
par(new=TRUE)
plot(df3$Close, type="l", xlab="Date", ylab="Price")


#####################################################################################
s_norm <- ugarchspec(mean.model = list(armaOrder = c(3,2)),variance.model = list(model = 'eGARCH',garchOrder = c(1,1)),
                     distribution.model = 'sstd')

m_norm <- ugarchfit(data = return, spec = s_norm, solver ='hybrid')
m_norm

resid_norm = residuals(m_norm)
qqnorm(resid_norm,  main = 'QQ plot for residuals from GARCH Normal')
qqline(resid_norm)

acf(resid_norm, main="ACf of garch residuals")
pacf(resid_norm, main = "PACF of garch residuals")

## Pearson goodness < 0.05: Normal is not a good model then

## impact of news:
## lets see whether the model is symmetric or not

news_norm = newsimpact(m_norm)
plot(news_norm$zx, news_norm$zy, ylab = news_norm$yexpr, xlab = news_norm$xexpr,main='News Impact')

## symmetric Curve: positive and negative news have the same impact

## Volatility Forecast for next 2 0 days
sfinal = s_norm
setfixed(sfinal) = as.list(coef(m_norm))
s_norm_forecast = ugarchforecast(data = return,n.ahead = 60,fitORspec = sfinal)
plot(sigma(s_norm_forecast))


sim <- ugarchpath(spec = sfinal, m.sim = 2, n.sim = 1*60, rseed = 123)
plot.zoo(fitted(sim))
plot.zoo(sigma(sim))


print(tail(df$Close))
last_value = tail(df$Close,1)

p <- last_value*apply(fitted(sim), 2, 'cumsum') + last_value
matplot(p, type = "l", lwd = 3)


matplot(cbind(df2$Close, p), type = "l", lwd = c(3, 1), col = c("darkblue", "red"), 
        xlab = paste("Time (", end_date, " to ", as.Date("2020-10-31"), ")", sep = ""), 
        ylab = "Price", main = "Actual Prices vs Simulated Price Paths considering Leverage Effect")

#############################################################################################
#############################################################################################

return = (diff(log(df3$Close)))

s_norm <- ugarchspec(mean.model = list(armaOrder = c(3,2)),variance.model = list(model = 'gjrGARCH',garchOrder = c(1,1)),
                     distribution.model = 'sstd')

m_norm <- ugarchfit(data = return, spec = s_norm, solver ='hybrid')
m_norm


plot(m_norm, which='all')

resid_norm = residuals(m_norm)
qqnorm(resid_norm,  main = 'QQ plot for residuals from ggjGARCH Normal')
qqline(resid_norm)

acf(resid_norm, main="ACF of ggjgarch residuals")
pacf(resid_norm, main = "PACF of ggjgarch residuals")

## Pearson goodness < 0.05: Normal is not a good model then

## impact of news:
## lets see whether the model is symmetric or not

news_norm = newsimpact(m_norm)
plot(news_norm$zx, news_norm$zy, ylab = news_norm$yexpr, xlab = news_norm$xexpr,main='News Impact')

## symmetric Curve: positive and negative news have the same impact

## Volatility Forecast for next 2 0 days
sfinal = s_norm
setfixed(sfinal) = as.list(coef(m_norm))
s_norm_forecast = ugarchforecast(data = return,n.ahead = 60,fitORspec = sfinal)
plot(sigma(s_norm_forecast))


sim <- ugarchpath(spec = sfinal, m.sim = 2, n.sim = 1*60, rseed = 123)
plot.zoo(fitted(sim))
plot.zoo(sigma(sim))


print(tail(df3$Close))
last_value = tail(df3$Close,1)[1]
last_value

p <- last_value*apply(fitted(sim), 2, 'cumsum') + last_value
matplot(p, type = "l", lwd = 3)


matplot(cbind(df2$Close, p), type = "l", lwd = c(3, 1), col = c("blue", "red"), 
        xlab = paste("Time (", end_date, " to ", as.Date("2020-10-31"), ")", sep = ""), 
        ylab = "Price", main = "Actual Prices vs Simulated Price Paths using ggrGarch")


