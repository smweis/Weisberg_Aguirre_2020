clear all;
close all;

questData = qpInitialize('stimParamsDomainList',{[2 4 8 16 32 64]},...
'psiParamsDomainList',{.001:.001:.012,.5:.5:2,.5:.5:5,.5:.5:3},...
'qpPF',@qpWatsonTemporalModel,...
'nOutcomes',21);


outcomes = 1:21;


%% Adjust these parameters and run the script. 
simParams = [.004 2 1 1];
%simParams = [-0.00251422630566837,1.00595645717933,3.79738894349084,0.951504640228191];

nTrials = 128;
sdNoise = 0;


%% 
for i = 1:nTrials
    stim = qpQuery(questData);
    predictedProportions = qpWatsonTemporalModelWithNoise(stim,simParams,sdNoise);
    x = rand;
    if x < max(predictedProportions)
        [~,idx] = max(predictedProportions);
    else
        [~,idx] = maxk(predictedProportions,2);
        idx = idx(2);
    end
    outcome = outcomes(idx);
    questData = qpUpdate(questData,stim,outcome);
end
[~,maxIndex] = max(questData.posterior);
paramGuesses = questData.psiParamsDomain(maxIndex,:);

freqSupport = 0:.01:64;

figure; hold on;
plot(freqSupport,watsonTemporalModel(freqSupport,simParams),'.k');
for j = 1:size(paramGuesses,1)
    a(j,:) = watsonTemporalModel((freqSupport),paramGuesses(j,:));
    plot(freqSupport,a(j,:));
end

