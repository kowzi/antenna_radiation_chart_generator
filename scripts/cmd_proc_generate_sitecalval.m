function cmd_proc_generate_sitecalval(filename_db)
%CMD_PROC_GENERATE_SITECALVAL Summary of this function goes here
%   Detailed explanation goes here

    conn = sqlite(filename_db);
    sqlquery = [
        "create table if not exists site_calval as select distinct s.frequency_MHz, "+...
        "(s.s21_dB-t.gain_dBi) as calval_0dBi from Site_Measurement as s inner join TAR3115_dataset_Data3mV "+...
        "as t on s.frequency_MHz = t.frequency_MHz";
        
        "create table if not exists site_calval_TAR3115_dataset_Data1mV as select distinct s.frequency_MHz, "+...
        "(s.s21_dB-t.gain_dBi) as calval_0dBi from Site_Measurement as s inner join TAR3115_dataset_Data1mV "+...
        "as t on s.frequency_MHz = t.frequency_MHz";

        "create table if not exists site_calval_TAR3115_dataset_Data1mH as select distinct s.frequency_MHz, "+...
        "(s.s21_dB-t.gain_dBi) as calval_0dBi from Site_Measurement as s inner join TAR3115_dataset_Data1mH "+...
        "as t on s.frequency_MHz = t.frequency_MHz";

        "create table if not exists site_calval_TAR3115_dataset_Data3mV as select distinct s.frequency_MHz, "+...
        "(s.s21_dB-t.gain_dBi) as calval_0dBi from Site_Measurement as s inner join TAR3115_dataset_Data3mV "+...
        "as t on s.frequency_MHz = t.frequency_MHz";

        "create table if not exists site_calval_TAR3115_dataset_Data3mH as select distinct s.frequency_MHz, "+...
        "(s.s21_dB-t.gain_dBi) as calval_0dBi from Site_Measurement as s inner join TAR3115_dataset_Data3mH "+...
        "as t on s.frequency_MHz = t.frequency_MHz";
        ];
    
    for n=1:1:length(sqlquery)
        fetch(conn, sqlquery(n));
    end
    close(conn);


end

