function [filenames] = cmd_sql_getfiles(filepath_sqlite)
%cmd_sql_getfiles:
%   Return the filenames stored in the sqlite file.
    conn = sqlite(filepath_sqlite,'readonly');
    sqlquery = "select file_name from dut_gains group by file_name";    % Creating the list of files.
    return_buff = fetch(conn, sqlquery);
    close(conn);
    filenames = return_buff.file_name;
end