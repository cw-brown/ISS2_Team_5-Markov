%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% SYMBOL MACHINE DEMONSTRATION #2
%%% More advanced modeling with the Symbol Machine
%%% Colorado School of Mines EENG311 - Fall 2024 - Mike Wakin
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% PART 1 of 4
fprintf('======= PART 1 OF 4 =========\n');

% Let's use some real data: the daily maximum temperature at Denver 
% International Airport. Training set uses dates 1995-03-01 to 2013-03-31; 
% testing set uses dates 2014-01-01 to 2022-12-31. Symbol key: 1 = 2F or 
% below; 2 = 2F to 16F; 3 = 16F to 30F; 4 = 30F to 44F; 5 = 44F to 58F; 
% 6 = 58F to 72F; 7 = 72F to 86F; 8 = 86F to 100F; 9 = 100F or above. 
% Data from GHCN (Global Historical Climatology Network)-Daily.

% We'll develop our model and optimize our forecasts using the TRAINING
% dataset, then we can deploy the optimized model on the TESTING dataset.
sequenceLength = initializeSymbolMachineF24('sequence_DIAtemp_train.mat',0);

% We don't expect a uniform probability forecast to work very well; let's
% try it just as a baseline for comparing our later methods.
probs = [1/9 1/9 1/9 1/9 1/9 1/9 1/9 1/9 1/9];
for ii = 1:sequenceLength
    [symbol,penalty] = symbolMachineF24(probs);
end
reportSymbolMachineF24;

%% PART 2 of 4
fprintf('======= PART 2 OF 4 =========\n');

% What if we try to LEARN a nonuniform pmf based on the training data? 
% We are allowed to treat the training data as "past data" that we can use 
% for training such a model. So it is OK to use the LOAD command on the
% TRAINING data for building a model, but we should NEVER USE THE LOAD
% COMMAND ON AN ACTUAL SET OF TEST DATA.
clear all;
load sequence_DIAtemp_train.mat; % OK because this is TRAINING data

% Now let's step through the training sequence one symbol at a time and 
% learn a nonuniform pmf. Since we've loaded the whole training sequence 
% into the Matlab Workspace, we don't need to interact with the Symbol 
% Machine for this part.
sequenceLength = length(sequence);
symbolCounts = ones(1,9); 
for ii = 1:sequenceLength
    thisSymbol = sequence(ii);
    symbolCounts(thisSymbol) = symbolCounts(thisSymbol) + 1;
end
probs = symbolCounts/sum(symbolCounts);
figure(1);clf;
h = stem(probs);set(h,'LineWidth',2);title('Learned from training data');
xlabel('symbol s'); ylabel('p_S(s)');

% Now let's use the nonuniform pmf that we just learned as a forecasting 
% model for the training data. 
sequenceLength = initializeSymbolMachineF24('sequence_DIAtemp_train.mat',0);
for ii = 1:sequenceLength
    [symbol,penalty] = symbolMachineF24(probs);
end
reportSymbolMachineF24;
% We reduced the penalty from 20940.525 bits (3.1699 bits per symbol) to 
% 16676.694 bits (2.5245 bits per symbol)!

%% PART 3 of 4
fprintf('======= PART 3 OF 4 =========\n');

% There are many ways that we can develop even more powerful models. 
% To some degree, the best type of model will depend on the type of data.
% For the DIATemp data, for example, we might find it helpful to use
% conditional probability in our forecasting: every day is NOT independent
% from the days preceding it (even accounting for the nonuniform pmf).

% Just like we did with the Dickens corpus, let's learn a conditional
% probability model (from the training data) for the pmf of a symbol
% conditioned on the symbol that preceded it.
clear all;
load sequence_DIAtemp_train.mat; % OK because this is TRAINING data
sequenceLength = length(sequence);
symbolCounts = ones(9,9);
for ii = 2:sequenceLength
    currentSymbol = sequence(ii);
    precedingSymbol = sequence(ii-1);
    symbolCounts(precedingSymbol,currentSymbol) = ...
        symbolCounts(precedingSymbol,currentSymbol) + 1;
end
probMatrix = symbolCounts;
for ii = 1:9
    probMatrix(ii,:) = probMatrix(ii,:)/sum(probMatrix(ii,:));
end
% Each row of probMatrix is a conditional pmf (which sums to 1)
figure(2);clf;
imagesc(probMatrix);colorbar;title('Learned from training data');
ylabel('preceding symbol');
xlabel('forecasted symbol');

% Now let's use the conditional pmfs that we just learned for forecasting 
% the training data. 
sequenceLength = initializeSymbolMachineF24('sequence_DIAtemp_train.mat',0);
% We can start with a uniform forecast for the first symbol
probs = [1/9 1/9 1/9 1/9 1/9 1/9 1/9 1/9 1/9];
[symbol,penalty] = symbolMachineF24(probs);
for ii = 2:sequenceLength
    % For each subsequent symbol, we can base our forecast on the preceding
    % symbol (which was given to us by the Symbol Machine)
    [symbol,penalty] = symbolMachineF24(probMatrix(symbol,:));
    %                                   
end
reportSymbolMachineF24;
% You should now see a total penalty of just 10970.599 bits (1.6607 bits 
% per symbol). Quite a bit better! Make sure your code is working
% properly (i.e., you are getting this total penalty of 10970.599 bits) 
% before moving on.

%% PART 4 of 4
fprintf('======= PART 4 OF 4 =========\n');

% Now that we've done some development and optimizing our model on the
% TRAINING dataset, we're ready to deploy it on the TESTING dataset.
% Specifically, we can use the conditional pmfs we learned from training 
% data to forecast the testing data. 
sequenceLength = initializeSymbolMachineF24('sequence_DIAtemp_test.mat',0);
% We can start with a uniform forecast for the first symbol
probs = [1/9 1/9 1/9 1/9 1/9 1/9 1/9 1/9 1/9];
[symbol,penalty] = symbolMachineF24(probs);
for ii = 2:sequenceLength
    % For each subsequent symbol, we can base our forecast on the preceding
    % symbol (which was given to us by the Symbol Machine)
    [symbol,penalty] = symbolMachineF24(probMatrix(symbol,:));
    %                                   ^^^ INSERT YOUR CODE HERE!
end
reportSymbolMachineF24;
% Email Prof. Wakin the SYMBOL MACHINE REPORT that is created for this last
% part (PART 4 of 4). If you have any questions about getting the code to 
% work, please ask!
