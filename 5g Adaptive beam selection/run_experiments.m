function results = run_experiments(model,cfg)
names={'Stationary user','Straight path','Direction changes','High speed', ...
    'Obstacle blockage','Changing channel','NN vs baseline trace','Low-SNR cell edge'};
results=cell(8,1);
for s=1:8
    fprintf('  Experiment %d/8: %s\n',s,names{s});
    results{s}=simulate_scenario(model,cfg,s,false);
    results{s}.name=names{s};
end
end
