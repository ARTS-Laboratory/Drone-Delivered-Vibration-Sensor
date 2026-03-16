# -*- coding: utf-8 -*-
"""
Created on Mon Mar 16 12:25:05 2026

@author: davis
"""

import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

# Load CSV with no header row
df = pd.read_csv("TeensyData.csv", header=None)

# Column 0 = y1, Column 1 = y2, Column 2 = x
y1 = df[0]
y2 = df[1]
x = df[2]
mean1 = np.mean(y1)
mean2 = np.mean(y2)
## mean2 *= -1
print(mean1)
print(mean2)

plt.figure(figsize=(10, 6))
plt.plot(x, y1 - mean1, marker="s", label="Dataset 1")
plt.plot(x, (y2 - mean2)*(-1), marker="s", label="Dataset 2")
# change as necessary to view different section of graph
plt.xlim(27.55,27.7)
plt.ylim(-0.5, 0.5)
plt.xlabel("time (s)")
plt.ylabel("acceleration (m/s^2)")
plt.title("Acceleration vs Time")
plt.legend()
plt.grid(True)
plt.show()