#!/usr/bin/python3



import datetime, argparse, sys
'''
########### parseWindows.py ###############
        Script to parse through Windows logs
        Version: %s
        Created by: Robert Crager (@RobbieBePoppin)
###########################################
         Usage: parseWindows.py -f <file> or <std.out text to terminal> | python3 parseWindows.py
         Optional: -t <time (windows log format [iso format])
            -i <timeframe> -s <search fields> -o <greppable output>
         -h for help :)
###########################################
'''

################# TODO ################

"""

## Sort all output data by timestamp ## ---- done

add the username, computer, process id, and new process id fields (optional, but maybe add a few as default options) ---- done

-	An option that writes the output to a delimited file for further processing  - in progress

- option to take piped input from bash

"""

#######################################

scrVers = "0.4"





############## SCRIPT SETUP #################

###### SETUP ARGS #######



notPipedInput=True

parser = argparse.ArgumentParser()

parser.add_argument("-f", "--filename", help = "[REQUIRED] Input File. Format: '-f win-log.txt' Can be replaced with a piped input.", required=False)

parser.add_argument("-t", "--searchtime", help = "[OPTIONAL,preferred] Time to Search For (isoFormat). Format: '-t 2022-05-06T16:51:57' Default: Will show every line with specified search terms, regardless of event time.")

parser.add_argument("-i", "--timeframe", help = "[OPTIONAL] Search Timeframe (mins). Format: '-i 5' Default: 3 Mins")

parser.add_argument("-s", "--searchfields", nargs='+',help = "[OPTIONAL] Fields to Pull from the Log. Format: '-s TimeCreated CommandLine NewProcessName'. (Delimited by a space) Default: TimeCreated CommandLine NewProcessName ParentProcessName")

parser.add_argument("-sA", "--searchExtendedfields",help = "[OPTIONAL] Pull extended set of fields from log. Looks for all default search fields as well as: TargetUserName, SubjectUserName, Computer, ProcessID, NewProcessID, EventID", action='store_true')

parser.add_argument("-o", "--output", help = "[OPTIONAL] Output in a greppable (searchable) format, where fields are separated by a comma (,).", action='store_true')

args = parser.parse_args()



## assign vars to args

## & set default values

filename = args.filename if args.filename!=None else ""

searchtime = args.searchtime if args.searchtime!=None else ""

timeframe = args.timeframe if args.timeframe!=None else 3

searchFields = args.searchfields if args.searchfields!=None else ["TimeCreated","CommandLine","NewProcessName","ParentProcessName"]

outputGrep = args.output if args.output!=None else False

extended = args.searchExtendedfields if args.searchExtendedfields!=None else False

fileRead = ""

dumpLog = False

oldVersion = False

notPipedInput = sys.stdin.isatty()



# for handling and holding the results received

class Result:

    def __init__(self,time, lineNum, params):

        self.time = time

        self.lineNum = lineNum

        self.params = params

    def __lt__(self,other):

        # I can't believe this is built into python

        # I love python (built-in sort function for classes)

        # maybe let user change this later on, not now though

        return self.time < other.time

    def outToStdOut(res):

        # print attributes to standard output

        print("\n--- Line %s ---" % res.lineNum)

        print("\t %s " % res.time)

        for x in res.params: # print remainder of parameters

            print('\t %s ' % x)



    def outputGrep(res,delimeter):

        # print results with specified delimeter

        # might be an issue to print on same line with res.params issue (contains \n character at end somehow) (makes sense for this to be part of the print statement in python without the end= param specified)

        print(str(res.time), end=delimeter) # maybe try end=delimeter variable make it easier overall

        for x in res.params:

            print(str(x), end=delimeter)

        print("--- Line %s ---" % res.lineNum)





# for easier seeing with your eyes and stuffs

def error(msg):

    error = "[!!! ERROR !!!] "

    print(error+msg+'\n')

    parser.print_help()

    exit()



info = "[--- INFO ---] "



def printHeader():

    print("""

    ########### parseWindows.py ###############

        Script to parse through Windows logs

        Version: %s

        Created by: Robert Crager (@RobbieBePoppin)

    ###########################################

         Usage: parseWindows.py -f <file> or <std.out text to terminal> | python3 parseWindows.py

         Optional: -t <time (windows log format [iso format])

            -i <timeframe> -s <search fields> -o <greppable output>

         -h for help :)

    ###########################################

    """ % scrVers)



#### for older versions ####

def converttoTime(str):

    ## expected input '2022-05-07t09:08:27'

    ## expected output: datetime.datetime.isoformat() object

    ## fromisoformat not avail in versions <3.7 py

        # So parse through string value and return datetime object

    dateObj = datetime.datetime(1,1,1) #set to 0001-01-01 by default

    date = str.upper().split('T')[0].split('-') #should be YYYY-MM-DD, but in list form [YYYY,MM,DD]

    time = str.upper().split('T')[1].split('.')[0].split(':') #should be HH:MM:SS.MS but in list form (& no MS) [HH,MM,SS]

    ## individual properties

    yr=int(date[0])

    mon = int(date[1])

    day = int(date[2])

    hr=int(time[0])

    try:

        #default to 00 if no value given

        min=int(time[1]) 

    except:

        min= 0

    try:

        #default to 00 if no value given

        sec=int(time[2]) 

    except:

        sec = 0



    try:

       dateObj = datetime.datetime(yr,mon,day,hr,min,sec)

    except:

        error("Error Converting the Date %s to a datetime. Exiting." % str)

    return dateObj



###### TRY ARGS GIVEN ######

if(not filename and notPipedInput): # if no filename and no pipe input

	error("Enter a file to read.")

elif(not filename and not notPipedInput): # if no filename and pipe input > use piped input

    fileRead=sys.stdin

else: # otherwise, filename should exist and attempt to read file

    try:

        fileRead=open(filename,'r').readlines()

    except IOError:

        error("File not found. Filename specified does not exist. Ensure you enter the full path of the file.")



try:

# reading and casting minutes

	timeframe = (int)(timeframe)

except:

    error("Invalid Timeframe Selected. Please enter an integer value.")



if(not searchtime):

    dumpLog = True

    print(info+"No Time Specified, Dumping File...")

else:

    oldVersion = (int(sys.version.split('.')[1])<7)

    try:

    # convert searchTime to time

        if(oldVersion):

            searchtime = converttoTime(searchtime.upper())

        else:

            searchtime = datetime.datetime.fromisoformat(searchtime.upper())

    except:

        error("Search Time specified is not valid. Please use only the following format: YYYY-MM-DDTHH:MM:SS EX. 2022-05-06T16:51:57")





if(extended):

    tmplst = ["NewProcessID","'ProcessID","EventID", "TargetUserName", "SubjectUserName", "Computer"]

    for x in tmplst:

        searchFields.insert(1,x)



if(timeframe==3 and searchFields==["TimeCreated","CommandLine","NewProcessName","ParentProcessName"]):

    print(info+"Using Default Values...")



# convert all items in searchFields to lowercase

tmp = map(lambda x: x.lower(), searchFields)

searchFields = list(tmp)



# ensure timecreated is in searchfield (for proper sorting)

if('timecreated' not in searchFields):

    searchFields.insert(0,"timecreated")



# if user piped input

if(not notPipedInput):

    filename="Piped Input"



if(dumpLog):

    print(info+"Searching %s for parameters: %s" % (filename,searchFields)) # just for debugging purposes

else:

    print(info+"Searching %s with timeframe: %s mins around time: %s for parameters: %s" % (filename,timeframe,searchtime,searchFields)) # just for debugging purposes

    

############## MAIN SCRIPT #################

def getAttr(searchLine, searches):

    output=[]

    # add each tag found to a temp list for adding to a Result Object later

    for tag in searches:

        if(tag in searchLine): #search for each parameter individually & add to bulk output

            endDelimeter = "</Data>".lower()

            startIndex = searchLine.find(tag) #first index of search string on given line

            testEndIndex = searchLine.find("/>",startIndex) #just to be safe ig

            customEndIndex = searchLine.find("/%s>" % tag,startIndex) #end with tag closing statement (ie. </eventid>)

            # I should restructure this part, but I don't want to deal with that right now --

            endIndex = searchLine.find(endDelimeter,startIndex) # End of <Data> tag since search string or /> whichever is first

            if(("timecreated" in tag) and (not dumpLog)):

                # maybe sort everything by time created ascending?

                startSearchTime = searchtime + (datetime.timedelta(minutes=-timeframe)) # get 'timeframe' before the time listed

                endSearchTime = searchtime + (datetime.timedelta(minutes=timeframe))# get 'timeframe' after the time listed

                # parse the systemtime variable (we know it's going to end with a />, so use testEndIndex)

                timeStr = searchLine[startIndex:testEndIndex]

                if(oldVersion): # fromisoformat not in version on SDL

                    listedTime = converttoTime(timeStr.split("'")[1]) # split by ' making it SystemTime='<isoTime>.<miliseconds>', then by . -> <isoTime> 

                else:

                    listedTime = datetime.datetime.fromisoformat(timeStr.split("'")[1].split('.')[0]) # split by ' making it SystemTime='<isoTime>.<miliseconds>', then by . -> <isoTime> 

                if(startSearchTime <= listedTime <= endSearchTime):

                    # add the results to output, otherwise

                    output.insert(0,listedTime) # incase it doesn't find the time first

                else:

                    # skip this line entirely if it's a required tag

                    output.clear()

                    return output

            else:

                # Only search for non 'timecreated' tags & add to output list

                # use the smallest value (so long as it's not set to -1)

                # remove from comparison list if -1 (cannot find tag end)

                compareList = [endIndex,testEndIndex,customEndIndex]

                if(endIndex==-1):compareList.remove(endIndex)

                if(testEndIndex==-1):compareList.remove(testEndIndex)

                if(customEndIndex==-1):compareList.remove(customEndIndex)

                realEndIndex = min(compareList)

                output.append(searchLine[startIndex:realEndIndex]) # Get substring of search string field

                # if((testEndIndex<endIndex) and (testEndIndex != -1)): #use the former value (/>)

                #     output.append(searchLine[startIndex:testEndIndex]) # Get substring of search string field

                # elif((customEndIndex<testEndIndex) and (customEndIndex<endIndex) and (customEndIndex != -1)):

                #     continue

                # else:

                #     output.append(searchLine[startIndex:endIndex]) # Get substring of search string field

            

        else: # if even 1 of the search terms isn't found, clear `the output entirely and don't print the search at all

            output.clear()

            return output

    return output



def main():

    printHeader()

    lineCounter=0

    results = [] # hold all results for current search

    for line in fileRead:

        lineCounter+=1

        line = line.lower() # sanitize the line so no case sensitive issues

        # make this into a for loop when passing in variable # of items from user (or just pass in a tuple or list natively & loop in function itself)

        lineSearch = getAttr(line,searchFields) #Get ParentProcessName Value

        if(not lineSearch):

            continue

        else:

            # crete a Result Object and add applicable parameters to it

            res = Result(lineSearch[0],lineCounter, lineSearch[1:]) # lineSearch[0] is time, then line, then all but first lineSearch items

            results.append(res)



    if(not results):

        print("[+++ COMPLETE +++] Search for %s returned 0 results!!" % (searchFields))

    else:

        # sort the results list

        # loop through and print each in order (has to be more efficient way but this works)

        results.sort() #does this affect the actual object or return the object??

        for x in results: # print results to standard output

            if(outputGrep):

                x.outputGrep(",")

            else:

                x.outToStdOut()



if __name__=="__main__":

    main()