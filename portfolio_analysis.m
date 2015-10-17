%%%%% Part 2: Portfolio Selection
%
%%% Exercise 3:

%% download data of all 30 DAX components

dateBeg = '01012000';
dateEnd = '01012015';
daxComp = {'ADS.DE', 'ALV.DE','BAS.DE', 'BAYN.DE', 'BEI.DE', ...
    'BMW.DE', 'CBK.DE', 'DAI.DE', 'DB1.DE', 'DBK.DE', ...
    'DPW.DE', 'DTE.DE', 'EOAN.DE', 'FME.DE', 'FRE.DE',...
    'HEI.DE', 'HEN3.DE', 'IFX.DE', 'LHA.DE', 'LIN.DE', ...
    'MAN.DE', 'MEO.DE', 'MRK.DE', 'MUV2.DE', 'RWE.DE', ...
    'SAP', 'SDF.DE', 'SIE.DE', 'TKA.DE', 'VOW3.DE'};

data = getPrices(dateBeg, dateEnd, daxComp);

%% estimate mean and standard deviation of percentage discrete returns

% calculate percentage discrete returns
discreteRetsTable = price2discreteRetWithHolidays(data);

discreteRets = 100*discreteRetsTable{:, :};

% estimate mean and std
mu=array2table(zeros(1,30));
mu.Properties.VariableNames=data.Properties.VariableNames;
mu.Properties.RowNames = {'mean'};

sigma=array2table(zeros(1,30));
sigma.Properties.VariableNames=data.Properties.VariableNames;
sigma.Properties.RowNames = {'std'};

for i=1:30
    val=discreteRets(:,i);
    mu{1,i}=mean(val(~isnan(val)));
    sigma{1,i}=std(val(~isnan(val)));
end


%% estimate correlation coefficients

rho=array2table(ones(30,30));
rho.Properties.VariableNames=data.Properties.VariableNames;
rho.Properties.RowNames=data.Properties.VariableNames;

for i=1:30
    val_1=discreteRets(:,i);
    ind_1=~isnan(val_1);
    for j=(i+1):30
        val_2=discreteRets(:,j);
        ind=ind_1 & (~isnan(val_2));
        r=corrcoef(val_1(ind),val_2(ind));
        rho{i,j}=r(1,2);
        rho{j,i}=r(1,2);
    end
end


%% histogram of correlation coefficients

rho_values=[];
for i=1:30
    for j=(i+1):30
        rho_values=[rho_values, rho{i,j}];
    end
end

histogram(rho_values,20)

%% display the pair with the highest correlation coefficients

rho_max=max(rho_values);

for i=1:30
    for j=(i+1):30
        if rho{i,j}==rho_max
            display({daxComp{i} daxComp{j}});
        end
    end
end


%% plot standard deviation and mean

figure('position', [50 50 1200 600])

scatter(sigma{:,:}, mu{:,:}, 15, 'red', 'filled')


%% portfolio of DBK.DE and DPW.DE

tickSymbs_dual={'DBK_DE','DPW_DE'};

k=200;
w=rand(k,1);
weightMat_dual=[w 1-w];

% covariance matrix of (DBK.DE, DPW.DE)
covMat_dual=diag(sigma{1,tickSymbs_dual})*rho{tickSymbs_dual,...
    tickSymbs_dual}*diag(sigma{1,tickSymbs_dual});

% calculate portfolio mean and std
mu_dual=weightMat_dual*mu{1,tickSymbs_dual}';

sigma_dual=zeros(1,k);

for i=1:k
    sigma_dual(i)=sqrt(weightMat_dual(i,:)*covMat_dual*...
        weightMat_dual(i,:)');
end


hold on;

scatter(sigma_dual, mu_dual, 15, 'blue', 'filled')

hold on;

scatter(sigma{1,tickSymbs_dual},mu{1,tickSymbs_dual}, ...
    30, 'green', 'filled')


%% portfolio of DBK.DE, DPW.DE, TKA.DE and CBK.DE

tickSymbs_quad={'DBK_DE','DPW_DE', 'TKA_DE', 'CBK_DE'};

n=50000;

w=rand(n,4);

weightMat_quad=w./kron(ones(1,4),sum(w,2));

% covariance matrix of (DBK.DE, DPW.DE, TKA.DE, CBK.DE)
covMat_quad=diag(sigma{1,tickSymbs_quad})*rho{tickSymbs_quad,...
    tickSymbs_quad}*diag(sigma{1,tickSymbs_quad});

% calculate portfolio mean and std
mu_quad=weightMat_quad*mu{1,tickSymbs_quad}';

sigma_quad=zeros(1,n);

for i=1:n
    sigma_quad(i)=sqrt(weightMat_quad(i,:)*covMat_quad*...
        weightMat_quad(i,:)');
end

figure('position', [50 50 1200 600])

scatter(sigma_quad, mu_quad, 8, 'red', 'filled')

hold on;

scatter(sigma{1,tickSymbs_quad},mu{1,tickSymbs_quad}, ...
    30, 'green', 'filled')

%% analysis of the findings
%
%






