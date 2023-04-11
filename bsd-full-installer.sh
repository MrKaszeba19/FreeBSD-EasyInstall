# -----------------------------------------------
# install necessary things
echo "Updating FreeBSD packages..."
freebsd-update fetch
freebsd-update install
echo "Installing XFCE..."
pkg install -y xorg
pkg install slim
pkg install xfce
if [ $? -ne 0 ] ;
then
    echo "Error when installing XFCE."
    exit 1
fi

#------------------------------------------------
# set up xfce things
echo "Applying global XFCE settings..."
echo '#----------------' >> /etc/rc.conf
echo '# xfce4 addition ' >> /etc/rc.conf
echo 'moused_enable="YES"' >> /etc/rc.conf 
echo 'dbus_enable="YES"' >> /etc/rc.conf
echo 'hald_enable="YES"' >> /etc/rc.conf
echo 'slim_enable="YES"' >> /etc/rc.conf
echo 'exec xfce4-session' >> /root/.xinitrc

#------------------------------------------------
# set up users that might log in using XFCE
usern="user"
while [ -n "usern" ]
do
    echo
    echo "Setting up users that may log in via XFCE"
    echo "Type an username of the user (or press RETURN to quit)"
    read USER
    if [ "s$usern" -ne "s" ] ;
    then
        echo "User: $usern"
        home_dir=`getent passwd "$usern" | cut -d : -f 6`
        cp /root/.xinitrc "$home_dir/.xinitrc"
        pw groupmod video -m $usern
        pw groupmod wheel -m $usern
        echo "Done setting up $usern."
    fi
done

echo
echo "Done. Please reboot."

