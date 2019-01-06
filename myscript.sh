#!/bin/bash

##################################################################################################
#   -> Hi, for simplicity as of now, I've stored username, password and DB name in variables     #
#   -> I used to store them in .bashrc for a little security.                                    #
#   -> My script may generate a mysql warning on execution because password is exposed in this.  #
#   -> I've made one demo account on slack and created a sample workspace on it and made one     #
#       sample app where I've enabled webhook to send alert messages                             #
#   -> Kindly change password and db-name according to your requirement                          #
##################################################################################################

u="root"                             #mysql username
p="UZAC6YcTmIvlPukC"                 #mysql password
db="test_db"                    #mysql db_name
mysql -u $u -p$p -e "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE' AND TABLE_SCHEMA='$db'" > /tmp/mom
                                                                                  #storing all tables name of db in temporary file 
declare -i table_count=$(cat /tmp/mom | wc -l)  #storing count of table
declare -i tinyint=2**8                         #storing u-max value of tinyint 
declare -i smallint=2**16                       #storing u-max value of smallint
declare -i mediumint=2**24                      #storing u-max value of mediumint
declare -i int=2**32                            #storing u-max value of int
declare -i bigint=2**64                         #storing u-max value of bigint **storage capacity depends upon machine underlying architecture
for((i=table_count;i>=2;i--))                  
do                                                                     #traversing all tables in databases
  table_name=$(head -n $i /tmp/mom | tail -n 1)       #finding table name
  datatype=$(mysql -u $u -p$p -e "use $db; describe $table_name;" | grep --line-buffered  "auto_increment" | awk '{print $2}' | cut -d '(' -f 1 )                                                   #fetching datatype of auto-increment id of table
  declare -i  lastid=$(mysql -u $u -p$p -e "select TABLE_ROWS from information_schema.TABLES where TABLE_SCHEMA = '$db' AND table_name='$table_name';" | grep --line-buffered -o '[0-9]*')       #Fetching last autoincrement id of table
 declare -i remainingids                 # variable to store remaining autoincrement ids of a table
 if [ "$datatype" = "tinyint" ]         #comparing datatype of autoincrement idof table
 then
      remainingids=$tinyint-$lastid        #calculating remaining auto-increment ids of a table
 elif [ "$datatype" = "smallint" ];
 then
      remainingids=$smallint-$lastid
 elif [ "$datatype" = "mediumint" ];
 then 
      remainingids=$mediumint-$lastid
 elif [ "$datatype" = "int" ];
 then 
      remainingids=$int-$lastid
 else
      remainingids=$int-$lastid
 fi
 if [ $remainingids -lt 100 ]      # check if remaining ids are less than 100 for a table then trigger slack message alert webhook
   then
      curl -X POST -H 'Content-type: application/json' --data '{"text":"Hi there, '"$table_name"' is going to run out of auto-increment IDs soon."}' https://hooks.slack.com/services/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             #slack app workspace webhook url
 fi
done
rm -rf /tmp/mom              #removing temporary file made earlier
