# Provision machine

Install machine
```
make setup
```

Create smbpassword
```
sudo smbpasswd -a mhe
```

Make user docker root
```
sudo usermod -aG docker mhe
```

Create password file for nginx
```
docker-compose run --rm nginx htpasswd mhe
```

Create password file for registry
```
docker-compose run --rm registry htpasswd -Bbn user pass > /auth/.htaccess
```

Create certificates
```
make ssl-standalone
```

Schedule ssl renewal
```
schedule `make ssl` using cron, cygwin cron or windows task scheduler
```

Start services
```
make start
```
