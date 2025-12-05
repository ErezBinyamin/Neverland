local_ip ()  { 
    ip -family inet address | grep --color=auto 'noprefixroute' | grep --color=auto -Po '(?<=inet[ ])([0-9]{1,3}[.]){3}[0-9]{1,3}' | head -n1
}

next_port () { 
    local PORT=${1};
    local USED_PORTS=$(echo $(netstat -awlpunt 2>/dev/null | grep -Eo ':[0-9]+ ' | tr -d ':' | sort -un));
    local NEXT_PORT=${PORT:-1024};
    while [[ "${USED_PORTS}" =~ "${NEXT_PORT}" ]]; do
        let NEXT_PORT++;
    done;
    echo ${NEXT_PORT}
}

pihole() {
	if docker container ls 2>/dev/null | grep -q 'pihole'
	then
		echo "Stopping pihole..."
		docker container stop pihole
		docker container rm pihole
		echo "pihole stopped"
	else
		# https://github.com/pi-hole/docker-pi-hole/blob/master/README.md 
		PIHOLE_BASE="${PIHOLE_BASE:-$(pwd)}"
		[[ -d "$PIHOLE_BASE" ]] || mkdir -p "$PIHOLE_BASE" || { echo "Couldn't create storage directory: $PIHOLE_BASE"; exit 1; }

		# Note: ServerIP should be replaced with your external ip.
		local P_DNS=$(next_port 53)
		local P_DHCP=$(next_port 67)
		local P_HTTP=$(next_port 80)
		local P_HTTPS=$(next_port 443)
		local TIMEZONE='America/New_York' # https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
		local WEBPASSWORD='pipass'
		local SERVER_IP=$(local_ip)
		
		printf "\nStarting up pihole container: http://${SERVER_IP}:${P_HTTP}\n\n"
		#printf "\nUsing Ports:\n\tDNS: ${P_DNS}\n\tHTTP: ${P_HTTP}\n\tHTTPS: ${P_HTTPS}\n\tDHCP: ${P_DHCP}\n\n"
		printf "\nUsing Ports:\n\tDNS: ${P_DNS}\n\tHTTP: ${P_HTTP}\n\tHTTPS: ${P_HTTPS}\n\n"

		# Required if you are using Pi-hole as your DHCP server, else not needed
		#    --publish ${P_DHCP}:67/udp
		#    --privileged
		docker run --detach \
		    --name pihole \
		    --publish ${P_DNS}:53/tcp \
		    --publish ${P_DNS}:53/udp \
		    --publish ${P_HTTP}:80/tcp \
		    --publish ${P_HTTPS}:443/tcp \
		    --volume "${PIHOLE_BASE}/etc-pihole/:/etc/pihole/" \
		    --volume "${PIHOLE_BASE}/etc-dnsmasq.d/:/etc/dnsmasq.d/" \
		    --dns=1.1.1.1 \
		    --dns=8.8.8.8 \
		    --restart=unless-stopped \
		    --hostname pi.hole \
		    --env VIRTUAL_HOST="pi.hole" \
		    --env PROXY_LOCATION="pi.hole" \
		    --env PIHOLE_DNS_="127.0.0.1#5353;8.8.8.8;8.8.4.4;1.1.1.1" \
		    --env TZ=${TIMEZONE} \
		    --env ServerIP=${SERVER_IP} \
		    --env WEBPASSWORD=${WEBPASSWORD} \
		    --restart=unless-stopped \
		    --cap-add=NET_ADMIN \
		    pihole/pihole:latest

		if [ $? -ne 0 ]
		then
			echo "[ERROR] Docker is complaining and wont start pihole"
			return 1
		fi

		printf "\n------------\nSleeping for 10 seconds\n"
		sleep 10
		wait

		if ! docker ps | grep --quiet 'pihole'
		then
			echo "[ERROR] pihole containter not running."
			return 1
		fi

		printf "\n------------\n> Checking container health:\n"
		for i in $(seq 1 20); do
		    if [ "$(docker inspect -f "{{.State.Health.Status}}" pihole)" == "healthy" ] ; then
		        printf ' OK'
		        echo -e "\n$(docker logs pihole 2> /dev/null | grep 'password:') for your pi-hole: https://${IP}/admin/"
		        return 0
		    else
		        sleep 3
		        printf '.'
		    fi

		    if [ $i -eq 20 ] ; then
		        echo -e "\nTimed out waiting for Pi-hole start, consult your container logs for more info (\`docker logs pihole\`)"
		        return 1
		    fi
		done;
	fi
}

