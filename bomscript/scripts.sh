curl http://www.bom.gov.au/australia/radar/ > radar.html
grep "<area" radar.html | grep -v "national" > radararea.txt
awk -F '"' '{print $6 "/" $8 }' radararea.txt | awk -F "/" '{print $3 "." $4}' | awk -F "." '{print $1","$4}' > area128code.txt
curl ftp://ftp2.bom.gov.au/anon/gen/radar/ --user anonymous:guest > bomftp.txt
grep ".T." bomftp.txt |  awk '{print $9}'  > bomfiles.txt
awk -F "." '{print $1","$0}' bomfiles.txt > bomIdToFiles.csv
awk -F "," '{print $2","$1",area"}' area128code.txt >> bomIdToFiles.csv
awk -F "," '{if($3 == "")area[$1][count[$1]++]=$2; else search[$1]=$2 }END{for(b in search){for(j =0 ; j<=count[search[b]];j++) if(area[search[b]][j] != "")print b ",128,"  area[search[b]][j]; }}' bomIdToFiles.csv > nameToBomIdMap.csv
awk -F "," '{print $3}' nameToBomIdMap.csv > bomfiles1.txt
for f in $(cat bomfiles1.txt); do
   if curl --output /dev/null --silent --head --fail -J -O "http://ws.cdn.bom.gov.au/radar/$f";
        then
       		echo "$f exists" >> success.txt;
#		curl -J -O "http://ws.cdn.bom.gov.au/radar/$f"; 
	else
                echo "$f doesn't";
        fi
done
