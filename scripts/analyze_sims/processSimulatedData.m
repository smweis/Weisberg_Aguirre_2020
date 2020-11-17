function [stats] = processSimulatedData(resultsDir,groupingVars,varargin)
%% [stats] = processSimulatedData(resultsDir,groupingVars,factor,level)
% Super messy function - sorry! 
%
% Usage:
%     [stats] = processSimulatedData(resultsDir,groupingVars,factor,level)
%
% Description:
%     Plot simulated data. Will always compare qp and random along another
%     axis of a factor or level. S
%
%
% Required inputs:
%   resultsDir            - String - the absolute path to directory housing the
%                           results.(e.g.,'C:\Users\stevenweisberg\Documents\MATLAB\projects\Weisberg_Aguirre_2020\results\Paper_Results\batch2'
%   groupingVars          - Cell array, giving the names of factors varied
%                           during the simulations.
% Optional inputs:
%   factor                - String. Name of factor you want to plot. 
%   level                 - String/int. Level of the factor you want to
%                           use.
%
% Example
%{
%Change me!
resultsDir = 'C:\Users\stevenweisberg\Documents\MATLAB\projects\Weisberg_Aguirre_2020\results\Paper_Results\batch2';
groupingVars = {'nOutcomes','noiseSD','qpPresFinal'};
factor = 'noiseSD'; % Or try other groupingVars
level = .1; % or try .25 for noiseSD. 
% Other options for this batch are: 
%factor = 'nOutcomes'; level = 7; level = 15; level = 31;
% Can't combine them right now. 
%}

%% Handle initial inputs
p = inputParser;

% Required input
p.addRequired('resultsDir',@isstr);
p.addRequired('groupingVars',@iscell);

% Optional input
p.addOptional('factor','noiseSD',@isstr);
p.addOptional('level',.1);


% Parse
p.parse(resultsDir,groupingVars,varargin{:});

%%
posterFormat = struct;
posterFormat.lightRandColor = '#3D92C9';
posterFormat.darkRandColor = '#165172';
posterFormat.lightQPColor = '#F99C16';
posterFormat.darkQPColor = '#FA4515';
posterFormat.veridicalColor = '#000000';

% Grab the names of all the mat files in the results directory
resultsNames = dir(fullfile(resultsDir,'*.mat'));

% Check if data have already been processed.
if ~isempty(find(strcmp({resultsNames.name}, 'loadedData.mat')==1,1))
    load(fullfile(resultsDir,'loadedData.mat'));
% If the number of mat files in the results directory doesn't match the
% number of files found in loadedData.mat, re-run it to grab the right
% data.
    if size(data.qpfmriResults,1) ~= size(resultsNames,1)-1
        data = loadSimulatedData(resultsDir);
    end
else 
    data = loadSimulatedData(resultsDir);
end

% Turn the struct into a table for easier plotting.
dataTable = struct2table(data.qpfmriResults);

% Grab one of files. Useful for a few details that aren't likely to change
% across simulations. 
myQpfmriParams = load(fullfile(resultsNames(2).folder,resultsNames(2).name));
myQpfmriParams = myQpfmriParams.qpfmriResults;

% Get rid of data, which is enormous. 
clear('data');

% Re-code a couple variables that don't store properly.
for i = 1:height(dataTable)
    temp = dataTable.entropyOverTrials(i,end);
    dataTable.entropyFinal(i) = temp{end}(end);
    dataTable.maxBOLDFinalPreFit(i) = dataTable.maxBOLDoverTrials(i,end);
    if contains(dataTable.outNum{i},'qp')
        dataTable.qpPresFinal{i} = 'qp';
    else
        dataTable.qpPresFinal{i} = 'random';
    end
end



inputVars = {'nOutcomes','noiseSD','qpPresFinal','maxBOLDFinal',...,
    'maxBOLDFinalPreFit','psiParamsBadsFinal','entropyFinal'};

dsa = dataTable(:,inputVars);
G = findgroups(dataTable.qpPresFinal,dataTable.nOutcomes,dataTable.noiseSD);
stats = grpstats(dsa,groupingVars,{'mean','median','std','meanci'});




qpRows = (dataTable.qpPresFinal=="qp" & dataTable.(p.Results.factor)==p.Results.level);
qpRows = dataTable(qpRows==1,:);
randRows = (dataTable.qpPresFinal=="random" & dataTable.(p.Results.factor)==p.Results.level);
randRows = dataTable(randRows==1,:);

modelResponseNoCorrection = myQpfmriParams.model(myQpfmriParams.stimulusDomain{:},myQpfmriParams.simulatedPsiParams);
predictedRelativeResponse = myQpfmriParams.model(myQpfmriParams.stimulusDomain{:},myQpfmriParams.simulatedPsiParams) - myQpfmriParams.model(min(myQpfmriParams.stimulusDomain{:}),myQpfmriParams.simulatedPsiParams);



% Figure

figure('Position', get(0, 'Screensize'));
set(gcf,'color','w');
subPlotRows = 2;
subPlotCols = 2;
qPlusPanels = [1 3];
randPanels = [2 4];
subplot(subPlotRows,subPlotCols,qPlusPanels);

hold on;


ylim([0 1]);
ax = gca;
ax.FontSize = 25;
set(gca,'XScale', 'lin');
xlabel('Contrast','FontSize',30);
ylabel('Normalized Predicted Response','FontSize',30);


for j = 1:size(qpRows,1)
    params = qpRows.psiParamsBadsFinal(j,:);
    qpResponse = myQpfmriParams.model(myQpfmriParams.stimulusDomain{:},params) - myQpfmriParams.model(min(myQpfmriParams.stimulusDomain{:}),params);
    simResponse = myQpfmriParams.model(myQpfmriParams.stimulusDomain{:},params);
    qpRows.rSquared(j) = corr(modelResponseNoCorrection',simResponse')^2;
    plot2 = plot(myQpfmriParams.stimulusDomain{:},qpResponse,'-','Color',posterFormat.darkQPColor,'LineWidth',2,'HandleVisibility','off');
    plot2.Color(4) = 0.2;
end

plotV = plot(myQpfmriParams.stimulusDomain{:},predictedRelativeResponse,'-','Color',posterFormat.veridicalColor,'LineWidth',6);
plotV.Color(4) = .75;


qpRowsMean = mean(qpRows.psiParamsBadsFinal);
qpMeanResponse = myQpfmriParams.model(myQpfmriParams.stimulusDomain{:},qpRowsMean) - myQpfmriParams.model(min(myQpfmriParams.stimulusDomain{:}),qpRowsMean);
plot(myQpfmriParams.stimulusDomain{:},qpMeanResponse,'--','Color',posterFormat.lightQPColor,'LineWidth',3);

legend('Veridical','Q+','Location','Northwest');

subplot(subPlotRows,subPlotCols,randPanels);
hold on;
ylim([0 1]);
ax = gca;
ax.FontSize = 25;
set(gca,'XScale', 'lin');
xlabel('Contrast','FontSize',30);
ylabel('Normalized Predicted Response','FontSize',30);
for j = 1:size(randRows,1)
    params = randRows.psiParamsBadsFinal(j,:);
    randomResponse = myQpfmriParams.model(myQpfmriParams.stimulusDomain{:},params) - myQpfmriParams.model(min(myQpfmriParams.stimulusDomain{:}),params);
    simResponse = myQpfmriParams.model(myQpfmriParams.stimulusDomain{:},params);
    randRows.rSquared(j) = corr(modelResponseNoCorrection',simResponse')^2;
    plot2 = plot(myQpfmriParams.stimulusDomain{:},randomResponse,'-','Color',posterFormat.darkRandColor,'LineWidth',2,'HandleVisibility','off');
    plot2.Color(4) = 0.2;
end

plotV = plot(myQpfmriParams.stimulusDomain{:},predictedRelativeResponse,'-','Color',posterFormat.veridicalColor,'LineWidth',6);
plotV.Color(4) = .75;


randRowsMean = mean(randRows.psiParamsBadsFinal);
randMeanResponse = myQpfmriParams.model(myQpfmriParams.stimulusDomain{:},randRowsMean) - myQpfmriParams.model(min(myQpfmriParams.stimulusDomain{:}),randRowsMean);
plot(myQpfmriParams.stimulusDomain{:},randMeanResponse,'--','Color',posterFormat.lightRandColor,'LineWidth',3);


sgtitle(sprintf('%s Model Fits for %s = %s(SD)',func2str(myQpfmriParams.model),p.Results.factor,num2str(p.Results.level)),'FontSize',45);
legend('Veridical','Random','Location','Northwest');



[pval,h] = ranksum(qpRows.rSquared,randRows.rSquared)

% Histogram of r-squared results
binRange = .75:0.025:1;
hcx = histcounts(qpRows.rSquared,[binRange Inf]);
hcy = histcounts(randRows.rSquared,[binRange Inf]);
figure;
b = bar(binRange,[hcx;hcy]');
b(1).FaceColor = posterFormat.darkQPColor;
b(2).FaceColor = posterFormat.darkRandColor;

sgtitle(sprintf('R-squared goodness of fit for %s = %s',p.Results.factor,num2str(p.Results.level)));
legend('QP','Random','Location','Northwest');

mean(qpRows.rSquared)
mean(randRows.rSquared)

% Lineplot of change over time for maxBOLD
figure('Position', get(0, 'Screensize'));
set(gcf,'color','w');
sgtitle(sprintf('Change in parameter fits over trials for %s = %s',p.Results.factor,num2str(p.Results.level)));

subplot(3,1,1);

shadedErrorBar(1:dataTable.nTrials,qpRows.maxBOLDoverTrials(:,:),...,
    {@mean,@(x) std(x)/sqrt(length(x))},'lineprops',{'color',posterFormat.darkQPColor});
hold on;
shadedErrorBar(1:dataTable.nTrials,randRows.maxBOLDoverTrials(:,:),...,
    {@mean,@(x) std(x)/sqrt(length(x))},'lineprops',{'color',posterFormat.darkRandColor});
legend('QP','Random');
ylabel('Max BOLD estimate (% signal change)');
title(sprintf('MaxBOLD fits over trials'));
ylim([0,2.5]);
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
shadedErrorBar(1:dataTable.nTrials,qpSlope,{@mean,@(x) std(x)/sqrt(length(x))},'lineprops',{'color',posterFormat.darkQPColor});
hold on;
shadedErrorBar(1:dataTable.nTrials,randSlope,{@mean,@(x) std(x)/sqrt(length(x))},'lineprops',{'color',posterFormat.darkRandColor});
legend('QP','Random');
title(sprintf('Slope fits over trials'));
ylabel('Slope parameter');
ylim([0,1]);
yline(dataTable.simulatedPsiParams(1,1),'-','Veridical','LabelHorizontalAlignment','left','HandleVisibility','off');

% Lineplot of change over time for SemiSat
subplot(3,1,3);
shadedErrorBar(1:dataTable.nTrials,qpSemiSat,{@mean,@(x) std(x)/sqrt(length(x))},'lineprops',{'color',posterFormat.darkQPColor});
hold on;
shadedErrorBar(1:dataTable.nTrials,randSemiSat,{@mean,@(x) std(x)/sqrt(length(x))},'lineprops',{'color',posterFormat.darkRandColor});
legend('QP','Random');
title(sprintf('Semi-saturation fits over trials'));
xlabel('Trial Number');
ylabel('Semi-sat parameter');
ylim([0,1]);
yline(dataTable.simulatedPsiParams(1,2),'-','Veridical','LabelHorizontalAlignment','left','HandleVisibility','off');

end
