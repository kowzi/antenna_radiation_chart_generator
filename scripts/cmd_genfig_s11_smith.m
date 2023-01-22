function cmd_genfig_s11_smith(output_dir, filenames, cmdXlim_mode, cmdXlim_GHz, format_style, saveformat, cmdColorOrder, cmdLineStyleOrder, cmdLineWidthOrder)
%UNTITLED Summary of this function goes here
%   input_sqlite    ... sqlite file to be read
%   output_dir      ... output directory
%   filename        ... filename table of sqlite to be read
%   freq_plan       ... frequency plan. ex. =[1993 2643 2993 3000]; =3000:1:3500;
%   saveformat      ... output file format. ex. = [".png"; ".emf"; ".fig"; ".csv";];
%   alt_filenames   ... alternate filename used for the legend. ex. = ["Proposed 1"; "Proposed 2";];
    
    % https://jp.mathworks.com/help/matlab/matlab_prog/pass-contents-of-cell-arrays-to-functions.html
    %line_styles = {"b-" "Color" "[0 0 1]" "LineWidth" 2; "b-" "Color" "[0 0 0]" "LineWidth" 1;};

    f=figure;
    hold on;

    for n=1:1:length(filenames)

        sp0_org         = sparameters(filenames(n));
        sp0_freq_org    = sp0_org.Frequencies;

        if(cmdXlim_mode=="auto")
            sp0_freq        = sp0_freq_org(1):1e6:sp0_freq_org(end);        % New frequency plan for the interpolation with 1 MHz
            sp0             = rfinterp1(sp0_org, sp0_freq);                 % Interpolation process
            sp0_rfparam     = rfparam(sp0,1,1);

        elseif(cmdXlim_mode=="man")
            sp0_freq        = sp0_freq_org(1):1e6:sp0_freq_org(end);        % New frequency plan for the interpolation with 1 MHz
            sp0             = rfinterp1(sp0_org, sp0_freq);                 % Interpolation process
            sp0_rfparam     = rfparam(sp0,1,1);
            [sp0_freq, sp0_rfparam] = rfparam_rangecut(cmdXlim_GHz(1)*1e9,cmdXlim_GHz(2)*1e9,sp0_freq,sp0_rfparam);
        end

        h = smithplot(sp0.Frequencies, rfparam(sp0,1,1),'GridType','ZY');
        h.LineWidth     = cmdLineWidthOrder(n);
        h.LineStyle     = cmdLineStyleOrder(n);
        h.Marker        = {'none', 'o', 'square'};
        h.FontName      = 'Times New Roman';
        h.GridLineWidth = 0.5;
    end

    smithplot(sp0_freq(1),sp0_rfparam(1));
    smithplot(sp0_freq(end),sp0_rfparam(end));

  
    if(contains(format_style,"ieee"))
        ax = gca;   % set the aexes property to ax.
        %set(ax,'FontName','Times New Roman','XMinorGrid','off','YMinorGrid','off','ZMinorGrid','off','FontSize',19,'FontWeight','bold','LineWidth',1,'ZGrid','on', 'XTick', xlim_min:1:xlim_max);
        ax.ColorOrder = cmdColorOrder;
        %ax.LineStyleOrder = {'-','-'};
        box on;
        axis on;
        grid off;
    else
        %ax = gca;   % set the aexes property to ax.
        %set(ax,'FontSize',19,'LineWidth',1,'XTick', xlim_min:1:xlim_max);
        box on;
        axis on;
        grid on;
        grid minor;
    end

    f.Position = [0 0 650 650];
    %daspect([1 1 1]);
    pbaspect([1 1 1]);

    savefilename = replace(filenames(1),".","");
    output_dir_filename = output_dir+"/"+savefilename;
    if not(exist(output_dir_filename,"dir"))
        mkdir(output_dir_filename);
    end

    %% saving a file -----
    for k=1:1:length(saveformat)
        if strcmp(saveformat(k),".fig")
            savefig(gcf,output_dir_filename+"/"+savefilename+".fig");
        elseif strcmp(saveformat(k),".csv")
            csvbuff_matrix = ['angle[deg]' strcat(savefilename,'[dBi]'); angle_deg antenna_gain_dBi];
            writematrix(csvbuff_matrix,output_dir_filename+"/"+savefilename+"_dut_gains.csv");
        else
            exportgraphics(gcf,output_dir_filename+"/"+savefilename+saveformat(k));
        end
    end
    clf;



end