load("lotery_27_11.mat")

%% PA Model
% Define variables
M = 4; % Number of memory samples, you can change this
numHiddenLayers = 5; % Number of hidden layers, you can change this
numNeurons = 20; % Number of neurons in each hidden layer, you can change this

% Assuming your complex signals are stored in vectors: inputSignal and outputSignal
inputSignal = sig_in;
outputSignal = sig_out;

% Separate real and imaginary parts
realInput = real(inputSignal);
imagInput = imag(inputSignal);
realOutput = real(outputSignal);
imagOutput = imag(outputSignal);

% Prepare input matrix with memory samples
inputMatrixModel = [];
for k = M:length(realInput)
    inputSample = [];
    for j = 0:M-1
        inputSample = [inputSample, realInput(k-j), imagInput(k-j)];
    end
    inputMatrixModel = [inputMatrixModel; inputSample];
end



% Prepare output matrix
outputMatrixModel = [realOutput(M:end)'; imagOutput(M:end)'];

% Define the neural network
inputSize = 2 * M;
outputSize = 2;

layers = [
    featureInputLayer(inputSize)
];


% Add hidden layers
for i = 1:numHiddenLayers
    layers = [layers; fullyConnectedLayer(numNeurons); reluLayer];
end

% Add output layer
layers = [layers;
    fullyConnectedLayer(outputSize);
    regressionLayer];

% Create the network
pa_net = layerGraph(layers);

% Set training options
options = trainingOptions('adam', ...
    'MaxEpochs', 20, ...
    'MiniBatchSize', 64, ...
    'Shuffle', 'every-epoch', ...
    'Plots', 'training-progress', ...
    'Verbose', false);

% Train the network
pa_net = trainNetwork(inputMatrixModel, outputMatrixModel', pa_net, options);

% Predict using the trained network
predictedOutput = predict(pa_net, inputMatrixModel);

% Post-process the predicted output
realPredicted = predictedOutput(:, 1);
imagPredicted = predictedOutput(:, 2);

% Combine real and imaginary parts
complexPredictedOutput = realPredicted + 1i * imagPredicted;

% Actual output
realActual = realOutput(M:end);
imagActual = imagOutput(M:end);
complexActualOutput = realActual + 1i * imagActual;

%% Plot the PA Model results
Input_signal = sig_in(M:end);
Output_signal = complexActualOutput;
Output_no_DPD_estimated = complexPredictedOutput;
close all;
figure;
subplot(2, 1, 1);
plot(realActual, 'b'); hold on;
plot(realPredicted, 'r--');
title('Real Part');
legend('True', 'Predicted');

subplot(2, 1, 2);
plot(imagActual, 'b'); hold on;
plot(imagPredicted, 'r--');
title('Imaginary Part');
legend('True', 'Predicted');

if 1 % Plot AM/AM - AM/PM core
    figure; subplot(2,1,1); hold on; grid on;
    % 1. AM/AM RAW data 
    plot(10.*log10((abs(Input_signal)).^2/50*1000), ...
            20*log10( abs(Output_signal) ./ abs(Input_signal) ),'or','MarkerSize',2);
    % 2. AM/AM Fitted data
    plot(10.*log10(abs(sig_in(M:end)).^2/50*1000), ...
                20*log10(abs(Output_no_DPD_estimated)./abs(Input_signal)),'kx','MarkerSize',5);   
    axis([ -10 20 -10 5]);
    title('AM2AM Results'); xlabel('Pout [dBm]'); ylabel('AM/AM [dB]');

    subplot(2,1,2);  hold on; grid on;
    % 1. AM/PM RAW data 
    plot(10.*log10(abs(Input_signal).^2/50*1000), ...
             ( angle(Output_signal ./ Input_signal ) )./pi*180,'or','MarkerSize',2);        
    % 2. AM/PM Fitted data
    plot(10.*log10(abs(Input_signal).^2/50*1000), ...
            (angle(Output_no_DPD_estimated./Input_signal))./pi*180,'kx','MarkerSize',5);        
    xlabel('Pout [dBm]'); ylabel('AM/PM [Degrees]'); 
    title(['AM2PM Results']); axis([-10 20 -50 50]);    
end

% Performance
% Assuming 'predictedOutput' and 'outputMatrixModel' are already computed


% Combine real and imaginary parts
complexPredictedOutput = realPredicted + 1i * imagPredicted;


% Calculate performance metrics
mseReal = mean((realPredicted - realActual).^2);
mseImag = mean((imagPredicted - imagActual).^2);
maeReal = mean(abs(realPredicted - realActual));
maeImag = mean(abs(imagPredicted - imagActual));

% Display performance
fprintf('Performance Metrics:\n');
fprintf('MSE (Real Part): %.4f\n', mseReal);
fprintf('MSE (Imaginary Part): %.4f\n', mseImag);
fprintf('MAE (Real Part): %.4f\n', maeReal);
fprintf('MAE (Imaginary Part): %.4f\n', maeImag);


%% DPD

% Define variables
M = 4; % Number of memory samples, you can change this
numHiddenLayers = 5; % Number of hidden layers, you can change this
numNeurons = 20; % Number of neurons in each hidden layer, you can change this

% Assuming your complex signals are stored in vectors: inputSignal and outputSignal
inputSignal = sig_in;
outputSignal = sig_out;

% Separate real and imaginary parts
realInput = real(inputSignal);
imagInput = imag(inputSignal);
realOutput = real(outputSignal);
imagOutput = imag(outputSignal);

% Prepare input matrix with memory samples from the output signal
inputMatrixDPD = [];
for k = M:length(realOutput)
    inputSample = [];
    for j = 0:M-1
        inputSample = [inputSample, realOutput(k-j), imagOutput(k-j)];
    end
    inputMatrixDPD = [inputMatrixDPD; inputSample];
end

% Prepare output matrix from the input signal
outputMatrixDPD = [realInput(M:end)'; imagInput(M:end)'];

% Define the neural network
inputSize = 2 * M;
outputSize = 2;

layers = [
    featureInputLayer(inputSize)
];

% Add hidden layers
for i = 1:numHiddenLayers
    layers = [layers; fullyConnectedLayer(numNeurons); reluLayer];
end

% Add output layer
layers = [layers;
    fullyConnectedLayer(outputSize);
    regressionLayer];

% Create the network
dpd_net = layerGraph(layers);

% Set training options
options = trainingOptions('adam', ...
    'MaxEpochs', 20, ...
    'MiniBatchSize', 64, ...
    'Shuffle', 'every-epoch', ...
    'Plots', 'training-progress', ...
    'Verbose', false);

% Train the network
dpd_net = trainNetwork(inputMatrixDPD, outputMatrixDPD', dpd_net, options);

% Predict using the trained network
predictedOutput = predict(dpd_net, inputMatrixDPD);

% Post-process the predicted output
realPredicted = predictedOutput(:, 1);
imagPredicted = predictedOutput(:, 2);

% Combine real and imaginary parts
complexPredictedInput = realPredicted + 1i * imagPredicted;

% Actual output
realActual = realInput(M:end);
imagActual = imagInput(M:end);
complexActualOutput = realActual + 1i * imagActual;

%% Run signal through DPD and PA Model

% Use the trained DPD network to predict the DPD output
dpdPredictedOutput = predict(dpd_net, inputMatrixModel); % Use inputMatrixModel built from sig_in

% Post-process the predicted DPD output
realDPDPredicted = dpdPredictedOutput(:, 1);
imagDPDPredicted = dpdPredictedOutput(:, 2);

% Combine real and imaginary parts to get the complex DPD predicted output
complexDPDPredictedOutput = realDPDPredicted + 1i * imagDPDPredicted;

% Prepare input matrix for the PA model using the DPD output
inputMatrixPAModel = [];
for k = M:length(realDPDPredicted)
    inputSample = [];
    for j = 0:M-1
        inputSample = [inputSample, realDPDPredicted(k-j), imagDPDPredicted(k-j)];
    end
    inputMatrixPAModel = [inputMatrixPAModel; inputSample];
end

% Use the trained PA network to predict the PA output
paPredictedOutput = predict(pa_net, inputMatrixPAModel);

% Post-process the predicted PA output
realPAPredicted = paPredictedOutput(:, 1);
imagPAPredicted = paPredictedOutput(:, 2);

% Combine real and imaginary parts to get the complex PA predicted output
complexPAPredictedOutput = realPAPredicted + 1i * imagPAPredicted;

% Actual output
realInputActual = realInput(M + M - 1:end);
imagInputActual = imagInput(M + M - 1:end);
complexInputActual = realInputActual + 1i * imagInputActual;

% Adjust the output signal to match the length of the PA predicted output
adjustedRealOutput = realOutput(M + M - 1:end);
adjustedImagOutput = imagOutput(M + M - 1:end);

% Plot the comparison
figure;
subplot(2, 1, 1);
plot(realInputActual, 'b'); hold on;
plot(realPAPredicted, 'r--');
plot(adjustedRealOutput, 'g-.');
title('Real Part - Input vs PA Predicted vs Output');
legend('Input Signal', 'PA Predicted', 'Output Signal');

subplot(2, 1, 2);
plot(imagInputActual, 'b'); hold on;
plot(imagPAPredicted, 'r--');
plot(adjustedImagOutput, 'g-.');
title('Imaginary Part - Input vs PA Predicted vs Output');
legend('Input Signal', 'PA Predicted', 'Output Signal');

%% Performance

% Calculate performance metrics for sig_in vs paPredictedOutput
mseRealPAPredicted = mean((realPAPredicted - realInputActual).^2);
mseImagPAPredicted = mean((imagPAPredicted - imagInputActual).^2);
maeRealPAPredicted = mean(abs(realPAPredicted - realInputActual));
maeImagPAPredicted = mean(abs(imagPAPredicted - imagInputActual));

% Calculate performance metrics for sig_in vs sig_out
mseRealSigOut = mean((adjustedRealOutput - realInputActual).^2);
mseImagSigOut = mean((adjustedImagOutput - imagInputActual).^2);
maeRealSigOut = mean(abs(adjustedRealOutput - realInputActual));
maeImagSigOut = mean(abs(adjustedImagOutput - imagInputActual));

% Calculate EVM for sig_in vs paPredictedOutput
evmRealPAPredicted = sqrt(mean((realPAPredicted - realInputActual).^2)) / mean(abs(realInputActual)) * 100;
evmImagPAPredicted = sqrt(mean((imagPAPredicted - imagInputActual).^2)) / mean(abs(imagInputActual)) * 100;

% Calculate EVM for sig_in vs sig_out
evmRealSigOut = sqrt(mean((adjustedRealOutput - realInputActual).^2)) / mean(abs(realInputActual)) * 100;
evmImagSigOut = sqrt(mean((adjustedImagOutput - imagInputActual).^2)) / mean(abs(imagInputActual)) * 100;

fprintf("\n");

fprintf('\nPerformance Metrics for X vs Y without DPD:\n');
fprintf('MSE (Real Part): %.4f\n', mseRealSigOut);
fprintf('MSE (Imaginary Part): %.4f\n', mseImagSigOut);
fprintf('MAE (Real Part): %.4f\n', maeRealSigOut);
fprintf('MAE (Imaginary Part): %.4f\n', maeImagSigOut);
fprintf('EVM (Real Part): %.4f%%\n', evmRealSigOut);
fprintf('EVM (Imaginary Part): %.4f%%\n', evmImagSigOut);

fprintf('\nPerformance Metrics for X vs Y with DPD:\n');
fprintf('MSE (Real Part): %.4f\n', mseRealPAPredicted);
fprintf('MSE (Imaginary Part): %.4f\n', mseImagPAPredicted);
fprintf('MAE (Real Part): %.4f\n', maeRealPAPredicted);
fprintf('MAE (Imaginary Part): %.4f\n', maeImagPAPredicted);
fprintf('EVM (Real Part): %.4f%%\n', evmRealPAPredicted);
fprintf('EVM (Imaginary Part): %.4f%%\n', evmImagPAPredicted);

%% Plot AM/AM - AM/PM after DPD
if 1
    figure; subplot(2,1,1); hold on; grid on;
    % AM/AM after DPD and PA
    plot(10.*log10((abs(complexDPDPredictedOutput)).^2/50*1000), ...
            20*log10( abs(complexPAPredictedOutput) ./ abs(complexDPDPredictedOutput) ),'or','MarkerSize',2);
    axis([ -10 20 -10 5]);
    title('AM2AM Results after DPD and PA'); xlabel('Pout [dBm]'); ylabel('AM/AM [dB]');

    subplot(2,1,2);  hold on; grid on;
    % AM/PM after DPD and PA
    plot(10.*log10(abs(complexDPDPredictedOutput).^2/50*1000), ...
             ( angle(complexPAPredictedOutput ./ complexDPDPredictedOutput ) )./pi*180,'or','MarkerSize',2);        
    xlabel('Pout [dBm]'); ylabel('AM/PM [Degrees]'); 
    title(['AM2PM Results after DPD and PA']); axis([-10 20 -50 50]);    
end

% Display performance metrics
mseReal = mean((realPAPredicted - realActual).^2);
mseImag = mean((imagPAPredicted - imagActual).^2);
maeReal = mean(abs(realPAPredicted - realActual));
maeImag = mean(abs(imagPAPredicted - imagActual));

fprintf('Performance Metrics After DPD and PA:\n');
fprintf('MSE (Real Part): %.4f\n', mseReal);
fprintf('MSE (Imaginary Part): %.4f\n', mseImag);
fprintf('MAE (Real Part): %.4f\n', maeReal);
fprintf('MAE (Imaginary Part): %.4f\n', maeImag);


