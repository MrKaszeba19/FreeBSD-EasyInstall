# FreeBSD isntaller script

**Author:** RooiGevaar19 ([github](https://www.github.com/RooiGevaar19))

Here I'm working on a script that will allow full installation 
and configuration 
of FreeBSD along with grapical desktop environment 
and some useful programs.

## How to use

1. Install base FreeBSD, set up users etc., and reboot.
2. Log in as **root**
3. Install package manager, as well as `wget` and `git` packages
    - Type command `pkg install wget`. At this moment FreeBSD will configure `pkg`.
    - Then type `pkg install git`.  
4. Get EasyInstall script via either:
    - wget, i.e. `wget https://raw.githubusercontent.com/RooiGevaar19/FreeBSD-EasyInstall/master/FreeBSD-EasyInstall.sh`
    - cloning repository, i.e. `git clone https://github.com/RooiGevaar19/FreeBSD-EasyInstall.git`
   and follow its steps. You can automatically agree on all questions with `-y` flag.
5. Reboot with `reboot` command and enjoy. :smile:
