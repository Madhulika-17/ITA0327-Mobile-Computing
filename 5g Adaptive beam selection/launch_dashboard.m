function launch_dashboard(model,cfg)
% Interactive MATLAB dashboard; no App Designer/toolboxes required.
f=figure('Name','5G Adaptive Beam Selection Dashboard','Color',[0.055 0.075 0.11], ...
    'Position',[80 70 1250 760],'NumberTitle','off');
ax=axes('Parent',f,'Position',[0.06 0.16 0.55 0.75], ...
    'Color',[0.08 0.11 0.16],'XColor','w','YColor','w');
hold(ax,'on'); grid(ax,'on'); axis(ax,[-110 110 -110 110]); axis(ax,'square');
xlabel(ax,'X position (m)','Color','w'); ylabel(ax,'Y position (m)','Color','w');
title(ax,'LIVE 5G COVERAGE & ADAPTIVE BEAM TRACKING','Color','w');
th=linspace(0,2*pi,300);
plot(ax,cfg.coverageRadius*cos(th),cfg.coverageRadius*sin(th),':','Color',[.4 .55 .7]);
plot(ax,0,0,'rp','MarkerSize',18,'MarkerFaceColor','r');
text(ax,3,3,'gNB','Color','w','FontWeight','bold');
for b=1:cfg.numBeams
    a=deg2rad(cfg.beamAngles(b));
    plot(ax,[0 95*cos(a)],[0 95*sin(a)],'Color',[.25 .4 .55],'LineStyle','--');
end
userPlot=plot(ax,0,0,'co','MarkerSize',12,'MarkerFaceColor','c');
beamPlot=plot(ax,[0 0],[0 0],'y-','LineWidth',3);
status=uicontrol(f,'Style','text','Units','normalized','Position',[.65 .82 .31 .11], ...
    'String','READY | 5G NR SIMULATED','BackgroundColor',[.08 .15 .2], ...
    'ForegroundColor',[.4 1 .7],'FontSize',13,'FontWeight','bold');
info=uicontrol(f,'Style','text','Units','normalized','Position',[.65 .53 .31 .26], ...
    'String','Press Start to begin.','HorizontalAlignment','left', ...
    'BackgroundColor',[.08 .11 .16],'ForegroundColor','w','FontSize',12);
speedLabel=uicontrol(f,'Style','text','Units','normalized','Position',[.65 .45 .12 .04], ...
    'String','Speed (m/s)','BackgroundColor',get(f,'Color'),'ForegroundColor','w');
speedSlider=uicontrol(f,'Style','slider','Units','normalized','Position',[.78 .46 .18 .03], ...
    'Min',1,'Max',30,'Value',8);
blockCheck=uicontrol(f,'Style','checkbox','Units','normalized','Position',[.65 .39 .3 .05], ...
    'String','Enable temporary blockage','BackgroundColor',get(f,'Color'),'ForegroundColor','w');
startBtn=uicontrol(f,'Style','pushbutton','Units','normalized','Position',[.65 .30 .14 .07], ...
    'String','START','FontSize',12,'FontWeight','bold','Callback',@startSim);
stopBtn=uicontrol(f,'Style','pushbutton','Units','normalized','Position',[.82 .30 .14 .07], ...
    'String','STOP','FontSize',12,'Callback',@(~,~) setappdata(f,'running',false));
resetBtn=uicontrol(f,'Style','pushbutton','Units','normalized','Position',[.65 .21 .31 .06], ...
    'String','RESET USER','Callback',@resetSim);
uicontrol(f,'Style','text','Units','normalized','Position',[.65 .10 .31 .06], ...
    'String','Simulation only — no physical 5G radio control.','BackgroundColor',get(f,'Color'), ...
    'ForegroundColor',[1 .75 .35],'FontSize',10);
setappdata(f,'running',false); setappdata(f,'x',-75); setappdata(f,'y',-10);
setappdata(f,'beam',1); setappdata(f,'t',0);

    function resetSim(~,~)
        setappdata(f,'running',false); setappdata(f,'x',-75); setappdata(f,'y',-10);
        setappdata(f,'beam',1); setappdata(f,'t',0);
        set(userPlot,'XData',-75,'YData',-10); set(beamPlot,'XData',[0 0],'YData',[0 0]);
        set(status,'String','READY | RESET'); set(info,'String','User reset. Press Start.');
    end
    function startSim(~,~)
        if getappdata(f,'running'), return; end
        setappdata(f,'running',true);
        while ishandle(f) && getappdata(f,'running')
            x=getappdata(f,'x'); y=getappdata(f,'y'); t=getappdata(f,'t')+1;
            v=get(speedSlider,'Value');
            x=x+v*0.12; y=35*sin(t*0.025);
            if hypot(x,y)>cfg.coverageRadius*0.95, x=-75; end
            blocked=get(blockCheck,'Value') && mod(t,180)>60 && mod(t,180)<110;
            [p,snr]=channel_model(x,y,blocked,cfg);
            bearing=atan2d(y,x); d=hypot(x,y);
            feat=[x/cfg.coverageRadius,y/cfg.coverageRadius,d/cfg.coverageRadius, ...
                sind(bearing),cosd(bearing),v/30,0,1,double(blocked),snr/30];
            [b,prob]=predict_beam(model,feat);
            set(userPlot,'XData',x,'YData',y);
            ang=deg2rad(cfg.beamAngles(b));
            set(beamPlot,'XData',[0 95*cos(ang)],'YData',[0 95*sin(ang)]);
            set(status,'String',sprintf('CONNECTED | NN BEAM %d | %.0f%%',b,100*max(prob)));
            set(info,'String',sprintf(['Position: (%.1f, %.1f) m\nDistance: %.1f m\n' ...
                'Selected beam: %d\nBest measured beam: %d\nRSSI: %.1f dBm\n' ...
                'Estimated SNR: %.1f dB\nBlockage: %s\nSpeed: %.1f m/s'], ...
                x,y,d,b,find(p==max(p),1),p(b),snr,yesno(blocked),v));
            setappdata(f,'x',x); setappdata(f,'y',y); setappdata(f,'beam',b); setappdata(f,'t',t);
            drawnow; pause(0.08);
        end
    end
end
function s=yesno(v)
if v, s='ON'; else, s='OFF'; end
end
