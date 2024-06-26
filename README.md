# FreeBSD easy interface installer script

```
______            ______  ___________ 
|  ___|           | ___ \/  ___|  _  \
| |_ _ __ ___  ___| |_/ /\ `--.| | | |  |--    _      |  _  __|_   | |
|  _| '__/ _ \/ _ \ ___ \ `--. \ | | |  |--/\ (  \  / | | |(  | /\ | |
| | | | |  __/  __/ |_/ //\__/ / |/ /   |__\/\_)  \/  | | |_) | \/\ \ \
\_| |_|  \___|\___\____/ \____/|___/              V
```

**Author:** MrKaszeba19 ([github](https://www.github.com/MrKaszeba19)) and Szowisz ([github](https://github.com/Szowisz))

Here we are working on a script that will allow full installation 
and configuration 
of FreeBSD along with graphical desktop environment 
and some useful programs.

## How to use

1. Install base FreeBSD, set up users etc., and reboot.
2. Log in as **root**
3. Install package manager, as well as `wget` and `git` packages
    - Type command `pkg install wget`. At this moment FreeBSD will configure `pkg`.
    - Then type `pkg install git` (optional).  
4. Get EasyInstall script via either:
    - wget, i.e. `wget https://raw.githubusercontent.com/MrKaszeba19/FreeBSD-EasyInstall/master/FreeBSD-EasyInstall.sh`
    - cloning repository, i.e. `git clone https://github.com/MrKaszeba19/FreeBSD-EasyInstall.git`
5. Add execute privileges to the obtained script, i.e. `chmod +x FreeBSD-EasyInstaller.sh`
6. Run your script, e.g. `./FreeBSD-EasyInstaller.sh`
   and follow its steps. You can automatically agree on all questions with `-y` flag.
7. Reboot with `reboot` command and enjoy. :smile:

## Available graphical desktop environments

- Xfce
- GNOME
- KDE Plasma

## Issues

- Logging in via KDE Plasma desktops does not work with Wayland (use X11 instead)


