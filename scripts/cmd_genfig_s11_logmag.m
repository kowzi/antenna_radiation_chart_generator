function cmd_genfig_s11_logmag(inout_dir, filenames, cmdXlim, format_style, saveformat, cmdLegendTexts, cmdColorOrder, cmdLineStyleOrder, cmdLineWidthOrder, cmdShowLimitLine)
%UNTITLED Summary of this function goes here
%   input_sqlite    ... sqlite file to be read
%   inout_dir      ... output directory
%   filename        ... filename table of sqlite to be read
%   freq_plan       ... frequency plan. ex. =[1993 2643 2993 3000]; =3000:1:3500;
%   saveformat      ... output file format. ex. = [".png"; ".emf"; ".fig"; ".csv";];
%   alt_filenames   ... alternate filename used for the legend. ex. = ["Proposed 1"; "Proposed 2";];
    
    % https://jp.mathworks.com/help/matlab/matlab_prog/pass-contents-of-cell-arrays-to-functions.html
    %line_styles = {"b-" "Color" "[0 0 1]" "LineWidth" 2; "b-" "Color" "[0 0 0]" "LineWidth" 1;};

    filename_suffix = '_s11-logmag';
    xlim_min = cmdXlim(1); 
    xlim_max = cmdXlim(2);

    f=figure;
    hold on;

    for n=1:1:length(filenames)
        %sp0_org = sparameters(append(inout_dir,"/",filenames(n)));
        sp0_org = sparameters(filenames(n));
        sp0_freq_org = sp0_org.Frequencies;
        sp0_freq = sp0_freq_org(1):1e6:sp0_freq_org(end);   % New frequency plan for the interpolation with 1 MHz
        sp0 = rfinterp1(sp0_org, sp0_freq);                 % Interpolation process
        sp0_s11_LOGMAG = 20*log10(abs(rfparam(sp0,1,1)));

        plot(sp0_freq/1e9,sp0_s11_LOGMAG,'LineStyle',cmdLineStyleOrder(n),'LineWidth',cmdLineWidthOrder(n));

        if(n==1)
            limit_line_freq  = sp0_freq;
            limit_line_points= length(rfparam(sp0,1,1));
        end
    
    end

    if(cmdShowLimitLine=="vswr2")
        s11_limit_line  = repelem(-9.542, limit_line_points);
        plot(limit_line_freq/1e9,s11_limit_line,'Color',[0 0 0],'LineStyle','-.');
    elseif(cmdShowLimitLine=="vswr3")
        s11_limit_line  = repelem(-6.021, limit_line_points);
        plot(limit_line_freq/1e9,s11_limit_line,'Color',[0 0 0],'LineStyle','-.');
    elseif(cmdShowLimitLine=="logmag10")
        s11_limit_line  = repelem(-10, limit_line_points);
        plot(limit_line_freq/1e9,s11_limit_line,'Color',[0 0 0],'LineStyle','-.');
    end

    
    if(contains(format_style,"ieee"))
        text_font = 'Times New Roman';

        xlabel('Frequency (GHz)','FontWeight','bold','FontName', text_font);
        ylabel('|S_{11}| (dB)'  ,'FontWeight','bold','FontName', text_font);
        legend(cmdLegendTexts,'Location','southoutside');
        
        xlim([xlim_min xlim_max]);
        ylim([-30 0]);
        ax = gca;   % set the aexes property to ax.
        set(ax,'FontName',text_font,'XMinorGrid','off','YMinorGrid','off','ZMinorGrid','off','FontSize',19,'FontWeight','bold','LineWidth',1,'ZGrid','on', 'XTick', xlim_min:1:xlim_max);

        ax.ColorOrder = cmdColorOrder;
        %ax.LineStyleOrder = {'-','-'};
        box on;
        axis on;
        grid off;

        f.Position = [0 0 650 650];
        %daspect([1 1 1]);
        pbaspect([1 1 1]);
    elseif(contains(format_style,"pptx"))
        text_font = 'Calibri';
        xlabel('Frequency (GHz)','FontWeight','bold','FontName', text_font);
        ylabel('|S_{11}| (dB)'  ,'FontWeight','bold','FontName', text_font);
        legend(cmdLegendTexts,'Location','southoutside');
        
        xlim([xlim_min xlim_max]);
        ylim([-30 0]);
        ax = gca;   % set the aexes property to ax.
        set(ax,'FontName', text_font, 'XMinorGrid','off','YMinorGrid','off','ZMinorGrid','off','FontSize',15,'FontWeight','bold','LineWidth',1,'ZGrid','on', 'XTick', xlim_min:1:xlim_max);
        %ax.XAxis.FontSize = 12;
        ax.DataAspectRatio=[0.4 1 1];

        ax.ColorOrder = cmdColorOrder;
        %ax.LineStyleOrder = {'-','-'};
        box on;
        axis on;
        grid off;

        f.Position = [0 0 650 650];
        %daspect([1 1 1]);
        %pbaspect([1 1 1]);
    else
        text_font = 'Times New Roman';
        xlabel('Frequency (GHz)','FontWeight','bold','FontName', text_font);
        ylabel('|S_{11}| (dB)'  ,'FontWeight','bold','FontName', text_font);
        legend(cmdLegendTexts,'Location','southoutside');
        
        xlim([xlim_min xlim_max]);
        ylim([-30 0]);
        ax = gca;   % set the aexes property to ax.
        set(ax,'FontSize',19,'LineWidth',1,'XTick', xlim_min:1:xlim_max);
        box on;
        axis on;
        grid on;
        grid minor;

        f.Position = [0 0 650 650];
        %daspect([1 1 1]);
        pbaspect([1 1 1]);
    end

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
            savefig(gcf,output_dir_filename+"/"+savefilename+filename_suffix+".fig");
        elseif strcmp(saveformat(k),".csv")
            csvbuff_matrix = ['Frequency [Hz]' 'S11[dB]'; sp0_freq sp0_s11_LOGMAG];
            writematrix(csvbuff_matrix,output_dir_filename+"/"+savefilename+filename_suffix+".csv");
        else
            exportgraphics(gcf,output_dir_filename+"/"+savefilename+filename_suffix+saveformat(k));
        end
    end

end