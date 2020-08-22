function Weisberg_Aguirre_2020LocalHook
%  Weisberg_Aguirre_2020LocalHook
%
% Configure things for working on the Weisberg & Aguirre 2020 project.
%
% For use with the toolboxToolbox.
%
% As part of the setup process, ToolboxToolbox will copy this file to your
% ToolboxToolbox localToolboxHooks directory (minus the "Template" suffix).
% The defalt location for this would be
%   ~/localHookFolder/neurofeedbackLocalHook.m
%
% Each time you run tbUseProject('neurofeedback'), ToolboxToolbox will
% execute your local copy of this file to do setup.
%
% You should edit your local copy with values that are correct for your
% local machine, for example the output directory location.
%


%% Say hello.
fprintf('Weisberg_Aguirre_2020 local hook.\n');
projectName = 'Weisberg_Aguirre_2020';

%% Delete any old prefs
if (ispref(projectName))
    rmpref(projectName);
end

%% Specify base paths for materials and data
% currentSubjectBasePath: current subject directory on the local machine. 
% projectBasePath: directory containing neurofeedback toolbox code and data

