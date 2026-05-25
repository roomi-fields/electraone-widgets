****** Firmware update Electra One Mini ​ ******
Firmware updates for Electra One Mini are normally handled through the Electra
One online web application, which is the recommended and simplest method.
However, the controller also includes a built-in bootloader that allows you to
update the firmware manually if needed.
Note
If you encounter any issues during the firmware update, please don’t hesitate
to contact us via the Electra One Forum or by email. We’re happy to assist you.
***** The firmware update procedure ​ *****
**** 1. Download the latest firmware file ​ ****
Click the button below to download firmware version 4.1.4 for Mini. The
downloaded file will be named firmware-mini-v4.1.4.srec.zip. Unzip it and make
sure the file firmware-mini-v4.1.4.srec is saved and ready to use.
Download
version 4.1.4 (February 18, 2026)
**** 2. Start the controller in the bootloader mode ​ ****
Follow the steps below to start the controller in the bootloader mode:
    * Disconnect Electra One Mini from your computer.
    * Press and hold the second button from the right on the front panel.
    * While holding the button, connect the controller to your computer using a
      USB cable.
    * Release the button once the controller is connected.
Make sure you are using the same computer on which the firmware file was
downloaded.
**** 3. Use the Mini's USB disk ​ ****
When the controller starts in bootloader mode, the display will show: USB DISK
MODE. Electra One Mini will appear on your computer as a USB storage device:
[Bootloader disk]
    * Rename the firmware file: firmware-mini-v4.1.4.srec to update.srec
    * Copy the update.srec file into the /boot folder on the Electra One Mini
      USB disk.
[Bootloader disk]
**** 4. Eject the disk and restart ​ ****
After the file has been copied:
    * Safely eject the Electra One Mini USB disk using your operating system.
    * Restart the controller by disconnecting and reconnecting the USB cable.
**** 5. Performing the update ​ ****
After restarting, Electra One Mini will automatically detect the update.srec
file in the /boot folder and begin the firmware update process.
The update progress is indicated on the display by an UPDATING FIRMWARE
progress bar. Once the update is complete, the controller will restart
automatically and run the newly installed firmware.
**** 9. Verify you are running 4.1.4 ​ ****
After the controller is restarted, check the firmware version in the Menu ::
System window.

WARNING
If you encounter any issues while running the update, feel free to contact
Martin on the forum or by email.
***** Notes ​ *****
   1. The firmware update typically takes 2 to 3 minutes. If the process takes
      significantly longer, it may indicate a problem. In that case, try power
      cycling the controller.
   2. Files starting with ._ are automatically created by macOS. These files
      are not used by the controller and can be safely ignored.
