# csv to DataFrame: https://note.nkmk.me/python-pandas-read-csv-tsv/
# DataFrame: https://note.nkmk.me/python-pandas-dataframe-values-columns-index/
# Quick reference: https://atmarkit.itmedia.co.jp/ait/articles/2109/07/news025.html

## SQLite
# https://qiita.com/saira/items/e08c8849cea6c3b5eb0c
# https://lightgauge.net/database/sqlite/8629/          Insert multiple items


import os               # getting the timestamp of csv file
import glob             # finding files
import pandas as pd     # importing csv file to dataframe
import sqlite3          # accessing Sqlite3

# Comment for the datasets.
# 3mV (Vertical position in 3 m distance has most closest in our lab). over 8GHz are different. 

def sqlcmd_set_dut_gains(filename_db="sitecal.db", tbname_dut_gains_dBi="dut_gains", site_calval="site_calval_TAR3115_dataset_Data3mV"):
    conndb = sqlite3.connect(filename_db, detect_types=sqlite3.PARSE_DECLTYPES|sqlite3.PARSE_COLNAMES)    # enabling the conversion fucntions.

    cur = conndb.cursor()
    #sql_command = 'create table dut_gains as select d.file_name, d.file_date_unixepoch, d.frequency_MHz, d.angle, (d.meas_s21_dB-s.calval_0dBi) as antenna_gain_dBi from dut_meas as d inner join site_calval as s on ROUND(d.frequency_MHz,1) = s.frequency_MHz where d.angle NOT IN (360.0)'%() 
    sql_command = 'create table {} as select distinct d.file_name, d.file_date_unixepoch, d.frequency_MHz, d.angle, (d.meas_s21_dB-s.calval_0dBi) as antenna_gain_dBi from dut_meas as d inner join {} as s on ROUND(d.frequency_MHz,1) = s.frequency_MHz where d.angle NOT IN (360.0)'.format(tbname_dut_gains_dBi,site_calval)
    cur.execute(sql_command)
    conndb.commit()

if __name__ == "__main__":
    db_file = './output/antmeas.db'
    sqlcmd_set_dut_gains(db_file)

