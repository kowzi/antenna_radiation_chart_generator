Execute a script in ./scripts directory

(1) SiteCal_Site19_KIT.mlx --> importing the measured site performance of .s2p with 1 MHz step linear interpolation. (\input_cal\Measurement_Site_19_KIT)
  --> cmd_proc_import_sitedata.m (creating a sqlite-db file)
(2) gain_interp.mlx        --> importing the antenna datasheet with an interpolation. run at ./input_cal/Datasheet_HornAnttena_ETS3115, 
  --> cmd_proc_import_antenna_ETS3115.m
(3) set_sitecal.py         --> generating the calibration value. this is a final process.
  --> cmd_proc_generate_sitecalval.m
(4) radpat_csv2sqlite.py   --> importing the radiation file in .csv format in the ./input to a sqlite file
  --> cmd_proc_import_measured_csv.m
(5) get_dutgain.py         --> calucurating the dBi value of the dut antennas defined in the file (imported with radpat_csv2sqlite.py)
  --> cmd_proc_generate_dutgain.m
(6) genfig_polar_sql.mlx   --> generating the figure files as demand
  --> merged into cmd_genfig_polar_sql_comparison.m
(7) genfig_polar_sql_comparison.mlx  --> for a comparison
  --> cmd_genfig_polar_sql_comparison.m
(8) sp11_response.mlx
  --> TB_genfig_s11_response.mlx & cmd_*
(9) TB_genfig_polar_sql_comparison.mlx
  --> Merged into App_RadiationPattern.mlx