

subjectID = 'TOME_3021';

% Enter run name and numbers here
subjectDirStem = '/Users/nfuser/Documents/rtQuest';

TR = 800;
ntrials = 30;
trialLength = 12000;


% Wrapper for all runs
for i = 1:5
    % Change the acquisition direction name depending on even or odd
    if mod(i,2) == 1
        runName = 'tfMRI_CheckFlash_PA_run';
    else
        runName = 'tfMRI_CheckFlash_AP_run';
    end

    [detrendTimeseries(i,:),stimParams] = optimalFlickerAnalysisPreprocess(subjectID,subjectDirStem,i,runName);
    [tfeParams,watsonParams(i,:)] = optimalFlickerAnalysisTFE(detrendTimeseries(i,:),stimParams,TR,ntrials,trialLength);
end

