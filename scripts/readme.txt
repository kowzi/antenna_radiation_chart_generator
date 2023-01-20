Execute a script in ./scripts directory

(1) SiteCal_Site19_KIT.mlx --> importing the measured site performance of .s2p with 0.1 MHz step linear interpolation. (\input_cal\Measurement_Site_19_KIT)
(2) gain_interp.mlx        --> importing the antenna datasheet with an interpolation. run at ./input_cal/Datasheet_HornAnttena_ETS3115, 
(3) set_sitecal.py         --> generating the calibration value. this is a final process.

(4) radpat_csv2sqlite.py   --> importing the radiation file in .csv format in the ./input to a sqlite file

(5) get_dutgain.py         --> calucurating the dBi value of the dut antennas defined in the file (imported with radpat_csv2sqlite.py)

(6) genfig_polar_sql.mlx   --> generating the figure files as demand
(7) genfig_polar_sql_comparison.mlx  --> for a comparison
