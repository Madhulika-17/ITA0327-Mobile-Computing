function run_project()
% Neural Network-Based Adaptive Beam Selection for Improved Mobile User Connectivity
% Toolbox-free MATLAB implementation. Tested design target: MATLAB R2020a+.
% Run: run_project

clc; close all;
fprintf('\n============================================================\n');
fprintf('  5G ADAPTIVE BEAM SELECTION - SIMULATION\n');
fprintf('============================================================\n');

cfg = default_config();
fprintf('Generating labelled channel dataset...\n');
[dataX, dataY] = generate_dataset(cfg);
fprintf('Dataset: %d samples, %d input features, %d beam classes.\n', ...
    size(dataX,1), size(dataX,2), cfg.numBeams);

fprintf('Training feedforward neural network (custom backpropagation)...\n');
model = train_model(dataX, dataY, cfg);
save('trained_beam_model.mat', 'model', 'cfg');
fprintf('Saved trained model: trained_beam_model.mat\n');

fprintf('Evaluating held-out test data...\n');
test_metrics = evaluate_model(model, dataX, dataY, cfg);
fprintf('Held-out classification accuracy: %.2f%%\n', test_metrics.accuracy*100);

fprintf('\nRunning eight simulation scenarios...\n');
experiment_results = run_experiments(model, cfg);
save('experiment_results.mat', 'experiment_results', 'test_metrics', 'cfg');

fprintf('\nOpening interactive simulation dashboard...\n');
launch_dashboard(model, cfg);

fprintf('\nGenerating final experiment plots...\n');
plot_experiment_results(experiment_results, test_metrics, cfg, model);
fprintf('\nFinished. Check the Results folder and the open dashboard.\n');
end

function cfg = default_config()
cfg.numBeams = 8;
cfg.beamAngles = (0:cfg.numBeams-1) * 360/cfg.numBeams;
cfg.coverageRadius = 100;
cfg.carrierGHz = 3.5;
cfg.bandwidthMHz = 100;
cfg.txPowerdBm = 30;
cfg.noiseFigureDb = 7;
cfg.shadowStdDb = 2.0;
cfg.fadingStdDb = 1.5;
cfg.numSamples = 12000;
cfg.hiddenUnits = 32;
cfg.epochs = 180;
cfg.learningRate = 0.025;
cfg.seed = 42;
cfg.resultsDir = 'Results';
if ~exist(cfg.resultsDir, 'dir'), mkdir(cfg.resultsDir); end
end
