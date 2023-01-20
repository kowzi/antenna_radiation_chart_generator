function cmd_genfig_polar_sql_comparison(input_sqlite, output_dir, filenames, freq_plan, saveformat, alt_filenames, cmdColorOrder, cmdLineStyleOrder, cmdLineWidthOrder)
%UNTITLED Summary of this function goes here
%   input_sqlite    ... sqlite file to be read
%   output_dir      ... output directory
%   filename        ... filename table of sqlite to be read
%   freq_plan       ... frequency plan. ex. =[1993 2643 2993 3000]; =3000:1:3500;
%   saveformat      ... output file format. ex. = [".png"; ".emf"; ".fig"; ".csv";];
%   alt_filenames   ... alternate filename used for the legend. ex. = ["Proposed 1"; "Proposed 2";];
    
    conn = sqlite(input_sqlite,'readonly');
    
    % https://jp.mathworks.com/help/matlab/matlab_prog/pass-contents-of-cell-arrays-to-functions.html
    %line_styles = {"b-" "Color" "[0 0 1]" "LineWidth" 2; "b-" "Color" "[0 0 0]" "LineWidth" 1;};
        
        
    for m=1:1:length(freq_plan)
    
        % graph property
        ax = polaraxes;
        ax.ColorOrder = cmdColorOrder;          % https://jp.mathworks.com/help/matlab/creating_plots/defining-the-color-of-lines-for-plotting.html
        LineStyleOrder = cmdLineStyleOrder;
        LineWidthOrder = cmdLineWidthOrder;
        legend_titles = {};

        for n=1:1:length(filenames)
            %sqlquery = "select file_name, frequency_MHz, angle, antenna_gain_dBi from dut_gains as d where ROUND(d.frequency_MHz,1)>3999.0 and ROUND(d.frequency_MHz,1)<4000.0 and d.file_name='Horn_vs_Monopole_E03_01EE.csv'";
            sqlquery = sprintf("select file_name, frequency_MHz, angle, antenna_gain_dBi from dut_gains as d" + ...
                " where ROUND(d.frequency_MHz,1)>%0.1f and ROUND(d.frequency_MHz,1)<%0.1f and d.file_name='%s'",freq_plan(m)-1,freq_plan(m)+1,filenames(n));
            dut_antennas = fetch(conn, sqlquery);
            
            if ~isempty(dut_antennas)
                
                % Data Plot;
                % Technique to close the loop of the polar chart. [1:end 1] means make an array from 1 to end and add data(1) at last
                % Data flipping. use flip().
                if contains(filenames(n),'CFG-R')
                    antenna_gain_dBi = flip(dut_antennas.antenna_gain_dBi);
                else
                    antenna_gain_dBi = dut_antennas.antenna_gain_dBi;
                end
                angle_rad = dut_antennas.angle*(2*pi/360);
                angle_deg = dut_antennas.angle;
    
                hold on;
                p=polarplot(ax, angle_rad([1:end 1]),antenna_gain_dBi([1:end 1]),LineStyleOrder(n),'LineWidth',LineWidthOrder(n));
                %p.LineStyle="-";
                p.Marker="none";
    
                if contains(filenames(n),'VV_')
                    %freq    = [sprintf('%s: %.0f MHz - H-Plane',replace(filenames(n),".csv",""), dut_antennas.frequency_MHz(2))];
                    freq    = [sprintf('%s: %.0f MHz - H-Plane {\theta}', alt_filenames(n), dut_antennas.frequency_MHz(2))];
                    %p.Color = "#0072BD";
                elseif contains(filenames(n),'HH_')
                    %freq    = [sprintf('%s: %.0f MHz - E-Plane',replace(filenames(n),".csv",""), dut_antennas.frequency_MHz(2))];
                    freq    = [sprintf('%s: %.0f MHz - E-Plane {\theta}', alt_filenames(n), dut_antennas.frequency_MHz(2))];
                    %p.Color = "#D95319";
                elseif contains(filenames(n),'VH_')
                    %freq    = [sprintf('%s: %.0f MHz - E-Plane',replace(filenames(n),".csv",""), dut_antennas.frequency_MHz(2))];
                    freq    = [sprintf('%s: %.0f MHz - E-Plane {\phi}', alt_filenames(n), dut_antennas.frequency_MHz(2))];
                    %p.Color = "#D95319";
                elseif contains(filenames(n),'HV_')
                    %freq    = [sprintf('%s: %.0f MHz - E-Plane',replace(filenames(n),".csv",""), dut_antennas.frequency_MHz(2))];
                    freq    = [sprintf('%s: %.0f MHz - H-Plane {\phi}', alt_filenames(n), dut_antennas.frequency_MHz(2))];
                    %p.Color = "#D95319";
                else
                    %freq    = [sprintf('%s: %.0f MHz ',replace(filenames(n),".csv",""), dut_antennas.frequency_MHz(2))];
                    freq    = [sprintf('%s: %.0f MHz ', alt_filenames(n), dut_antennas.frequency_MHz(2))];
                    %p.Color = "#7E2F8E";
                end
                legend_titles = [legend_titles, freq];
            end
        end
    
        rlim([-30 10]);
        
        %% https://jp.mathworks.com/help/matlab/ref/matlab.graphics.axis.polaraxes-properties.html
        legend(ax, legend_titles,'Interpreter', 'none', 'Location', 'southoutside','FontSize',8);
        title('Antenna Gain [dBi]');
        ax.ThetaDir = 'clockwise';
        ax.ThetaZeroLocation = 'top';
        ax.FontSize=12;
        ax.FontName='Times New Roman';
        ax.FontWeight='bold';
    
        savefilename = sprintf("%s_%0.1fMHz",replace(filenames(1),".csv",""),freq_plan(m));
        file_output = output_dir+"/"+replace(filenames(1),".csv","");
        if not(exist(file_output,"dir"))
            mkdir(file_output);
        end
    
        %% .png file write -----
        for k=1:1:length(saveformat)
            if strcmp(saveformat(k),".fig")
                savefig(gcf,file_output+"/"+savefilename+".fig");
            elseif strcmp(saveformat(k),".csv")
                csvbuff_matrix = ['angle[deg]' strcat(savefilename,'[dBi]'); angle_deg antenna_gain_dBi];
                writematrix(csvbuff_matrix,file_output+"/"+savefilename+"_dut_gains.csv");
            else
                exportgraphics(gcf,file_output+"/"+savefilename+saveformat(k));
            end
        end
        clf;
    
    end
    
    close(conn);


end