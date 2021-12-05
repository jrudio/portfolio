caddy_endpoint=localhost:2019
caddy_file_remote=https://raw.githubusercontent.com/jrudio/portfolio/main/Caddyfile
caddy_bucket="gs://${caddy_bucket}"

# download caddy if doesn't exist
if [ ! -f /usr/local/bin/caddy ] && [ ! -f /usr/bin/caddy ]; then
    sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo tee /etc/apt/trusted.gpg.d/caddy-stable.asc
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
    sudo apt update
    sudo apt install caddy
fi

# pull caddy config
# if [ ! -f /etc/caddy/Caddyfile ]; then
#     echo "Downloading Caddyfile..."
#     wget -O /etc/caddy/Caddyfile $caddy_file_remote
# fi

# check if caddyfile exists
# if [ ! -f /etc/caddy/Caddyfile ]; then
#     echo "Caddyfile not found"
#     exit 1
# fi

# check if gsutil exists
if [ ! -f /usr/bin/gsutil ]; then
    echo "gsutil does not exist"
    echo "aborting"
    exit 1
fi

# add certificates to caddy
if [ ! -f /etc/caddy/certs/caddy.crt ] && [ ! -f /etc/caddy/certs/caddy.key ]; then
    echo "adding certificates to caddy..."
    mkdir -p /etc/caddy/certs
    gsutil cp $caddy_bucket/caddy.crt /etc/caddy/certs/caddy.crt

    # check again
    if [ ! -f /etc/caddy/certs/caddy.crt ] && [ ! -f /etc/caddy/certs/caddy.key ]; then
        echo "certificates added"
    fi
fi


# check if port is in use
caddy_port_check=$(sudo netstat -tulpn | grep LISTEN | grep 2019 | grep caddy)

if [[ $caddy_port_check ]]; then
    echo "caddy is already running. exiting..."
    exit 0
fi

# start caddy
sudo caddy start -config /etc/caddy/Caddyfile

caddy_response=$(curl --write-out %{http_code} --connect-timeout 3 --silent --output /dev/null $caddy_endpoint)

# test caddy is running
# response should either be 200 or 404 to be considered running
if [ $caddy_response -ne 200 ] && [ $caddy_response -ne 404 ]; then
    echo "caddy is not running"
    exit 1
else
    echo "caddy is running..."
fi

echo "startup finished"