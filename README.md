# Linux Atom Updater

This project was created to allow the Atom Editor (Atom.io) on Linux to be updated automatically either on a scheduled basis or with a simple command.

## Features

* Installs Atom Editor on your system
* Updates Atom Editor to the newest version possible
* Schedules updates on a daily, weekly or monthly basis for Atom Editor

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
