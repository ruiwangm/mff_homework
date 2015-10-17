%%%%%%%  Part 1: GARCH
%
%%%% Exercise 1: Volatility Clusters

%% load stock prices of DBK

tickSymb = {'DBK.DE'};

dateBeg = '01012000';
dateEnd = '01012015';

dbkPrices = getPrices(dateBeg, dateEnd, tickSymb);


%% calculate percentage logarithmic returns

logRetsTable = price2retWithHolidays(dbkPrices);

logRets = 100*logRetsTable{:, :};



%% estimate GARCH

Mdl = garch('Offset',NaN,'GARCHLags',1,'ARCHLags',1);

EstMdl=estimate(Mdl,logRets);


%% backtesting

% estimate VAR
muHat=EstMdl.Offset;

sigmaHat=sqrt(infer(EstMdl,logRets));

alphaLevel = 1 - 0.95;
 
var_norm = norminv(alphaLevel, muHat, sigmaHat);

% plot past observations (green)
dats = datenum(logRetsTable.Properties.RowNames, 'yyyy-mm-dd');

figure('position', [50 50 1200 600])

scatter(dats, logRets, 8, [0.4 0.7 0.4], 'filled')

datetick 'x'

set(gca, 'xLim', [dats(1) dats(end)])

hold on;

% add VAR estimates to figure (blue)
scatter(dats, var_norm, 8, [0 0.3 0.8], 'filled')

% add exceedances to figure (red)
exceedances = logRets < var_norm;

dats_exceed = dats(exceedances);

logRets_exceed = logRets(exceedances);

hold on;

scatter(dats_exceed, logRets_exceed, 18, [0.9 0.05 0.05], 'filled')


% display overall exceedance frequency
nObs=length(logRets);

exceedFreq=sum(exceedances)/nObs;

display(exceedFreq)


%% plot empirical autocorrelation

[V,simRets]=simulate(EstMdl,40000);

figure('position', [50 50 1200 600])

subplot(1, 2, 1)
autocorr(logRets.^2)
title('Real Data')

subplot(1, 2, 2)
autocorr(simRets.^2)
title('GARCH Model')


%% plot real data and sample paths

[V,simRets1]=simulate(EstMdl,nObs);
[V,simRets2]=simulate(EstMdl,nObs);
[V,simRets3]=simulate(EstMdl,nObs);

figure('position', [50 50 1200 600])

subplot(2, 3, 2)
plot(logRets)
ax=gca;
title('Real Data')

subplot(2, 3, 4)
plot(simRets1) 
set(gca,'yLim',ax.YLim)
title('Simulation')

subplot(2, 3, 5)
plot(simRets2)
set(gca,'yLim',ax.YLim)
title('Simulation')

subplot(2, 3, 6)
plot(simRets3)
set(gca,'yLim',ax.YLim)
title('Simulation')

% It is not possible to recognize the real historic path without knowledge
% of the arrangement.



%%%% Exercise 2: Fat Tails

%% kernel estimate of real data

figure('position', [50 50 1200 600])

ksdensity(logRets)


%% normal estimate of real data

[mu, sigma] = normfit(logRets);

x=-25:0.1:25;

hold on;

plot(x,normpdf(x,mu,sigma),'red')



%% kernel estimate of GARCH

[V,x]=simulate(EstMdl,40000);

[f,xi] = ksdensity(x);

hold on;

plot(xi,f,'green');

set(gca,'xLim',[-25 25])


%% estimate GARCH with t-distributed innovations

Mdl_t = garch('Offset',NaN,'GARCHLags',1,'ARCHLags',1,'Distribution','t');

EstMdl_t=estimate(Mdl_t,logRets);


%% kernel estimate of new GARCH

[V,x]=simulate(EstMdl_t,40000);

[f,xi] = ksdensity(x);

hold on;

plot(xi,f,'black')

set(gca,'xLim',[-25 25])

%% which is the best?

% GARCH with t-distributed innovations replicate the leptokurtosis of the 
% real data.




