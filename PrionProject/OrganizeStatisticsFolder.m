%% reorganize statistics_figures folder in PrionProject

cd("/Users/alessio/ToAnalyze/PrionProject/KnockOut/statistics_figures")

mkdir("excel_tables")
mkdir("graphs_fig")
mkdir("graphs_png")
mkdir("mat_files")

movefile("*.xlsx","excel_tables")
movefile("*.fig","graphs_fig")
movefile("*.png","graphs_png")
movefile("*.mat","mat_files")


