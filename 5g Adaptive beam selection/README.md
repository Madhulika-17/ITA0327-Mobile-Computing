# Neural Network-Based Adaptive Beam Selection for Improved Mobile User Connectivity in 5G Networks

## What this project contains
- A physics-inspired 2D 5G base-station / mobile-user simulation.
- Eight directional beams and an animated interactive dashboard.
- A feedforward neural network trained with custom MATLAB backpropagation (no Deep Learning Toolbox required).
- A strongest-measured-beam baseline.
- Eight repeatable mobility/channel scenarios.
- Held-out test accuracy, confusion matrix, training loss, CSV metrics and comparison plots.

## Requirements
- MATLAB R2020a or later recommended.
- Base MATLAB only. No additional toolbox is required by the provided code.
- The project does not control a physical 5G base station or phone. It is a software simulation; real over-the-air beam management requires compatible SDR / 5G testbed hardware and protocol integration.

## Run
1. Extract the ZIP file.
2. Open MATLAB and set the Current Folder to the extracted `5G_Adaptive_Beam_Selection` directory.
3. In the Command Window run:
   `run_project`
4. The script generates a dataset, trains the neural network, evaluates a held-out test split, runs eight experiments, opens the dashboard, and saves files under `Results/`.
5. To run only the dashboard after training:
   `load('trained_beam_model.mat'); launch_dashboard(model,cfg)`

## Dashboard controls
- START / STOP: run or pause the moving mobile user.
- Speed slider: change simulated user speed.
- Blockage checkbox: enable a temporary obstruction.
- RESET USER: reset the trajectory.

## Model and feature design
The classifier input vector is:
1. normalized x coordinate
2. normalized y coordinate
3. normalized distance
4. sine of user bearing
5. cosine of user bearing
6. normalized speed
7. sine of heading
8. cosine of heading
9. blockage flag
10. normalized estimated SNR

The output is one of eight beam classes. A two-layer feedforward network uses ReLU hidden units and softmax output. Training labels are derived from the strongest modelled directional beam in the generated channel data.

## Baseline and interpretation
The baseline chooses the beam with the highest measured per-beam RSSI at each time step. The neural model predicts a beam from position, motion and channel-derived features. Because the baseline has direct access to all simulated beam measurements, it is an informed benchmark and can outperform the classifier in some conditions. Do not claim the neural model always wins. The CSV contains measured simulation outputs for the run.

## Metrics and limitations
- RSSI and SNR: model-derived link estimates.
- Throughput: Shannon-style upper-bound estimate `B*log2(1+SNR_linear)`, not measured application throughput.
- Outage: fraction of steps with selected-beam SNR below 0 dB.
- Beam switches: number of beam-index changes.
- Latency: the current comparison fields are explicitly labelled design estimates, not measured wall-clock timings. For a formal report, instrument `predict_beam` and the baseline with `tic/toc` on the target PC.
- Channel model: simplified path-loss + directional gain + blockage + random fading/shadowing; not a standards-compliant 3GPP TR 38.901 channel model.

## Files
- `run_project.m` — main entry point and configuration.
- `generate_dataset.m` — labelled dataset generation.
- `channel_model.m` — simplified directional channel model.
- `train_model.m` — neural network training.
- `predict_beam.m` — inference.
- `evaluate_model.m` — held-out evaluation and confusion matrix.
- `simulate_scenario.m` — mobility and performance simulation.
- `run_experiments.m` — eight experiments.
- `launch_dashboard.m` — interactive visual dashboard.
- `plot_experiment_results.m` — CSV and figures.

## Suggested faculty demonstration (2–3 minutes)
1. Run `run_project` and show the training output / held-out accuracy.
2. Explain that the base station is at (0,0) and has eight directional beams.
3. Press START and move the speed slider to show user movement and beam changes.
4. Enable blockage and observe the RSSI/SNR estimate change.
5. Show `Results/performance_comparison.csv` and the throughput/RSSI comparison plots.
6. Explain honestly that the environment is simulated and does not transmit or receive real 5G signals.

## Reproducibility
The random seed is fixed in `run_project.m` (`cfg.seed = 42`). The dataset and experiment runs can therefore be repeated with the same MATLAB version and random-number implementation.
