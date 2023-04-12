#!/bin/sh

agree=0
if [ "$1" = "-y" ] ;
then
    agree=1
fi

update_packages () {
    if [ "$agree" -eq "1" ] ;
    then 
        pkg upgrade -y
        if [ "$?" -ne "0" ] ;
        then
            echo "Error when updating FreeBSD packages."
            exit 1
            # TODO: add continue option
        fi
    else
        pkg upgrade
        if [ "$?" -ne "0" ] ;
        then
            echo "Error when updating FreeBSD packages."
            exit 1
            # TODO: add continue option
        fi
    fi
}

install_desktop () {
    dk=$1
    if [ "$agree" -eq "1" ] ;
    then 
        pkg install -y xorg slim $dk
        if [ "$?" -ne "0" ] ;
        then
            echo "Error when installing $dk."
            exit 1
        fi
    else
        pkg install xorg slim $dk
        if [ "$?" -ne "0" ] ;
        then
            echo "Error when installing $dk."
            exit 1
        fi
    fi
}

configure_desktop () {
    dk=$1
    echo '#------------------------------' >> /etc/rc.conf
    echo '# freebsd-easyinstall addition ' >> /etc/rc.conf
    echo 'moused_enable="YES"' >> /etc/rc.conf 
    echo 'dbus_enable="YES"' >> /etc/rc.conf
    echo 'hald_enable="YES"' >> /etc/rc.conf
    echo 'slim_enable="YES"' >> /etc/rc.conf
    if [ "$dk" = "xfce" ] ;
    then
        echo 'exec xfce4-session' >> /root/.xinitrc
    else
        echo "Error when configuring $dk."
        exit 1
    fi
}

setup_user () {
    usern=$1
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
}

configure_users_dialog () {
    usern="user"
    while [ "s$usern" != "s" ]
    do
        echo
        echo "Type an username of the user (or press RETURN to quit)"
        read usern
        if [ "s$usern" != "s" ] ;
        then
            setup_user $usern
        fi
    done

    # TODO: add option to remove root from video access
    # TODO: add all users option
    # TODO: add install basic software option
}

# ===========================================================================
# 
# MAIN
#
# -----------------------------------------------
# install necessary things
echo "------------------------------------------------------------------"
echo "Updating FreeBSD packages..."
update_packages

echo "------------------------------------------------------------------"
echo "Installing XFCE..."
install_desktop xfce

#------------------------------------------------
# set up xfce things
echo "------------------------------------------------------------------"
echo "Applying global XFCE settings..."
configure_desktop xfce

#------------------------------------------------
# set up users that might log in using XFCE
echo "------------------------------------------------------------------"
echo "Setting up users that may log in via XFCE"
configure_users_dialog

echo
echo "------------------------------------------------------------------"
echo "Done. Please reboot."

