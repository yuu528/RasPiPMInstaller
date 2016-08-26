#!/bin/bash
if [ uname -n = "raspberrypi" ]; then
	:
else
	exit
fi

#start
whiptail --title "RaspberryPi PMMP Installer" --yes-button "はい" --no-button "いいえ" --yesno "あなたが使用しているOSは、Raspbian LITE ですか?" 0 0
if $? ; then
	exit
fi

#askserver
value=(Genisys-master "(http://github.com/iTXTech/Genisys)" ClearSky-php7 "(http://github.com/ClearSkyTeam/ClearSky)" PocketMine-MP-master "(http://github.com/PocketMine/PocketMine-MP)")
srv=$(whiptail --title "RaspberryPi PMMP Installer" --ok-button "OK" --cancel-button "中止" --menu "選択してください" 0 0 0 "${value[@]}" 3>&1 1>&2 2>&3)
if $?; then
	end ユーザーが中止したため
fi

#if [ $srv = "その他" ]; then
#	srv=$(whiptail --title "RaspberryPi PMMP Installer" --ok-button "OK" --cancel-button "中止" --inputbox "GitHub リポジトリ名を入力してください" 0 0 3>&1 1>&2 2>&3)
#	if $?; then
#		:
#	else
#		end ユーザーが中止したため
#	fi
#fi

whiptail --title "RaspberryPi PMMP Installer" --msgbox "サーバーソフトウェアを $srv にセットしました。\nダウンロードを開始します。" 0 0 0 0
case $srv in
	"Genisys" ) git clone https://github.com/iTXTech/Genisys.git;;
	"ClearSky" ) git clone https://github.com/ClearSkyTeam/ClearSky.git;;
	"PocketMine-MP" ) git clone https://github.com/PocketMine/PocketMine-MP.git;;
esac

unzip $srv.zip
if [ -e "$srv" ]; then
	:
else
	end ダウンロードエラーのため
fi
cd $srv
wget https://bintray.com/pocketmine/PocketMine/download_file?file_path=PHP_7.0.6_ARM_Raspbian_hard.tar.gz && gzip -dc PHP_7.0.6_ARM_Raspbian_hard.tar.gz | tar xvf -
chmod -r 755 ./

mv start.sh pesrv

echo "export PATH=$PATH:/home/pi/$srv" >> ~/.bash_profile
source .bash_profile
whiptail --title "RaspberryPi PMMP Installer" --yes-button "はい" --no-button "いいえ" --yesno "サーバーのインストールが完了しました。\nOSの軽量化を行いますか?\n(GUIなど、サーバーに不必要なパッケージが削除されます。)" 0 0
if $?; then
	whiptail --title "RaspberryPi PMMP Installer" --msgbox "インストーラを終了します。以降は pesrv で実行できます。" 0 0 0 0
else
	cd ~/
	sudo apt-get update
	sudo apt-get install deborphan chkconfig
	sudo apt-get autoremove --purge "libx11-.*" "lxde-.*" raspberrypi-artwork xkb-data omxplayer penguinspuzzle sgml-base xml-core "alsa-.*" "cifs-.*" "samba-.*" "fonts-.*" "desktop-*" "gnome-.*"
	sudo apt-get remove dbus plymouth ntp alsa-utils triggerhappy motd avahi-daemon netatalk
	sudo apt-get autoremove -y wolfram-engine
	sudo apt-get autoremove -y scratch
	sudo apt-get autoremove -y python-pygame
	sudo apt-get autoremove -y pistore
	sudo apt-get autoremove -y sonic-pi
	sudo apt-get autoremove -y python-minecraftpi
	sudo apt-get autoremove -y idle idle3
	sudo apt-get autoremove -y netsurf-common dillo
	sudo apt-get autoremove -y debian-reference-common
	sudo apt-get autoremove -y libraspberrypi-doc
	sudo apt-get autoremove -y man manpages
	sudo apt-get autoremove -y git git-man
	sudo apt-get autoremove -y galculator
	sudo apt-get autoremove --purge $(deborphan)
	sudo apt-get autoremove --purge
	sudo apt-get autoclean
	rm -rf /home/pi/python_games/
	sudo rmdir /usr/local/games/
	sudo rmdir /usr/games/
	sudo apt-get update && sudo apt-get upgrade && sudo rpi-update
	sudo echo "tmpfs    /tmp    tmpfs    defaults,size=64m 0    0" >> /etc/fsfab
	sudo echo "tmpfs    /var/log    tmpfs    defaults,size=32m 0    0" >> /etc/fstab
	sudo rm -rf /tmp/*
	sudo rm -rf /var/log/*
	touch init-ramdisk
	echo \#\!/bin/sh>>init-ramdisk
	echo "### BEGIN INIT INFO">>init-ramdisk
	echo "# Provides:       init-ramdisk">>init-ramdisk
	echo "# Required-Start: $local_fs">>init-ramdisk
	echo "# Required-Stop:  $local_fs">>init-ramdisk
	echo "# Default-Start:  2 3 4 5">>init-ramdisk
	echo "# Default-Stop:   0 1 6">>init-ramdisk
	echo "### END INIT INFO">>init-ramdisk
	echo >>init-ramdisk
	echo chmod 775 /var/log>>init-ramdisk
	echo mkdir -p /var/log/ConsoleKit/>>init-ramdisk
	echo mkdir -p /var/log/fsck/>>init-ramdisk
	echo mkdir -p /var/log/apt/>>init-ramdisk
	echo mkdir -p /var/log/ntpstats/>>init-ramdisk
	echo mkdir -p /var/log/samba/>>init-ramdisk
	echo chown root.ntp /var/log/ntpstats/>>init-ramdisk
	echo chown root.adm /var/log/samba/>>init-ramdisk
	echo touch /var/log/lastlog>>init-ramdisk
	echo touch /var/log/wtmp>>init-ramdisk
	echo touch /var/log/btmp>>init-ramdisk
	echo chown root.utmp /var/log/lastlog>>init-ramdisk
	echo chown root.utmp /var/log/wtmp>>init-ramdisk
	echo chown root.utmp /var/log/btmp>>init-ramdisk
	sudo mv init-ramdisk /etc/init.d/init-ramdisk
	sudo chmod 755 /etc/init.d/init-ramdisk
	sudo chkconfig --add init-ramdisk
	sudo apt-get autoremove -y dphys-swapfile
	sudo apt-get install dropbear
	touch dropbear

	echo "# disabled because OpenSSH is installed">>dropbear
	echo "# change to NO_START=0 to enable Dropbear">>dropbear
	echo NO_START=0>>dropbear
	echo >>dropbear
	echo "# the TCP port that Dropbear listens on">>dropbear
	echo DROPBEAR_PORT=22>>dropbear
	echo >>dropbear
	echo "# any additional arguments for Dropbear">>dropbear
	echo DROPBEAR_EXTRA_ARGS="-w">>dropbear
	echo >>dropbear
	echo "# specify an optional banner file containing a message to be">>dropbear
	echo \# sent to clients before they connect, such as "/etc/issue.net">>dropbear
	echo DROPBEAR_BANNER="">>dropbear
	echo >>dropbear
	echo "# RSA hostkey file (default: /etc/dropbear/dropbear_rsa_host_key)">>dropbear
	echo "#DROPBEAR_RSAKEY="/etc/dropbear/dropbear_rsa_host_key"">>dropbear
	echo >>dropbear
	echo "# DSS hostkey file (default: /etc/dropbear/dropbear_dss_host_key)">>dropbear
	echo "#DROPBEAR_DSSKEY="/etc/dropbear/dropbear_dss_host_key"">>dropbear
	echo >>dropbear
	echo "# Receive window size - this is a tradeoff between memory and">>dropbear
	echo "# network performance">>dropbear
	echo DROPBEAR_RECEIVE_WINDOW=65536>>dropbear
	sudo mv dropbear /etc/default/dropbear
	sudo apt-get purge openssh-server
	whiptail --title "RaspberryPi PMMP Installer" --msgbox "インストーラは正常にインストールを完了しました。\nバグがあった場合は\nGitHub: http://github.com/yuu528/RasPiPMInstaller/issues\nまでお願いします。" 0 0 0 0
fi
exit

end () {
	whiptail --title "RaspberryPi PMMP Installer" --msgbox "インストーラは $1 中止されました。" 0 0 0 0
	exit
}