#!/bin/sh

echo 'Installing required packages'
read foo
apt-get -y install samba sssd ntp
DEBIAN_FRONTEND=noninteractive apt-get -y install krb5-user



# krb5.conf
echo 'Configuring Kerberos'
read foo

cat << EOF > /etc/krb5.conf
[libdefaults]
	default_realm = AD.FOOBAR.COM

# The following krb5.conf variables are only for MIT Kerberos.
	krb4_config = /etc/krb.conf
	krb4_realms = /etc/krb.realms
	kdc_timesync = 1
	ccache_type = 4
	forwardable = true
	proxiable = true

# The following libdefaults parameters are only for Heimdal Kerberos.
	v4_instance_resolve = false
	v4_name_convert = {
		host = {
			rcmd = host
			ftp = ftp
		}
		plain = {
			something = something-else
		}
	}
	fcc-mit-ticketflags = true

[realms]
	AD.FOOBAR.COM = {
		kdc = DC1.AD.FOOBAR.COM
		kdc = DC2.AD.FOOBAR.COM
		admin_server = DC1.AD.FOOBAR.COM
	}

[login]
	krb4_convert = true
	krb4_get_tickets = false

EOF



# ntp.conf
echo 'Configuring NTP'
read foo
sed -i.orig 's/^server/#server/g' /etc/ntp.conf

cat << EOF >> /etc/ntp.conf
server dc1.ad.foobar.com
server dc2.ad.foobar.com
EOF



# smb.conf
echo 'Configuring Samba'
read foo
cp /etc/samba/smb.conf /etc/samba/smb.conf.orig
cat << EOF > /etc/samba/smb.conf
[global]
   workgroup = AD
   client signing = yes
   client use spnego = yes
   kerberos method = secrets and keytab
   realm = AD.FOOBAR.COM
   security = ads

   server string = %h server (Samba, Ubuntu)
   dns proxy = no
   log file = /var/log/samba/log.%m
   max log size = 1000
   syslog = 0
   panic action = /usr/share/samba/panic-action %d
   server role = standalone server
   passdb backend = tdbsam
   obey pam restrictions = yes
   unix password sync = yes
   passwd program = /usr/bin/passwd %u
   passwd chat = *Enter\snew\s*\spassword:* %n\n *Retype\snew\s*\spassword:* %n\n *password\supdated\ssuccessfully* .
   pam password change = yes
   map to guest = bad user
   usershare allow guests = yes
EOF



# sssd.conf
echo 'Configuring SSSD'
read foo
cat << EOF > /etc/sssd/sssd.conf
[sssd]
services = nss, pam, sudo
config_file_version = 2
domains = AD.FOOBAR.COM

[domain/AD.FOOBAR.COM]
id_provider = ad
access_provider = ad
cache_credentials = True
override_homedir = /home/%d/%u
default_shell = /bin/bash
EOF

sudo chown root:root /etc/sssd/sssd.conf
sudo chmod 600 /etc/sssd/sssd.conf



# hosts
echo 'Configuring Hosts'
read foo
cat << EOF >> /etc/hosts
#192.168.3.1 dc1.ad.foobar.com dc1
#192.168.3.2 dc2.ad.foobar.com dc2
EOF

HOSTNAME=`hostname`
sed -i.orig "s/${HOSTNAME}/${HOSTNAME}.ad.foobar.com ${HOSTNAME}/g" /etc/hosts



# pam
echo 'Configuring PAM'
read foo
sed -i.orig '/session\s*required\s*pam_unix.so/a session required pam_mkhomedir.so skel=/etc/skel/ umask=0077' /etc/pam.d/common-session



# lightdm
echo 'Configuring LightDM'
read foo
cat << EOF >> /usr/share/lightdm/lightdm.conf.d/50-unity-greeter.conf
greeter-show-manual-login=true
greeter-hide-users=true
EOF
cat << EOF >> /usr/share/lightdm/lightdm.conf.d/50-ubuntu.conf
allow-guest=false
EOF



# restart services
echo 'Restarting SMBD'
read foo
systemctl restart smbd.service
echo 'Restarting NMBD'
read foo
systemctl restart nmbd.service
echo 'Restarting NTP'
read foo
systemctl restart ntp.service



# join the domain
echo 'Obtaining Kerberos ticket'
read foo
sudo kinit Administrator
echo 'Getting info about the obtained ticket'
read foo
sudo klist
echo 'Joining to the domain'
read foo
sudo net ads join -k

echo 'Restarting SSSD'
read foo
systemctl restart sssd.service
