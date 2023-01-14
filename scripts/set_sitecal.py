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

def sqlcmd_set_site_calvals(filename_db="sitecal.db"):
    conndb = sqlite3.connect(filename_db, detect_types=sqlite3.PARSE_DECLTYPES|sqlite3.PARSE_COLNAMES)    # enabling the conversion fucntions.

    cur = conndb.cursor()
    cur.execute( 'create table if not exists site_calval as select s.frequency_MHz, (s.s21_dB-t.gain_dBi) as calval_0dBi from Site_Measurement as s inner join TAR3115_dataset_Data3mV as t on s.frequency_MHz = t.frequency_MHz')
    cur.execute( 'create table if not exists site_calval_TAR3115_dataset_Data1mV as select s.frequency_MHz, (s.s21_dB-t.gain_dBi) as calval_0dBi from Site_Measurement as s inner join TAR3115_dataset_Data1mV as t on s.frequency_MHz = t.frequency_MHz')
    cur.execute( 'create table if not exists site_calval_TAR3115_dataset_Data1mH as select s.frequency_MHz, (s.s21_dB-t.gain_dBi) as calval_0dBi from Site_Measurement as s inner join TAR3115_dataset_Data1mH as t on s.frequency_MHz = t.frequency_MHz')
    cur.execute( 'create table if not exists site_calval_TAR3115_dataset_Data3mV as select s.frequency_MHz, (s.s21_dB-t.gain_dBi) as calval_0dBi from Site_Measurement as s inner join TAR3115_dataset_Data3mV as t on s.frequency_MHz = t.frequency_MHz')
    cur.execute( 'create table if not exists site_calval_TAR3115_dataset_Data3mH as select s.frequency_MHz, (s.s21_dB-t.gain_dBi) as calval_0dBi from Site_Measurement as s inner join TAR3115_dataset_Data3mH as t on s.frequency_MHz = t.frequency_MHz')
    conndb.commit()

if __name__ == "__main__":
    db_file = '../antmeas.db'
    sqlcmd_set_site_calvals(db_file)

