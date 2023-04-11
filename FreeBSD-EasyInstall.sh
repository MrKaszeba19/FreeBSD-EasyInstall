#!/bin/sh

agree=0
if [ "$1" = "-y" ] ;
then
    agree=1
fi

# -----------------------------------------------
# install necessary things
echo "------------------------------------------------------------------"
echo "Updating FreeBSD packages..."
# TODO: change the updater
freebsd-update fetch
freebsd-update install
if [ "$?" -ne "0" ] ;
then
    echo "Error when updating FreeBSD packages."
    exit 1
    # TODO: add continue option
fi

echo "------------------------------------------------------------------"
echo "Installing XFCE..."
if [ "$agree" -eq "1" ] ;
then 
    pkg install -y xorg slim xfce
    if [ "$?" -ne "0" ] ;
    then
        echo "Error when installing XFCE."
        exit 1
    fi
else
    pkg install xorg slim xfce
    if [ "$?" -ne "0" ] ;
    then
        echo "Error when installing XFCE."
        exit 1
    fi
fi

#------------------------------------------------
# set up xfce things
echo "------------------------------------------------------------------"
echo "Applying global XFCE settings..."
echo '#----------------' >> /etc/rc.conf
echo '# xfce4 addition ' >> /etc/rc.conf
echo 'moused_enable="YES"' >> /etc/rc.conf 
echo 'dbus_enable="YES"' >> /etc/rc.conf
echo 'hald_enable="YES"' >> /etc/rc.conf
echo 'slim_enable="YES"' >> /etc/rc.conf
echo 'exec xfce4-session' >> /root/.xinitrc
echo "Done."

#------------------------------------------------
# set up users that might log in using XFCE
echo "------------------------------------------------------------------"
echo "Setting up users that may log in via XFCE"
usern="user"
while [ "s$usern" != "s" ]
do
    echo
    echo "Type an username of the user (or press RETURN to quit)"
    read usern
    if [ "s$usern" != "s" ] ;
    then
        echo "User: $usern"
        home_dir=`getent passwd "$usern" | cut -d : -f 6`
        if [ "a$home_dir" != "a" ] ; then
            echo "User exists"
            echo "Home directory: $home_dir"
            cp /root/.xinitrc "$home_dir/.xinitrc"
            pw groupmod video -m $usern
            pw groupmod wheel -m $usern
            echo "Done setting up $usern."
        else
            echo "Error when setting up $usern. This user probably does not exist."
        fi
    fi
done

# TODO: add option to remove root from video access
# TODO: add all users option
# TODO: add install basic software option
# TODO: convert all to functions

echo
echo "------------------------------------------------------------------"
echo "Done. Please reboot."

