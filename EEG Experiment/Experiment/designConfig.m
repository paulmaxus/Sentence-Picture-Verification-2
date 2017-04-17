function [expDes]=designConfig(const)
% ----------------------------------------------------------------------
% Goal of the function :
% Experimental Design
% ----------------------------------------------------------------------
% Input(s) :
% const
% ----------------------------------------------------------------------
% Output(s):
% expDes is the design object
% ----------------------------------------------------------------------

%% Experimental variables

% Var 1 : Polarity
expDes.oneV =[0;1];

% Var 2 : Truth value
expDes.twoV = [0;1];

% Var 3 : Adjective position: which attribute is in focus, binary or
% ternary?
expDes.threeV = [0;1];
    %  0 = shape-color
    %  1 = color-shape

% Var 4 : Shape
expDes.fourV = [0;1];
    %  0 = circular
    %  1 = rectangular

% Var 5 : Color
expDes.fiveV = [0;1];
    %  0 = black
    %  1 = white

% Var 6: Relevant object position in the picture
expDes.sixV = [0;1];
    %  0 = left
    %  1 = right

%% Experimental configuration

expDes.var1_list = expDes.oneV;
expDes.nb_var1= numel(expDes.var1_list);

expDes.var2_list = expDes.twoV;
expDes.nb_var2= numel(expDes.var2_list);

expDes.var3_list = expDes.threeV;
expDes.nb_var3= numel(expDes.var3_list);

expDes.var4_list = expDes.fourV;
expDes.nb_var4= numel(expDes.var4_list);

expDes.var5_list = expDes.fiveV;
expDes.nb_var5= numel(expDes.var5_list);

expDes.var6_list = expDes.sixV;
expDes.nb_var6= numel(expDes.var6_list);

expDes.nb_var  = 6; % number of variables

% number of trials
expDes.nb_trials = expDes.nb_var1 * expDes.nb_var2 * expDes.nb_var3 * expDes.nb_var4 * expDes.nb_var5 * expDes.nb_var6;

%% Experimental loop
% build design matrix based on the number of trials and the variable so
% that for each trial you know the variable settings
trialMat = zeros((expDes.nb_trials),expDes.nb_var+2);
ii = 0;
for iv1=1:expDes.nb_var1
    for iv2=1:expDes.nb_var2
        for iv3=1:expDes.nb_var3
            for iv4=1:expDes.nb_var4
                for iv5=1:expDes.nb_var5
                    for iv6=1:expDes.nb_var6
                        ii = ii + 1;
                        trialMat(ii, 1) = iv1-1;
                        trialMat(ii, 2) = iv2-1;
                        trialMat(ii, 3) = iv3-1;
                        trialMat(ii, 4) = iv4-1;
                        trialMat(ii, 5) = iv5-1;
                        trialMat(ii, 6) = iv6-1;
                    end
                end
            end
        end
    end
end

% Read trigger codes for each trial from table and add as columns (sentence
% codes and picture codes)
scodes = readtable('SentenceCodesNumber.csv');
pcodes = readtable('PictureCodesNumber.csv');
for t = 1:expDes.nb_trials
    % extract sentence code that matches current trials polarity and order
    % variable (indices are +1 in the encoding table
    srow = scodes.Polarity == trialMat(t,1)+1 & scodes.Order == trialMat(t,3)+1;
    scode = scodes.code(srow);
    % extract picture code
    prow = pcodes.Polarity == trialMat(t,1)+1 & pcodes.Truth == trialMat(t,2)+1 ...
        & pcodes.Order == trialMat(t,3)+1 & pcodes.SjPos == trialMat(t,6)+1 ...
        & pcodes.Color == trialMat(t,5)+1 & pcodes.Shape == trialMat(t,4)+1;
    pcode = pcodes.code(prow);
    % add sentence and picture codes code to trial matrix
    trialMat(t,:) = [trialMat(t,1:6), scode, pcode]; % codes are 7 and 8
end

% Randomize trial matrix: Block 1
trialMat1 = trialMat(randperm((expDes.nb_trials)),:);

% Randomize trial matrix: Block 2
trialMat2 = trialMat(randperm((expDes.nb_trials)),:);

% Put both blocks in one matrix
expDes.expMat = [trialMat1; trialMat2];
%csvwrite('trials.csv', expDes.expMat);

%% Practice

expDes.pracNb = 8; % Amount of practice trials

% Pick random trials (half aff, half neg) from trial matrix and keep their indices for practice run

% First block
pracVec1 = []; % trial matrix indices
aff = 1;
neg = 1;

while aff <= ((expDes.pracNb) / 2)
    randT = randi([1 (expDes.nb_trials / 2)]);
    trial = expDes.expMat(randT,:);
    if trial(1) == 1 % check if trial is affirmative
        pracVec1 = [pracVec1,randT];
        aff = aff+1;
    end
end

while neg <= ((expDes.pracNb) / 2)
    randT = randi([1 (expDes.nb_trials / 2)]);
    trial = expDes.expMat(randT,:);
    if trial(1) == 0
        pracVec1 = [pracVec1,randT];
        neg = neg+1;
    end
end

expDes.pracVec1 = pracVec1;

end
