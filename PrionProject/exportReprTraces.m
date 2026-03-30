
fig = gcf;
set(fig,'Renderer','painters')

savepath = uigetdir;
filename = 'SemiLogBurstProfile_DIV24';
filepath = fullfile(savepath, filename);

exportgraphics(fig, [filepath '.pdf'], 'ContentType','vector');
savefig(fig, filepath);
