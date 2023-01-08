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

def dut_meas_csv2sqlite(filepath_name="",filename_db="antmeas.db", db_table="dut_meas"):

    #filename_meas_csv = 'Horn_vs_Dipole_01EE.csv'
    filename_meas_csv = os.path.split(filepath_name)[1]

    df = pd.read_csv(filepath_name,header=1,index_col=0)
    csv_date  = os.path.getctime(filepath_name)
    csv_index = df.index
    csv_columns = df.columns

    #filename_db     = filename_meas_csv.split('.')[0] + '.db'
    conndb = sqlite3.connect(filename_db,detect_types=sqlite3.PARSE_DECLTYPES|sqlite3.PARSE_COLNAMES)    # enabling the conversion fucntions.
    sqlite3.dbapi2.converters['DATETIME'] = sqlite3.dbapi2.converters['TIMESTAMP']                  # definig the api 'DATETIME'. actual data type of SQLite3 is CHAR.

    cur = conndb.cursor()
    cur.execute( 'CREATE TABLE IF NOT EXISTS '+db_table+'(\
        id INTEGER PRIMARY KEY AUTOINCREMENT,\
        file_name TEXT,\
        file_date_unixepoch REAL,\
        frequency_MHz REAL,\
        angle REAL,\
        meas_s21_dB REAL)')
    conndb.commit()

    # ---- execute, lapse time 16.6 sec
    #for col in csv_columns:
    #    for idx in csv_index:
    #        cur.execute('INSERT INTO measurement(file_name, file_date_unixepoch, freq_GHz, angle, meas_s21_dB) values(?,?,?,?,?)',[filename_meas_csv,csv_date,float(col.split("GHz")[0]),abs(idx-360),float(df.loc[idx,col])])

    # ---- execute many, lapse time 14.6 sec
    freq_points = []
    for col in csv_columns:
        db_buff = []
        col_MHz = float(col.split("GHz")[0])*1000
        freq_points.append(str(col_MHz))
        for idx in csv_index:
            db_buff.append([filename_meas_csv,csv_date,col_MHz,abs(idx-360),float(df.loc[idx,col])])
        cur.executemany('INSERT INTO '+db_table+'(file_name, file_date_unixepoch, frequency_MHz, angle, meas_s21_dB) values(?,?,?,?,?)',db_buff)

    conndb.commit()
    with open(filename_meas_csv.split('.')[0]+'_freq.pts', mode='w') as f:
       for freq_point in freq_points:
        f.write(freq_point+'\n')

    conndb.close()

if __name__ == "__main__":
    db_file = '../antmeas.db'
    #if os.path.exists(db_file):
    #    os.remove(db_file)
    #    print('Removed old file:'+db_file)

    #csvfiles = glob.glob('*.csv', recursive=False)
    csvfiles = glob.glob('./**/*.csv', recursive=True)
    cnt = 1
    for csvfile in csvfiles:
        print('Processing...[%d/%d] %s'%(cnt,len(csvfiles),csvfile))
        #print(os.path.split(csvfile)[1])
        dut_meas_csv2sqlite(csvfile,db_file,'dut_meas')
        cnt=cnt+1

