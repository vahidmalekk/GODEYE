#!/bin/bash

#get domain and print domain 
domain=$1

#check status code of command

status=`echo $?`

#color codes
red='\e[0;31m'
green='\e[0;32m'
yellow='\e[0;33m'
blue='\e[0;34m' 
white='\e[0;37m'

echo  -e "$yellow[ + ] start recon for $1 $white"


#check the directory of subdomains exist
if [ -d ./$1 ]
then 
echo "[ + ] direcoty project exsit."
else 
mkdir $1
echo "[ + ] directory project created"
fi

#change directory to subdomain directory 


#use tools and methodology for finding subdomain and check if the file exist  
if [ -f
 "./$1/domain.txt" ]
then 
echo "[ + ] subdomain file For $1 exist  "
echo  -e "[ + ] I have $red `wc -l $1/domain.txt | cut -d " " -f 1 ` $white subdomain of $1 in my database"

#tools

#subfinder
subfinder --silent -d $1 >> $1/new.txt
status=`echo $?`
echo -e  "[ + ]$green status code of subfider for $1 is $white $status" 

#cert.sh
curl -s "https://crt.sh?q=$1&output=json" |  jq ".[].common_name"| cut -d'"' -f2 | sed 's/\\n/\n/g' | sed 's/\*.//g'| sed -r 's/([A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4})//g' |sort | uniq | grep -E "*.$1" >> $1/new.txt 2>/dev/null
status=`echo $?`
echo -e  "[ + ]$green status code of cert.sh website for $1 is $white $status" 

#assetfinder 
echo "$1" | assetfinder -subs-only | grep -v "*" >> $1/new.txt
status=`echo $?`
echo -e  "[ + ]$green status code of assetfinder for $1 is $white $status"

#findomian
findomain -t pod.ir | grep -v "Searching in the" | grep -v "Target ==> " | grep -v "Good luck Hax0r " | grep -v "Job finished in " >> $1/new.txt
status=`echo $?`
echo -e "[ + ]$green status code of findomain for $1 is $white $status"

#chaos

chaos -key 786c2ce5-2122-4b47-bcd2-a5346ff11a22  -d $1 -silent >> $1/new.txt
status=`echo $?`
echo -e  "[ + ]$green status code of chaos for $1 is $white $status" 

#start endpoint discovery

#gau
for url in `cat $1/new.txt`
do
echo $url | gau --blacklist .svg,.png,.jpg,.css,.jpeg,.gif,.mp3,.mp4,.pdf >> $1/newendpoint 2>/dev/null
done
status=`echo $?`
echo -e  "[ + ]$green status code of gau for $1 is $white $status" 


#katana

katana -silent -list $1/new.txt| grep -v  -E "*.jpg|*.png|*.css|*.gif|*.mp3|*.jpeg|*.pdf|*.svg">> $1/newendpoint 
status=`echo $?`
echo -e  "[ + ]$green status code of katana for $1 is $white $status" 

#wayback 

cat $1/new.txt | waybackurls |  grep -v  -E "*.jpg|*.png|*.css|*.gif|*.mp3|*.jpeg|*.pdf|*.svg" >> $1/newendpoint 
status=`echo $?`
echo -e  "[ + ]$green status code of katana for $1 is $white $status" 

#hakrawler
cat $1/new.txt | httpx -silent  | hakrawler >> $1/newendpoint 
status=`echo $?`
echo -e  "[ + ]$green status code of #hakrawler for $1 is $white $status" 


#end of endpoint discovery

# sort endpoint 

cat $1/newendpoint | sort -u > $1/finalEndpoint
status=`echo $?`
echo -e  "[ + ]$green sorted endpoint with status code  $white $status" 

#extract subdomain from urls
cat $1/finalEndpoint | cut -d "/" -f 3 | grep "$1" | sort -u  >> $1/new.txt

echo -e  "[ + ]$green find subdomains from urls $white $status"

#find subdomain from content 

for u in `cat $1/finalEndpoint`
do
curl -s -k $u | grep -E "*.$1" | cut -d "/" -f 3 | sort -u >> $1/subfromcontent 
sleep 1
done
status=`echo $?`
echo -e  "[ + ]$green subdomain from content  status code  is $white $status" 


cat $1/subfromcontent | cut -d "/" -f 3  | sort -u  >> $1/new.txt


#compare the result of the out put with last time


##############################################



#extract js files from endpoint and search for critical words such as apikey,.....

cat $1/finalEndpoint | grep -E "*.js$" > newJSfiles
status=`echo $?`
echo -e  "[ + ]$green Creat new Js File with status  $white $status" 


#compare newJsfiles with last time


curl -s -k  | grep -E -i 

####################################################################################################################################################################
else

echo "[ + ] Creating Firt Demo File For $1"
#subfinder

subfinder --silent -d $1 >> $1/domain.txt
status=`echo $?`
echo -e "[ + ]$green status code of subfider for $1 is $white $status" 

#cert.sh
curl -s "https://crt.sh?q=$1&output=json" |  jq ".[].common_name"| cut -d'"' -f2 | sed 's/\\n/\n/g' | sed 's/\*.//g'| sed -r 's/([A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4})//g' |sort | uniq | grep -E "*.$1"  >> $1/domain.txt
status=`echo $?`
echo -e "[ + ]$green status code of cert.sh website for $1 is $white $status" 

#assetfinder 
echo "$1" | assetfinder -subs-only | grep -v "*" >> $1/domain.txt
status=`echo $?`
echo -e  "[ + ]$green status code of assetfinder for $1 is $white $status"

#finddomian
findomain -t pod.ir | grep -v "Searching in the" | grep -v "Target ==> " | grep -v "Good luck Hax0r " | grep -v "Job finished in " >> $1/domain.txt
status=`echo $?`
echo -e  "[ + ]$green status code of findomain for $1 is $white $status"

#chaos
chaos -key 786c2ce5-2122-4b47-bcd2-a5346ff11a22  -d $1 -silent >> $1/domain.txt
status=`echo $?`
echo -e  "[ + ]$green status code of chaos for $1 is $white $status" 

#endpoint discovery

#gau
for url in `cat $1/domain.txt`
do
echo $url | gau --blacklist .svg,.png,.jpg,.css,jpeg,.gif,.mp3,.mp4,.pdf  >> $1/endpoint 2>/dev/null
done
status=`echo $?`
echo -e  "[ + ]$green status code of gau for $1 is $white $status" 

fi

#katana

katana -silent -list $1/domain.txt | grep -v  -E "*.jpg|*.png|*.css|*.gif|*.mp3|*.jpeg|*.pdf|*.svg" >> $1/endpoint 2>/dev/null
status=`echo $?`
echo -e  "[ + ]$green status code of katana for $1 is $white $status"  

#wayback

cat $1/domain.txt | waybackurls |  grep -v  -E "*.jpg|*.png|*.css|*.gif|*.mp3|*.jpeg|*.pdf|*.svg" >> $1/endpoint
status=`echo $?`
echo -e  "[ + ]$green status code of katana for $1 is $white $status" 

#hakrawler
cat $1/domain.txt | httpx -silent  | hakrawler >> $1/endpoint
status=`echo $?`
echo -e  "[ + ]$green status code of hakrawler for $1 is $white $status" 
#end of endpoint discovery

# sort endpoint 

cat $1/endpoint | sort -u > $1/final
status=`echo $?`
echo -e  "[ + ]$green sorted endpoint with status code  $white $status" 

#extract subdomain from urls
cat $1/final | cut -d "/" -f 3 | grep "$1" | sort -u  >> $1/domain.txt

echo -e  "[ + ]$green find subdomains from urls $white $status"

#find subdomain from content 

for u in `cat $1/final`
do
curl $u | grep -E "*.$1" | cut -d "/" -f 3 | sort -u >> $1/sub
sleep 1
done
status=`echo $?`
echo -e  "[ + ]$green subdomain from content  status code  is $white $status" 


cat $1/sub| cut -d "/" -f 3  | sort -u  >> $1/domain.txt

#get Js files
cat $1/final | grep -E "*.js$" > JSfiles
status=`echo $?`
echo -e  "[ + ]$green Creat  Js File with status  $white $status" 



