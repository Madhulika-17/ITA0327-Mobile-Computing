function [beamRSSI, snrDb] = channel_model(x, y, blocked, cfg)
% Directional-beam link model with distance loss, antenna gain,
% blockage loss and small-scale fading. Values are simulation estimates.
r = max(sqrt(x.^2 + y.^2), 1);
bearing = mod(atan2d(y,x), 360);
pathLoss = 32.4 + 20*log10(cfg.carrierGHz) + 30*log10(r);
beamRSSI = zeros(1,cfg.numBeams);
for b = 1:cfg.numBeams
    delta = abs(mod(bearing - cfg.beamAngles(b) + 180, 360) - 180);
    % Main-lobe gain with a smooth directional roll-off.
    antennaGain = 12 - min(30, 0.018*(delta.^2));
    blockageLoss = blocked * 18;
    fading = cfg.fadingStdDb * randn;
    shadow = cfg.shadowStdDb * randn;
    beamRSSI(b) = cfg.txPowerdBm + antennaGain - pathLoss ...
        - blockageLoss + fading + shadow;
end
noiseDbm = -174 + 10*log10(cfg.bandwidthMHz*1e6) + cfg.noiseFigureDb;
snrDb = max(-10, mean(beamRSSI) - noiseDbm);
end
