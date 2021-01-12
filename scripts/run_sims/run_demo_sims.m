
% Do you want to save figures?
savefig = true;




% Provide a model handle
model = @logistic;
% Specify the parameter domain. Each value must correspond to a parameter
% expected by the model.
paramsDomain = struct;
paramsDomain.slope = makeDomain(-1.2,-.2,10,'spacing','log');
paramsDomain.semiSat = makeDomain(.01,1,10);
paramsDomain.beta = makeDomain(.75,1.25,11,'spacing','zeno');
% Sigma in the parameter domain is searching for noiseSD
paramsDomain.sigma = makeDomain(0.01,1,10);
% Specify a stimulus domain and whether it spaced linear or log.
stimulusDomain = {makeDomain(.01,1,25)};
stimulusDomainSpacing = 'lin';
% Number of trials to run.
nTrials = 30;
% Allow Q+ to control the stimuli or not (false).
qpPres = true;
% Set the number of outcome categories / bins.
nOutcomes = 15;
% Do you want to see plots?
showPlots = true;
% The range of BOLD signal to simulate (e.g., from baseline to maximum BOLD)
maxBOLDSimulated = 1.5;
% How noisy simulated BOLD data are
noiseSD = .05;
%How long the trials are (in seconds).
trialLength = 12;

% How long is the TR?
TR = 800;


% Simulated Parameters
simulatedPsiParams = [.41,.57,1,noiseSD];

% seed
seed = 12345;

[myQpfmriParams,myQpParams] = qpfmriParams(model,paramsDomain,'qpPres',qpPres,...,
'stimulusDomain',stimulusDomain,'stimulusDomainSpacing',stimulusDomainSpacing,...,
'noiseSD',noiseSD,'nTrials',nTrials,'maxBOLDSimulated',maxBOLDSimulated,...,
'trialLength',trialLength,'nOutcomes',nOutcomes,'TR',TR,'seed',seed,'simulatedPsiParams',simulatedPsiParams);
% Run the simulation.
[qpfmriResultsLow]=simulate(myQpfmriParams,myQpParams,'showPlots',showPlots);



% Save figure
if savefig
    figLowName = fullfile('results','figs',strcat('figLowSimulation'));
    print(figLowName,'-dpng','-r300');
end


noiseSD = .15;
[myQpfmriParams,myQpParams] = qpfmriParams(model,paramsDomain,'qpPres',qpPres,...,
'stimulusDomain',stimulusDomain,'stimulusDomainSpacing',stimulusDomainSpacing,...,
'noiseSD',noiseSD,'nTrials',nTrials,'maxBOLDSimulated',maxBOLDSimulated,...,
'trialLength',trialLength,'nOutcomes',nOutcomes,'TR',TR,'seed',seed,'simulatedPsiParams',simulatedPsiParams);
% Run the simulation.
[qpfmriResultsMedium]=simulate(myQpfmriParams,myQpParams,'showPlots',showPlots);


% Save figure
if savefig
    figMedName = fullfile('results','figs',strcat('figMedSimulation'));
    print(figMedName,'-dpng','-r300');
end


noiseSD = .25;
[myQpfmriParams,myQpParams] = qpfmriParams(model,paramsDomain,'qpPres',qpPres,...,
'stimulusDomain',stimulusDomain,'stimulusDomainSpacing',stimulusDomainSpacing,...,
'noiseSD',noiseSD,'nTrials',nTrials,'maxBOLDSimulated',maxBOLDSimulated,...,
'trialLength',trialLength,'nOutcomes',nOutcomes,'TR',TR,'seed',seed,'simulatedPsiParams',simulatedPsiParams);
% Run the simulation.
[qpfmriResultsHigh]=simulate(myQpfmriParams,myQpParams,'showPlots',showPlots);

if savefig
    figHighName = fullfile('results','figs',strcat('figHighSimulation'));
    print(figHighName,'-dpng','-r300');
end
