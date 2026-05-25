****** RPN and NRPN (Registered and Non-Registered Parameter Numbers) ​ ******
***** Why RPN and NRPN Exist ​ *****
Standard Control Change messages are limited:
    * only 128 controller numbers
    * many already have fixed meanings
    * not enough for complex instruments
RPN and NRPN provide a way to control many more parameters, including:
    * pitch bend range
    * tuning
    * vibrato depth
    * manufacturer-specific parameters
They do this by turning CC messages into a parameter selection + value system.
***** Key Idea: “Select a Parameter, Then Set Its Value” ​ *****
RPN and NRPN work in two steps:
    * Select which parameter you want to control
    * Send the value for that parameter
This is very similar to:
“Choose a knob, then turn it”
***** What RPN and NRPN Mean ​ *****
    * RPN — Registered Parameter Number Standardized parameters defined by the
      MIDI specification
    * NRPN — Non-Registered Parameter Number Manufacturer-defined parameters
      (device-specific)
Both use the same mechanism, only the parameter meaning differs.
***** How Parameters Are Selected ​ *****
RPN:
Purpose CC  Role
RPN MSB 101 Parameter MSB
RPN LSB 100 Parameter LSB
NRPN:
Purpose  CC Role
NRPN MSB 99 Parameter MSB
NRPN LSB 98 Parameter LSB
These CCs select which parameter will receive the value.
***** How Values Are Sent ​ *****
Once a parameter is selected, its value is sent using Data Entry CCs:
CC Purpose
6  Data Entry MSB
38 Data Entry LSB (optional)
This gives you 7-bit or 14-bit resolution, just like high-resolution CC.
***** Complete RPN Message Flow (Example) ​ *****
Example: Pitch Bend Range
Pitch Bend Range is a standard RPN.
Parameter number:
    * MSB = 0
    * LSB = 0
Step 1: Select the RPN
CC 101 = 0
CC 100 = 0
Step 2: Send the Value
CC 6 = 2
This sets pitch bend range to ±2 semitones.
***** Complete NRPN Message Flow (Example) ​ *****
NRPN works exactly the same, but with different CCs.
Step 1: Select the NRPN
CC 99 = <MSB>
CC 98 = <LSB>
Step 2: Send the Value
CC 6  = <MSB>
CC 38 = <LSB>   (optional)
***** 14-bit Values with RPN / NRPN ​ *****
Just like 14-bit CC:
    * CC 6 → coarse value
    * CC 38 → fine value Combined as:
value = MSB * 128 + LSB
***** Why This Is Powerful ​ *****
RPN and NRPN allow:
    * thousands of parameters
    * high-resolution values
    * backward compatibility
    * standardized control where possible
All using existing CC infrastructure.
***** Important: RPN and NRPN Are “Sticky” ​ *****
Once selected:
    * the parameter remains active
    * future Data Entry messages continue to affect it
This can cause problems if not handled carefully.
***** RPN Reset (Very Important) ​ *****
###What Is RPN Reset? RPN Reset clears the currently selected RPN parameter so
that further Data Entry messages do nothing accidentally. How to Reset RPN
Selection
Send:
CC 101 = 127
CC 100 = 127
This means: “No RPN selected”
**** Why RPN Reset Is Critical ​ ****
If you don’t reset:
    * later CC 6 messages may change the wrong parameter
    * bugs can appear far from their cause
    * behavior becomes unpredictable
Best practice:
    * Always reset RPN after setting a value.
***** NRPN Reset ​ *****
NRPN has a similar reset:
CC 99 = 127
CC 98 = 127
***** Summary ​ *****
RPN and NRPN extend MIDI Control Change by introducing a parameter-selection
mechanism followed by Data Entry messages. RPN parameters are standardized,
while NRPN parameters are device-specific. Both support high-resolution values
and require careful handling, including resetting the selected parameter after
use. Mastering RPN and NRPN is essential for advanced MIDI control.
