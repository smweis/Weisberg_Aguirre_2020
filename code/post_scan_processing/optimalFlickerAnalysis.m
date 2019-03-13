%% Enter in some initial values

% Set FSL directory
setenv('FSLDIR','/usr/local/fsl');

% Enter subject ID here
subjectID = 'TOME_3021';

% Enter run name and numbers here
runNums = [1];
runName = 'tfMRI_CheckFlash_PA_run';

% Download all relevant data from Flywheel and place in subject directory.
subjectDir = fullfile('/Users/nfuser/Documents/rtQuest',subjectID);
addpath(subjectDir);

% Some scanner details:
TR = 800; % msecs
nTrials = 30;
trialLength = 12000; % msecs

%% Create retinotopy-based V1 mask
% Retintopy data, downloaded from Flywheel from a previous study. 
areasPath = fullfile(subjectDir,horzcat(subjectID,'_native.template_areas.nii.gz'));
eccenPath = fullfile(subjectDir,horzcat(subjectID,'_native.template_eccen.nii.gz'));
anglesPath = fullfile(subjectDir,horzcat(subjectID,'_native.template_angle.nii.gz'));

% Read in retinotopic maps with MRIread
areasMap = MRIread(areasPath);
eccenMap = MRIread(eccenPath);
anglesMap = MRIread(anglesPath);

% Relevant retinotopic values. 
areas = 1; % V1
eccentricities = [0 12];
angles = [0 360];

% Create retinotopic mask (in T1w space)
[maskFullFile,saveName] = makeMaskFromRetino(eccenMap,areasMap,anglesMap,areas,eccentricities,angles,subjectDir);

%% Register functional data to anatomical data. 
% Where is anatomical and functional data (NOTE, FUNC DATA ARE IN STANDARD SPACE):
T1Path = fullfile(subjectDir,horzcat(subjectID,'_T1.nii.gz'));

funcName = [runName num2str(runNums)];
funcDataPath = fullfile(subjectDir,subjectID,'MNINonLinear','Results',funcName,[funcName '.nii.gz']);


% Extract brain from T1 
fprintf('BET\n');
cmd = horzcat('/usr/local/fsl/bin/bet ',T1Path,' ',subjectDir,'/betT1.nii.gz');
system(cmd);

% Get scout EPI image.
fprintf('Create scout EPI image\n');
cmd = horzcat('/usr/local/fsl/bin/fslroi ',funcDataPath,' ',subjectDir,'/scoutEPI.nii.gz 0 91 0 109 0 91 0 1');
system(cmd);

% Calculate registration matrix
fprintf('Calculate registration matrix\n');
cmd = horzcat('/usr/local/fsl/bin/flirt -ref /usr/local/fsl/data/standard/MNI152_T1_2mm_brain.nii.gz -in ',subjectDir,'/betT1.nii.gz -out ',subjectDir,'/T12standard -omat ',subjectDir,'/T12standard.mat ');
system(cmd);

% Apply registration to mask
fprintf('Apply registration matrix to mask\n');
cmd = horzcat('/usr/local/fsl/bin/flirt -ref /usr/local/fsl/data/standard/MNI152_T1_2mm_brain.nii.gz -in ',maskFullFile,' -applyxfm -init ',subjectDir,'/T12standard.mat -out ',subjectDir,'/retinoMask2standard');
system(cmd);

% Binarize mask, thresholded at .2 to get rid of some noise
fprintf('Threshold and binarize mask\n');
cmd = horzcat('/usr/local/fsl/bin/fslmaths ',subjectDir,'/retinoMask2standard -thr .4 -bin ',subjectDir,'/retinoMask2standardBin');
system(cmd);



%% Spot check

% Everything (retino data, functional data) should be in MNI space. Spot
% check that with fsleyes 

cmd = horzcat('/usr/local/fsl/bin/fsleyes ', subjectDir,'/scoutEPI.nii.gz ',subjectDir,'/retinoMask2standardBin.nii.gz');
system(cmd);

%% Extract V1 timeseries

funcData = MRIread(funcDataPath);
funcData = funcData.vol;

retinoMask = MRIread(horzcat(subjectDir,'/retinoMask2standardBin.nii.gz'));
ROIindex = logical(retinoMask.vol);

v1Timeseries = zeros(1,size(funcData,4));

for i = 1:size(funcData,4)
    tempVol = funcData(:,:,:,i);
    tempVolMasked = tempVol(ROIindex);
    v1Timeseries(i) = mean(tempVolMasked,'all');
end


v1Detrend = detrend(v1Timeseries);






%% Model V1 timeseries with tFE
% Construct the model object
temporalFit = tfeIAMP('verbosity','none');


%% Temporal domain of the stimulus
deltaT = 100; % in msecs
totalTime = size(funcData,4)*TR; % in msecs.

stimulusStruct.timebase = linspace(0,totalTime-deltaT,totalTime/deltaT);
nTimeSamples = size(stimulusStruct.timebase,2);


% We will create a set of stimulus blocks, each 12 seconds in duration.
% Every 6th stimulus block (starting with the first) is a "zero frequency"
% stimulus condition and thus will serve as the reference condition for a
% linear regression model
eventTimes=[];
for ii=0:nTrials-1
    if mod(ii,6)~=0
        eventTimes(end+1) = ii*trialLength;
    end
end
nInstances=length(eventTimes);
defaultParamsInfo.nInstances = nInstances;
for ii=1:nInstances
    stimulusStruct.values(ii,:)=zeros(1,nTimeSamples);
    stimulusStruct.values(ii,(eventTimes(ii)/deltaT)+1:(eventTimes(ii)/deltaT+trialLength/deltaT))=1;
end


% Define a kernelStruct. In this case, a double gamma HRF
hrfParams.gamma1 = 6;   % positive gamma parameter (roughly, time-to-peak in secs)
hrfParams.gamma2 = 12;  % negative gamma parameter (roughly, time-to-peak in secs)
hrfParams.gammaScale = 10; % scaling factor between the positive and negative gamma componenets

kernelStruct.timebase=linspace(0,15999,16000);

% The timebase is converted to seconds within the function, as the gamma
% parameters are defined in seconds.
hrf = gampdf(kernelStruct.timebase/1000, hrfParams.gamma1, 1) - ...
    gampdf(kernelStruct.timebase/1000, hrfParams.gamma2, 1)/hrfParams.gammaScale;
kernelStruct.values=hrf;

% Normalize the kernel to have unit amplitude
[ kernelStruct ] = normalizeKernelArea( kernelStruct );



%% Initialize the response struct
responseStruct.timebase = linspace(0,totalTime-TR,totalTime/TR);
responseStruct.values = zeros(1,length(responseStruct.timebase));
responseStruct.values = v1Detrend;


%% Construct a packet and model params
thePacket.stimulus = stimulusStruct;
thePacket.response = responseStruct;
thePacket.kernel = kernelStruct;
thePacket.metaData = [];


params = temporalFit.fitResponse(thePacket,...
            'defaultParamsInfo', defaultParamsInfo, ...
            'searchMethod','linearRegression');
    
% Load Stims from this run        
stimParams = load('/Users/nfuser/Documents/rtQuest/TOME_3021/stimFreqData_Run1_01_25_2019_16_35.mat');
% Load stim frequencies that ARE NOT zero
stims = stimParams.params.stimFreq(stimParams.params.stimFreq>0);

minBOLD = min(params.paramMainMatrix);
if minBOLD < 0
    scaledBOLDresponse = params.paramMainMatrix' - minBOLD;
else
    scaledBOLDresponse = params.paramMainMatrix';
    minBOLD = 0;
end

scaledBOLDresponse = scaledBOLDresponse/max(scaledBOLDresponse);

myObj = @(p) sqrt(sum((scaledBOLDresponse-watsonTemporalModel(stims,p)).^2));
x0 = [2 2 2];
watsonParams = fmincon(myObj,x0,[],[],[],[],[0 0 0]);

stimulusFreqHzFine = logspace(0,log10(30),100);

figure; semilogx(stims,scaledBOLDresponse,'*');
xlabel('Stimulus Frequency, log');
ylabel('Arbitrary units, relative activation');
hold on; semilogx(stimulusFreqHzFine,watsonTemporalModel(stimulusFreqHzFine,watsonParams),'-k');
    
