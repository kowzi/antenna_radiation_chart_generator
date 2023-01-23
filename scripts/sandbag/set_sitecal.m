clear;
close all;
clc;

set_sitecal_local("../output/antmeas.db");

function set_sitecal_local(filename_db)
    conn = sqlite(filename_db);
    sqlquery = [
        "create table if not exists site_calval as select distinct s.frequency_MHz, "+...
        "(s.s21_dB-t.gain_dBi) as calval_0dBi from Site_Measurement as s inner join TAR3115_dataset_Data3mV "+...
        "as t on s.frequency_MHz = t.frequency_MHz";
        
        "create table if not exists site_calval_TAR3115_dataset_Data1mV as distinct select s.frequency_MHz, "+...
        "(s.s21_dB-t.gain_dBi) as calval_0dBi from Site_Measurement as s inner join TAR3115_dataset_Data1mV "+...
        "as t on s.frequency_MHz = t.frequency_MHz";

        "create table if not exists site_calval_TAR3115_dataset_Data1mH as distinct select s.frequency_MHz, "+...
        "(s.s21_dB-t.gain_dBi) as calval_0dBi from Site_Measurement as s inner join TAR3115_dataset_Data1mH "+...
        "as t on s.frequency_MHz = t.frequency_MHz";

        "create table if not exists site_calval_TAR3115_dataset_Data3mV as distinct select s.frequency_MHz, "+...
        "(s.s21_dB-t.gain_dBi) as calval_0dBi from Site_Measurement as s inner join TAR3115_dataset_Data3mV "+...
        "as t on s.frequency_MHz = t.frequency_MHz";

        "create table if not exists site_calval_TAR3115_dataset_Data3mH as distinct select s.frequency_MHz, "+...
        "(s.s21_dB-t.gain_dBi) as calval_0dBi from Site_Measurement as s inner join TAR3115_dataset_Data3mH "+...
        "as t on s.frequency_MHz = t.frequency_MHz";
        ];
    
    fetch(conn, sqlquery);
    close(conn);
    
end

