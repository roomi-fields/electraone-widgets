****** Controller's User Interface ​ ******
Electra One controller user interface is designed so that a computer is not
needed once the presets are uploaded to the controller. All information that a
user might need is available and accessible directly from the hardware. Of
course, you may leave Electra One connected to a computer while using it. If
you want to work with software VST plugins or DAW, you even have to keep it
connected.
***** Elements of the user interface ​ *****
The user interface relies on four important elements:
    * color display that shows information about presets and displays
      navigation means
    * display touch, that allows working with Controls and navigate between
      pages, presets, and configurations.
    * buttons to switch between sections, pages, as well as to load and save
      your data
    * touch-sensitive knobs that are used to improve orientation on the pages
      of Controls and to make choices on the selection screens.
***** The display ​ *****
**** The status bar ​ ****
The Status bar is located at the top of the screen. The status bar is meant to
provide information about the USB device port, devices connected to the USB
Host port, and MIDI IO ports.
[Status bar]
The status bar is updated dynamically in real-time. The location of the status
bar labels reflects the physical location of the ports on the rear panel.
The activity on the ports is indicated by flashing the port labels.
*** USB Device port ​ ***
The rightmost item of the status bar. It indicates the physical position and
MIDI activity of the USB device port <USB DEVICE>.
[USB Device port]
*** USB Host devices ​ ***
USB Host devices item provides information about MIDI USB devices connected to
Electra’s USB Host port The MIDI USB devices are identified by their “Product
name”. It means that when a USB device is connected to the <USB HOST> port, its
name is shown.
[USB Host port]
*** MIDI IO ports ​ ***
The MIDI input / output labels identify the physical <MIDI IO> DIN-5 ports. The
indicators are flashing whenever there is a flow of MIDI data.
[MIDI IO ports]
**** Active section ​ ****
Electra’s display can show up to 36 Controls on one screen. There are, however,
only 12 knobs. To allow the user to easily reach all 36 Controls, the screen is
divided into three sections of 12 Controls.
Only one section can be active at the time. The Controls of the active section
are connected to the 12 knobs. Turning a knob will cause a change of the value
of the corresponding Control.
The Active section is selected with the three buttons on the left side of
Electra.
[Active section buttons]
    * Button 3, referred to as [SECTION 1], makes the top section active
    * Button 4, referred to as [SECTION 2], makes the middle section active
    * Button 5, referred to as [SECTION 3], makes the bottom section active
The Active section is always highlighted, while the inactive sections are
dimmed. The section highlighting helps users to get oriented on the screen and
make a visual connection between the knobs and the controls.
The Active section can be also switched by clicking a Control on the display.
The click will activate the section where the Control is located.
Top section active
[Active section top]
Middle section active
[Active section middle]
Bottom section active
[Active section bottom]
If the dimming of inactive sections is not appropriate, different style of
marking the active section can be used. This is can be done on the Electra One
configuration_page in the Electra One account application.
***** Right side buttons ​ *****
Right side buttons provide access to presets, preset pages, snapshots,
configuration, and to request patches.
[Right side buttons]
    * Button 6, referred to as [PATCH REQUEST]
    * Button 7, referred to as [SNAPSHOTS]
    * Button 8, referred to as [MENU]
**** Patch request ​ ****
If preset consists of instructions to request and parse device patch data, the
requests are sent when the [PATCH REQUEST] button is pressed. Electra One
controller will update the values of the Controls according to their patch
settings as soon as the Device responds with the patch dump MIDI data.
**** Snapshots ​ ****
Pressing the [SNAPSHOTS] button will open the Snapshots window. Snapshots are
saved sets of preset Control values. The Snapshots window can be closed by
pressing the [SNAPSHOTS] again.
[Snapshots]
There are 12 banks, each having 36 snapshot slots. Current snapshot bank can be
changed by pressing and holding the [MENU]. The knob touch or tapping the Bank
button on the screen can be used to switch the snapshot banks. The snapshots
bank selection is shown as long as the [MENU] button is held pressed.
[Snapshots]
There are several buttons at the top of the Snapshots window. These are to
manange the snapshots and send them out to the connected MIDI devices.
*** Load ​ ***
Swicthes Electra One to the Load mode. Subsequent tap on any of the saved
snapshots will will update the preset values, will send the values to connected
devices, and eventually the Snapshots window will be closed.
*** Load & Stay ​ ***
Swicthes Electra One to the Load & Stay mode. Subsequent taps on any of the
saved snapshots will will update the preset values, will send the values to
connected devices. On contrary to the Load, the Load & Stay does not close the
Snapshots window. It means you can keep sending the snapshots as long as you
keep the Snaphosts window open.
*** Send current ​ ***
Sends all current preset values to the connected devices. No data is sent or
modified.
*** Remove ​ ***
Switches Electra One to the Delete mode. Subsequent taps on any of the saved
snapshots will permanently remove them from the controller.
*** Save current ​ ***
Switches Electra One to the Save mode. Subsequent taps on any of the saved
snapshots will create a new snapshot at given location. When a used slot is
chosen, the original saved snapshot will be overwriten.
**** Menu ​ ****
Pressing [MENU] allows user to switch pages, presets, and enter the USB host
configuration page. The [MENU] button is used in combination with the other two
buttons on the right side of the controller, ie. with the [PATCH REQUEST] and
[SNAPSHOTS].
The following functions are assigned to the [MENU] button:
    * switch between preset Pages
    * switch between Preset banks and Presets stored in Electra One's internal
      storage
    * configure assignment of USB devices connected to USB Host port <USB HOST>
*** Page selection ​ ***
Each Electra preset may have up to 12 pages of Controls. When [MENU] button is
pressed and held pressed a list of all pages will appear at the bottom of the
screen.
[Page hint]
The currently selected page is highlighted. The page names are displayed so
that their position corresponds to the knobs. The knob touch or tapping the
Page button on the screen can be used to switch the pages. Empty page buttons
represent unused pages, these cannot be accessed.
*** Preset selection ​ ***
Not only that each preset has 12 pages, Electra One gives you a very fast way
to switch between 72 presets, organized in 6 banks of 12 presets.
** Changing the current preset ​ **
To reach the Preset selection, press and hold the [MENU] and then press the
right-middle [SNAPSHOTS] button. The Preset selection window with 12 preset
slots and 6 bank buttons will appear.
The selection is done in the same way as selecting pages. You can use either
tapping the knobs or with the touch on the display.
[Preset selection]
The preset is loaded immediately after it is selected. If the preset slot is
empty, an empty preset will be loaded and shown. Selecting an empty preset slot
makes the slot available for uploading a new preset.
The Electra Preset Library and the Preset Editor always upload presets to the
currently selected preset slot. If the selected slot contains a preset,
uploading a new preset from the editor will overwrite the original preset.
** Changing the current preset bank ​ **
The banks can be switched by tapping the on-screen bank buttons
[Preset banks]
Each bank may have up to 12 presets. Once the preset bank is changed, you can
choose the preset as described above.
The active bank is highlighted with a colour background:
*** USB Host configuration ​ ***
Electra features a <USB HOST> port to connect USB MIDI devices and Electra
accessories. Although there is only one USB port, it is possible to connect a
standard USB Hub to increase the number of USB ports.
Any USB MIDI device connected to Electra’s <USB HOST> port can be assigned to
PORT 1, PORT 2, or CTRL.
To open the USB Host configuration window, press and hold the [MENU] and then
press the right-top [PATCH REQUEST] button.
[USB Host selection]
If the USB device, for example, a master keyboard, is connected to PORT 1, the
messages it sends will be forwarded to <USB DEVICE> port Electra Port 1 and
<MIDI 1 OUT> port. Any MIDI message sent to either <USB DEVICE> port Electra
Port 1 or <MIDI 1 IN> port will be automatically forwarded to the USB device
connected to the <USB HOST> port 1. PORT 2 uses the same principle.
The CTRL port is used for Electra's external_MIDI_control. External control
allows you to switch pages and presets by sending MIDI messages to Electra's
<USB HOST> port.
***** Interacting with controls ​ *****
**** Active control ​ ****
To make orientation even easier, the touch on knobs marks corresponding
controls underlined. It means you can see what Control is active even if you do
not turn the knob.
[Active control]
**** Switching the Active section ​ ****
A single tap on a Control will switch to the Active section where the control
is located.
**** Control detail ​ ****
Touch and prolonged hold of the Control will display a Control detail window
with a full-size version of the Control. The Control detail provides you with
fine control over the value. The detail window can be also revealed by holding
the knob and pressing the [SECTION 1] button.
Each type of Control has its special detail window:
*** Fader detail ​ ***
The fader detail is meant to allow maximum width sweeps of the Control value.
The fader strip is wide and high enough to provide adequate room for your
finger.
[Fader detail]
*** List detail ​ ***
The list detail is meant to provide a tablet like swipeable list of values. The
values can be browsed by swiping the items up and down. The item is selected
with a single tap on the display.
[List detail]
*** Envelope detail ​ ***
The envelope detail is meant to allow users to change all envelope values from
one place. When the detail window is shown, Electra re-assigns knobs to
individual envelope values. This temporary knob assignment is available only as
long as the detail window is shown.
[List detail]
*** Locking the detail window ​ ***
Normally, the detail window is closed immediately after changing the value or
making a selection. This could be inappropriate in some situations. To prevent
this the window can be locked by tapping the lock symbol:
[Lock disabled]
When the lock is tapped, the symbol gets highlighted and the detail window can
be used to change the value many times.
[Lock enabled]
The locked detail window can be closed by tapping the lock symbol again or
tapping the display elsewhere outside the detail window.
*** Detail window knob assignment ​ ***
The detail window keeps the assignment of the original knob. It means you can
use the same knob to change the value of the Control when it is displayed in
the detail window.
**** Resetting to the default value ​ ****
A double-tap on the Control resets its value to the default defined in the
preset.
**** Changing active value of envelopes ​ ****
The multi-value controls, such as envelopes, have knobs assigned to one of
their values when the preset is loaded. This default assignment is set by the
user in the Preset editor. There are situations, however, when a different
value needs to be adjusted and opening the envelope detail window is not
appropriate. In such situation, a quick active value change gesture can be
used. There are two ways to achieve changing the value that is assigned to the
knob:
    * hold the knob of the envelope (it means the name of the control is
      underlined) and tap the envelope control on the display. The value
      assigned to the knob will be switched to the next available and will
      become highlighted.
    * hold the knob of the envelope (it means the name of the control is
      underlined) and press either [SECTION 2] or [SECTION 3] button. The
      [SECTION 2] will switch to the next available value within the envelope.
      The [SECTION 3] will switch to the sprevious available value within the
      envelope.
