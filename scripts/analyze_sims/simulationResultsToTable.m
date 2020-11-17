function [dataTable,myQpfmriParams] = simulationResultsToTable(resultsDir)
%% [dataTable,myQpfmriParams] = simulationResultsToTable(resultsDir)
%
% Usage:
%     [dataTable,myQpfmriParams] = simulationResultsToTable(resultsDir)
%
% Description:
%     
%
%
% Required inputs:
%   resultsDir            - String - the absolute path to directory housing the
%                           results.(e.g.,'C:\Users\stevenweisberg\Documents\MATLAB\projects\Weisberg_Aguirre_2020\results\Paper_Results\batch2'
%
%% 
% Example
%{

resultsDir = 'C:\Users\stevenweisberg\Documents\MATLAB\projects\Weisberg_Aguirre_2020\results\Paper_Results\archive\batch1_sigma20';
dataTable = simulationResultsToTable(resultsDir);
%}

%% Handle initial inputs
p = inputParser;

% Required input
p.addRequired('resultsDir',@isstr);


% Parse
p.parse(resultsDir);

%%

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

