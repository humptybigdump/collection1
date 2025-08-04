#!/usr/bin/env python3

import os
import sys
import serial
import time
import serial.tools.list_ports

DEV_UART = '/dev/ttyUSB1'

if ('-win') in sys.argv:
    plist = list(serial.tools.list_ports.comports())

    if len(plist) <= 0:
        print("The Serial port can't be found!")
    else:
        plist_0 = list(plist[1])
        DEV_UART = plist_0[0]

BAUD_RATE=115200

ser = serial.Serial(
    port=DEV_UART,
    baudrate=BAUD_RATE,
    parity=serial.PARITY_NONE,
    stopbits=serial.STOPBITS_ONE,
    bytesize=serial.EIGHTBITS,
    timeout=1 # timeout in seconds
)

# if you connect the reset signal in LatticeiCE40HX8K.pcf
# (with set_io RST B13), then you can reset the FPGA like this:
time.sleep(0.001);
ser.setRTS(False);
time.sleep(0.001);
ser.setRTS(True);
time.sleep(0.001);

# You can also work with the FTDI CTS and DTR signals if you want. Please check the
#  LatticeiCE40HX8K.pcf and the top_level.v how RTS is connected. Similarly you can use
#  the DTR and CTS lines.

# consume data already buffered in the usb-to-serial adapter from before resetting the board
print("Data left on usb-serial adapter from reset: < "+str(ser.read(32).decode('utf8','ignore'))+" >");

# ---------------------
# ..... do stuff ......

# interact with board, send an 's'
ser.write(b's')
# set all LEDs off (0)
ser.write(b'\0')

# TODO-Exercise: Uncomment the two following code lines and adapt the hardware design, so you can send "A"
# from the board to here. The following code receives two bytes from the boad through uart, timeout is in
# seconds as defined above. Then data is printed as ascii characters.
#data = ser.read(2)
#print(data.decode('ascii'))

# TODO-Exercise: Adapt it so you can send two characters, like "AB"
# ???

# example, here we change the LEDs every 2 seconds
print("Now watch the LEDs on the board!");

# TODO-Exercise: Change it to a for-loop in which you make a running-led light, so the lighted up led moves
#                from left to right (that can be entirely done here in the python script)

time.sleep(1)
ser.write(b's')
ser.write(b'a')
time.sleep(1)
ser.write(b'S') # we made the hardware to react to both 's' and 'S'
ser.write(b'b')
time.sleep(1)
ser.write(b'S')
ser.write(b'c')
time.sleep(1)
ser.write(b'S')
ser.write(b'd')
time.sleep(1)
ser.write(b'S')
ser.write(b'e')
time.sleep(1)
ser.write(b'S')
ser.write(b'f')
time.sleep(1)
ser.write(b'S')
ser.write(b'g')

#TODO-Exercise turn LEDs off again
#ser.write(b'?')
#ser.write(b'?')

ser.close()

print("Finished");
