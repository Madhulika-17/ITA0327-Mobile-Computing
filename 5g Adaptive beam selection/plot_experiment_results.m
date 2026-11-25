function plot_experiment_results(results,testMetrics,cfg,model)
out=cfg.resultsDir;
% Summary table
n=numel(results);
Scenario=strings(n,1); RSSI_NN=zeros(n,1); RSSI_Baseline=zeros(n,1);
SNR_NN=zeros(n,1); SNR_Baseline=zeros(n,1);
Throughput_NN_Mbps=zeros(n,1); Throughput_Baseline_Mbps=zeros(n,1);
Switches_NN=zeros(n,1); Switches_Baseline=zeros(n,1);
Outage_NN=zeros(n,1); Outage_Baseline=zeros(n,1);
for i=1:n
 r=results{i}; Scenario(i)=string(r.name);
 RSSI_NN(i)=r.meanRSSNN; RSSI_Baseline(i)=r.meanRSSBaseline;
 SNR_NN(i)=r.meanSNRNN; SNR_Baseline(i)=r.meanSNRBaseline;
 Throughput_NN_Mbps(i)=r.meanThroughputNN; Throughput_Baseline_Mbps(i)=r.meanThroughputBaseline;
 Switches_NN(i)=r.switchesNN; Switches_Baseline(i)=r.switchesBaseline;
 Outage_NN(i)=r.outageNN; Outage_Baseline(i)=r.outageBaseline;
end
T=table(Scenario,RSSI_NN,RSSI_Baseline,SNR_NN,SNR_Baseline, ...
 Throughput_NN_Mbps,Throughput_Baseline_Mbps,Switches_NN,Switches_Baseline, ...
 Outage_NN,Outage_Baseline);
writetable(T,fullfile(out,'performance_comparison.csv'));
figure('Color','w','Name','Scenario throughput comparison');
bar([Throughput_NN_Mbps Throughput_Baseline_Mbps]); grid on;
set(gca,'XTickLabel',cellstr(Scenario),'XTickLabelRotation',25);
ylabel('Mean throughput (Mbps)'); legend('Neural network','Strongest measured beam','Location','best');
title('Throughput by scenario');
saveas(gcf,fullfile(out,'throughput_comparison.png'));
figure('Color','w','Name','Scenario RSSI comparison');
bar([RSSI_NN RSSI_Baseline]); grid on;
set(gca,'XTickLabel',cellstr(Scenario),'XTickLabelRotation',25);
ylabel('Mean selected-beam RSSI (dBm)'); legend('Neural network','Strongest measured beam','Location','best');
title('Selected-beam RSSI by scenario');
saveas(gcf,fullfile(out,'rssi_comparison.png'));
figure('Color','w','Name','Training history');
subplot(2,1,1); imagesc(testMetrics.confusion); colorbar; xlabel('Predicted beam'); ylabel('True beam');
title(sprintf('Held-out confusion matrix (accuracy %.1f%%)',100*testMetrics.accuracy));
subplot(2,1,2); plot(1:numel(model.lossHistory),model.lossHistory);
xlabel('Epoch'); ylabel('Training cross-entropy'); grid on; title('Neural network training loss');
saveas(gcf,fullfile(out,'training_and_confusion.png'));
fprintf('Saved CSV and plots under %s\\n',out);
end
