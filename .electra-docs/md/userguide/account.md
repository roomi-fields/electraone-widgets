****** Electra One Account ​ ******
WARNING
Please note, browser with WebMIDI support is required. WebMIDI is currently
supported with Chrome and Edge browsers.
The Electra One Account is a free web application that gives you full access to
the Electra One ecosystem. With an account, you can connect your Electra One
controller to the cloud-based preset library, manage your controller, and
create or share your own presets.
Whether you're building new presets, editing existing ones, or simply
organizing your controller, the Electra One Account is your central hub.
What You Can Do with an Electra One Account?
    * Browse and upload presets from the Electra One library to your
      controller.
    * Create and edit your own presets using the built-in web editor.
    * Manage your controller: upload presets, organize preset slots, configure
      MIDI routing, and more.
    * Share your presets with the community or keep them private.
    * Access advanced tools like: Lua scripting, Snapshot management, Preset
      version history, and MIDI console.
***** Signing in ​ *****
To access the Preset Library and Preset Editor, you need to sign in to your
Electra One account.
[Electra App login page]
After signing in, you'll have access to two distinct preset libraries: Your
personal library – contains presets you’ve created or uploaded and the shared
library – a collection of presets shared by other Electra One users.
If you don’t have an account yet, click the Create_new_account link to sign up.
You’ll only be asked to provide a nickname and an email address.
After signing in, you’ll arrive at the Account home page. In the following
text, we’ll go over what you can do there.
***** My presets ​ *****
My Presets is your personal library of Electra One presets. It stores all the
presets you’ve created, imported, or copied from others for private use or
future editing.
You can add presets to your My Presets library in four ways:
   1. Create a new preset from scratch using the web editor
   2. Copy a shared preset from the public Preset Library
   3. Import a preset file (.epr or .eproj) from your computer
   4. Import a preset from your connected Electra One controller
[My presets]
Your presets are displayed as a list of tiles, each one representing a single
preset. Clicking a tile opens the Preset Detail page, where you can view, edit,
or manage that preset.
You can also send a preset directly to your controller using the [Send to
Electra] button shown on each tile.
***** Preset library ​ *****
The Preset Library is a collection of presets shared by other Electra One
users. It’s a great place to discover new ideas, explore ready-made setups, and
find starting points for your own presets.
Each preset is displayed as a tile in the same way as in My presets. Clicking a
tile opens the Preset Detail page, where you can view more information and
preview the preset layout, and copy the preset to your own My presets library.
You can also send a preset directly to your controller by clicking the [Send to
Electra] button on the tile.
[Preset library]
***** Preset detail ​ *****
The Preset Detail page provides a full overview of the preset along with
several actions you can take, depending on whether it’s a preset you own or a
shared public one.
**** Overview ​ ****
At the top of the page, you’ll see a banner with the preset name and author.
Just below it, you’ll find available actions such as sending the preset to your
controller, opening it in the editor, or downloading it.
Further down, the left panel includes the preset description, assigned
categories, and the version history. The right panel shows previews of all
preset pages, allowing you to review the layout without opening the Electra
Editor or loading it onto your controller.
[Preset detail]
**** Actions for Your Own Presets ​ ****
If the preset belongs to you, the following actions are available:
    * Send to controller – Upload the preset to your Electra One.
    * Open in editor – Launch the Electra Editor to make changes.
    * Download preset – Save the preset file to your computer.
    * Download project – Includes the preset file and all related Lua script
      source code.
    * Make a copy – Clone the preset to create a duplicate in your library.
    * Share the preset – Make it publicly available to other Electra One users.
    * Manage snapshots – View, add, or delete snapshots linked to this preset.
    * Delete the preset – Remove the preset from your account.
    * Set categories and tags – Helps organize and classify your presets.
    * Manage revisions – View and access previous versions of the preset.
Preset categories, tags, and revision history are found at the bottom of the
preset description panel:
[Preset detail]
Categories and tags help you and others, if the preset is public, find presets
more easily. They are also used to filter results in both the Preset Library
and My Presets views.
TIP
Deleting a preset only removes it from your Electra One account. It does not
remove the preset from your controller. To permanently remove it from the
hardware, use the Preset Slots page in the Controller section.
**** Actions for Public Presets ​ ****
When viewing a public preset (shared by another user), you can:
    * Send to controller – Try the preset instantly on your Electra One.
    * Clone to your library – Make a private copy of the preset that you can
      edit and manage.
    * Download preset – Save the preset file to your computer.
    * Download project – Includes the preset and any associated Lua script
      source files.
    * Manage snapshots – Save and manage your own snapshots linked to this
      public preset.
**** Preset revisions ​ ****
The Preset Revisions feature is a powerful but often overlooked tool that
allows you to track the development of your presets over time. It helps you
save important milestones, experiment safely, and return to earlier versions
whenever needed.
You can access a Preset revision history page by clicking the previous
revisions link in the Last updated section of the Preset Detail page.
[Preset revisions]
A new revision is created each time you save a preset. When saving, you have
the option to add a short description of the changes made—this makes it easy to
identify versions later.
Revisions are also created automatically in certain cases, for example when you
send a preset with unsaved changes to the controller, or when you close the
editor without saving. These automatic snapshots ensure that your progress is
not lost even if you forget to save manually.
Each revision can be opened, reviewed, and even restored. You can also convert
any revision into a brand-new preset, allowing you to branch off and explore
new ideas without affecting your original work.
[Preset revision detail]
Revisions are especially useful when working with shared presets. Imagine
you’ve lready made a preset public, but want to improve it without immediately
publishing your changes. You can clone the shared preset to create a private
copy, do your work there, and once you’re satisfied, import the final revision
back into the public version. This allows you to test and refine your work
privately while keeping the published preset stable for other users.
For more on saving revisions, see Revisions in the Preset Editor documentation.
***** Controller ​ *****
The Controller section allows you to manage your connected Electra One hardware
directly from the web app. It provides tools to:
    * View, load, and delete presets in the controller’s preset slots
    * Adjust device settings and configuration
    * Perform firmware updates and recovery actions
    * Manage MIDI port assignments used for communication with the editor and
      account services
**** Preset slots ​ ****
Preset slots represent all available locations where presets can be loaded and
stored on your Electra One controller. Each Electra One controller provides 6
banks, with 12 preset slots in each bank.
[Preset slots list]
To load a preset onto the controller:
    * Select a preset slot on the left side of the page.
    * Choose a preset from your library on the right.
    * Click [UPLOAD TO SLOT] button to send the selected preset to the chosen
      slot.
If a preset is already loaded on the controller but missing from your Preset
Library, for example, if it was accidentally deleted, you can recover it by
clicking the [IMPORT FROM ELECTRA] button. This will add the preset back to
your online library.
Selecting a slot does more than just display its details: it also activates
that slot on your Electra One hardware, switching the controller to use the
selected preset.
[Preset slots detail]
To remove a preset from a slot, click the trash bin icon next to the slot.
**** Configuration ​ ****
The Configuration section allows you to adjust how your Electra One controller
behaves. All settings available here can also be configured directly on the
controller itself.
The configuration options are grouped into the following areas:
    * User Interface – Adjusts how the interface responds to touch and knob
      interactions
    * Preset Banks – Set custom names and colors for your preset banks
    * Remote Knobs – Configure how Electra One maps incoming and outgoing CC
      messages
    * MIDI Control – Set up how external MIDI messages trigger internal Electra
      commands
    * Buttons – Assign actions or commands to the hardware buttons
    * Router – Define routing rules between Electra’s internal and external
      MIDI ports
    * USB Host – Control how connected USB MIDI devices are recognized and
      assigned
*** User Interface ​ ***
This section allows you to customize how Electra One responds to user input.
You can configure gestures such as knob touch behavior, double-tap and long-
touch actions, and control set switching.. These settings help tailor the
controller's interface for live use, automation control, or personal
preference.
[Controller configuration Interfaces]
*** Preset Banks ​ ***
Each Electra One controller supports 6 preset banks. In this section, you can
assign custom names and colors to each bank to make navigation easier,
especially when using many presets in performance or studio workflows.
[Controller configuration Preset banks]
*** Remote Knobs ​ ***
This feature lets you extend Electra One’s controls using external MIDI
devices. You can map up to 36 incoming CC messages to on-screen controls and
optionally send those CCs back out when controls are adjusted on Electra One.
This setup supports real-time automation, bidirectional feedback, and can even
control non-CC messages like SysEx via virtual translation.
[Controller configuration Remote knobs]
*** MIDI Control ​ ***
Map incoming MIDI messages such as CCs, notes, or program changes to internal
commands, like switching pages, presets, or opening the snapshot window, making
it easy to integrate Electra One into larger MIDI setups or use pad controllers
as additional input.
[Controller configuration Midi Control]
*** Buttons ​ ***
Electra One has six hardware buttons. In this section, you can assign each
button a command or action from the internal list. To expand their
functionality, Electra also supports an “alternate mode” triggered by a user-
defined toggle. This allows each button to perform two different actions
depending on the current mode.
[Controller configuration Buttons]
*** Router ​ ***
Electra One includes a powerful internal MIDI router. This section allows you
to configure routing between all available MIDI interfaces—USB Device, USB
Host, and 5-pin MIDI—in both directions. Unlike on the controller, where
routing is configured using a 6×6 input/output matrix, the web interface
presents routes as a list of individual connections, making it easier to view
and manage them one by one.
[Controller configuration Router]
*** USB Host ​ ***
When using the USB Host port, Electra One can detect and manage connected USB
MIDI devices. In this section, you can define rules for how device ports are
assigned to Electra’s internal MIDI ports: Port 1 and Port 2. To identify USB
MIDI devices, the system supports string pattern matching, as well as matching
by USB VID and PID (Vendor and Product identifiers).
[Controller configuration USB Host]
**** Firmware update ​ ****
The Firmware Update section allows you to manage your Electra One controller's
firmware directly from the web application. On this page you can:
    * Update to the latest firmware version with a single click using [UPDATE
      FIRMWARE] button.
    * Download firmware update files (.srec) for manual updates via the
      controller’s bootloader and USB Disk mode use the [Download] link for
      that.
    * View change log information for the latest firmware release.
    * View important device information, including:
          o Hardware revision
          o Currently installed firmware version
          o Serial number of the controller
          o Adjust which MIDI ports are used for communication between the
            controller and the Electra One web tools
For advanced update methods, such as using the bootloader or performing
recovery, you can refer to the Bootloader chaper of the User Guide.
[Firmware update]
