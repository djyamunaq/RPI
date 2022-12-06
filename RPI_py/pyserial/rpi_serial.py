#!/usr/bin/env python3
 
import serial # Module needed for serial communication
import time

port = serial.Serial('/dev/ttyAMA0', 9600, timeout=1)
port.flush()

while (1):
  # msg = ('rpi')
  # port.write(msg.encode('utf-8'))

  if(port.in_waiting > 0):
    line = port.readline().decode('ISO-8859-1').rstrip()
    print(line)

  # time.sleep(1)
