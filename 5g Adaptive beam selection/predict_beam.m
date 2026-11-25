function [beamIndex, probabilities] = predict_beam(model, featureRow)
% Return one-based beam index and class probabilities.
xn = (featureRow-model.mu)./model.sigma;
z1 = max(0,xn*model.W1+model.b1);
z2 = z1*model.W2+model.b2;
z2 = z2-max(z2,[],2);
probabilities = exp(z2)./sum(exp(z2),2);
[~,beamIndex] = max(probabilities,[],2);
end
