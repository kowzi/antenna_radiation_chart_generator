function cmd_proc_import_measured_csv(filename_db, csv_filepath_name, db_table)

    % ================================================================================
    % Step 1 ---- table creation.
    % ================================================================================
    if isfile(filename_db)
        conn = sqlite(filename_db);
    else
        conn = sqlite(filename_db, "create");
    end

    sqlquery = "CREATE TABLE IF NOT EXISTS "+db_table+ ...
        "(id INTEGER PRIMARY KEY AUTOINCREMENT, file_name TEXT, file_date_unixepoch REAL, data_type TEXT, frequency_MHz REAL, angle REAL, meas_s21_dB REAL)";
    execute(conn, sqlquery);

    for p=1:1:length(csv_filepath_name)
        % ================================================================================
        % Step 2 ---- importing a .csv file and creating the table to be wrote with sqlwite
        % ================================================================================
        disp(csv_filepath_name(p));
        csv_filepath_name_info  = dir(csv_filepath_name(p));
        csv_posixtime           = posixtime(datetime(csv_filepath_name_info.date));
        [~, csv_filename, csv_ext] = fileparts(csv_filepath_name(p));
        csv_filename_ext = append(csv_filename,csv_ext);
        csv_cells = readcell(csv_filepath_name(p));
        % =========== DATA LOOP ===========================
        % angle : csv_cells(n,1), n>=3
        % s21   : csv_cells(n,m), n>=3 && m>=2
        % freq  : csv_cells(2,m), m>=2
        for m=2:1:length(csv_cells(2,:))        % maximum = the number of frequencies.
            buff_csv_filename_ext   = transpose(repelem(csv_filename_ext,   length(csv_cells(:,1))-2));
            buff_csv_posixtime      = transpose(repelem(csv_posixtime,      length(csv_cells(:,1))-2));
            buff_data_type          = transpose(repelem("meas",             length(csv_cells(:,1))-2));
            csv_cells_freq_MHz      = str2double(erase(csv_cells(2,m),"GHz"))*1000;
            buff_csv_cells_freq_MHz = transpose(repelem(csv_cells_freq_MHz, length(csv_cells(:,1))-2));
            csv_angle               = cell2mat(csv_cells(3:end,1));
            csv_s21dB               = cell2mat(csv_cells(3:end,m));
    
            %data = table(["test1"; "test2"],[12345.6; 78.98],[2000; 2001], [90; 180], [-20; -30], 'VariableNames',{'file_name' 'file_date_unixepoch' 'frequency_MHz' 'angle' 'meas_s21_dB'});
            data = table(buff_csv_filename_ext,buff_csv_posixtime,buff_data_type, buff_csv_cells_freq_MHz,csv_angle,csv_s21dB,'VariableNames',{'file_name' 'file_date_unixepoch' 'data_type' 'frequency_MHz' 'angle' 'meas_s21_dB'});
            sqlwrite(conn, db_table, data);
    
    %         csv_cells_freq_MHz = str2double(erase(csv_cells(2,m),"GHz"))*1000;
    %         for n=3:1:length(csv_cells(:,1))    % maximum = 360
    %             csv_angle = cell2mat(csv_cells(n,1));       % convert a cell data to a numeric.
    %             csv_s21dB = cell2mat(csv_cells(n,m));       % convert a cell data to a numeric.
    %             %sqlquery = [sqlquery; sprintf("insert into %s (file_name, file_date_unixepoch, frequency_MHz, angle, meas_s21_dB) values('%s',%s,%f,%f,%f)", db_table, csv_filename_ext, csv_posixtime, csv_cells_freq_MHz, csv_angle, csv_s21dB )];
    %             %csv_db_records(x,:) = {csv_filename_ext, csv_posixtime, csv_cells_freq_MHz, csv_angle, csv_s21dB};
    %             x=x+1;
    %         end
        end
    end
    % ================================================================================
    % Step 3 ---- SQL data process
    % ================================================================================
    %sqlwrite(conn,db_table,csv_db_records);
    close(conn);

end

