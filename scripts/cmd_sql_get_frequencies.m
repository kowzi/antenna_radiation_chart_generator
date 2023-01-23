function [frequencies] = cmd_sql_get_frequencies(filepath_sqlite, filename_csv)
%cmd_sql_getfiles:
%   Return the filenames stored in the sqlite file.
    conn = sqlite(filepath_sqlite,'readonly');
    sqlquery = sprintf("select distinct d.frequency_MHz from dut_gains as d where d.file_name='%s'", filename_csv);    % Creating the list of files.
    return_buff = fetch(conn, sqlquery);
    close(conn);
    frequencies = transpose(return_buff.frequency_MHz);
end