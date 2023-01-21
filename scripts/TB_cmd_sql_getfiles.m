
output_dir = "../output/";
output_file= "antmeas_contents.txt";
filenames = cmd_sql_getfiles("../output/antmeas.db");

writematrix(filenames, append(output_dir,output_file));

