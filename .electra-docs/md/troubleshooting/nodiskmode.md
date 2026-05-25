****** Bootloader USB Disk Mode Not Working ​ ******
***** Symptoms ​ *****
    * Electra One is not recognized as a USB drive when USB Disk mode is
      enabled in the bootloader.
    * The "ELECTRA" disk does not appear on your computer after enabling USB
      Disk mode.
    * Windows File explorer crashes when opening Electra One Disk
    * The issue occurs mainly on Windows 11 and some Linux distributions.
If you're seeing these symptoms, it likely means your computer cannot access
Electra One in USB Disk mode due to compatibility issues with the bootloader.
***** Cause ​ *****
This issue is related to the original bootloader version, which was developed
during the Windows 10 era. While it works on most systems, changes in Windows
11 and some Linux distributions prevent the Electra One from mounting correctly
as a USB mass storage device.
***** Solution ​ *****
Firmware version 4.0.0 introduces the ability to update the bootloader, which
addresses these compatibility issues. It also adds support for updating the
firmware directly from the web browser, so USB Disk mode will no longer be
required in future updates.
To resolve the issue, you need to manually update your controller to firmware
4.0.0 or later by copying the firmware file directly to the SD card.
***** Recovery Procedure ​ *****
   1. Prepare the Firmware File
          o Download the latest firmware update, eg. firmware-v4.0.0.srec.zip,
            from the downloads page.
          o Unzip it to access the .srec file.
   2. Remove the SD card How you remove the SD card depends on the hardware
      revision of your controller:
          o Newer models have an SD card slot on the left side of the
            controller’s body. [Card in] Gently push the card inward until it
            clicks and releases. Then pull it out. [New slot]
          o Older models have the SD card under the bottom plastic lid. To
            access it, remove the lid using a T6 hex key (Allen wrench). Tote,
            that the screws marked in red are longer. [old screws] Then
            carefully remove the card from the slot on the PCB - gently push
            the card inward until it clicks and releases. Then pull it out.
            [old slot]
   3. Copy the Firmware to the SD Card
          o Insert the SD card into your computer.
          o Copy the firmware file, eg. firmware-v4.0.0.srec file to the boot
            folder on the SD card.
   4. Reinsert the card into your controller
          o For newer models, simply insert the card into the side slot until
            it clicks into place.
          o For older models, place the card back into the PCB slot. Before
            reattaching the bottom lid, test that the controller boots
            correctly with the new card.
   5. Start the Bootloader
          o Follow the firmware update instructions found in the Firmware
            Update guide.
***** SD card size ​ *****
There was previously a restriction limiting SD cards to a maximum size of 4 GB,
but this is no longer required. You can now use larger SD cards with Electra
One.
However, you must ensure that the card is formatted using the FAT32 file
system. Cards formatted with exFAT will not work.
***** Further Assistance ​ *****
Following these steps should resolve most issues related to a corrupted or
unreadable SD card. If problems continue, please reach out via the Electra_One
Community_forum or contact Electra One support via email.
