clear;
close all;
clc;

get_dutgain_local("../output/antmeas.db", "dut_gains", "site_calval_TAR3115_dataset_Data3mV");


function get_dutgain_local(filename_db, tbname_dut_gains_dBi, site_calval)
    conn = sqlite(filename_db);
    sqlquery = sprintf("create table %s as select distinct d.file_name, d.file_date_unixepoch, d.frequency_MHz, d.angle," + ...
        "(d.meas_s21_dB-s.calval_0dBi) as antenna_gain_dBi from dut_meas as d inner join %s as s on ROUND(d.frequency_MHz,1)"+...
        "= s.frequency_MHz where d.angle NOT IN (360.0)",tbname_dut_gains_dBi,site_calval);
    fetch(conn, sqlquery);
    close(conn);
end