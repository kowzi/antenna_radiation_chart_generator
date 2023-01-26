function cmd_genfig_s11_zparam(inout_dir, filenames, cmdXlim, format_style, saveformat, cmdColorOrder, cmdLineStyleOrder, cmdLineWidthOrder)
%UNTITLED Summary of this function goes here
%   input_sqlite    ... sqlite file to be read
%   inout_dir      ... output directory
%   filename        ... filename table of sqlite to be read
%   freq_plan       ... frequency plan. ex. =[1993 2643 2993 3000]; =3000:1:3500;
%   saveformat      ... output file format. ex. = [".png"; ".emf"; ".fig"; ".csv";];
%   alt_filenames   ... alternate filename used for the legend. ex. = ["Proposed 1"; "Proposed 2";];
    
    % https://jp.mathworks.com/help/matlab/matlab_prog/pass-contents-of-cell-arrays-to-functions.html
    %line_styles = {"b-" "Color" "[0 0 1]" "LineWidth" 2; "b-" "Color" "[0 0 0]" "LineWidth" 1;};

    filename_suffix = '_s11-zparam';

    xlim_min = cmdXlim(1); 
    xlim_max = cmdXlim(2);

    f=figure;
    hold on;

    for n=1:1:length(filenames)
        sp0_org = sparameters(append(inout_dir,"/",filenames(n)));
        zp0_org = zparameters(append(inout_dir,"/",filenames(n)));       % https://jp.mathworks.com/help/rf/ref/zparameters.html
        sp0_freq_org = sp0_org.Frequencies;
        sp0_freq = sp0_freq_org(1):1e6:sp0_freq_org(end);   % New frequency plan for the interpolation with 1 MHz
        zp0 = rfinterp1(zp0_org, sp0_freq);
        
        %sp0_z11_complex = s2z(rfparam(sp0,1,1),50);
        sp0_z11_abs     = abs(rfparam(zp0,1,1));
        sp0_z11_real    = real(rfparam(zp0,1,1));
        sp0_z11_imag    = imag(rfparam(zp0,1,1));

        plot(sp0_freq/1e9, sp0_z11_real, 'DisplayName', 'Real(Z_{50})','LineStyle',cmdLineStyleOrder(n),'LineWidth',cmdLineWidthOrder(n));
        plot(sp0_freq/1e9, sp0_z11_imag, 'DisplayName', 'Imag(Z_{50})','LineStyle',cmdLineStyleOrder(n),'LineWidth',cmdLineWidthOrder(n));
        plot(sp0_freq/1e9, sp0_z11_abs, 'DisplayName', '|Z_{50}|','LineStyle',cmdLineStyleOrder(n),'LineWidth',cmdLineWidthOrder(n));

    end

    %title(buff_title);
    xlabel('Frequency (GHz)','FontWeight','bold','FontName','Times New Roman')
    ylabel('Z Parameter(50)','FontWeight','bold','FontName','Times New Roman')
    legend('Location','southoutside');
    
    xlim([xlim_min xlim_max]);
    ylim([-150 250]);
    yticklabels([-150 -100 -50 0 50 100 150 200 250]);
   
    if(contains(format_style,"ieee"))
        ax = gca;   % set the aexes property to ax.
        set(ax,'FontName','Times New Roman','XMinorGrid','off','YMinorGrid','off','ZMinorGrid','off','FontSize',19,'FontWeight','bold','LineWidth',1,'ZGrid','on', 'XTick', xlim_min:1:xlim_max);
        ax.ColorOrder = cmdColorOrder;
        %ax.LineStyleOrder = {'-','-'};
        box on;
        axis on;
        grid off;
    else
        ax = gca;   % set the aexes property to ax.
        set(ax,'FontSize',19,'LineWidth',1,'XTick', xlim_min:1:xlim_max);
        box on;
        axis on;
        grid on;
        grid minor;
    end

    f.Position = [0 0 650*1.1 650*1.1];
    %daspect([1 1 1]);
    pbaspect([1 1 1]);

    savefilename = replace(filenames(1),".","");
    output_dir_filename = inout_dir+"/"+savefilename;
    if not(exist(output_dir_filename,"dir"))
        mkdir(output_dir_filename);
    end

    %% saving a file -----
    for k=1:1:length(saveformat)
        if strcmp(saveformat(k),".fig")
            savefig(gcf,output_dir_filename+"/"+savefilename+filename_suffix+".fig");
        elseif strcmp(saveformat(k),".csv")
            csvbuff_matrix = ['Frequency [Hz]' 'Z50(ohm)' 'Z50(real)' 'Z50(imaginary)'; sp0_freq sp0_z11_abs sp0_z11_real sp0_z11_imag];
            writematrix(csvbuff_matrix,output_dir_filename+"/"+savefilename+filename_suffix+".csv");
        else
            exportgraphics(gcf,output_dir_filename+"/"+savefilename+filename_suffix+saveformat(k));
        end
    end




end