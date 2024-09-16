
library(tseries)
library(tidyverse)
library(ggplot2)
library(stats)
library(forecast)
library(TSA)
library(urca)
library(FinTS)
library(rugarch)



df_main = read_csv("E:\\Stevens institute\\SecondSem\\MA641 Time Series\\Project\\archive\\FDDRates.csv",show_col_types = FALSE)
colnames(df_main) = c('date','value')

df_main$date <- as.Date(df_main$date, "%Y-%m-%d")
plot(df_main, main = 'original_dataset', type='l')

###############################################################################

start_date <- as.Date("1980-01-01")
end_date <- as.Date("2016-12-01")
last_date = as.Date("2016-12-01")
########################

#for prediction purpose: ## just next 60 values
#############################

## for model fitting purpose
df <- df_main[df_main$date >= start_date & df_main$date < end_date,]

df_test <- df_main[df_main$date >= end_date & df_main$date < as.Date("2019-12-01"),]


data1 = df$value
data_365 = ts(data1, frequency = 12)
decompose_data = decompose(data_365, "multiplicative")
plot(data1, type='l')
plot(decompose_data, type='l',lwd=2, col = 'blue')

########################################################

data1 = df$value
acf(data1, main = 'ACF of original data', lag.max = 100)
## exponentially dying

pacf(data1,main = 'PACF of original data', lag.max = 100 )

## spikes are there at regular intervals

## Performing dickey Fuller Test

adf_test = adf.test(data1)
print(adf_test)


###################################################################
######################################################################

## full data with seasonal and first difference

close_sdiff = (diff(log(data1), lag = 12))
plot(close_sdiff, type='l', main = 'seasonal log diff ')

adf_test = adf.test(close_sdiff)
adf_test


 #################################################

## Model Determination:


## for the SARMA Model
acf(as.vector(data1), lag.max = 100, main = 'ACF for full data for P and Q')
pacf(as.vector(data1), lag.max = 100, main = 'PACF for full data for P and Q')

## from the ACF: its dying: so SMA(Q) = 0
## from the PACF: its significant: so SAR(P) = 3


######################################################

acf(close_sdiff, lag.max = 48, main = 'ACF for full log diff. data for p and q')
pacf(close_sdiff, lag.max = 48, main = 'PACF for full log diff. data for p and q')
eacf(close_sdiff)
## Possible models:
## ARIMA(2,1,2)
## ARIMA(3,1,3)
## ARIMA(4,1,4)
## ARIMA(2,1,3)
## ARIMA(3,1,4)

    

############################################

#######################################################


fit_sarma <- function(data, p, d, q){
  library(forecast)
  # Fit SARMA model with given parameters
  model <- arima(data, order = c(p, d, q), seasonal = list(order = c(3,1,0), period = 12), method = 'ML')
  
  # Calculate BIC value
  bic <- BIC(model)
  
  return(list(model = model, bic = bic))
}


sarma_212 <- fit_sarma(close_sdiff, 2, 1, 2)
#sarma_313 <- fit_sarma(close_sdiff, 3, 1, 3)
#sarma_414 <- fit_sarma(close_sdiff, 4, 1,4)
sarma_213 <- fit_sarma(close_sdiff, 2, 1, 3)
#sarma_314 <- fit_sarma(close_sdiff, 3, 1, 4)


# Find the model with the minimum BIC
bic_values <- c(sarma_212$bic, sarma_213$bic)
min_bic <- min(bic_values)
min_bic_index <- which.min(bic_values)
min_bic_index

## sarma_222 is better

## Residuals analysis

acf(sarma_212$model$residuals, lag.max = 600)
pacf(sarma_212$model$residuals, lag.max = 600)

###################################################################

library(forecast)

# Fit SARIMA model to full data

manualFit <- arima(df$value, order = c(2,1,2), seasonal = list(order = c(3,1,0), period = 12), method='ML')
manual_pred = predict(manualFit, n.ahead = 24)

plot(manual_pred$pred)
plot(df_test$value)

matplot(cbind(df_test$value, manual_pred$pred), type = "l", lwd = c(3, 1), col = c("blue", "red"))
###################################################################

## finding the GARCH order

close_sdiff_garch = ((close_sdiff))
garch(x=close_sdiff_garch)

## a1 and b1: MEANS : alpha = 1 and beta = 1
## GARCH(1,1)

##############################################################################
###############################################################

s_norm <- ugarchspec(mean.model = list(armaOrder = c(2,2)),variance.model = list(model = 'eGARCH',garchOrder = c(1,1)),
                     distribution.model = 'norm')

m_norm <- ugarchfit(data = close_sdiff_garch, spec = s_norm)

m_norm

resid_norm = residuals(m_norm)
qqnorm(resid_norm,  main = 'QQ plot for residuals from GARCH Normal')
qqline(resid_norm)

acf(resid_norm, main="ACf of garch residuals", lag.max = 200)
pacf(resid_norm, main = "PACF of garch residuals", lag.max = 200)
##############################################################################

sfinal = s_norm
setfixed(sfinal) = as.list(coef(m_norm))
s_norm_forecast = ugarchforecast(data = close_sdiff,n.ahead = 36,fitORspec = sfinal)


sim <- ugarchpath(spec = sfinal, m.sim = 2, n.sim = 1*36, rseed = 123)
plot.zoo(fitted(sim))
plot.zoo(sigma(sim))


print(tail(df$value))
last_value = tail(df$value,1)[1]
last_value

p <- last_value*apply(fitted(sim), 2, 'cumsum') + last_value
matplot(p, type = "l", lwd = 3)


matplot(cbind(df_test$value, p), type = "l", lwd = c(3, 1), col = c("blue", "red"), 
        xlab = paste("Time (", end_date, " to ", as.Date("2018-12-01"), ")", sep = ""), 
        ylab = "Price", main = "Actual Prices vs Simulated Price Paths using ggrGarch")

############################################################################
# Box-Ljung test:
Box.test(resid_norm, type = "Ljung-Box")
## >0.05: so proper fit

shapiro.test(resid_norm)





