%%%%%%%  Part 1: GARCH
%
%%%% Exercise 1: Volatility Clusters

%%
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

muHat=EstMdl.Offset;

sigmaHat=sqrt(infer(EstMdl,logRets));

alphaLevel = 1 - 0.95;

var_norm = norminv(alphaLevel, muHat, sigmaHat);


% plot exceedances

dats = datenum(logRetsTable.Properties.RowNames, 'yyyy-mm-dd');

figure('position', [50 50 1200 600])

scatter(dats, logRets, 8, [0.5 0.7 0.5], 'filled')

datetick 'x'

set(gca, 'xLim', [dats(1) dats(end)])

hold on;

scatter(dats, var_norm, 8, [0 0.3 0.5], 'filled')
 
exceedances = logRets < var_norm;

dats_exceed = dats(exceedances);

logRets_exceed = logRets(exceedances);

hold on;

scatter(dats_exceed, logRets_exceed, 18, [0.9 0.05 0.05], 'filled')


% display frequency of exceedances
nObs=length(logRets);

exceedFreq=sum(exceedances)/nObs;

exceedFreq


%% empirical autocorrelation
[V,simRets]=simulate(EstMdl,40000);

figure('position', [50 50 1200 600])

subplot(1, 2, 1)
autocorr(logRets.^2)

subplot(1, 2, 2)
autocorr(simRets.^2)


%% sample paths

[V,simRets1]=simulate(EstMdl,nObs);
[V,simRets2]=simulate(EstMdl,nObs);
[V,simRets3]=simulate(EstMdl,nObs);


figure('position', [50 50 1200 600])

subplot(2, 3, 2)
plot(logRets)
ax=gca;

subplot(2, 3, 4)
plot(simRets1) 
set(gca,'yLim',ax.YLim)

subplot(2, 3, 5)
plot(simRets2)
set(gca,'yLim',ax.YLim)

subplot(2, 3, 6)
plot(simRets3)
set(gca,'yLim',ax.YLim)

%%%% Exercise 2: Fat Tails
