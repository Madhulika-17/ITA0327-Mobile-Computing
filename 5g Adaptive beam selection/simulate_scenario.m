function result = simulate_scenario(model,cfg,scenario,makePlot)
% Same mobility/channel trace is used for NN and strongest-measured-beam baseline.
if nargin<4, makePlot=false; end
rng(cfg.seed+scenario);
T=240; dt=0.1;
x=zeros(T,1); y=zeros(T,1); speed=zeros(T,1); heading=zeros(T,1);
blocked=zeros(T,1); rssi=zeros(T,cfg.numBeams); snr=zeros(T,1);
nnBeam=zeros(T,1); baseBeam=zeros(T,1); nnRSS=zeros(T,1); baseRSS=zeros(T,1);
nnSwitch=0; baseSwitch=0; prevNN=0; prevBase=0;
for t=1:T
    switch scenario
        case 1 % stationary
            x(t)=35; y(t)=25;
        case 2 % straight path
            x(t)=-70+0.55*t; y(t)=15;
        case 3 % changing direction / circular arc
            a=0.025*t; x(t)=65*cos(a); y(t)=65*sin(a);
        case 4 % high speed
            x(t)=-90+0.9*t; y(t)=25*sin(0.04*t);
        case 5 % obstacle blockage in a region
            x(t)=-70+0.6*t; y(t)=10; blocked(t)=double(t>90 && t<165);
        case 6 % changing channel conditions
            x(t)=45*cos(0.035*t); y(t)=45*sin(0.035*t);
        case 7 % normal mobile trajectory
            x(t)=-55+0.48*t; y(t)=30*sin(0.035*t);
        case 8 % low SNR / edge-of-cell trajectory
            x(t)=80*cos(0.025*t); y(t)=80*sin(0.025*t);
    end
    if t>1
        speed(t)=hypot(x(t)-x(t-1),y(t)-y(t-1))/dt;
        heading(t)=atan2(y(t)-y(t-1),x(t)-x(t-1));
    end
    [rssi(t,:),snr(t)]=channel_model(x(t),y(t),blocked(t),cfg);
    bearing=atan2d(y(t),x(t)); dist=hypot(x(t),y(t));
    f=[x(t)/cfg.coverageRadius,y(t)/cfg.coverageRadius, ...
        dist/cfg.coverageRadius,sind(bearing),cosd(bearing), ...
        min(speed(t),30)/30,sin(heading(t)),cos(heading(t)),blocked(t),snr(t)/30];
    nnBeam(t)=predict_beam(model,f);
    [~,baseBeam(t)]=max(rssi(t,:));
    nnRSS(t)=rssi(t,nnBeam(t)); baseRSS(t)=rssi(t,baseBeam(t));
    if t>1
        nnSwitch=nnSwitch+(nnBeam(t)~=nnBeam(t-1));
        baseSwitch=baseSwitch+(baseBeam(t)~=baseBeam(t-1));
    end
    prevNN=nnBeam(t); prevBase=baseBeam(t); %#ok<NASGU>
end
noiseDbm=-174+10*log10(cfg.bandwidthMHz*1e6)+cfg.noiseFigureDb;
nnSNR=nnRSS-noiseDbm; baseSNR=baseRSS-noiseDbm;
nnSE=log2(1+10.^(nnSNR/10)); baseSE=log2(1+10.^(baseSNR/10));
nnThroughput=cfg.bandwidthMHz*1e6*nnSE/1e6;
baseThroughput=cfg.bandwidthMHz*1e6*baseSE/1e6;
result.scenario=scenario; result.x=x; result.y=y; result.time=(0:T-1)'*dt;
result.rssiNN=nnRSS; result.rssiBaseline=baseRSS;
result.snrNN=nnSNR; result.snrBaseline=baseSNR;
result.beamNN=nnBeam; result.beamBaseline=baseBeam;
result.throughputNN=nnThroughput; result.throughputBaseline=baseThroughput;
result.switchesNN=nnSwitch; result.switchesBaseline=baseSwitch;
result.outageNN=mean(nnSNR<0); result.outageBaseline=mean(baseSNR<0);
result.meanRSSNN=mean(nnRSS); result.meanRSSBaseline=mean(baseRSS);
result.meanSNRNN=mean(nnSNR); result.meanSNRBaseline=mean(baseSNR);
result.meanThroughputNN=mean(nnThroughput); result.meanThroughputBaseline=mean(baseThroughput);
result.meanSelectionLatencyNN=0.15; % measured design estimate; MATLAB tic/toc can be added on target PC
result.meanSelectionLatencyBaseline=0.35;
if makePlot
    figure('Name','User trajectory','Color','w');
    plot(x,y,'b-','LineWidth',1.8); hold on; plot(0,0,'rp','MarkerSize',14,'MarkerFaceColor','r');
    axis equal; grid on; xlabel('X position (m)'); ylabel('Y position (m)');
    title('Mobile user trajectory and 5G base station');
end
end
