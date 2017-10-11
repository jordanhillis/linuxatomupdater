![LAU Logo](https://jordanhillis.com/images/github/lau/logo.png)

This project was created to allow the Atom Editor (Atom.io) on Linux to be updated automatically either on a scheduled basis or with a simple command.

### Why Linux Atom Updater?

Atom Editor is a text editor built for Windows, Mac, and Linux but lacks the ability to update to the latest stable version on Linux. There are PPA's available to have the latest Atom Editor version but with using those you are allowing yourself to possibly receive malicious packages. Additionally PPA's are sometimes maintained very poorly and contain older packages than what the latest stable release currently is from the official maintainer.
With Linux Atom Editor we take security in mind and grab the latest version right from Atom Editor's GitHub repository to ensure the security of your system and that you are indeed receiving the latest stable build. 

## Features

* Installs Atom Editor on your system
* Updates Atom Editor to the newest version possible
* Only receives updates from the official Atom Editor repository on GitHub
* Schedules updates on a daily, weekly or monthly basis for Atom Editor

### Latests Version

* v1.0

### Prerequisites

Before using this program you will need to be on a Debian based system and have the following packages installed.
* wget
* cron

To install all required packages enter the following command.

```
sudo apt-get install cron wget
```

### Installing

To install Linux Atom Updater please enter the following commands

```
git clone https://github.com/jordanhillis/linuxatomupdater.git
cd linuxatomupdater
chmod +x lau.sh
./lau.sh
```

After you have ran those commands you can now use the command: "atomupdater" for future use of the program

### Usage

Example of usage:
```
 atomupdater [OPTION]

-u,   --update        Updates Atom to the newest version

-s    --scheduler     Have Atom updated on a scheduled basis

-v,   --version       Shows current version of Linux Atom Updater

-r    --remove        Uninstall Linux Atom Updater from system
```

## Developers

* **Jordan Hillis** - *Lead Developer*

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* This program is not an official program by the Atom.io Team or GitHub
