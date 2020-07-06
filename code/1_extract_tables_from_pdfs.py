import os, getpass, camelot
import pandas as pd



os.chdir('/Users/' + getpass.getuser())

ffile = [s for s in os.listdir('Dropbox/territorial_control/docs') if s.endswith('.pdf')]

for wave in [re.search('\\d+', f) for f in ffile]:
   if wave.group(0) == '34': page = '49-end'
   if wave.group(0) == '36': page = '63-end'
   if wave.group(0) == '28': page = '36-end'
   if wave.group(0) == '38': page = '41-end'
   if wave.group(0) == '30': page = '49-end'
   if wave.group(0) == '40': page = '52-end'
   if wave.group(0) == '44': page = '38-end'
   if wave.group(0) == '42': page = '55-end'
   if wave.group(0) == '32': page = '47-end'
   if wave.group(0) == '43': page = '54-85'
   if wave.group(0) == '35': page = '62-end'
   if wave.group(0) == '29': page = '40-end'
   if wave.group(0) == '37': page = '55-103'
   if wave.group(0) == '31': page = '72-end'
   if wave.group(0) == '27': page = '28-end'
   if wave.group(0) == '39': page = '110-end'
   if wave.group(0) == '41': page = '47-end'
   if wave.group(0) == '33': page = '49-end'

   tables = camelot.read_pdf('Dropbox/territorial_control/docs/' + wave, 
                        flavor = 'stream', edge_tol = 500, pages = page, row_tol = 40,
                          strip_text='\n')
    
   tablesn = pd.DataFrame()
   for table in tables:
      tablesn = tablesn.append(table.df)
   tablesn.to_csv('Dropbox/territorial_control/data/replaced_villages/' + wave_n.group(0) + '.csv')




# Intercept interviews:

for wave in ffile:
    wave_n = re.search('\\d+', wave)
    print(wave_n.group(0))
    if wave_n.group(0) == '34': page = '39-48'
    if wave_n.group(0) == '36': page = '49-62'
    if wave_n.group(0) == '28': page = '32-35'
    if wave_n.group(0) == '38': page = '33-40'
    if wave_n.group(0) == '30': page = '42-48'
    if wave_n.group(0) == '40': page = '44-51'
    if wave_n.group(0) == '44': page = '28-37'
    if wave_n.group(0) == '42': page = '46-54'
    if wave_n.group(0) == '32': page = '40-46'
    if wave_n.group(0) == '43': page = '44-53'
    if wave_n.group(0) == '35': page = '54-61'
    if wave_n.group(0) == '29': page = '33-39'
    if wave_n.group(0) == '37': page = '48-54'
    if wave_n.group(0) == '31': page = '65-71'
    if wave_n.group(0) == '27': page = '33-end'
    if wave_n.group(0) == '39': page = '45-52'
    if wave_n.group(0) == '41': page = '38-46'
    if wave_n.group(0) == '33': page = '41-48'
    
    tables = camelot.read_pdf('Dropbox/territorial_control/docs/' + wave, 
                        flavor = 'stream', edge_tol = 500, pages = page, row_tol = 40,
                          strip_text='\n')
    
   tablesn = pd.DataFrame()
   for table in tables:
      tablesn = tablesn.append(table.df)
   tablesn.to_csv('Dropbox/territorial_control/data/intercept_interviews/' + wave_n.group(0) + '.csv')



# tables = camelot.read_pdf('/Users/mariamilosh/Dropbox/State_Reach/DATA/ANQAR/ANQAR_METHOD_REPORTS/ANQAR Wave ' + wave + ' Methods Report v1.pdf',
#  flavor = 'stream',
#   edge_tol = 500,
#   pages = page,
#    row_tol = 40)


# Cross ref tables
# wave = '29'
# page = '33-39'
# tables = camelot.read_pdf('/Users/mariamilosh/Dropbox/State_Reach/DATA/ANQAR/ANQAR_METHOD_REPORTS/ANQAR Wave ' + wave + ' Methods Report v1.pdf',
#  flavor = 'stream', edge_tol = 500,
#   pages = page,
#    row_tol = 13.6)