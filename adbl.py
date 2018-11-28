#!/usr/bin/python

import sys, getopt
import datetime
import mysql.connector
import ConfigParser
import pprint

# =========================================================
# This file connects to the Lexical Database prototype and 
# produces a report in the form of a lexicon which will be 
# directly compiled by the FOMA Toolkit or XFST. 
# =========================================================

# python Reports.py --file=nroot.prq.foma --header=NRootPRQin --headershort=NRoot --lang=4 --type=12
def main(argv):
   Config = 'ConfigFile.ini'
   File = 'nroot.prq.foma'
   FileHeader = 'NRootPRQin'
   FileHeaderShort = 'NRoot'
   Language = 4
   Type = 12
   try:
      opts, args = getopt.getopt(argv,"hc:f:e:s:l:t:",["configfile=","file=","header=","headershort=","lang=","type="])
   except getopt.GetoptError:
      print 'Reports.py -c <configfile> -f <file> -e <fileheader> -s <fileheadershort> -l <language> -t <type>'
      sys.exit(2)
   for opt, arg in opts:
      if opt == '-h':
         print 'Reports.py -c <configfile> -f <file> -e <fileheader> -s <fileheadershort> -l <language> -t <type>'
         sys.exit()
      elif opt in ("-c", "--configfile"):
         Config = arg
      elif opt in ("-f", "--file"):
         File = arg
      elif opt in ("-e", "--header"):
         FileHeader = arg
      elif opt in ("-s", "--headershort"):
         FileHeaderShort = arg
      elif opt in ("-l", "--lang"):
         Language = arg
      elif opt in ("-t", "--type"):
         Type = arg
   config = ConfigParser.RawConfigParser()
   config.read(Config)
   SECTION = 'DEVELOPMENT'
   HOST = config.get(SECTION, 'HOST')
   USER = config.get(SECTION, 'USER')
   PASSWORD = config.get(SECTION, 'PASSWORD')
   DATABASE = config.get(SECTION, 'DATABASE')

   cnx = mysql.connector.connect(user=USER, database=DATABASE, host=HOST, password=PASSWORD)
   cursor = cnx.cursor(buffered=True)
   args = (FileHeaderShort,)
   cursor.callproc("sp_QueryEntries",args)
   fo = open(File, "wb")
   index = 0;
   fo.write("define "+FileHeader+" [\n")
   for result in cursor.stored_results():
     for lexicon_entry in result.fetchall():
       if index==0:
         x=lexicon_entry[0].encode('utf-8') 
         fo.write(" "+x[1:]+"\n")
       else:
         fo.write(lexicon_entry[0].encode('utf-8')+"\n") 
       index+=1
   fo.write("];\n")
   fo.close()

   cursor.close()
   cnx.close()

   cursor.close()
   cnx.close()

if __name__ == "__main__":
   main(sys.argv[1:])
