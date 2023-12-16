function cmd_proc_import_antrad_hfss_multi_csv(filename_db, csv_filepath_names, db_table)
    % filename_dB       : The database filename of SQLite.
    % csv_filepath_names: ABS path and file name to be processed.
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
        %% Preload the first line of .csv file
        csv_filepath_name = csv_filepath_names;
        fp = fopen(csv_filepath_name);
        varNames = strsplit(fgetl(fp),',');     % read the first line and split the string with ',' ::example >> "Phi [deg]","dB(RealizedGainPhi) [] - Freq='3.607GHz' Theta='0deg'","dB(RealizedGainPhi) [] - Freq='4.682GHz' Theta='0deg'" <<
        fclose(fp);

        buff_frequency_MHz = 0;

        %% Extract a frequency list
        for k=2:1:length(varNames)
            buff_varNames = regexp(varNames{k}, '''([^'']*)''', 'match'); % "dB(RealizedGainPhi) [] - Freq='3.607GHz' Theta='0deg'" --> '3.607GHz', '0deg'
            buff_varNames = replace(buff_varNames,"'","");      % '3.607GHz', '0deg'    --> 3.607GHz, 0deg
            buff_varNames = replace(buff_varNames,"GHz","");    % 3.607GHz, 0deg        --> 3.607, 0deg
            %buff_varNames = replace(buff_varNames,"deg","");    % 3.607, 0deg           --> 3.607, 0
            buff_frequency_MHz = [buff_frequency_MHz, round(str2double(buff_varNames(1))*1000,0)];
        end

        %% Read .csv file to
        opts                    = detectImportOptions(csv_filepath_name);
        opts.MissingRule        = "omitrow";
        opts.VariableNames{1}   = 'angle';
        buff_table              = readtable(csv_filepath_name,opts);        % read .csv to Table

        % DataBase recrods --- common information: 'file_name','file_date_unixepoch'
        csv_filepath_names_info    = dir(csv_filepath_name);
        csv_posixtime              = posixtime(datetime(csv_filepath_names_info.date));
        [~, csv_filename, csv_ext] = fileparts(csv_filepath_name);
        csv_filename_ext           = append(csv_filename,csv_ext);

        %% Column scan and add table to SQLite db
        for m=2:1:length(varNames)

            % create DB table
            %db_table = table('file_name','file_date_unixepoch','frequency_MHz','angle','antenna_gain_dBi');
            %db_table.file_name              = transpose(repelem(csv_filename_ext,   length(buff_table.angle)));
            %db_table.file_date_unixepoch    = transpose(repelem(csv_posixtime,      length(buff_table.angle)));
            %db_table.frequency_MHz          = transpose(repelem(frequency_MHz,      length(buff_table.angle)));
            %db_table.angle                  = buff_table.angle;
            %db_table.antenna_gain_dBi       = buff_table.VariableNames(m);

            file_name              = transpose(repelem(csv_filename_ext,        length(buff_table.angle)));
            file_date_unixepoch    = transpose(repelem(csv_posixtime,           length(buff_table.angle)));
            data_type              = transpose(repelem("hfss",                  length(buff_table.angle)));
            frequency_MHz          = transpose(repelem(buff_frequency_MHz(m),   length(buff_table.angle)));
            angle                  = buff_table.angle;
            antenna_gain_dBi       = table2array(buff_table(:,m));
            buff_db = table(file_name,file_date_unixepoch,data_type,frequency_MHz,angle,antenna_gain_dBi);

            toDelete = (buff_db.angle == 360);   % Create the flag of matrix to delete Row if the value matches with 360
            buff_db(toDelete,:)=[];              % Delete Row with toDelete matrix

            sqlwrite(conn,db_table,buff_db);     % write Table to Database

        end

    end

    % close the database
    close(conn);

end

