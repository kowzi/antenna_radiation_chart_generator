function cmd_proc_import_antrad_hfss_csv(filename_db, csv_filepath_names, db_table, angle_select)
    % filename_dB       : The database filename of SQLite.
    % csv_filepath_names: matrix. the file list can be processed.
    % db_table          : Table name of the database to be set.
    % angle_select      : Angle select. Unique for HFSS.
    %    "phi" to be Phi[deg] at 2nd column.
    %    "theta" to be Theta[deg] at 3rd column.
    % SQLite table structure:
    %   filename, unix-epoch-time, 'frequency_MHz','angle','antenna_gain_dBi'

    % ================================================================================
    % Step 1 ---- table creation in the database file
    % ================================================================================
    if isfile(filename_db)
        conn = sqlite(filename_db);
    else
        conn = sqlite(filename_db, "create");
    end

    % ================================================================================
    % Step 2 ---- importing a .csv file and creating the table to be wrote with sqlwite
    % ================================================================================
    for p=1:1:length(csv_filepath_names)
        csv_filepath_names_info  = dir(csv_filepath_names(p));
        csv_posixtime           = posixtime(datetime(csv_filepath_names_info.date));
        [~, csv_filename, csv_ext] = fileparts(csv_filepath_names(p));
        csv_filename_ext        = append(csv_filename,csv_ext);

        opts                = detectImportOptions(csv_filepath_names(p));
        opts.VariableNames  = {'frequency_MHz','Phi_deg','Theta_deg','antenna_gain_dBi'};
        opts.MissingRule    = "omitrow";

        buff_table                      = readtable(csv_filepath_names(p),opts);
        buff_table(:,"frequency_MHz")   = round(buff_table(:,"frequency_MHz").*1000, 0);                            % convert GHz to MHz and round with 0
        file_date_unixepoch             = transpose(repelem(csv_posixtime,      length(buff_table.frequency_MHz)));
        file_name                       = transpose(repelem(csv_filename_ext,   length(buff_table.frequency_MHz)));
        data_type                       = transpose(repelem("hfss",             length(buff_table.angle)));
        buff_table                      = addvars(buff_table,data_type,          'Before',"frequency_MHz");         % add variable
        buff_table                      = addvars(buff_table,file_date_unixepoch,'Before',"data_type");             % add variable
        buff_table                      = addvars(buff_table,file_name,          'Before',"file_date_unixepoch");   % add variable

        if angle_select == "phi"
            buff_table = removevars(buff_table,"Theta_deg");
            buff_table = renamevars(buff_table,"Phi_deg",  "angle");
        elseif angle_select == "theta"
            buff_table = removevars(buff_table,"Phi_deg");
            buff_table = renamevars(buff_table,"Theta_deg","angle");
        else
            buff_table = removevars(buff_table,"Theta_deg");
            buff_table = renamevars(buff_table,"Phi_deg",  "angle");
        end

        toDelete = (buff_table.angle == 360);   % Create the flag of matrix to delete Row if the value matches with 360
        buff_table(toDelete,:)=[];              % Delete Row with toDelete matrix

    end
    % ================================================================================
    % Step 3 ---- SQL data process
    % ================================================================================
    sqlwrite(conn,db_table,buff_table);
    close(conn);

end

