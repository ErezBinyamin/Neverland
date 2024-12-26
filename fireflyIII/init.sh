#!/bin/bash

main() (

  # Download source
  if [ -f "docker-compose.yml" ]
  then
    echo "[DOWNLOADED] docker-compose.yml"
  else
    wget "https://raw.githubusercontent.com/firefly-iii/docker/refs/heads/main/docker-compose-importer.yml" --output-document 'docker-compose.yml'
  fi
  if [ -f "app.env" ]
  then
    echo "[DOWNLOADED] app.env"
  else
    wget "https://raw.githubusercontent.com/firefly-iii/firefly-iii/refs/heads/main/.env.example" --output-document 'app.env'
  fi
  if [ -f "importer.env" ]
  then
    echo "[DOWNLOADED] importer.env"
  else
    wget "https://raw.githubusercontent.com/firefly-iii/data-importer/refs/heads/main/.env.example" --output-document 'importer.env'
  fi
  if [ -f "db.env" ]
  then
    echo "[DOWNLOADED] db.env"
  else
    wget "https://raw.githubusercontent.com/firefly-iii/docker/refs/heads/main/database.env" --output-document 'db.env'
  fi


  # Only generate keys/tokens once, save in local config file
  if [ -f init.env ]
  then
    source init.env
    echo "[LOADED] init.env"
  else
    local TZ=$(getTZ)
    local APP_KEY=$(head /dev/urandom | tr -dc 'a-zA-Z0-9' | head -c 32)
    local STATIC_CRON_TOKEN=$(head /dev/urandom | tr -dc 'a-zA-Z0-9' | head -c 32)
    local APP_URL=$(grep 'APP_URL' app.env | sed 's/APP_URL=//')
    printf "
    #!/bin/bash
    export TZ=${TZ}
    export APP_KEY=${APP_KEY}
    export STATIC_CRON_TOKEN=${STATIC_CRON_TOKEN}
    export APP_URL=${APP_URL}
    " >> init.env
    echo "[SAVED] init.env"
  fi
  
  # Make file edits/configurations/fixes
  if grep --quiet 'cron/REPLACEME' docker-compose.yml
  then
    sed -i \
      -e "s/: \.env/: app.env/" \
      -e "s/: \.db.env/: db.env/" \
      -e "s/: \.importer.env/: importer.env/" \
      -e "s#cron/REPLACEME#cron/${STATIC_CRON_TOKEN}#" docker-compose.yml
  else
    echo "[CONFIGURED] docker-compose.yml"
  fi

  if grep --quiet 'SomeRandomStringOf32CharsExactly' app.env
  then
    sed -i \
      -e "s@TZ=Europe/Amsterdam@TZ=${TZ}@" \
      -e "s@APP_KEY=SomeRandomStringOf32CharsExactly@APP_KEY=${APP_KEY}@" \
      -e "s@STATIC_CRON_TOKEN=@STATIC_CRON_TOKEN=${STATIC_CRON_TOKEN}@" app.env
  else
    echo "[CONFIGURED] app.env"
  fi

  if grep --quiet "^FIREFLY_III_URL=$" importer.env
  then
    sed -i \
      -e "s@FIREFLY_III_URL=@FIREFLY_III_URL=${APP_URL}@" \
      -e "s@TZ=Europe/Amsterdam@TZ=${TZ}@" importer.env
  else
    echo "[CONFIGURED] importer.env"
  fi

  return 0
)

getTZ() {
	# Source https://superuser.com/questions/309034/how-to-check-which-timezone-in-linux/1334239#1334239
	#set -euo pipefail
	
	if filename=$(readlink /etc/localtime); then
	    # /etc/localtime is a symlink as expected
	    timezone=${filename#*zoneinfo/}
	    if [[ $timezone = "$filename" || ! $timezone =~ ^[^/]+/[^/]+$ ]]; then
	        # not pointing to expected location or not Region/City
	        >&2 echo "$filename points to an unexpected location"
	        exit 1
	    fi
	    echo "$timezone"
	else  # compare files by contents
	    # https://stackoverflow.com/questions/12521114/getting-the-canonical-time-zone-name-in-shell-script#comment88637393_12523283
	    find /usr/share/zoneinfo -type f ! -regex ".*/Etc/.*" -exec \
	        cmp -s {} /etc/localtime \; -print | sed -e 's@.*/zoneinfo/@@' | head -n1
	fi
}

main $@
