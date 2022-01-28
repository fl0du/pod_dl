#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

echo -e "${ORANGE}******************************************************${NC}"
echo -e "${ORANGE}******************************************************${NC}"
echo -e "${ORANGE}***************** Podcast Downlaoder *****************${NC}"
echo -e "${ORANGE}******************************************************${NC}"
echo -e "${ORANGE}******************************************************${NC}"

if [ -z "$1" ];then
    echo -e "\n${RED}/!\ Arg 1 is needed : podcast emission name /!\ ${NC} \n"
    exit 1
fi

if [ -z "$2" ];then
    echo -e "\n${RED}/!\ Arg 2 is needed : year to get /!\ ${NC} \n"
    exit 1
fi

POD=$1
YEAR_TO_GET=$2

URL_DL_PAGE="https://www.franceinter.fr/emissions/$POD?p="
URL_POD="media.radiofrance-podcast.net"

#echo -e "$URL_DL_PAGE"
#echo -e "$URL_POD"
echo -e "\n${BLUE}------------------------------------------------------${NC}"
echo -e "\n${BLUE}---> $POD : $YEAR_TO_GET  ${NC}"
echo -e "\n${BLUE}------------------------------------------------------${NC}\n"

for i in {1..15}
do
    echo -e "${PURPLE} ------ Get Page : $i ------ ${NC}"
    #Download 
    wget  -q $URL_DL_PAGE$i -O "dl_page_$i_raw"

    if [ $? -ne 0 ]; then
	echo -e "${RED} /!\ Page : $i not available /!\ ${NC}"
	exit 1
    else
	cat "dl_page_$i_raw" | grep $URL_POD > "dl_page_$i"
	rm -f "dl_page_$i_raw"
	mkdir -p $POD
	
	while IFS= read -r line; do
	    URL_MP3=`echo "$line" | cat | cut -d \" -f 2`
	    #echo -e $URL_MP3
	    NAME_MP3=`echo "$URL_MP3" | cat | cut -d / -f 5`
	    #echo -e $NAME_MP3
	    DATE_MP3=`echo "$NAME_MP3" | cat | cut -d - -f 2`
	    #echo -e $DATE_MP3
	    MONTH_MP3=`echo "$DATE_MP3" | cat | cut -d \. -f 2`
	    #echo -e $MONTH_MP3
	    YEAR_MP3=`echo "$DATE_MP3" | cat | cut -d \. -f 3`

	    if [ "$YEAR_MP3" == "$YEAR_TO_GET" ]; then

		mkdir -p $POD/$YEAR_TO_GET
		
		if [ "$MONTH_MP3" == "01" ]; then
		    MONTH_FOLDER=janvier
		elif [ "$MONTH_MP3" == "02" ]; then
		    MONTH_FOLDER=fevrier
		elif [ "$MONTH_MP3" == "03" ]; then
		    MONTH_FOLDER=mars
		elif [ "$MONTH_MP3" == "04" ]; then
		    MONTH_FOLDER=avril
		elif [ "$MONTH_MP3" == "05" ]; then
		    MONTH_FOLDER=mai
		elif [ "$MONTH_MP3" == "06" ]; then
		    MONTH_FOLDER=juin
		elif [ "$MONTH_MP3" == "07" ]; then
		    MONTH_FOLDER=juillet
		elif [ "$MONTH_MP3" == "08" ]; then
		    MONTH_FOLDER=aout
		elif [ "$MONTH_MP3" == "09" ]; then
		    MONTH_FOLDER=septembre
		elif [ "$MONTH_MP3" == "10" ]; then
		    MONTH_FOLDER=octobre
		elif [ "$MONTH_MP3" == "11" ]; then
		    MONTH_FOLDER=novembre
		elif [ "$MONTH_MP3" == "12" ]; then
		    MONTH_FOLDER=decembre
		fi
		mkdir -p $POD/$YEAR_TO_GET/$MONTH_FOLDER	    
		wget -q $URL_MP3 -O $POD/$YEAR_TO_GET/$MONTH_FOLDER/$DATE_MP3.mp3

		if [ $? -ne 0 ]; then
		    echo -e "${RED} /!\ $URL_MP3 not available /!\ ${NC}"
		else
		    echo -e "${GREEN} :: $DATE_MP3 downloaded :: ${NC}"
		fi
	    fi	
	done < dl_page_$i
    fi
done

rm dl_page_*
tar -czf  "$POD".tar.gz $POD
