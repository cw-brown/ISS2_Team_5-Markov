%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% SYMBOL MACHINE DEMONSTRATION #1
%%% Exploring basic functionality of the Symbol Machine
%%% Colorado School of Mines EENG311 - Fall 2024 - Mike Wakin
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all; close all;

%% PART 1 of 3
fprintf('======= PART 1 OF 3: sequence_demoA.mat =========\n');

% Initialize Symbol Machine with one of the provided sequences
sequenceLength = initializeSymbolMachineF24('sequence_demoA.mat',1);
% To turn off the "verbose" output... change this 1 to 0 --------^  
%
% Stepping through the sequence one symbol at a time, your job is to 
% provide the Symbol Machine with a probabilistic forecast (a pmf) for the
% next symbol in the sequence. For each symbol you will incur a penalty 
% equal to -log2(the probability you forecasted for that symbol).
% 
% Since there are 9 possible symbols (the digits 1 through 9), your pmf 
% should have 9 entries that sum to 1. One possible (but very simple) pmf 
% that you could provide the Symbol Machine would be to always forecast 
% with the uniform pmf. Here is what that would look like.
probs = [1/9 1/9 1/9 1/9 1/9 1/9 1/9 1/9 1/9];
for ii = 1:sequenceLength
    [symbol,penalty] = symbolMachineF24(probs);
end
%
% After you have forecasted all of the entries in the sequence, the
% following function gives you a report of how good your predictions were.
reportSymbolMachineF24;

% What happens if we use a different pmf for forecasting? We might incur a
% lower penalty on some symbols, but a higher penalty on some other
% symbols. On average, we might do better, but in this case we do worse.
% (In fact, this sequence was generated independently from the uniform
% distribution, and this is why forecasting with the uniform pmf gives a
% lower penalty.)
sequenceLength = initializeSymbolMachineF24('sequence_demoA.mat',1);
probs = [0.92 0.01 0.01 0.01 0.01 0.01 0.01 0.01 0.01];
for ii = 1:sequenceLength
    [symbol,penalty] = symbolMachineF24(probs);
end
reportSymbolMachineF24;

%% PART 2 of 3
fprintf('======= PART 2 OF 3: sequence_demoB.mat =========\n');

% Let's experiment with a sequence generated independently from a 
% *nonuniform*, unknown pmf. We could naively use a uniform pmf for the 
% forecasts.
sequenceLength = initializeSymbolMachineF24('sequence_demoB.mat',1);
probs = [1/9 1/9 1/9 1/9 1/9 1/9 1/9 1/9 1/9];
for ii = 1:sequenceLength
    [symbol,penalty] = symbolMachineF24(probs);
end
reportSymbolMachineF24;

% Our forecasts should be more accurate if we use a pmf that is matched to
% the actual distribution of the sequence. Supposing we don't know in 
% advance what the true pmf is, we can try to learn it along the way. 
% In the following code, we start with a uniform pmf, but as we go, we 
% reshape the pmf according to the symbols that we actually saw (up until 
% now) in the sequence. Note that we incur a lower total penalty than when 
% we used the uniform pmf.
sequenceLength = initializeSymbolMachineF24('sequence_demoB.mat',1);
symbolCounts = ones(1,9); 
for ii = 1:sequenceLength
    probs = symbolCounts/sum(symbolCounts);
    [thisSymbol,penalty] = symbolMachineF24(probs);
    symbolCounts(thisSymbol) = symbolCounts(thisSymbol) + 1;
end
reportSymbolMachineF24;

%% PART 3 of 3
fprintf('======= PART 3 OF 3: sequence_demoC.mat =========\n');

% The final demo sequence is more of a "time series", where similar values
% tend to occur after one another. The code below uses a simple method for
% forecasting the next symbol, putting high probability on values that were
% similar to the last symbol. In the future, you will have access to
% "training" and "testing" datasets, so you can use the training data to
% get a sense of what sort of forecasting model might be most effective.
sequenceLength = initializeSymbolMachineF24('sequence_demoC.mat',1);
probs = [1/9 1/9 1/9 1/9 1/9 1/9 1/9 1/9 1/9];
for ii = 1:sequenceLength
    [symbol,penalty] = symbolMachineF24(probs);
    probs = ones(1,9);
    probs(symbol) = 7;
    if symbol < 9
        probs(symbol+1) = 3;
    end
    if symbol > 1
        probs(symbol-1) = 3;
    end
    probs = probs/sum(probs);
end
reportSymbolMachineF24;
