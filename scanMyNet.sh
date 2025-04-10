#!/bin/bash#####################################################################
#          Automatically detects new ip in a given Network and performs some   #   
#          Scans and graps informations like open Ports, Services and Vendor   #
#          CAUTION: This script depends on nmap and is running very Loud scans #
#          just use this script in regulated environments with legal permission#
################################################################################


# loadingScreen(){

#}


checkDependencies(){

}

checkRootPrivileges(){
  if [[ "${EUID}" -ne 0 ]]; then                                               # check for root priviliges       
    echo "The Nmap OS detection scan type (-O) requires root privileges."
    exit 1
  fi
}

checkInput(){                                                                  # Check if the two expected arguments are set
  if [[ -z "$1" ]] ; then
    echo "You must provide a target network to this script."
    echo "${0} 167.123.177.0/24 :for scanning a external network"
    echo "${0} local            :for scanning a internal network"
    exit 1
  fi
}


scanWithARP(){
  echo "Performing an arp-scan against ${network}..."
    sudo arp-scan -x -I ${interface} ${network} | while read -r line; do       
      host=$(echo "${line}" | awk '{print $1}')                               
      if ! grep -q "${host}" "${myIps}"; then                            
        echo "Found a new host: ${host}!"                                     
        echo "${host}" >> "${myIps}"
      fi
    done
}




# STEP 1: Only scan if IP list doesn't exist
runLoudNetworkScan(){
if [[ ! -s "$myIps" ]]; then
    echo "Running a loud network scan against: $targetNetwork"
    nmapScan=$(sudo nmap -sn ${targetNetwork})

    while IFS= read -r line; do
        if [[ "$line" == "Nmap scan report for"* ]]; then
            ip=$(echo "$line" | awk '{print $NF}' | tr -d '()')
            echo "$ip" >> "$myIps"
        fi
    done <<< "$nmapScan"
else
    echo "[+] Skipping host discovery scan, '$myIps' already exists."
fi
}
runLoudNetworkScan

# STEP 2: Only run detailed scan if output.txt doesn't exist
runDetailedNetworkScan(){
if [[ ! -s "$output" ]]; then
    echo "[+] Running detailed Nmap scan with -A"
    nmapScanAggr=$(sudo nmap -A -iL "$myIps")

    echo -e "IP\tMAC\tPORT\tSTATE\tSERVICE\tVERSION" > "$output"

    current_ip=""
    mac=""
    while IFS= read -r line; do
        if [[ "$line" == "Nmap scan report for"* ]]; then
            current_ip=$(echo "$line" | awk '{print $NF}' | tr -d '()')
        elif [[ "$line" == *"MAC Address:"* ]]; then
            mac=$(echo "$line" | awk -F "MAC Address: " '{print $2}' | awk '{print $1}')
        elif [[ "$line" =~ ^[0-9]+/tcp ]]; then
            port=$(echo "$line" | awk '{print $1}')
            state=$(echo "$line" | awk '{print $2}')
            service=$(echo "$line" | awk '{print $3}')
            version=$(echo "$line" | cut -d' ' -f4-)

            echo -e "${current_ip}\t${mac}\t${port}\t${state}\t${service}\t${version}" >> "$output"
        fi
    done <<< "$nmapScanAggr"
else
    echo "[+] Skipping Nmap -A scan, '$output' already exists."
fi
}
runDetailedNetworkScan


# STEP 3: Add vendor column using MAC address
scanForVendorName(){
declare -A macVendors

for mac in $(awk '{print $2}' "$output" | grep -E '([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}' | sort -u); do
    if [[ -n "$mac" ]]; then
        vendor=$(curl -s "https://api.macvendors.com/${mac}")
        macVendors["$mac"]="$vendor"
        sleep 3
    fi
done

echo -e "IP\tMAC\tPORT\tSTATE\tSERVICE\tVERSION\tVENDOR" > output_with_vendor.txt
tail -n +2 "$output" | while read -r line; do
    mac=$(echo "$line" | awk '{print $2}')
    if [[ "$mac" =~ ([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2} ]]; then
        vendor="${macVendors[$mac]}"
    else
        vendor="-"
    fi
    echo -e "$line\t$vendor" >> output_with_vendor.txt
done

echo "[+] Done. Output written to 'output_with_vendor.txt'"
}
scanForVendorName



################################################################################
main(){
  checkRootPrivileges
  checkInput "$1"
  
  myIps="networkIPs.txt"
  output="output.txt"
  targetNetwork="$1"
  interface=$(ip -o -4 addr show up | awk '{print $2}' | head -n 1)
  previous_size=$(stat -c %s "$filename")

  while [[ true ]]; do
    scanWithARP
    runLoudNetworkScan
    runDetailedNetworkScan
    scanForVendorName 
    sleep $((RANDOM % 121 + 20))
  done
  
}

main"$@"











