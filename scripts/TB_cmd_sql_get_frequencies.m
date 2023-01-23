clear;
clc;
a = cmd_sql_get_frequencies("../output/KONDO_20230123.db","pMag_Etheta_HH.csv");
b = cmd_sql_get_frequencies("../output/KONDO_20230123.db","pMag_Ephi_VH.csv");

