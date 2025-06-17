# Firewall configuration for Development server

```shell
sudo ufw allow from 173.245.48.0/20 to any port 443 proto tcp
sudo ufw allow from 103.21.244.0/22 to any port 443 proto tcp
sudo ufw allow from 103.22.200.0/22 to any port 443 proto tcp
sudo ufw allow from 103.31.4.0/22 to any port 443 proto tcp
sudo ufw allow from 141.101.64.0/18 to any port 443 proto tcp
sudo ufw allow from 108.162.192.0/18 to any port 443 proto tcp
sudo ufw allow from 190.93.240.0/20 to any port 443 proto tcp
sudo ufw allow from 188.114.96.0/20 to any port 443 proto tcp
sudo ufw allow from 197.234.240.0/22 to any port 443 proto tcp
sudo ufw allow from 198.41.128.0/17 to any port 443 proto tcp
sudo ufw allow from 162.158.0.0/15 to any port 443 proto tcp
sudo ufw allow from 104.16.0.0/13 to any port 443 proto tcp
sudo ufw allow from 104.24.0.0/14 to any port 443 proto tcp
sudo ufw allow from 172.64.0.0/13 to any port 443 proto tcp
sudo ufw allow from 131.0.72.0/22 to any port 443 proto tcp
sudo ufw allow from 192.168.0.0/24 to any port 22 proto tcp
sudo ufw allow from 192.168.0.0/24 to any port 8080 proto tcp
sudo ufw allow from 192.168.0.0/24 to any port 9300 proto tcp
sudo ufw allow from 192.168.0.0/24 to any port 9098 proto tcp
sudo ufw allow from 127.0.0.1 to any port 3100 proto tcp
sudo ufw allow from 192.168.0.0/24 to any port 3100 proto tcp
sudo ufw allow from 192.168.0.0/24 to any port 9000 proto tcp
sudo ufw allow from 127.0.0.1 to any port 9000 proto tcp
sudo ufw allow from 192.168.0.0/24 to any port 9000 proto tcp
sudo ufw allow from 172.17.0.0/16 to any port 9000 proto tcp
sudo ufw allow from 172.18.0.0/16 to any port 9000 proto tcp
```
