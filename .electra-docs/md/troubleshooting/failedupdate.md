****** Online firmware updated failed ​ ******
***** Symptoms ​ *****
    * Electra is stuck on "Updating firmware" screen.
    * Electra does not boot up.
If you're experiencing these symptoms, you most likely attempted to run an
online firmware update using an older version of the Bootloader - the firmware
management software running on the controller.
***** Cause ​ *****
This issue occurs because the new firmware was uploaded, but the older
Bootloader version is not capable of applying the firmware update
automatically. To run online firmware updates, bootloader version 1.1 is
required.
***** Solution ​ *****
The solution is to update to the latest version of the Bootloader. Before doing
so, you might need to clear the failed firmware update that is preventing your
controller from starting up.
To resolve the issue, follow the steps below.:
***** Recovery Procedure ​ *****
   1. Power recycle your controller
          o Disconnect the USB cable and reconnect it.
          o If the firmware update progress bar starts moving, wait until the
            update completes and the controller starts up. Then skip to step 9.
            If the controller remains stuck on the "Updating firmware" screen,
            continue with step 2.
   2. Prepare for recovery
          o Disconnect the USB cable again.
   3. Press and hold the [RIGHT-BOTTOM] button
          o Locate the [RIGHT-BOTTOM] hardware button on the controller and
            press and hold it. [RIGHT-BOTTOM]
   4. Reconnect the USB cable while holding the button
          o With the button still held down, plug the USB cable back in to
            power up the controller.
   5. Wait for the bootloader to start
          o Continue holding the button until you see the bootloader screen
            appear. Visit the Bootloader_documentation for more details.
   6. Enable the USB Disk mode
          o On the bootloader screen, tap the [Enable USB Disk] button. This
            will expose Electra One’s internal SD card as a USB drive on your
            computer called ELECTRA.
   7. Remove all pending updates
          o Remove all files from the boot folder on the ELECTRA disk.
   8. Eject the ELECTRA disk and restart
    * Eject the ELECTRA disk.
    * Tap the [RESTART] on-screen button.
   1. Update the bootloader
    * Visit the Bootloader_documentation and follow the instructions to update
      your Bootloader to the latest version.
***** Further Assistance ​ *****
Following these steps should resolve most issues related to the failed online
update. If problems continue, please reach out via the Electra_One_Community
forum or contact Electra One support via email.
