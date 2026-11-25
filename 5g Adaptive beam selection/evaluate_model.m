function metrics = evaluate_model(model, X, labels, cfg)
% Evaluate on the deterministic held-out 15% test partition.
rng(cfg.seed);
N=size(X,1); perm=randperm(N);
nTrain=floor(.70*N); nVal=floor(.15*N);
testIds=perm(nTrain+nVal+1:end);
pred=zeros(numel(testIds),1);
for i=1:numel(testIds)
    pred(i)=predict_beam(model,X(testIds(i),:));
end
truth=labels(testIds);
metrics.accuracy=mean(pred==truth);
metrics.confusion=zeros(cfg.numBeams);
for i=1:numel(truth)
    metrics.confusion(truth(i),pred(i))=metrics.confusion(truth(i),pred(i))+1;
end
metrics.predictions=pred; metrics.truth=truth;
metrics.testCount=numel(testIds);
end
