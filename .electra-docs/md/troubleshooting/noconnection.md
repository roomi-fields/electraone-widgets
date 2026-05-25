****** Controller Not Detected ​ ******
If your Electra One controller is not recognized by the Electra One web app or
is missing from the list of available MIDI devices, it may indicate a problem
with the USB connection, system MIDI routing, or web app configuration.
This issue can occur on both macOS and Windows systems, and typically involves
either the device not appearing at all or the main communication port being
missing or unresponsive.
***** Symptoms ​ *****
    * Electra One does not appear in the Electra One web app (app.electra.one).
      after completing the startup animation.
    * On macOS, the required Electra Controller CTRL port is missing or
      unresponsive.
    * On Windows, the Electra Controller (MIDIIN3) / (MIDIOUT3) ports are
      missing or non-functional.
***** Recovery Procedure ​ *****
   1. Check if Electra One appears as a USB device
      Before troubleshooting MIDI or software:
      On MacOS:
          o Open System Information → select USB from the sidebar.
          o Look for a device labeled Electra One under the USB tree. [System
            Information]
      On Windows:
          o Open Device Manager → expand the Universal Serial Bus devices
            section.
          o Look for a device labeled Electra One or similar.
      If the device does not appear, try:
          o Using a different USB cable (short and high quality).
          o Plugging into another USB port.
          o Avoiding USB hubs temporarily to isolate the issue.
   2. Verify MIDI ports are present
      On macOS:
          o Open Audio MIDI Setup → Window → Show MIDI Studio
          o You should see Electra One with three virtual ports.
          o The Electra Controller CTRL port must be present and responsive.
            [MIDI Studio]
      On Windows:
          o Use a DAW or MIDI monitor (e.g. MIDI-OX) to inspect available
            ports.
          o Look for:
                # Electra Controller (MIDIIN3)
                # Electra Controller (MIDIOUT3)
      If these ports are missing or unresponsive, try rebooting your system
      after reconnecting the device.
   3. Confirm Electra One Web App MIDI Setup
      In the Electra One Web App:
          o Click the Contoller in the top Menu
          o Under MIDI PORT CONFIGURATION, make sure the Input and Output ports
            are assigned to:
                # macOS: Electra Controller CTRL
                # Windows: Electra Controller (MIDIIN3) / ... (MIDIOUT3)
      [MIDI Studio]
      If ports are assigned incorrectly or blank: - Reassign them using the
      dropdowns. - Refresh the browser page after making changes.
   4. Test on different computer
      If Electra One still isn’t recognized after trying these steps, test it
      on a different computer to rule out local configuration issues.
***** Further Assistance ​ *****
If nothing of above did not help, please post in the Electra_One_Community
forum or contact Electra One support via email.
