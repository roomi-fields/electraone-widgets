****** Bit Masking and Bit Shifting in MIDI ​ ******
MIDI data is transmitted as bytes, but many MIDI parameters are larger than a
single byte or need to be split to fit MIDI’s rules. Bit masking and bit
shifting are techniques used to pack and unpack values into bytes safely and
efficiently.
***** Why Bit Operations Are Needed in MIDI ​ *****
MIDI has important constraints:
    * Data bytes must be 7-bit (0–127)
    * Status bytes must have the MSB set
    * SysEx data must not look like status bytes
    * Parameters may be larger than 7 bits
Because of this, values often need to be:
    * split across multiple bytes
    * packed into bit fields
    * reconstructed on reception
Bit masking and shifting make this possible.
***** What Is Bit Shifting? ​ *****
Bit shifting moves bits left or right inside a number.
**** Left Shift (<<) ​ ****
Shifting left multiplies by powers of two.
value << 1  → value × 2
value << 7  → value × 128
Example:
00000101 (5)
<< 1
00001010 (10)
**** Right Shift (>>) ​ ****
Shifting right divides by powers of two.
value >> 1 → value ÷ 2
Example:
00001010 (10)
>> 1
00000101 (5)
***** What Is Bit Masking? ​ *****
A bit mask is used to isolate specific bits using the AND operation. Example
mask:
00001111
This keeps the lower 4 bits and clears the rest. Example:
10101101
AND 00001111
=   00001101
Masking is used to:
    * extract parts of a value
    * clear unwanted bits
    * enforce 7-bit limits
***** Splitting a Value into 7-bit MIDI Bytes (Sending) ​ *****
**** Problem ​ ****
You want to send a value larger than 127 in a SysEx message. Example:
value = 1000
Binary
1111101000
This does not fit in one MIDI data byte.
**** Solution: Split into Multiple 7-bit Bytes ​ ****
msb = (value >> 7) & 0x7F
lsb = value & 0x7F
This produces:
    * MSB: upper bits
    * LSB: lower 7 bits
**** Why Mask with 0x7F? ​ ****
0x7F = 01111111
This guarantees:
    * MSB of the byte is 0
    * Byte is valid MIDI data
**** Example SysEx Payload ​ ****
F0 <vendor> <param> <msb> <lsb> F7
***** Reconstructing a Value from MIDI Bytes (Receiving) ​ *****
Reconstructing a Value from MIDI Bytes (Receiving)
value = (msb << 7) | lsb
Example:
msb = 7
lsb = 104

value = (7 << 7) + 104
value = 1000
**** Why Parameters Are Split Across Multiple Bytes ​ ****
   1. MIDI Data Byte Limit
          o MIDI data bytes must be 0–127.
          o Any larger value must be split.
   2. Avoiding Status Byte Conflicts If a byte has MSB = 1, it looks like a
      status byte. Splitting prevents this.
***** Packing Multiple Small Values into One Byte ​ *****
Sometimes multiple parameters are packed into one byte. Example:
    * upper 4 bits → parameter A
    * lower 4 bits → parameter B Sending
byte = (a << 4) | b
Receiving
a = (byte >> 4) & 0x0F
b = byte & 0x0F
This is common in compact SysEx formats.
***** Summary ​ *****
Bit masking and bit shifting are fundamental techniques for working with MIDI
data. They allow values to be split into safe 7-bit bytes for transmission and
reassembled on reception. These techniques are essential when composing or
parsing SysEx messages, where parameters may span multiple bytes to avoid
status byte conflicts, support higher resolution, and maintain compatibility.
Mastery of bit operations makes MIDI protocols understandable, predictable, and
robust.
