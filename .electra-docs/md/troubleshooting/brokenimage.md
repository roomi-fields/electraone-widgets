****** Bricked after the firmware update ​ ******
If your Electra One MIDI Controller fails to start and displays only a black
screen after powering on, it may be due to an invalid firmware image being
uploaded to the device. While this situation can make the controller appear
“bricked,” it can often be resolved by entering bootloader mode and manually
managing the firmware.
***** Symptoms ​ *****
    * Black screen on power-up - The controller does not show any startup
      animation after being powered on. The screen stays black after powering
      it on.
    * Unresponsive device – The controller does not react to button presses or
      interactions during normal startup.
***** Recovery Procedure ​ *****
   1. Prepare for recovery
          o Make sure your Electra One controller is powered off.
   2. Press and hold the [RIGHT-BOTTOM] button
          o Locate the [RIGHT-BOTTOM] hardware button on the controller and
            press and hold it. [RIGHT-BOTTOM]
   3. Reconnect the USB cable while holding the button
          o With the button still held down, plug the USB cable back in to
            power up the controller.
   4. Wait for the bootloader to start
          o Continue holding the button until you see the bootloader screen
            appear. Visit the Bootloader_documentation for more details.
   5. Enable the USB Disk mode
          o On the bootloader screen, tap the [Enable USB Disk] button. This
            will expose Electra One’s internal SD card as a USB drive on your
            computer.
   6. Copy the latest firmware file to the boot folder
          o Download the lastest firmware file from the Downloads page.
          o Unzip the downloaded firmware file.
          o Copy the unzipped firmware-vx.x.x.srec file to the boot folder on
            the Electra One disk. [boot folder]
   7. Select a Firmware Image to Boot
          o Tap the blue tile that shows the name of the firmware file you just
            uploaded. The controller will then re-install the firmware using
            that file. [Bootloader]
***** Important Notes ​ *****
If bootloader mode does not appear when holding the [RIGHT-BOTTOM] button, this
could indicate a dead_SD_card or a more critical issue beyond standard
recovery. In such cases, do not attempt further manual recovery — contact
support for assistance to avoid damaging the device.
***** Further Assistance ​ *****
If you're unable to enter bootloader mode or manage firmware images, please
reach out via the Electra_One_Community_forum or contact Electra One support
directly.
Sharing your experience with the community may also help other users
encountering similar issues.
