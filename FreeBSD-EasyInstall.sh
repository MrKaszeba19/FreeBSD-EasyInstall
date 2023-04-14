#!/bin/sh

agree=0
if [ "$1" = "-y" ] ;
then
    agree=1
fi

welcome_screen() {
    clear
    echo
    echo
    echo
    echo
    echo
    echo
    echo
    echo "   ______            ______  ___________ "
    echo "   |  ___|           | ___ \\/  ___|  _  \\"
    echo "   | |_ _ __ ___  ___| |_/ /\\ '--.| | | |  |--    _      |  _  __|_   | |"
    echo "   |  _| '__/ _ \\/ _ \\ ___ \\ '--. \\ | | |  |--/\\ (  \\  / | | |(  | /\\ | |"
    echo "   | | | | |  __/  __/ |_/ //\__/ / |/ /   |__\\/\\_)  \\/  | | |_) | \\/\\ \ \\"
    echo "   \\_| |_|  \\___|\\___\\____/ \\____/|___/              V"
    echo
    echo "                            by RooiGevaar19, 2023"
}

choose_desktop() {
    flag=0
    dktop=0
    while [ "$flag" != "1" ]
    do
        clear
        echo "What desktop do you want to have?"
        echo "    1 - Xfce"
        echo "    2 - GNOME"
        echo "    3 - KDE Plasma"
        echo 
        echo "    0 - Exit"
        read ans_a
        echo $ans_a | grep "[^0-2]" > /dev/null 2>&1
        if [ "$?" -ne "0" ]; 
        then
            flag=1
            case $ans_a in
	            1)
                    echo "You've picked XFCE."
                    dktop=1
	    	    ;;
	            2)
                    echo "You've picked GNOME."
                    dktop=2
	    	    ;;
                2)
                    echo "You've picked KDE."
                    dktop=3
	    	    ;;
                0)
                    echo "Quitting."
                    exit 0
                ;;
	            *)
		            fatal_error 1 "Error when picking up the desktop. This desktop does not exist or is not supported."
		        ;;
            esac
        fi
    done
    return $dktop;
}

fatal_error () {
    code=$1
    msg=$2
    echo $msg
    exit $code
}

update_packages () {
    if [ "$agree" -eq "1" ] ;
    then 
        pkg upgrade -y
        if [ "$?" -ne "0" ] ;
        then
            fatal_error 2 "Error when updating FreeBSD packages."
            # TODO: add continue option
        fi
    else
        pkg upgrade
        if [ "$?" -ne "0" ] ;
        then
            fatal_error 2 "Error when updating FreeBSD packages."
            # TODO: add continue option
        fi
    fi
}

# TODO: Add support for slim, gdm

install_desktop () {
    dk=$1
    case $dk in
	    xfce)
	    	if [ "$agree" -eq "1" ] ;
            then 
                pkg install -y xorg slim xfce
            else
                pkg install xorg slim xfce
            fi
	    	;;
	    gnome)
	    	if [ "$agree" -eq "1" ] ;
            then 
                pkg install -y xorg gdm gnome gnome-desktop gnome-session
            else
                pkg install xorg gdm gnome gnome-desktop gnome-session
            fi
	    	#break
	    	;;
        kde)
	    	if [ "$agree" -eq "1" ] ;
            then 
                pkg install -y kde5 plasma5-sddm-kcm sddm xorg
            else
                pkg install kde5 plasma5-sddm-kcm sddm xorg
            fi
	    	;;
	    *)
		    fatal_error 3 "Error when searching $dk. This desktop does not exist or is not supported."
		    ;;
    esac
    if [ "$?" -ne "0" ] ;
    then
        fatal_error 4 "Error when installing $dk."
    fi
}

configure_desktop () {
    dk=$1
    echo '#------------------------------' >> /etc/rc.conf
    echo '# freebsd-easyinstall addition ' >> /etc/rc.conf
    echo 'dbus_enable="YES"' >> /etc/rc.conf
    case $dk in
	    xfce)
            echo 'moused_enable="YES"' >> /etc/rc.conf 
            echo 'hald_enable="YES"' >> /etc/rc.conf
            echo 'slim_enable="YES"' >> /etc/rc.conf
	    	echo 'exec xfce4-session' >> /root/.xinitrc
	    	;;
	    gnome)
            echo 'moused_enable="YES"' >> /etc/rc.conf 
            echo 'hald_enable="YES"' >> /etc/rc.conf
	    	echo 'gnome_enable="YES"' >> /etc/rc.conf
            echo 'gdm_enable="YES"' >> /etc/rc.conf
            echo 'proc /proc procfs rw 0 0' >> /etc/fstab
	    	#break
	    	;;
        kde)
            echo 'sddm_enable="YES"' >> /etc/rc.conf 
            echo 'proc /proc procfs rw 0 0' >> /etc/fstab
	    	#break
	    	;;
	    *)
		    fatal_error 5 "Error when searching $dk. This desktop does not exist or is not supported."
		    ;;
    esac
    if [ "$?" -ne "0" ] ;
    then
        fatal_error 6 "Error when configuring $dk."
    fi
    # TODO: check if the lines already exist in the files
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

    ans_a="1"
    flag="0"
    while [ "$flag" != "1" ]
    do
        echo
        echo "Do you want to prevent root from logging in via Xfce?"
        echo "    0 - No"
        echo "    1 - Yes"
        read ans_a
        echo $ans_a | grep "[^(0|1)]" > /dev/null 2>&1
        if [ "$?" -ne "0" ]; 
        then
            flag="1"
            if [ "$ans_a" = "1" ] ;
            then
                rm /root/.xinitrc
            fi
        fi
    done
    # TODO: add install basic software option
}

# ===========================================================================
# 
# MAIN
#
# -----------------------------------------------
# install necessary things
clear
welcome_screen
sleep 1
clear
choose_desktop
opt=$?
dktop=""
case $opt in
    1)
        dktop="xfce"
    	dktop_name="XFCE"
        ;;
    2)
        dktop="gnome"
    	dktop_name="GNOME"
        ;;
    2)
        dktop="kde"
    	dktop_name="KDE Plasma"
        ;;
    *)
	    fatal_error 3 "Error when searching $dktop. This desktop does not exist or is not supported."
	    ;;
esac

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
if [ "$dktop" = "xfce" ] ;
then
    echo
    echo "------------------------------------------------------------------"
    echo "Setting up users that may log in via $dktop_name..."
    configure_users_dialog $dktop_name
fi

echo
echo "------------------------------------------------------------------"
echo "Done. Please reboot."

