# Matlab_Stock_Predictions_w_HeikinAshi
Mimics a momentum-based trading system I developed using Heikinashi candles (variation of Japanese candles): Tests on 52 securities.

This code will replicate a popular technician strategy known as heikinashi candles inorder to make predictions on future returns.  

Heikinashi is a way of representing data similar to japanese candlesticks (Op, Hi, Lo,Cl),
however with moving average concept applied to them; this is done to reduce noise in the timeseries allowing for better trend detection.

The core of this trading strategy is momentumn based "swing trading", using new highs and lows to make our decisions.

Achieves a sharpe ratio of 1.4575, APR of 14.68%; however commissions are not considered to keep the example simple.  (average trade 
duration is 3 days round trip, so this isn't too egregious.)  Nonetheless this is still more proof of concept and curiosity than live-ready code.

Cumulative Returns: ![heikinashireturns](https://user-images.githubusercontent.com/34739163/43686465-96bd4510-9883-11e8-89ac-7109c1d40b06.jpg)


