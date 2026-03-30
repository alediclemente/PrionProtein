%-- For DIV10 I use 2023-12-09T11-04-33I22442_WT_DIV10

%% =========================
%  PREPROCESS RASTER (axRast)
%  =========================

% 1) Remove '-' lines
hR_lines = findobj(axRast,'Type','line','LineStyle','-');
delete(hR_lines)

% 2) Set MarkerSize to 5 (remaining raster markers)
hR_markers = findobj(axRast,'Type','line');
set(hR_markers,'MarkerSize',5)

% 3) Draw horizontal scalebar
hold(axRast,'on')
plot(axRast,[0 30],[-15 -15],'k-','LineWidth',3)
hold(axRast,'off')


%% =========================
%  PREPROCESS STH (axSTH)
%  =========================

% 1) Remove:
%    - all '--' lines
%    - '-' green lines
%    - '-' red lines
%    (keep black solid lines)

hSTH = findobj(axSTH,'Type','line');

for k = 1:length(hSTH)
    
    ls = hSTH(k).LineStyle;
    col = hSTH(k).Color;
    
    isDashed = strcmp(ls,'--');
    isGreen  = strcmp(ls,'-') && isequal(col,[0 1 0]);
    isRed    = strcmp(ls,'-') && isequal(col,[1 0 0]);
    
    if isDashed || isGreen || isRed
        delete(hSTH(k))
    end
end

% 2) Set remaining LineWidth to 2
hSTH_remaining = findobj(axSTH,'Type','line');
set(hSTH_remaining,'LineWidth',2,'color','r')

% 3) Draw vertical scalebar
hold(axSTH,'on')
plot(axSTH,[-15 -15],[0 50],'k-','LineWidth',3)
hold(axSTH,'off')


%% =========================
%  CREATE NEW FIGURE (1/3 – 2/3 layout)
%  =========================

fig = figure;

% Top = STH (1/3 height)
axTop = axes(fig,'Position',[0 2/3 1 1/3]);

% Bottom = Raster (2/3 height)
axBottom = axes(fig,'Position',[0 0 1 2/3]);


%% =========================
%  COPY CONTENT
%  =========================

copyobj(allchild(axSTH),axTop);
copyobj(allchild(axRast),axBottom);


%% =========================
%  FINAL AXES SETTINGS
%  =========================

% Remove axes visuals
axis(axTop,'off')
axis(axBottom,'off')

% X limits (both)
xlim(axTop,[-20 180])
xlim(axBottom,[-20 180])

% Y limits
yTop = 250;         %--- change here to change y axis limits
ylim(axTop,[0 yTop])
ylim(axBottom,[-20 120])

hold(axTop,'on')
plot(axTop,[1 1],[yTop yTop],'k.')


%% =========================
%  DONE – Ready to export
%  =========================

savepath = uigetdir;
filename = '2022-07-25T16-13-10FVB_KO_I20963_DIV24__rastSTH'; %--- change here for filename
fullname = [savepath '/' filename];
fileformat = '.png';

exportgraphics(fig,[fullname fileformat],'Resolution',600);

savefig(fig,fullname);

