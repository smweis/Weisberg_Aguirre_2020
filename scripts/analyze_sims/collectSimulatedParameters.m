function [allParamCombos] = collectSimulatedParameters(simulationParameters)
%% [allParamCombos] = collectSimulatedParameters(simulationParameters)
%
% Usage:
%     [allParamCombos] = collectSimulatedParameters(simulationParameters)
%
% Description:
%     
%
%
% Required inputs:
%   simulationParameters  - Cell array - list of names of parameters you
%                           want to filter the simulations on. 
%% 
% Example
%{

simulationParameters = {'nOutcomes','fMRInoise','trialLength','TR'};
[allParamCombos] = collectSimulatedParameters(simulationParameters);
%}

for i = 1:length(simulationParameters)
    simulationParameterVariables.(simulationParameters{i}) = unique(dataTableOut.(simulationParameters{i}));
end


allParamCombos = allcomb(simulationParameterVariables.nOutcomes,...,
    simulationParameterVariables.noiseSD,simulationParameterVariables.trialLength,...,
    simulationParameterVariables.TR);

