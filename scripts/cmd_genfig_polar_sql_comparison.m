function cmd_genfig_polar_sql_comparison(input_sqlite, output_dir, filenames, freq_plan, saveformat, alt_filenames, cmdColorOrder, cmdLineStyleOrder, cmdLineWidthOrder, enGainTotal, enPeakMarker)
%UNTITLED Summary of this function goes here
%   input_sqlite    ... sqlite file to be read
%   output_dir      ... output directory
%   filename        ... filename table of sqlite to be read
%   freq_plan       ... frequency plan. ex. =[1993 2643 2993 3000]; =3000:1:3500;
%   saveformat      ... output file format. ex. = [".png"; ".emf"; ".fig"; ".csv";];
%   alt_filenames   ... alternate filename used for the legend. ex. = ["Proposed 1"; "Proposed 2";];
    
    rlim_min = -30;
    rlim_max = 10;
    
    % https://jp.mathworks.com/help/matlab/matlab_prog/pass-contents-of-cell-arrays-to-functions.html
    %line_styles = {"b-" "Color" "[0 0 1]" "LineWidth" 2; "b-" "Color" "[0 0 0]" "LineWidth" 1;};
        

%    for m=1:1:length(freq_plan)
    parfor m=1:length(freq_plan)

        conn = sqlite(input_sqlite,'readonly');
    
        % graph property
        clf;
        ax = polaraxes;
        if(enPeakMarker==false)
            ax.ColorOrder = cmdColorOrder;          % https://jp.mathworks.com/help/matlab/creating_plots/defining-the-color-of-lines-for-plotting.html
            LineStyleOrder = cmdLineStyleOrder;
        else
            ax.ColorOrder = [cmdColorOrder; 0 0.4470 0.7410];          % https://jp.mathworks.com/help/matlab/creating_plots/defining-the-color-of-lines-for-plotting.html
            LineStyleOrder = [cmdLineStyleOrder '-'];
        end

        LineWidthOrder = cmdLineWidthOrder;
        legend_titles = {};

        %% https://jp.mathworks.com/help/matlab/ref/matlab.graphics.axis.polaraxes-properties.html
        title('Antenna Gain [dBi]');
        ax.ThetaDir = 'clockwise';
        ax.ThetaZeroLocation = 'top';
        ax.FontSize=12;
        ax.FontName='Times New Roman';
        ax.FontWeight='bold';
        rlim([rlim_min rlim_max]);
        legend(ax, legend_titles, 'Location', 'southoutside', 'FontSize', 8);

        hold on;

        for n=1:1:length(filenames)
            %sqlquery = "select file_name, frequency_MHz, angle, antenna_gain_dBi from dut_gains as d where ROUND(d.frequency_MHz,1)>3999.0 and ROUND(d.frequency_MHz,1)<4000.0 and d.file_name='Horn_vs_Monopole_E03_01EE.csv'";
            sqlquery = sprintf("select distinct file_name, frequency_MHz, angle, antenna_gain_dBi from dut_gains as d" + ...
                " where ROUND(d.frequency_MHz,1)>%0.1f and ROUND(d.frequency_MHz,1)<%0.1f and d.file_name='%s'",freq_plan(m)-1,freq_plan(m)+1,filenames(n));
            dut_antennas = fetch(conn, sqlquery);
            
            if ~isempty(dut_antennas)
                
                % Data Plot;
                % Technique to close the loop of the polar chart. [1:end 1] means make an array from 1 to end and add data(1) at last
                % Data flipping. use flip().


                % --- structure/variables to be used for
                %   antenna_gain_dBi(n)        -- % value for all purpose
                %   antenna_gain_dBi_view(n)   -- % limited value by xlim only for the polarc chart
                %   angle_rad(n)               -- % value in radian for the polar chart
                %   angle_deg(n)               -- % value in degree for .csv file
                % --- Configuring the plot property
                if contains(filenames(n),'CFG-R')
                    antenna_gain_dBi = flip(dut_antennas.antenna_gain_dBi);
                else
                    antenna_gain_dBi = dut_antennas.antenna_gain_dBi;
                end

                if contains(filenames(n),'VV')
                    %p.Color = "#0072BD";
                    buf_legend    = sprintf('%s: %.1f MHz - H-Plane, E_{\\theta}', alt_filenames(n), dut_antennas.frequency_MHz(2));
                elseif contains(filenames(n),'HH')
                    %p.Color = "#D95319";
                    buf_legend    = sprintf('%s: %.1f MHz - E-Plane, E_{\\theta}', alt_filenames(n), dut_antennas.frequency_MHz(2));
                elseif contains(filenames(n),'VH')
                    %p.Color = "#D95319";
                    buf_legend    = sprintf('%s: %.1f MHz - E-Plane, E_{\\phi}', alt_filenames(n), dut_antennas.frequency_MHz(2));
                elseif contains(filenames(n),'HV')
                    %p.Color = "#D95319";
                    buf_legend    = sprintf('%s: %.1f MHz - H-Plane, E_{\\phi}', alt_filenames(n), dut_antennas.frequency_MHz(2));
                else
                    %p.Color = "#7E2F8E";
                    buf_legend    = sprintf('%s: %.1f MHz ', alt_filenames(n), dut_antennas.frequency_MHz(2));
                end

                antenna_gain_dBi_view = antenna_gain_dBi;                           
                antenna_gain_dBi_view(antenna_gain_dBi_view<rlim_min)=rlim_min;     
                
                angle_rad = dut_antennas.angle*(2*pi/360);
                angle_deg = dut_antennas.angle;  
    
                polarplot(ax, angle_rad([1:end 1]),antenna_gain_dBi_view([1:end 1]), 'Marker', 'none', 'LineStyle', LineStyleOrder(n), 'LineWidth', LineWidthOrder(n));

                legend_titles = [legend_titles, buf_legend];
                legend(ax, legend_titles, 'Location', 'southoutside','FontSize',8);

                if(enPeakMarker==true && n==1)
                    [PeakMarker_gain_dBi, index_pkmarker] = max(antenna_gain_dBi_view); 
                    PeakMarker_angle_rad = angle_rad(index_pkmarker);
                    PeakMarker_angle_deg = angle_deg(index_pkmarker);
                end

%                 % calculate a total-gain chart.
%                 if(enGainTotal==true)
%                     antenna_gain_total     = antenna_gain_total + 10.^((antenna_gain_dBi)/20);
%                     antenna_gain_dBi_total = 20*log10(antenna_gain_total); 
%                     antenna_gain_dBi_total(antenna_gain_dBi_total<rlim_min)=rlim_min;
%                     polarplot(ax, angle_rad([1:end 1]),antenna_gain_dBi_total([1:end 1]),'LineWidth',2);
%                 end

            end

        end

        % === placing a peak marker.
        if(enPeakMarker==true)
            buf_legend = sprintf("Peak gain %.1f dBi @ %d deg", PeakMarker_gain_dBi, PeakMarker_angle_deg);
            polarplot(ax, PeakMarker_angle_rad, PeakMarker_gain_dBi, 'Marker', 'o', 'DisplayName', buf_legend);
        end

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
    
    close(conn);
        
    end
    
    delete(gcp('nocreate'))

end