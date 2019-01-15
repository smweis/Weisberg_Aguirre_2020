function predictedProportions = qpWatsonTemporalModelWithNoise(frequency, params, sdNoise)
% Express the returned value from the Watson model as amplitude proportions
%
% Syntax:
%  predictedProportions = qpWatsonTemporalModelWithNoise(frequency, params, sdNoise)
%
% Description:
%	Given a frequency and the parameters of the Watson model, will return
%	the predicted proportions of a number of categories (nCategories,
%	default = 21). sdNoise is a noise parameter, corresponding to the
%	standard deviation of the number of bins in freqSupport that the
%	freqIdxInSupport can move. Essentially, we're shifting around the
%	frequency index in the support vector. 
%
%
% Examples:
%{
    
%}


freqRange=[0 64];
nCategories=21;

% Obtain the Watson model for these params across the frequency range at a
% high resolution

%defaults

freqSupport = freqRange(1):0.01:freqRange(2);
y = watsonTemporalModel(freqSupport, params);

% Where is the passed frequency value in frequence support
predictedProportions = zeros(length(frequency),nCategories);

for jj = 1:length(frequency)
    [~,freqIdxInSupport] = min(abs(freqSupport-frequency(jj)));
    freqIdxInSupport = freqIdxInSupport + sdNoise*randn;
    if freqIdxInSupport > 6401
        freqIdxInSupport = 6401;
    elseif freqIdxInSupport < 0
        freqIdxInSupport = 1;
    else
        freqIdxInSupport = round(freqIdxInSupport);
    end
    
    
% Scale the Watson model to have unit amplitude
%    y = y - min(y);
%    if max(y) ~= 0
%        y = y ./ max(y);
%    end


% Loop over the categories and report the proportion value for the
% specified frequency in each amplitude category
    catBinSize = 1 / nCategories;
    for ii = 1:nCategories
    
        categoryCenter = (ii-1)*catBinSize + catBinSize/2;
        
        distFromCatCenter = y(freqIdxInSupport) - categoryCenter;
        if ii == 1
            if distFromCatCenter < 0 
                predictedProportions(jj,ii) = 1;
            else
                predictedProportions(jj,ii) = (1 - abs(distFromCatCenter)/catBinSize); 
            end
        elseif ii == nCategories
            if distFromCatCenter > 0
                predictedProportions(jj,ii) = 1;
            else
                predictedProportions(jj,ii) = (1 - abs(distFromCatCenter)/catBinSize);
            end
        else
            predictedProportions(jj,ii) = (1 - abs(distFromCatCenter)/catBinSize);
        end
    
    end
end


predictedProportions(predictedProportions<0)=0;

end

