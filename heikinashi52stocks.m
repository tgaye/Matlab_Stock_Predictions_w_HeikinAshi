%Heinkin Ashi buy and sell, extra filters w/ Daily stocks
load('inputDataOHLCDaily_20120504.mat');
time = tday;
mawindow = 200;

%Indexes
cumretx = zeros(rows(cl),cols(cl));
aprx = zeros(cols(cl),1);
sharpex = zeros(cols(cl),1);
numTradesx = zeros(cols(cl),1);
avgLengthx = zeros(cols(cl),1);

%goes through C stocks with Heikin strat
for c=1:cols(cl)
    open = op(1:end,c);   
    high = hi(1:end,c);
    low =  lo(1:end,c);
    close = cl(1:end,c);

    adjopen = (open + close/2);
    adjhigh = high; %#ok<*UDIM>
    adjlow = low;
    adjclose = (open+high+low+close)/4;

%----------------------------------------------------------------------------------------
    positions = NaN(length(close),1);
    highvslow = zeros(length(close),1);
    ma = movingAvg(adjclose, mawindow);  %moving avg variables
    % plot(adjclose);
    % hold on;
    % plot(ma);

    %new highs/lows
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
    %Buy and Sell w/ filters

    for i=4:rows(close)       %1= buy
        if(highvslow(i-1,1)==-1 && highvslow(i-2,1)==-1 && highvslow(i-3,1)==-1 && highvslow(i,1)==1)....%candlestick signal
            ...%&& abs((adjclose(i,1)-adjclose(i-3,1))/adjclose(i-3,1))> .0025)....%momentum filter
            %&& adjclose(i,1) > ma(i,1)) %moving avg filter   

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

    for i=4:rows(close)       %-1 = sell
        if(highvslow(i-1,1)==1 && highvslow(i-2,1)==1 && highvslow(i-3,1)==1 && highvslow(i,1)==-1)....  candlestick signal
            ....&& (adjclose(i,1)-adjclose(i-3,1))/adjclose(i-3,1)> .0025).... % momentum filter
            %&& adjclose(i,1) < ma(i,1)) %moving avg filter

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
    n = 0;

    for i=1:rows(positions)

         if(positions(i,1)== -1 || positions(i,1)== 1)
             numTrades = numTrades + 1;  %counts trade

            for g=i: rows(positions)   %begins counting length of trade          
                if(positions(g,1)== -1 || positions(g,1)== 1)   
                    n = n+1;      % stores length of trade          
                else
                    break;                                             
                end     
            end     
            i= g; %#ok<FXSET>
         end    
    end

    avglength = n/numTrades;
    %display(avglength);
    %display(numTrades);
    avgLengthx(c,1)=avglength;
    numTradesx(c,1)=numTrades;
%----------------------------------------------------------------------------------------
    %P/L calculations
    
    table =[positions,close];
    pnl = NaN(rows(table),1);
    for i = 1:rows(table)-20
        g=0;
        h=0;
        if(table(i,1)==-1)
            g=i;        
            for n = i:rows(positions)
             if(isnan(table(n,1))) 
                 h=n;             
                 break
             else    
            end
            end
             ret=(close(h,1)-close(g,1))/close(g,1); %use normal close for returns
             pnl(h,1)=ret;   
        end 
    end     
    pnl(isnan(pnl))=0;

    aprx(c,1)= prod(1+pnl).^(252/length(pnl))-1;
    sharpex(c,1) = mean(pnl)*sqrt(252)/std(pnl);
    cumretx(1:1000,c)=cumprod(1+pnl)-1; % compounded ROE   
end

meancumret = mean(cumretx(1000,1:end))
meanapr = mean(aprx)
meansharpe = mean(sharpex)
meannumtrades = mean(numTradesx)
meanavglength = mean(avgLengthx) %#ok<*NOPTS>

portfolio = zeros(rows(cl),1);
for u=1:rows(cl)
    portfolio(u,1) = mean(cumretx(u,1:end));
    
end

plot(portfolio);

%aprport = prod(1+portfolio).^(252/length(portfolio))-1
%sharpeport = mean(portfolio)*sqrt(252)/std(portfolio)
%cumretport =cumprod(1+portfolio)-1 % compounded ROE 

    