function cmd_proc_import_sitedata(filename_db, site_name, site_s2p, frequency_step_MHz)
%CMD_PROC_SITECAL Summary of this function goes here
%   Detailed explanation goes here

    % OLD FILENAME: SiteCal_Site19_KIT.mlx
    
    %sp_file='../input_cal/Measurement_Site_19_KIT/20221126_SiteCal_ETS3115_HornBothSide.s2p';
    %filename_db = '../output/antmeas.db';
   
    [output_dir,sp_file_name,~] = fileparts(site_s2p);
    sp_ref = sparameters(site_s2p);
    
    % ======================================================================================
    % Step 1 : Interpolation
    % ======================================================================================
    sp_freq= sp_ref.Frequencies; % Hz
    sp_freq_MHz = sp_freq/1e6;   % to MHz
    sp_freq_MHz_new_points = sp_freq_MHz(1):frequency_step_MHz:sp_freq_MHz(end);
    sp_freq_MHz_new_points = transpose(sp_freq_MHz_new_points);
    sp_freq_MHz_interp      = [sp_freq_MHz; sp_freq_MHz_new_points];
    
    sp_freq_MHz_interp = sort(sp_freq_MHz_interp);
    sp_s11_dB = 20*log10(abs(rfparam(sp_ref,1,1)));
    sp_s21_dB = 20*log10(abs(rfparam(sp_ref,2,1)));
    
    sp_s11_dB_interp = interp1(sp_freq_MHz,sp_s11_dB,sp_freq_MHz_interp);
    sp_s21_dB_interp = interp1(sp_freq_MHz,sp_s21_dB,sp_freq_MHz_interp);
    
    data_s11 = [sp_freq_MHz_interp sp_s11_dB_interp];
    filename = string(append(output_dir,sp_file_name,'_s11.csv'));
    writematrix(data_s11,filename);
    
    data_s21 = transpose([sp_freq_MHz;sp_s21_dB]);
    filename = string(append(output_dir,sp_file_name,'_s21.csv'));
    writematrix(data_s21,filename);
    %rfplot(sp_ref);

    % ======================================================================================
    % Step 2 : Importing to Sqlite3
    % ======================================================================================
    if isfile(filename_db)
        conn = sqlite(filename_db);
    else
        conn = sqlite(filename_db, "create");
    end
    
    site_id = transpose(repelem(site_name, length(sp_freq_MHz_interp)));
    %data = table(site_id, sp_freq_MHz_interp,sp_s11_dB_interp,sp_s21_dB_interp,'VariableNames',["Site_ID", "frequency_MHz" "s11_dB" "s21_dB"]);
    data = table(sp_freq_MHz_interp,sp_s11_dB_interp,sp_s21_dB_interp,'VariableNames',["frequency_MHz" "s11_dB" "s21_dB"]);
    
    sqlwrite(conn, 'Site_Measurement', data);
    close(conn);
    
    % conn = sqlite(filename);      % auto-commit mode
    % readdb = sqlread(conn,'Site_Measurement');
    % close(conn);
    % plot(readdb.frequency_MHz,readdb.s11_dB,readdb.frequency_MHz,readdb.s21_dB);

end

