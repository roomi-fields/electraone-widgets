****** A broken SD card ​ ******
If your Electra One MIDI Controller fails to start and shows only a black
screen after powering on, it may be due to a damaged or unreadable SD card, or
corrupted files stored on it.
***** Symptoms ​ *****
    * Black screen on power-up - The controller does not display the startup
      animation after being powered on. The screen remains black. Users often
      notice a brief backlight flash, but the display stays blank.
***** Recovery Procedure ​ *****
   1. Prepare for recovery
          o Make sure your Electra One controller is powered off.
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
   3. Check the card using a computer
      Insert the card into your computer and try accessing its contents.
      Optionally, you can run a file system check using tools like diskutil
      (macOS), chkdsk (Windows), or other disk utilities.
   4. Format or replace the card
      If you detect issues—or to ensure stability—you may either:
          o Format the existing card, or
          o Use a new, high-quality SD card (recommended)
      Formatting requirements:
          o File system: FAT32
          o Recommended name: ELECTRA
   5. Copy factory files on the card
      Once the card is formatted, download the factory SD card image from the
      Downloads, unzip it, and copy the extracted files on the SD card. Once
      you are done, your SD card contents should look like this:
      After formatting, download the factory SD card contents from the
      Downloads page. Unzip the file and copy the extracted contents to the
      root of the SD card.
      Your SD card should look like this after copying:
      [SD card contents]
   6. Reinsert the card into your controller
          o For newer models, simply insert the card into the side slot until
            it clicks into place.
          o For older models, place the card back into the PCB slot. Before
            reattaching the bottom lid, test that the controller boots
            correctly with the new card.
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
