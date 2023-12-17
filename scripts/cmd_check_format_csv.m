function [csvtype] = cmd_check_format_csv(csv_filepath_name)
%Check the radiation format of the CSV files. Retrun the type in String.
%  Return value:
%   "LabMeasKIT"
%   "HFSS-SingleFreq"
%   "HFSS-MultiFreq"
%  Argument:
%   csv_filepath_name

    fp = fopen(csv_filepath_name);
    varNames = strsplit(fgetl(fp),',');     % read the first line
    fclose(fp);
    
    % 1st line check:
    if contains(varNames(1),"! CH1_S11_1 S21 MLOG")
        csvtype = "Meas_KITLab";
    elseif contains(varNames(1),"Freq [GHz]")
        csvtype = "Sim_HFSS-SingleFreq";
    elseif contains(varNames(1),"Phi [deg]") || contains(varNames(1),"Theta [deg]")
        csvtype = "Sim_HFSS-MultiFreq";
    else
        csvtype = "unknown";
    end
   

end