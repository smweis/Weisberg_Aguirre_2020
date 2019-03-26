function [tfeObj, thePacket] = tfeInit(varargin)
% My description
%
% Syntax:
%  [tfeObj, thePacket] = tfeInit(, varargin)
%
% Description:
%	.
%
% Inputs:
%   sceneGeometry         - Structure. SEE: createSceneGeometry
%
% Optional key/value pairs:
%  'eyePoseLB/UB'         - A 1x4 vector that provides the lower (upper)

%
% Outputs:
%   tfeObj               - Object handle
%   thePacket            - Structure.
%
% Examples:
%{

%}


%% Parse input
p = inputParser;

% Required input
%p.addRequired('sceneGeometry',@isstruct);

% Optional params
p.addParameter('nTrials', 25, @isscalar);
p.addParameter('trialLengthSecs', 12, @isscalar);
p.addParameter('baselineTrialRate', 6, @isscalar);
p.addParameter('verbose', false, @islogical);

% Parse and check the parameters
p.parse( varargin{:});

%% Construct the model object
tfeObj = tfeIAMP('verbosity','none');


%% Temporal domain of the stimulus
deltaT = 100; % in msecs
totalTime = p.Results.nTrials*p.Results.trialLengthSecs*1000; % in msecs.
eventDuration = p.Results.trialLengthSecs*1000; % block duration in msecs

% Define the timebase
stimulusStruct.timebase = linspace(0,totalTime-deltaT,totalTime/deltaT);
nTimeSamples = size(stimulusStruct.timebase,2);

% Create the stimulus struct
nEvents = 0;
eventTimes=[];
for ii=1:(p.Results.nTrials)
    if mod(ii-1,p.Results.baselineTrialRate)~=0
        nEvents = nEvents+1;
        eventTimes(nEvents) = (ii-1)*eventDuration;
        stimulusStruct.values(nEvents,:)=zeros(1,nTimeSamples);
        stimulusStruct.values(nEvents,(eventTimes(nEvents)/deltaT)+1:eventTimes(nEvents)/deltaT+eventDuration/deltaT)=1;
    end
end

%% Define a kernelStruct. In this case, a double gamma HRF
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



%% Construct a packet and model params
thePacket.stimulus = stimulusStruct;
thePacket.response = [];
thePacket.kernel = kernelStruct;
thePacket.metaData = [];


end