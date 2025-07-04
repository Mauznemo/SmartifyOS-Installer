# SmartifyOS Installer

>[!CAUTION]
>**Disclaimer:** This software is currently in the development phase and is intended for developers. It is not suitable for general use in vehicles yet.

## About

### Short description:
SmartifyOS is a base application (source code) that makes it easy for you to create a custom GUI for a DIY infotainment system in older cars. It is based on the [Unity Game Engine](https://unity.com/), which means you have almost unlimited possibilities to customize it to your liking.

[More](https://smartify-os.com/about)

### This repo contains:
1. The "one click installer" .sh file to auto install and setup an Debian with LXDE machine
2. All other files the main Unity app depends on like Android Auto, etc.


## Supported Platforms
| Platform         | Supported |
| ---------------- | --------- |
| Debian with LXDE | yes       |

## How to Install
### Install Debian with LXDE
<details>
  <summary><b>Simple Install</b></summary>

  1. Download [this](https://minio.smartify-os.com/downloads/debian-faime.iso) pre-made ISO Debian file (made with [fai-project.org](https://fai-project.org/FAIme/))
  2. Flash it to a USB drive and boot it on the computer (with for example [balenaEtcher](https://etcher.balena.io/))
  3. After reboot login username `debian` password `debian`
  4. Install LXDE and openbox
      ```
      sudo apt update
      ```
      ```
      sudo apt install lxde-core openbox
      ```
   5. Reboot the system
      ```
      sudo reboot
      ```
   
</details>

<details>
  <summary><b>Manual Install</b></summary>

  1. Download the [Debian ISO](https://www.debian.org/download) file
  2. Flash it to a USB drive and boot it on the computer (with for example [balenaEtcher](https://etcher.balena.io/))
   <details>
      <summary>Steps in Debian installer</summary>

  3. Select "Install"
  4. Select Language and Keyboard Layout
  5. Select Internet device (LAN Recommended)
  6. Name the system
  7. Set **NO** root password (this will install sudo and add your new user to sudoers)
  8. Select time zone
  9. Select "Guided - use entire disk"
  10. Select the drive to install the system on
  11. Select "All files in one partition"
  12. Then "Finish partitioning and write changes to disk" and "Yes"
  13. Select your mirror country
  14. Deselect "Debian desktop environment" and "GNOME" (Space)
   </details>

  15. After reboot login with your username and password
  16. Install LXDE and openbox
      ```
      sudo apt update
      ```
      ```
      sudo apt install lxde-core openbox
      ```
   17. Reboot the system
       ```
       sudo reboot
       ```
</details>

### Install SmartifyOS

<details open>
   <summary><b>Simple Install</b></summary>

1. Open the Export window in Unity (`Ctrl + E` or `SmartifyOS > Export`)
2. Select a USB drive and click "Export Installer"
3. On the mini computer press `Super (Win) + E` and open the usb drive, select the folder "SmartifyOS-Installer", right click it and select `Copy`
4. Go into "Documents", right click and select paste
5. Right click on the `SmartifyOS-Installer` folder and click open in terminal
6. Run
   ```
   chmod +x Install.sh
   ```
7. And then
   ```
   ./Install.sh
   ```
</details>

<details>
   <summary><b>Manual Install</b></summary>

1. Clone the repo
   ```
   git clone https://github.com/Mauznemo/SmartifyOS-Installer.git
   ```
2. Go into the directory 
   ```
   cd SmartifyOS-Installer
   ```
3. Copy your build Unity app into the `SmartifyOS/GUI/` directory
4. Run
   ```
   chmod +x Install.sh
   ```
5. And then
   ```
   ./Install.sh
   ```
</details>

<details>
   <summary><b>Possible problems</b></summary>

   > **Installer says it has no Internet**\
   > If you connected the LAN cable after boot you many need to reboot the system with it connected

   > **Boot takes really long**\
   > If you boot the system without a connected LAN cable it will try to connect to something anyways for several min. To stop it from doing so press `Super (Win) + E` click on `Applications > System Tools > LXTerminal` and run `./SmartifyOS/Scripts/SetNetworkServices.sh disable`

   > **Not valid errors**\
   > If you get en error like `E. Release file for ... is not valid yet` your system date an time is wrong. Run `sudo date -s "2024-12-27 21:35:00"` with your current date and time to fix it.

   > **Unity app never starts/freezes system or takes long to start after install**\
   > The default Unity app (if you didn't change it) expects the system to have Bluetooth if it doesn't have this it will freeze for around 10 sec every startup
</details>

## How to contribute
First have a look at the **[Contribution guidelines for this project](CONTRIBUTING.md)**.

1. Go to the repository’s GitHub page and click the "Fork" button to create a copy of the repository in your own GitHub account.
2. Clone your new repo
   ```
   git clone https://github.com/your-username/SmartifyOS-Installer.git
   ```
3. Cd into its directory
   ```
   cd SmartifyOS-Installer
   ```
4. Add the Main Repository as a Remote
   ```
   git remote add upstream https://github.com/Mauznemo/SmartifyOS-Installer.git
   ```
5. Open the directory in your preferred code editor

### Creating a pull request

1. Navigate to Your Forked Repository
2. Compare & Pull Request:
   - GitHub usually detects recent pushes and will show a prompt asking if you want to create a pull request. If this prompt appears, click on "Compare & pull request."
   - If the prompt does not appear, click the "Pull requests" tab, then click the "New pull request" button.
3. Select the Base and Compare Branches:
   - Base repository: This should be the original repository you forked from.
   - Base branch: Typically, this is the main or master branch of the original repository.
   - Head repository: This should be your forked repository.
   - Compare branch: Select the branch you just pushed.
4. Create Pull Request and make sure to follow the [Pull Request Guidelines](CONTRIBUTING.md#pull-request-guidelines)

## [Main Repository - SmartifyOS](https://github.com/Mauznemo/SmartifyOS)