%% Script to plot the ratio between Controls and KnockDowns in the prion project

clearvars
clc; close all;


mainfolder = uigetdir;
cd(mainfolder)

%% fetch data

%--controls
load('RESULTS/PrePost/PrePostPrion_CTRL.mat')

CTRL_ratio_Nbursts = ratio_Nbursts;
CTRL_ratio_BurstDur = ratio_BurstDur;
CTRL_ratio_MaxSpikeRate = ratio_MaxSpikeRate;

CTRL_ratio_Nspikes = ratio_Nspikes;
CTRL_ratio_SpikeInVsOut = ratio_SpikeInVsOut;

CTRL_ratio_NormSlope = ratio_NormSlope;
CTRL_ratio_TimeToPeak = ratio_TimeToPeak;

%--knockdown
load('RESULTS/PrePost/PrePostPrion_KnockDown.mat')

KD_ratio_Nbursts = ratio_Nbursts;
KD_ratio_BurstDur = ratio_BurstDur;
KD_ratio_MaxSpikeRate = ratio_MaxSpikeRate;

KD_ratio_Nspikes = ratio_Nspikes;
KD_ratio_SpikeInVsOut = ratio_SpikeInVsOut;

KD_ratio_NormSlope = ratio_NormSlope;
KD_ratio_TimeToPeak = ratio_TimeToPeak;

%% Plot spikes data ratio
spikeChanges = bar([mean(CTRL_ratio_Nspikes) mean(KD_ratio_Nspikes); ...
    mean(CTRL_ratio_SpikeInVsOut) mean(KD_ratio_SpikeInVsOut)],'FaceColor','flat');
hold on
plot([0.85 0.85 0.85], CTRL_ratio_Nspikes,'k.','MarkerSize',16)
plot([1.15 1.15 1.15], KD_ratio_Nspikes,'k.','MarkerSize',16)
plot([1.85 1.85 1.85], CTRL_ratio_SpikeInVsOut,'k.','MarkerSize',16)
plot([2.15 2.15 2.15], KD_ratio_SpikeInVsOut,'k.','MarkerSize',16)
plot([0 3],[1 1],'k--')
ylabel('Relative Increase')
ax = gca;
ax.Title.Interpreter = 'none';
ax.Title.String = 'Spikes';
ax.Box = 'off';
ax.TickDir = "out";
ax.FontSize = 14;
ax.FontWeight = 'bold';
ax.XTickLabel = {'N° of Spike'; 'Inside/Outside bursts'};

spikeChanges = gcf;
savefig(spikeChanges,'statistics_figures/spikeChange')
saveas(spikeChanges,'statistics_figures/spikeChange.png')
close all


%% Plot burst data ratio
burstChanges = bar([mean(CTRL_ratio_Nbursts) mean(KD_ratio_Nbursts); ...
    mean(CTRL_ratio_BurstDur) mean(KD_ratio_BurstDur); ...
    mean(CTRL_ratio_MaxSpikeRate) mean(KD_ratio_MaxSpikeRate)],'FaceColor','flat');
hold on
plot([0.85 0.85 0.85], CTRL_ratio_Nbursts,'k.','MarkerSize',16)
plot([1.15 1.15 1.15], KD_ratio_Nbursts,'k.','MarkerSize',16)
plot([1.85 1.85 1.85], CTRL_ratio_BurstDur,'k.','MarkerSize',16)
plot([2.15 2.15 2.15], KD_ratio_BurstDur,'k.','MarkerSize',16)
plot([2.85 2.85 2.85], CTRL_ratio_MaxSpikeRate,'k.','MarkerSize',16)
plot([3.15 3.15 3.15], KD_ratio_MaxSpikeRate,'k.','MarkerSize',16)
plot([0 4],[1 1],'k--')
ylim([0 22])
ylabel('Relative Increase')
ax = gca;
ax.Title.Interpreter = 'none';
ax.Title.String = 'Bursts';
ax.Box = 'off';
ax.TickDir = "out";
ax.FontSize = 14;
ax.FontWeight = 'bold';
ax.XTickLabel = {'N° of Bursts'; 'Burst Duration'; 'Burst Amplitude'};

burstChanges = gcf;
savefig(burstChanges,'statistics_figures/BurstChange')
saveas(burstChanges,'statistics_figures/BurstChange.png')
close all


%% Plot burst rise data change
BurstRiseChanges = bar([mean(CTRL_ratio_NormSlope) mean(KD_ratio_NormSlope); ...
    mean(CTRL_ratio_TimeToPeak) mean(KD_ratio_TimeToPeak)],'FaceColor','flat');
hold on
plot([0.85 0.85 0.85], CTRL_ratio_NormSlope,'k.','MarkerSize',16)
plot([1.15 1.15 1.15], KD_ratio_NormSlope,'k.','MarkerSize',16)
plot([1.85 1.85 1.85], CTRL_ratio_TimeToPeak,'k.','MarkerSize',16)
plot([2.15 2.15 2.15], KD_ratio_TimeToPeak,'k.','MarkerSize',16)
plot([0 3],[1 1],'k--')
ylabel('Relative Increase')
ax = gca;
ax.Title.Interpreter = 'none';
ax.Title.String = 'Burst Rise';
ax.Box = 'off';
ax.TickDir = "out";
ax.FontSize = 14;
ax.FontWeight = 'bold';
ax.XTickLabel = {'Normalized Rising Slope'; 'Time To Peak'};

BurstRiseChanges = gcf;
savefig(BurstRiseChanges,'statistics_figures/BurstRiseChange')
saveas(BurstRiseChanges,'statistics_figures/BurstRiseChange.png')


