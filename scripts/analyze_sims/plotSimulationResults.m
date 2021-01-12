function summaryStats = plotSimulationResults(resultsDir,simulationParameters,simulationValues,figName,savefig)
%% plotSimulationResults(resultsDir,simulationParameters,simulationValues,figName);

%
% Usage:
%     plotSimulationResults(resultsDir,simulationParameters,simulationValues,figName);

%
% Description:
%
%
%
% Required inputs:
%   resultsDir            - String - the absolute path to directory housing the
%                           results.(e.g.,'C:\Users\stevenweisberg\Documents\MATLAB\projects\Weisberg_Aguirre_2020\results\Paper_Results\model_parameter_set1'
%   simulationParameters  - Cell array - list of names of parameters you
%                           want to filter the simulations on.
%   simulationValues      - Vector - Values you want to filter based on.
%%
% Example
%{

resultsDir = 'C:\Users\stevenweisberg\Documents\MATLAB\projects\Weisberg_Aguirre_2020\results\Paper_Results\model_parameter_set1';

simulationParameters = {'nOutcomes','fMRInoise','trialLength','TR'};
simulationValues = {7,.15,12,800};

figName = 'test';
savefig = false;
plotSimulationResults(resultsDir,simulationParameters,simulationValues,figName,savefig);
%}

%% Handle initial inputs


% Colors for plotting
colors = struct;
colors.lightRandColor = '#3D92C9';
colors.darkRandColor = '#165172';
colors.lightQPColor = '#F99C16';
colors.darkQPColor = '#FA4515';
colors.veridicalColor = '#000000';

% Grab data and sample qpfmriparams
[dataTable,myQpfmriParams] = simulationResultsToTable(resultsDir);

% Select all data used for plotting (can only select ONE set of parameters
% at a time)
fprintf('Values used for this set of simulations are:\n');
for i = 1:length(simulationParameters)
    if isfloat(simulationValues{i})
        dataTableIndex = (abs(dataTable.(simulationParameters{i})-simulationValues{i})<eps(.5));
    else
        dataTableIndex = (dataTable.(simulationParameters{i})==simulationValues{i});
    end
    dataTable = dataTable(dataTableIndex,:);
    fprintf('%s = %s\n',simulationParameters{i},num2str(simulationValues{i}));
end

fprintf('Filtered down to %s simulations.\n',num2str(height(dataTable)));

% Different data tables for QP and RANDOM for easier plotting
qpRows = (dataTable.qpPresFinal=="qp");
qpRows = dataTable(qpRows==1,:);
randRows = (dataTable.qpPresFinal=="random");
randRows = dataTable(randRows==1,:);

% Two different veridical models
modelResponseNoCorrection = myQpfmriParams.model(myQpfmriParams.stimulusDomain{:},myQpfmriParams.simulatedPsiParams);
predictedRelativeResponse = myQpfmriParams.model(myQpfmriParams.stimulusDomain{:},myQpfmriParams.simulatedPsiParams) - myQpfmriParams.model(min(myQpfmriParams.stimulusDomain{:}),myQpfmriParams.simulatedPsiParams);



%% Figure 1: Model fits
% Figure setup
figure('Position', get(0, 'Screensize'));
fig1 = gcf;
set(fig1,'color','w');
subPlotRows = 2;
subPlotCols = 2;
qPlusPanels = [1 3];
randPanels = [2 4];
subplot(subPlotRows,subPlotCols,qPlusPanels);
hold on;
% Q+ PLOTTING
% Formatting and labels
ylim([0 1]);
ax = gca;
ax.FontSize = 25;
set(gca,'XScale', 'lin');
xlabel('Contrast','FontSize',30);
ylabel('Normalized Predicted Response','FontSize',30);

% Plot each parameter fit from each simulation as a thin line
for j = 1:size(qpRows,1)
    params = qpRows.psiParamsBadsFinal(j,:);
    qpResponse = myQpfmriParams.model(myQpfmriParams.stimulusDomain{:},params) - myQpfmriParams.model(min(myQpfmriParams.stimulusDomain{:}),params);
    simResponse = myQpfmriParams.model(myQpfmriParams.stimulusDomain{:},params);
    qpRows.rSquared(j) = corr(modelResponseNoCorrection',simResponse')^2;
    plot2 = plot(myQpfmriParams.stimulusDomain{:},qpResponse,'-','Color',colors.darkQPColor,'LineWidth',2,'HandleVisibility','off');
    plot2.Color(4) = 0.2;
end

% Plot veridical parameters as a thick black line
plotV = plot(myQpfmriParams.stimulusDomain{:},predictedRelativeResponse,'-','Color',colors.veridicalColor,'LineWidth',6);
plotV.Color(4) = .75;

% Plot the mean parameter fits as a thick colored line
qpRowsMean = mean(qpRows.psiParamsBadsFinal);
qpMeanResponse = myQpfmriParams.model(myQpfmriParams.stimulusDomain{:},qpRowsMean) - myQpfmriParams.model(min(myQpfmriParams.stimulusDomain{:}),qpRowsMean);
plot(myQpfmriParams.stimulusDomain{:},qpMeanResponse,'--','Color',colors.lightQPColor,'LineWidth',3);

% Legend labels for Q+
legend('Veridical','Q+','Location','Northwest');


% RANDOM PLOTTING
% Formatting and labels
subplot(subPlotRows,subPlotCols,randPanels);
hold on;
ylim([0 1]);
ax = gca;
ax.FontSize = 25;
set(gca,'XScale', 'lin');
xlabel('Contrast','FontSize',30);
ylabel('Normalized Predicted Response','FontSize',30);

% Plot veridical parameters as a thick black line
for j = 1:size(randRows,1)
    params = randRows.psiParamsBadsFinal(j,:);
    randomResponse = myQpfmriParams.model(myQpfmriParams.stimulusDomain{:},params) - myQpfmriParams.model(min(myQpfmriParams.stimulusDomain{:}),params);
    simResponse = myQpfmriParams.model(myQpfmriParams.stimulusDomain{:},params);
    randRows.rSquared(j) = corr(modelResponseNoCorrection',simResponse')^2;
    plot2 = plot(myQpfmriParams.stimulusDomain{:},randomResponse,'-','Color',colors.darkRandColor,'LineWidth',2,'HandleVisibility','off');
    plot2.Color(4) = 0.2;
end

% Plot veridical parameters as a thick black line
plotV = plot(myQpfmriParams.stimulusDomain{:},predictedRelativeResponse,'-','Color',colors.veridicalColor,'LineWidth',6);
plotV.Color(4) = .75;

% Plot the mean parameter fits as a thick colored line
randRowsMean = mean(randRows.psiParamsBadsFinal);
randMeanResponse = myQpfmriParams.model(myQpfmriParams.stimulusDomain{:},randRowsMean) - myQpfmriParams.model(min(myQpfmriParams.stimulusDomain{:}),randRowsMean);
plot(myQpfmriParams.stimulusDomain{:},randMeanResponse,'--','Color',colors.lightRandColor,'LineWidth',3);

% Title and legend
sgtitle(sprintf('%s Model Fits',func2str(myQpfmriParams.model)),'FontSize',45);
legend('Veridical','Random','Location','Northwest');

% Save as PNG
if savefig 
    fig1Name = fullfile('results','figs',strcat('fig1_',figName));
    print(fig1Name,'-dpng','-r300');
end

% Print Wilcoxon signed rank non-parametric t-tests
[pval,h, stats] = ranksum(qpRows.rSquared,randRows.rSquared);
df = length(qpRows.rSquared) + length(randRows.rSquared) - 2;
fprintf('Wilcoxon signed-rank test Z(%d) = %0.2f, p = %.4f\n',df,stats.zval,pval);
fprintf('Q+ M = %0.4f, SD = %0.4f\nRandom M = %0.4f, SD = %0.4f\n',...,
    mean(qpRows.rSquared),std(qpRows.rSquared),...,
    mean(randRows.rSquared),std(randRows.rSquared));

summaryStats.qpMean = mean(qpRows.rSquared);
summaryStats.qpSD = std(qpRows.rSquared);
summaryStats.randMean = mean(randRows.rSquared);
summaryStats.randSD = std(randRows.rSquared);
summaryStats.pval = pval;
summaryStats.stats = stats;

%% Figure 2: Histogram of r-squared results

% Plot setup
figure;
fig2 = gcf;
set(fig2,'color','w');

%Build histogram
binRange = .75:0.025:1;
hcx = histcounts(qpRows.rSquared,[binRange Inf]);
hcy = histcounts(randRows.rSquared,[binRange Inf]);
b = bar(binRange,[hcx;hcy]');
b(1).FaceColor = colors.darkQPColor;
b(2).FaceColor = colors.darkRandColor;

% Title and legend
sgtitle(sprintf('R-squared goodness of fit'));
legend('QP','Random','Location','Northwest');

% Save figure
if savefig 
    fig2Name = fullfile('results','figs',strcat('fig2_',figName));
    print(fig2Name,'-dpng','-r300');
end

%% Figure 3: Lineplot of change over time for maxBOLD
% Figure setup
figure('Position', get(0, 'Screensize'));
fig3 = gcf;
set(fig3,'color','w');
subplot(3,1,1);

% Plot maxBOLD fit over trials
shadedErrorBar(7:dataTable.nTrials(1),qpRows.maxBOLDoverTrials(:,7:end),...,
    {@mean,@(x) std(x)/sqrt(length(x))},'lineprops',{'color',colors.darkQPColor});
hold on;
shadedErrorBar(7:dataTable.nTrials,randRows.maxBOLDoverTrials(:,7:end),...,
    {@mean,@(x) std(x)/sqrt(length(x))},'lineprops',{'color',colors.darkRandColor});
legend('QP','Random');
ylabel('Max BOLD estimate (% signal change)');
title(sprintf('MaxBOLD fits over trials'));
ylim([0,2.5]);
xlim([7,30]);
yline(dataTable.maxBOLDSimulated(1),'-','Veridical','LabelHorizontalAlignment','left','HandleVisibility','off');

% Lineplot of change over time for slope/semisat
for i = 1:length(qpRows.maxBOLDoverTrials)
    qpSlope(i,:) = qpRows.psiParamsQuest{i}(:,1);
    qpSemiSat(i,:) = qpRows.psiParamsQuest{i}(:,2);
end
for i = 1:length(randRows.maxBOLDoverTrials)
    randSlope(i,:) = randRows.psiParamsQuest{i}(:,1);
    randSemiSat(i,:) = randRows.psiParamsQuest{i}(:,2);
end

% Lineplot of change over time for Slope
subplot(3,1,2);
shadedErrorBar(7:dataTable.nTrials,qpSlope(:,7:end),{@mean,@(x) std(x)/sqrt(length(x))},'lineprops',{'color',colors.darkQPColor});
hold on;
shadedErrorBar(7:dataTable.nTrials,randSlope(:,7:end),{@mean,@(x) std(x)/sqrt(length(x))},'lineprops',{'color',colors.darkRandColor});
legend('QP','Random');
title(sprintf('Slope fits over trials'));
ylabel('Slope parameter');
ylim([0,1]);
xlim([7,30]);
yline(dataTable.simulatedPsiParams(1,1),'-','Veridical','LabelHorizontalAlignment','left','HandleVisibility','off');

% Lineplot of change over time for SemiSat
subplot(3,1,3);
shadedErrorBar(7:dataTable.nTrials,qpSemiSat(:,7:end),{@mean,@(x) std(x)/sqrt(length(x))},'lineprops',{'color',colors.darkQPColor});
hold on;
shadedErrorBar(7:dataTable.nTrials,randSemiSat(:,7:end),{@mean,@(x) std(x)/sqrt(length(x))},'lineprops',{'color',colors.darkRandColor});
legend('QP','Random');
title(sprintf('Semi-saturation fits over trials'));
xlabel('Trial Number');
ylabel('Semi-sat parameter');
xlim([7,30]);
ylim([0,1]);
yline(dataTable.simulatedPsiParams(1,2),'-','Veridical','LabelHorizontalAlignment','left','HandleVisibility','off');

% Title
sgtitle(sprintf('Change in parameter fits over trials'));

% Save figure
if savefig
    fig3Name = fullfile('results','figs',strcat('fig3_',figName));
    print(fig3Name,'-dpng','-r300');
end

end
