#!/usr/bin/python3

import matplotlib.pyplot as plt
import numpy as np
import csv
import re
import sys
import cmath
import glob

S11magnitude = []
S11phase = []
S11freq = []

S21magnitude = []
S21phase = []
S21freq = []

S22magnitude = []
S22phase = []
S22freq = []

S12magnitude = []
S12phase = []
S12freq = []

i = 0

with open(glob.glob('S11*')[0], newline='') as csvfile:
    reader = csv.reader(csvfile, delimiter=',')
    for row in reader:
        if i == 0:
            i = 1
            continue
        S11magnitude.append(float(row[0]))
        S11phase.append(float(row[1]))
        S11freq.append(float(row[2]))

i = 0

with open(glob.glob('S21*')[0], newline='') as csvfile:
    reader = csv.reader(csvfile, delimiter=',')
    for row in reader:
        if i == 0:
            i = 1
            continue
        S21magnitude.append(float(row[0]))
        S21phase.append(float(row[1]))
        S21freq.append(float(row[2]))

i = 0

with open(glob.glob('S22*')[0], newline='') as csvfile:
    reader = csv.reader(csvfile, delimiter=',')
    for row in reader:
        if i == 0:
            i = 1
            continue
        S22magnitude.append(float(row[0]))
        S22phase.append(float(row[1]))
        S22freq.append(float(row[2]))

i = 0

with open(glob.glob('S12*')[0], newline='') as csvfile:
    reader = csv.reader(csvfile, delimiter=',')
    for row in reader:
        if i == 0:
            i = 1
            continue
        S12magnitude.append(float(row[0]))
        S12phase.append(float(row[1]))
        S12freq.append(float(row[2]))

fig, ax = plt.subplots(figsize=(12, 6))
ax.plot(S11freq, S11magnitude, label='S11Mag')
ax.plot(S21freq, S21magnitude, label='S21Mag')
ax.plot(S22freq, S22magnitude, label='S22Mag')
ax.plot(S12freq, S12magnitude, label='S12Mag')
ax.legend()
ax.set_xbound(S11freq[0], S11freq[-1])
ax.set_ybound(-100, 10)
ax.set_title("Magnitude vs Frequency")
ax.set_xlabel("Frequency (MHz)")
ax.set_ylabel("Magnitude (dB)")
ax.grid()
plt.show()

fig, ax = plt.subplots(figsize=(12, 6))
ax.plot(S11freq, S11phase, label='S11Phase')
ax.plot(S21freq, S21phase, label='S21Phase')
ax.plot(S22freq, S22phase, label='S22Phase')
ax.plot(S12freq, S12phase, label='S12Phase')
ax.legend()
ax.set_xbound(S11freq[0], S11freq[-1])
ax.set_ybound(-360, 360)
ax.set_title("Phase vs Frequency")
ax.set_xlabel("Frequency (MHz)")
ax.set_ylabel("Phase (degrees)")
ax.grid()
plt.show()