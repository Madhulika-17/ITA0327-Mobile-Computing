function [X, labels] = generate_dataset(cfg)
% Generate synthetic but physics-inspired training data.
% Inputs: normalized x/y, normalized distance, sin/cos bearing,
% speed, heading sin/cos, blockage indicator, SNR estimate.
% Labels are selected from the strongest modelled directional beam.
rng(cfg.seed);
N = cfg.numSamples;
X = zeros(N, 10);
labels = zeros(N,1);

for k = 1:N
    r = cfg.coverageRadius * sqrt(rand);
    theta = 2*pi*rand;
    x = r*cos(theta); y = r*sin(theta);
    speed = 0.2 + 28*rand;
    heading = 2*pi*rand;
    blocked = double(rand < 0.18);
    [beamPower, snr] = channel_model(x, y, blocked, cfg);
    bearing = atan2d(y,x);
    X(k,:) = [x/cfg.coverageRadius, y/cfg.coverageRadius, ...
        r/cfg.coverageRadius, sind(bearing), cosd(bearing), ...
        speed/30, sin(heading), cos(heading), blocked, snr/30];
    [~, labels(k)] = max(beamPower);
end
end
