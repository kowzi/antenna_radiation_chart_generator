function cmd_genfig_s11_smith(inout_dir, filenames, alternate_filename, cmdXlim_mode, cmdXlim_GHz, format_style, saveformat, cmdColorOrder, cmdLineStyleOrder, cmdLineWidthOrder)
%UNTITLED Summary of this function goes here
%   input_sqlite    ... sqlite file to be read
%   inout_dir      ... output directory
%   filename        ... filename table of sqlite to be read
%   freq_plan       ... frequency plan. ex. =[1993 2643 2993 3000]; =3000:1:3500;
%   saveformat      ... output file format. ex. = [".png"; ".emf"; ".fig"; ".csv";];
%   alt_filenames   ... alternate filename used for the legend. ex. = ["Proposed 1"; "Proposed 2";];
    
    % Smith plot:
    %   add a line:   https://jp.mathworks.com/help/rf/ref/smithplot.add.html

    filename_suffix = '_s11-smith';

    f=figure;
    hold on;

    %sp0_org = sparameters(append(inout_dir,"/",filenames(1)));
    sp0_org = sparameters(filenames(1));
    sp0_freq_org    = sp0_org.Frequencies;
    sp0_freq        = sp0_freq_org(1):1e6:sp0_freq_org(end);        % New frequency plan for the interpolation with 1 MHz
    sp0             = rfinterp1(sp0_org, sp0_freq);                 % Interpolation process
    sp0_rfparam     = rfparam(sp0,1,1);
    if(cmdXlim_mode=="man")
        [sp0_freq, sp0_rfparam] = rfparam_rangecut(cmdXlim_GHz(1)*1e9,cmdXlim_GHz(2)*1e9,sp0_freq,sp0_rfparam);
    end
    s = smithplot(sp0_freq, sp0_rfparam,'GridType','ZY');

    %Adding lines in smith plot:   https://jp.mathworks.com/help/rf/ref/smithplot.add.html
    add(s,sp0_freq(1),sp0_rfparam(1));
    add(s,sp0_freq(end),sp0_rfparam(end));

    s.LegendLabels  = {alternate_filename(1), append('start:',string(sp0_freq(1)/1e9)," GHz"), append('stop:',string(sp0_freq(end)/1e9)," GHz")}; 
    s.LineWidth     = 1.8*cmdLineWidthOrder;
    s.LineStyle     = cmdLineStyleOrder;
    s.Marker        = {'none', 'o', 'square'};
    s.FontName      = 'Times New Roman';
    s.GridLineWidth = 0.5;

    if(contains(format_style,"ieee"))
        s.ColorOrder    = [0 0.2235 0.3705; 0 0 1; 1 0 0];
    else
    end

    f.Position = [0 0 650 650];
    %daspect([1 1 1]);
    pbaspect([1 1 1]);    

    %savefilename = replace(filenames(1),".","");
    [~,savefilename,~] = fileparts(filenames(1));
    savefilename = string(savefilename);
    output_dir_filename = inout_dir+"/"+savefilename;

    if not(exist(output_dir_filename,"dir"))
        mkdir(output_dir_filename);
    end

    %% saving a file -----
    for k=1:1:length(saveformat)
        if strcmp(saveformat(k),".fig")
            savefig(gcf,output_dir_filename+"/"+savefilename+filename_suffix+"_"+cmdXlim_mode+".fig");
        elseif strcmp(saveformat(k),".csv")
            csvbuff_matrix = ['Frequency [Hz]' 'S11[real/imag]'; sp0_freq string(transpose(sp0_rfparam))];
            writematrix(csvbuff_matrix,output_dir_filename+"/"+savefilename+filename_suffix+"_"+cmdXlim_mode+".csv");
        else
            exportgraphics(gcf,output_dir_filename+"/"+savefilename+filename_suffix+"_"+cmdXlim_mode+saveformat(k));
        end
    end


end