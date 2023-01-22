clear;
close all;
clc;

radpat_csv2sqlite_local("../output/antmeas_test_radpat_csv2sqlite_m.db", "../input/Reference_3GHz_BowtieAntenna_01VV_CFG-R.csv", "dut_meas");
%radpat_csv2sqlite_local("../output/antmeas_test_radpat_csv2sqlite_m.db", "../input/test.csv", "dut_meas")

function [num_records] = radpat_csv2sqlite_local(filename_db, csv_filepath_name, db_table)

    % ================================================================================
    % Step 1 ---- table creation.
    % ================================================================================
    conn = sqlite(filename_db);
    sqlquery = "CREATE TABLE IF NOT EXISTS "+db_table+"(id INTEGER PRIMARY KEY AUTOINCREMENT,file_name TEXT,file_date_unixepoch REAL,frequency_MHz REAL,angle REAL,meas_s21_dB REAL)";
    fetch(conn, sqlquery);

    % ================================================================================
    % Step 2 ---- importing a .csv file and creating the table to be wrote with sqlwite
    % ================================================================================
    csv_filepath_name_info  = dir(csv_filepath_name);
    csv_posixtime           = posixtime(datetime(csv_filepath_name_info.date));
    [~, csv_filename, csv_ext] = fileparts(csv_filepath_name);
    csv_filename_ext = append(csv_filename,csv_ext);
    csv_cells = readcell(csv_filepath_name);
    length(csv_cells(1,:))
    length(csv_cells(:,2))

    tbl_names = ["file_name", "file_date_unixepoch", "frequency_MHz", "angle", "meas_s21_dB"];
    tbl_types = ["string",    "double",              "double",        "double","double"];
    csv_db_records = table('Size', [2 length(tbl_names)], 'VariableNames',tbl_names, 'VariableTypes', tbl_types);              % https://jp.mathworks.com/help/matlab/matlab_prog/create-a-table.html

    sqlquery = [];
    x=1;
    for m=2:1:length(csv_cells(2,:))
        csv_cells_freq_MHz = str2double(erase(csv_cells(2,m),"GHz"))*1000;
        for n=3:1:length(csv_cells(:,1))
            % angle : csv_cells(n,1), n>=3
            % freq  : csv_cells(2,m), m>=2
            % s21   : csv_cells(n,m), n>=3 && m>=2
            csv_angle = cell2mat(csv_cells(n,1));       % convert a cell data to a numeric.
            csv_s21dB = cell2mat(csv_cells(n,m));       % convert a cell data to a numeric.
            sqlquery = [sqlquery; sprintf("insert into %s (file_name, file_date_unixepoch, frequency_MHz, angle, meas_s21_dB) values('%s',%s,%f,%f,%f)", db_table, csv_filename_ext, csv_posixtime, csv_cells_freq_MHz, csv_angle, csv_s21dB )];
            %csv_db_records(x,:) = {csv_filename_ext, csv_posixtime, csv_cells_freq_MHz, csv_angle, csv_s21dB};
            x=x+1;
        end
    end
    
    % ================================================================================
    % Step 3 ---- SQL data process
    % ================================================================================
    %sqlwrite(conn,db_table,csv_db_records);
    close(conn);

    num_records = x-1;

end

