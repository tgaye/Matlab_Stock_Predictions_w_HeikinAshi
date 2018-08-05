%This code will replicate a popular technician strategy known as heikinashi
%candles inorder to make predictions on future returns.  Heikinashi is a
%way of representing data similar to japanese candlesticks (Op, Hi, Lo,
%Cl), however with moving average concept applied to them; this is 
%done to reduce noise in the timeseries allowing for better trend detection.

%Heinkin Ashi buy and sell strat (swing trade/momentum):
load('inputDataOHLCDaily_20120504.mat');

%Initalize indexes, for all 52 stocks in our data set.
cumretx = zeros(rows(cl),cols(cl)); 
APRx = zeros(cols(cl),1); 
sharpex = zeros(cols(cl),1); 
numTradesx = zeros(cols(cl),1);
avgLengthx = zeros(cols(cl),1);

%Goes through C stocks with Heikin strat
for c=1:cols(cl)-1
    %First we store the original op, hi, lo, cl
    open = op(1:end,c);   
    high = hi(1:end,c);
    low =  lo(1:end,c);
    close = cl(1:end,c);
    
    %Then we apply the moving average concept to our candlesticks
    adjopen = (open + close/2); %Adjusted open is
    adjhigh = high; %#ok<*UDIM>
    adjlow = low;
    adjclose = (open+high+low+close)/4;
    
    %Initialize array to store future positions
    positions = NaN(length(close),1);
    %Initialize array to keep track if we are at a new high or new low
    highvslow = zeros(length(close),1);

    %Stores new highs/lows
    for i=2:rows(close)
        if(adjclose(i,1)>adjclose(i-1,1))
            highvslow(i,1)=1;
        else
            highvslow(i,1)=-1;
        end
        %1 = new high
        %-1 = new low
    end
%----------------------------------------------------------------------------------------
    %Buy and Sell logic:
    %1 = BUY: 3 lows followed by high
    for i=2:rows(close)    
        if(highvslow(i-1,1)==-1 && highvslow(i-2,1)==-1 &&...
                    highvslow(i-3,1)==-1 && highvslow(i,1)==1)....%signal: 3 lows followed by new high.

            for g = i:rows(positions)
                if (highvslow(g,1) == -1)
                    positions(g,1)=0;
                    break;
                else
                    positions(g,1)=1;             
                end
            end       
        else
                positions(i,1)= positions(i,1);
        end
    end
    %-1 = SELL: 3 highs followed by low
    for i=2:rows(close)     
        if(highvslow(i-1,1)==1 && highvslow(i-2,1)==1 && ...
                    highvslow(i-3,1)==1 && highvslow(i,1)==-1)....%signal: 3 highs followed by new low

            for g = i:rows(positions)
                if (highvslow(g,1) == 1)
                    positions(g,1)=0;
                    break;
                else
                    positions(g,1)=-1;             
                end
            end       
        else
                positions(i,1)= positions(i,1);
        end
    end
%----------------------------------------------------------------------------------------
    %Trade count
    numTrades = 0;
    
    %Length of trade
    n = 0;

    for i=1:rows(positions)
        %Counts number of trades
         if(positions(i,1)== -1 || positions(i,1)== 1)
             numTrades = numTrades + 1;  
        
            for g=i: rows(positions) 
                %Counts length of each trade
                if(positions(g,1)== -1 || positions(g,1)== 1)   
                    n = n+1;              
                else
                    break;                                             
                end     
            end     
            i= g; %#ok<FXSET>
         end    
    end
    
    %Trade length metrics
    avglength = n/numTrades;
    avgLengthx(c,1)=avglength;
    numTradesx(c,1)=numTrades;
%----------------------------------------------------------------------------------------
    %P/L calculations
    
    %Stores long or short or NaN for no position
    table =(positions);
    %Initialize array for pnl values
    pnl = zeros(rows(table),1);
    
    %Nested For
    for i = 1:rows(table)-11     
        g=0;
        h=0;
        
        %Find new short sales
        if(table(i,1)==-1)
            g=i;        
            for n = i:rows(positions)
             %If NaN, break because position flattened
             if(isnan(table(n,1))) 
                 h=n;             
                 break
             else    
            end
            end
             %Use normal close for calculating returns (we dont trade at the adj price)
             ret=(close(h,1)-close(g,1))/close(g,1); 
             pnl(h,1)=ret;   
        end 
    end     
    
    %Metrics of this stock, X.
    APRx(c,1)= prod(1+pnl).^(252/length(pnl))-1;
    sharpex(c,1) = mean(pnl)*sqrt(252)/std(pnl);
    cumretx(1:1000,c)=cumprod(1+pnl)-1; % compounded ROE  
    
    %End of 52 stock loop
end

%Mean metrics across all 52 stocks (aka our portfolio)
meancumret = mean(cumretx(1000,1:end))
meanapr = mean(APRx)
meansharpe = mean(sharpex)
meannumtrades = mean(numTradesx)
meanavglength = mean(avgLengthx) %#ok<*NOPTS>

portfolio = zeros(rows(cl),1);
for u=1:rows(cl)
    %Use cumret of all 52 stocks as a makeshift portfolio
    portfolio(u,1) = mean(cumretx(u,1:end));
end

%Check results
plot(portfolio);


    

    