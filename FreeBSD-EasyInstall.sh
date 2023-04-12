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
    dktop_name=$1
    
    ans_a="1"
    flag="0"
    while [ "$flag" != "1" ]
    do
        echo
        echo "What do you want to do?"
        echo "    1 - Make all users be able to log in via $dktop_name"
        echo "    2 - Choose which users can log in via $dktop_name"
        read ans_a
        echo $ans_a | grep "[^(1|2)]" > /dev/null 2>&1
        if [ "$?" -ne "0" ]; 
        then
            flag="1"
            if [ "$ans_a" = "1" ] ;
            then
                for item in `cat /etc/passwd | awk -F':' '{if ($3 >= 1000 && $3 <= 10000) print $1;}'`
                do
                    setup_user $item
                done
            else
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
            fi
        fi
    done

    # TODO: add option to remove root from video access
    # TODO: add install basic software option
}

# ===========================================================================
# 
# MAIN
#
# -----------------------------------------------
# install necessary things

dktop="xfce"
dktop_name="XFCE"

echo "------------------------------------------------------------------"
echo "Updating FreeBSD packages..."
update_packages

echo "------------------------------------------------------------------"
echo "Installing $dktop_name..."
install_desktop $dktop

#------------------------------------------------
# set up xfce things
echo "------------------------------------------------------------------"
echo "Applying global $dktop_name settings..."
configure_desktop $dktop

#------------------------------------------------
# set up users that might log in using XFCE
echo
echo "------------------------------------------------------------------"
echo "Setting up users that may log in via $dktop_name..."
configure_users_dialog $dktop_name

echo
echo "------------------------------------------------------------------"
echo "Done. Please reboot."

