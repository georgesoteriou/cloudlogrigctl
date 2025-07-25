#! /bin/bash

# cloudlogbashcat.sh 
# A simple script to keep Cloudlog in synch with rigctld.
# Copyright (C) 2018  Tony Corbett, G0WFV
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

if [ -z "$cloudlogRadioId" ] || [ -z "$cloudlogApiKey" ] || [ -z "$cloudlogBaseURL" ] || [ -z "$rigctlRadioId" ]; then
  echo "Missing required environment variables. Please set cloudlogRadioId, cloudlogApiKey, cloudlogBaseURL, and rigctlRadioId."
  exit 1
fi

DEBUG=0

rigFreq=0
rigOldFreq=1

rigMode="MATCH"
rigOldMode="NO MATCH"
host=localhost
port=4532
cloudlogApiUrl="$cloudlogBaseURL/index.php/api/radio"

delay=1

echo "starting rigctl"
rigctld -m $rigctlRadioId -r /dev/ttyUSB0 &

sleep 2

while true; do
  
	# Open FD 3 to rig control server ...
	exec 3<>/dev/tcp/$host/$port

	if [[ $? -ne 0 ]]; then
		echo "Unable to contact server" >&2
		exit 1
	fi

	# Get rigctld frequency, mode and bandwidth - accepts multiple commands
	echo -e "fm" >&3
	read -r -u3 rigFreq
	read -r -u3 rigMode
	read -r -u3 rigWidth

	# Close FD 3
	exec 3>&-

  if [ $rigFreq -ne $rigOldFreq  ] || [ "$rigMode" != "$rigOldMode"  ]; then
    # rig freq or mode changed, update Cloudlog
    [[ $DEBUG -eq 1 ]] && printf  "%-10d   %-6s\n" $rigFreq $rigMode
    rigOldFreq=$rigFreq
    rigOldMode=$rigMode

    curl --silent --insecure \
         --header "Content-Type: application/json" \
         ${cloudlogHttpAuth:+"--header"} \
         ${cloudlogHttpAuth:+"Authorization: $cloudlogHttpAuth"} \
         --request POST \
         --data "{ 
           \"key\":\"$cloudlogApiKey\",
           \"radio\":\"$cloudlogRadioId\",
           \"frequency\":\"$rigFreq\",
           \"mode\":\"$rigMode\",
           \"timestamp\":\"$(date -u +"%Y/%m/%d %H:%M")\"
         }" $cloudlogApiUrl >/dev/null 2>&1
  fi

	sleep $delay
done

