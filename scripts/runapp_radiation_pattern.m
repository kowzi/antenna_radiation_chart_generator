function runapp_radiation_pattern(database_file,dir_output)
%RUNAPP_RADIATION_PATTERN Summary of this function goes here
%   Detailed explanation goes here

    csvfiles=dir('../input/*.csv');

    % database_file   = "../output/CH1_S21_1_S21_MLOG.db";
    % dir_output      = "../output";
    
    cmd_proc_import_sitedata(database_file,'Site19_KIT', '../input_cal/Measurement_Site_19_KIT/20221126_SiteCal_ETS3115_HornBothSide.s2p', 1.0);
    cmd_proc_import_antenna_ETS3115(database_file, '../input_cal/Datasheet_HornAnttena_ETS3115/', 1.0, false);
    cmd_proc_generate_sitecalval(database_file);
    
    for n=1:1:length(csvfiles)
        csvfile = csvfiles(n);
        csvfile_fullname = fullfile(csvfile.folder,csvfile.name);
        cmd_proc_import_measured_csv(database_file, csvfile_fullname, "dut_meas");
    end

    cmd_proc_generate_dutgain(database_file, 'dut_gains', 'site_calval_TAR3115_dataset_Data3mV');
    cmd_sql_getfiles(database_file)
    

    %filenames_to_pickup = ["pMag_Etheta_HH.csv";"pMag_Ephi_VH.csv"];
    filenames_to_pickup = ["CH1_S21_1_S21_MLOG.csv";];
    
    savefile_types = [".png"; ".emf"; ".csv";];
    alternate_filenames = ["pMag\_Etheta"; "pMag\_Ephi"];
    cmdColorOrder = [0 0 1; 1 0 0; 1 1 1];          % https://jp.mathworks.com/help/matlab/creating_plots/defining-the-color-of-lines-for-plotting.html
    cmdLineStyleOrder = ["-" "-" "-"];
    cmdLineWidthOrder = [1; 1; 1];
    
%     chart_frequency = cmd_sql_get_frequencies(database_file,filenames_to_pickup(1));    % for 'all range' retrieved from sqldatabase.
%     % chart_frequency = 3000:1:5000;                                                    % for specified frequencies in MHz
%     cmd_genfig_polar_sql_comparison(database_file, dir_output, filenames_to_pickup, chart_frequency, savefile_types, alternate_filenames, cmdColorOrder, cmdLineStyleOrder, cmdLineWidthOrder);

    for n=1:1:length(csvfiles)
        csvfile = csvfiles(n);
        csvfile_fullname = fullfile(csvfile.folder,csvfile.name);

        chart_frequency = cmd_sql_get_frequencies(database_file,csvfile_fullname);    % for 'all range' retrieved from sqldatabase.
        cmd_genfig_polar_sql_comparison(database_file, dir_output, csvfile_fullname, chart_frequency, savefile_types, alternate_filenames, cmdColorOrder, cmdLineStyleOrder, cmdLineWidthOrder);

    end


end

