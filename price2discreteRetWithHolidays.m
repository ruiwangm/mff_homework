function retsTable = price2discreteRetWithHolidays(prices)
%
% Input:
%   prices      nxm table of prices
%
% Output:
%   retsTable   (n-1)xm table of log returns

missingValues = isnan(prices{:, :});

pricesImputed = imputeWithLastDay(prices{:, :});

% calculate discrete returns
rets = pricesImputed(2:end, :)./pricesImputed(1:end-1, :)-1;

rets(missingValues(2:end, :)) = NaN;

% return log returns as table
retsTable = prices(2:end, :);
retsTable{:, :} = rets;

end

