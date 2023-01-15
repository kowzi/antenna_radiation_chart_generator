Execute a script in ./scripts directory

SiteCal_Site19_KIT.mlx --> importing the measured site performance of .s2p with 0.1 MHz step linear interpolation. (\input_cal\Measurement_Site_19_KIT)
gain_interp.mlx        --> importing the antenna datasheet with an interpolation. run at ./input_cal/Datasheet_HornAnttena_ETS3115, 
set_sitecal.py         --> generating the calibration value. this is a final process.

radpat_csv2sqlite.py   --> importing .csv files in the ./input to a sqlite file

get_dutgain.py         --> calculating the dBi value of the dut antennas defined in the file (imported with radpat_csv2sqlite.py)

genfig_polar_sql.mlx   --> generating the figure files as demand
genfig_polar_sql_comparison.mlx  --> for a comparison
