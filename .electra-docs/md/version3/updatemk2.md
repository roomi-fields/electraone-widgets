****** Firmware update Electra One mkII ​ ******
This document describes how to update your Electra One mkII from firmware
version 3.6.1 or older to the latest release, version 4.0.0.
Note
If you encounter any issues during the firmware update, please don’t hesitate
to contact us via the Electra One Forum or email. We’re happy to assist you.
***** The firmware update procedure ​ *****
**** 1. Download the latest firmware file ​ ****
Click the button below to download firmware version 4.0.0. The downloaded file
will be named firmware-v4.0.0.srec.zip. Unzip it and make sure the file
firmware-v4.0.0.srec is saved and ready to use.
Download
version 4.0.0 (May 1st 2025)
**** 2. Connect your controller to the computer ​ ****
Connect your Electra One mkII controller to your computer using a USB cable.
Make sure you’re using the same computer where you downloaded the firmware
file. Wait for the controller to fully start up.
**** 3. Switch to the bootloader mode ​ ****
When the controller is powered on, press and hold the right-bottom [MENU]
button. While keeping the [MENU] button pressed, briefly click the top-left
[SECTION 1] button. Finally, release the right-bottom [MENU] button.
[Switching to the bootloader]
If done correctly, the bootloader menu will be displayed:
[Electra One bootloader]
**** 4. Enable the USB Disk option ​ ****
Tap the green button labeled [Enable USB Disk] on the controller screen. After
tapping it, the label will change to [USB Disk enabled]. Your Electra One
controller should now appear on your computer as a USB drive named ELECTRA.
[Electra One USB disk]
**** 5. Copy the update file to the boot folder ​ ****
Copy the firmware-v4.0.0.srec file you downloaded in step 1 into the boot
folder on the Electra One disk. This process may take a few moments to
complete. Note: You may see other files already present in the boot folder —
it’s perfectly fine to leave them there.
[Electra One update copied]
Once the file has finished uploading and appears in the boot folder, you can
close Finder (macOS) or File Explorer (Windows), and safely eject the disk.
**** 6. Restart the controller ​ ****
Tap the on-screen [Restart] button to reboot the controller. Once it has
started up, disconnect the USB cable to fully power it off.
**** 7. Start the bootloader again ​ ****
With the controller powered off, press and hold the bottom-right [MENU] button.
While holding it, reconnect the USB cable to power on the device.
The bootloader will start, and firmware-v4.0.0 will appear in the list of
available firmware images:
[Firmware uploaded]
**** 8. Apply the update ​ ****
Tap the blue tile labeled firmware-v4.0.0 to begin the update process.
The controller will install the new firmware, and upon successful completion,
it will automatically restart and run the updated version.
**** 9. Verify you are running 4.0.0 ​ ****
When the controller restarts, check the startup screen — it should display a
message indicating that version 4.0.0 is starting.

WARNING
If you encounter any issues while running the update, feel free to contact
Martin on the forum or by email.
***** Notes ​ *****
   1. The firmware update typically takes 30 to 40 seconds. If the process
      takes significantly longer, it may indicate a problem. In that case, try
      power cycling the controller.
   2. Outdated or unused firmware image files can be safely deleted from the
      boot directory on the ELECTRA disk.
   3. Files starting with ._ are automatically created by macOS. These files
      are not used by the controller and can be safely ignored.
