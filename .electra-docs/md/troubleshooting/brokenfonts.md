****** Text Fonts are unreadable ​ ******
***** Symptoms ​ *****
    * Font display issues - Fonts on the device screen appear broken or
      unreadable.
    * Unusual Screen Behavior - The display shows irregular patterns or
      characters not aligning properly.
[Broken fonts]
If you are experiencing any of these symptoms, it may indicate corruption of
the graphical asset file located on the internal SD card. Follow the recovery
procedure below to resolve the issue.
***** Recovery Procedure ​ *****
   1. Download the UI toolkit file
          o Download the ui-0.9.6-1.bmp.zip file, unzip it, and keep the .bmp
            file ready for use in the next steps.
   2. Disconnect the USB cable
          o Unplug the USB cable from your Electra One controller to ensure it
            powers off completely.
   3. Press and hold the [RIGHT-BOTTOM] button
          o Locate the [RIGHT-BOTTOM] hardware button on the controller and
            press and hold it. [RIGHT-BOTTOM]
   4. Reconnect the USB cable while holding the button
          o With the button still held down, plug the USB cable back in to
            power up the controller.
   5. Wait for the bootloader to start
          o Continue holding the button until you see the bootloader screen
            appear. Visit the Bootloader_documentation for more details.
            [Bootloader]
   6. Enable the USB Disk mode
          o On the bootloader screen, tap the [Enable USB Disk] button. This
            will expose Electra One’s internal SD card as a USB drive on your
            computer.
   7. Copy the UI toolkit file to the assets folder
          o Copy the ui-0.9.6.bmp file into the assets folder on the Electra
            One drive. If a file with the same name already exists, delete it
            first before copying the new one. Your assets folder should look
            like this: [assets folder]
   8. Safely ejact the disk
          o Close Finder (on macOS) or File Explorer (on Windows), and safely
            eject the Electra One drive.
   9. Restart the controller
          o On the bootloader screen, tap the [Restart] button. Electra One
            will reboot and the fonts should now be displayed correctly.
***** Further Assistance ​ *****
After completing the steps above, the corrupted file should be restored,
resolving any display issues. If problems persist, please post in the Electra
One_Community_forum or contact Electra One support via email.
