****** Stuck at startup ​ ******
***** Symptoms ​ *****
    * Boot Failure: Electra One MIDI Controller gets stuck on the startup
      splash screen and fails to complete the boot sequence. The controller
      stays at the following screen:
[Splash screen]
If your Electra One controller is stuck during startup, it is often caused by a
problematic preset or Lua script saved in the default preset slot (i.e. the
last one used). This may happen if recent changes to the Lua script introduced
a fatal error or an infinite loop. If you haven't edited any Lua code recently,
the script file may have become corrupted for some other reason.
To resolve this, you can bypass the automatic loading of the default preset
during startup.
***** Recovery Procedure ​ *****
   1. Prepare for recovery
          o Make sure your Electra One controller is powered off.
   2. Press and hold the [LEFT-TOP] button
          o Locate the [LEFT-TOP] hardware button and press and hold it. [LEFT-
            TOP]
   3. Power on the controller while holding the button
          o While continuing to hold the [LEFT-TOP] button, connect the USB
            cable to power the controller on.
   4. Wait for the startup animation to finish
          o Keep the button held down until the startup animation completes.
            The controller will boot without loading any preset to the default
            preset slot.
   5. Release the button after startup
          o Once the controller has fully started, release the [LEFT-TOP]
            button. You should now see the controller running without any
            preset loaded.
   6. Upload the Correct Preset or Lua Script
          o Use the Electra One web app to remove or replace the problematic
            preset in the affected slot. You can do this by simply uploading a
            new preset to the slot or navigating to Controller → Preset Slots,
            selecting the slot, and uploading a corrected version.
***** Further Assistance ​ *****
Following the steps above should allow your Electra One to bypass any faulty
preset or Lua script and resume normal operation. If problems persist, please
post in the Electra_One_Community_forum or contact Electra One support via
email.
