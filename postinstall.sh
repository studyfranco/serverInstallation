#! /bin/bash
apt-get update
apt-get dist-upgrade -y
apt-get install -y htop iotop bash-completion pigz fail2ban apt-transport-https ca-certificates curl wget gnupg gnupg2 git rsync portsentry

echo "[sshd]
enabled = true

[recidive]
enabled = true
bantime = -1
findtime = 604800
banaction = iptables-allports" >> /etc/fail2ban/jail.d/defaults-debian.conf

# Il est conseillé de changer les configs de iptables-allports.conf
#actionban = <iptables> -I f2b-<name> 1 -s <ip> -j <blocktype>
#                echo '<ip>' >> /etc/init.d/firewall.block.ip
#puis de décommenter la ligne de deban dans le firewall

sed -ie '0,/maxretry = [0-9]*/ s/maxretry = [0-9]*/maxretry = 5/' /etc/fail2ban/jail.conf
sed -ie '0,/findtime  = [0-9]*/ s/findtime  = [0-9]*/findtime  = 6000/' /etc/fail2ban/jail.conf
sed -ie '0,/dbpurgeage = [0-9]*/ s/dbpurgeage = [0-9]*/dbpurgeage = 604800/' /etc/fail2ban/fail2ban.conf

service fail2ban restart

wget -O- https://raw.githubusercontent.com/studyfranco/server_installation/master/firewall | tee /etc/init.d/firewall
wget -O- https://raw.githubusercontent.com/studyfranco/server_installation/master/firewall.block.ip | tee /etc/init.d/firewall.block.ip
chmod 700 /etc/init.d/firewall
chmod 700 /etc/init.d/firewall.block.ip
update-rc.d firewall defaults;

mv /etc/skel/.bashrc /etc/skel/.bashrc.old
cp /root/.bashrc /root/.bashrc.old
wget -O- https://raw.githubusercontent.com/studyfranco/server_installation/master/bashrc | tee /etc/skel/.bashrc
cp /etc/skel/.bashrc /root/

#write out current crontab
crontab -l > /tmp/mycron
#echo new cron into cron file
echo "0 3 * * * /etc/init.d/firewall restart" >> /tmp/mycron
#install new cron file
crontab /tmp/mycron
rm /tmp/mycron

apt-get install -y cron-apt
echo "autoclean -y
dist-upgrade -y -o APT::Get::Show-Upgraded=true" > /etc/cron-apt/action.d/3-download

apt-get install -y software-properties-common xtables-addons-common libtext-csv-xs-perl libnet-cidr-lite-perl --no-install-recommends
perl -MCPAN -e'install Text::CSV_XS'
/usr/libexec/xtables-addons/xt_geoip_dl
mkdir -p /usr/share/xt_geoip
/usr/libexec/xtables-addons/xt_geoip_build -D /usr/share/xt_geoip *.csv

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null


apt-get update
apt-get install -y cgroupfs-mount docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin --no-install-recommends

exit 0