set -e

echo build starting nginx config

export ssl_certificate=/etc/letsencrypt/live/hernrup.se/fullchain.pem;
export ssl_certificate_key=/etc/letsencrypt/live/hernrup.se/privkey.pem;
export ssl_trusted_certificate=/etc/letsencrypt/live/hernrup.se/chain.pem;

LETSENCRYPT_ENABLED=true ;

if [ ! -d /etc/letsencrypt/live/hernrup.se ] ;
then
    LETSENCRYPT_ENABLED=false ;
fi

if [ ! -f /etc/letsencrypt/live/hernrup.se/fullchain.pem ] ;
then
    LETSENCRYPT_ENABLED=false ;
fi

if [ ! -f /etc/letsencrypt/live/hernrup.se/privkey.pem ] ;
then
    LETSENCRYPT_ENABLED=false ;
fi


if [ "$LETSENCRYPT_ENABLED" = false ] ;
then
    echo 'Letsencypt certificates missing, generating self-signed'

    mkdir -p /etc/cert/selfsigned
    openssl req -x509 -newkey rsa:4096 -sha256 -nodes -keyout /etc/cert/selfsigned/privkey.pem -out /etc/cert/selfsigned/cert.pem -subj "/CN=*.hernrup.se" -days 3650
    mkdir -p /etc/letsencrypt/live/hernrup.se
    cp /etc/cert/selfsigned/cert.pem /etc/letsencrypt/live/hernrup.se/chain.pem
    cp /etc/cert/selfsigned/cert.pem /etc/letsencrypt/live/hernrup.se/fullchain.pem
    cp /etc/cert/selfsigned/privkey.pem /etc/letsencrypt/live/hernrup.se/privkey.pem
fi

echo 'Running consul-template'
consul-template -once -config /etc/consul_template/config.json

echo 'Starting nginx'
nginx -g 'daemon off;'
