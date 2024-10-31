%% Markov Chain Analysis
load sequence_demoC.mat
train_data = sequence;
n = length(train_data);
stochas = zeros(9, 9);
for ii = 1:n-1
    from = train_data(ii);
    to = train_data(ii+1);
    stochas(from, to) = stochas(from, to) + 1;
end
stochas = stochas/n;
stochas = stochas + eps; % Cheat a little
stochas = stochas./sum(stochas, 2);

seqlength = initializeSymbolMachineF24('sequence_demoC.mat', 1);
for ii = 1:seqlength
    if ii == 1
        probs = [1/9 1/9 1/9 1/9 1/9 1/9 1/9 1/9 1/9];
    else
        stx = zeros(1, 9);
        stx(symbol) = 1;
        probs = stx*stochas;
    end
    [symbol, penalty] = symbolMachineF24(probs);
end
reportSymbolMachineF24;