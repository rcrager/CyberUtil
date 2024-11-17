#!/bin/bash

#####################################
#### Author: @RobbieBePoppin ########
#### Automate pulling request #######
#### counts for IOC URLs.    ########
#####################################

# if for some reason you want to use this, change all the PATH_REDACTED to an appropriate file path
# this was made for a specific use case though, so mainly just saving it for general practices

# SDL can be about 30 mins behind, so wait until 30 min mark for pulling these

# use this for the cronjob --> outFile="PATH_REDACTED-$searchDate_$searchTime"

searchDate=$(date '+%Y-%m-%d')
sdlDate=$(date '+%Y/%m/%d')
searchTime=$(date -d '-1 hour' +'%H')
FILE=$(PATH_REDACTED | grep "Copying output" | cut -d " " -f 4)


# gives us the full path of output file for current date
# with this being run every hour we have fully updated and automated information ready to pass into script to get necessary dates

# read the log data and parse it for only IOCs:
# ideally the IOCs are in a list or array of some sort so they're easy to change
cat $FILE | grep -E '"IOC_WEB_PATH_1"|"IOC_WEB_PATH_2"|"IOC_WEB_PATH_ETC"' > PATH_REDACTED-parse-tmp.txt

# read the IOCs log data for only the timeframe listed (last hour for current day):
cat PATH_REDACTED-parse-tmp.txt | grep "$searchDate $searchTime" > PATH_REDACTED-parse-tmp-time.txt

# need to do 2 things with grepOut, 1) pull the request count by IP & 2) get start and end time for each IP
reqCount=$(cat PATH_REDACTED-parse-tmp-time.txt | cut -d "," -f 12 | sort | uniq -c | sort -rn > PATH_REDACTED-parse-tmp-reqCount.txt)

loop=$(cat PATH_REDACTED-parse-tmp-time.txt | cut -d "," -f 12 | sort | uniq)

# 2) get start and end for each IP (after list of IPs in separate file or command/loop)
for line in $loop
do
# after cutting to only ip, lookup start and end times, echo them to same line?
# then get associated request count by grepping reqcount file for IP in loop line and add it to line

# order is Req count, IP, Start, Stop time
 reqIP=$(cat PATH_REDACTED-parse-tmp-reqCount.txt | grep $line)
 reqCount=$(echo $reqIP | cut -d " " -f 1)
 reqIP=$(echo $reqIP | cut -d " " -f 2)
 echo -ne "$reqCount,"
 echo -ne "$reqIP,"
 echo -ne "$(cat PATH_REDACTED-parse-tmp-time.txt | grep $line | cut -d "," -f 5 | sort | head -1),"
 echo -ne "$(cat PATH_REDACTED-parse-tmp-time.txt | grep $line | cut -d "," -f 5 | sort | tail -1)\n"
done


#clean up temp files
rm PATH_REDACTED-parse-tmp.txt
rm PATH_REDACTED-parse-tmp-time.txt
rm PATH_REDACTED-parse-tmp-reqCount.txt

# print header (will be sorting numerically anyways)
echo "Running report for $(date) ---"
echo "IOCs Searching for listed in share path under PATH_REDACTED_IOCs.txt --"

#echo "---> IOC_WEB_PATH_1"
#echo "---> IOC_WEB_PATH_2"
#echo "---> IOC_WEB_PATH_ETC"