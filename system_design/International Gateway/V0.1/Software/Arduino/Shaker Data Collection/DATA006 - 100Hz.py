import numpy as np
import pandas as pd
import matplotlib as mpl
import matplotlib.pyplot as plt


plt.close('all')


#%% Load data

file1 = 'D:/DATA000.csv'
file2 = 'E:/DATA000.csv'

# Sampling
fs = 400 # Hz
dt = 1/fs

#%% Function to load + process data
def process_data(filepath):
# tt= time, ac = acceleration
    D = pd.read_csv(filepath)
    ac = D.iloc[:,0].to_numpy()
    ac = ac - np.mean(ac)
    tt = np.arange(0, len(ac)*dt, dt)

    # FFT computation
    N = len(ac)                         # number of samples
    Y = np.fft.fft(ac)                  # FFT
    f = np.fft.fftfreq(N, d=dt)         # frequency vector

    # Take only positive frequencies
    mask = f >= 0
    f = f[mask]
    Y = Y[mask]
    # Amplitude (normalize)
    A = np.abs(Y) / N

    # Convert to dB scale
    A_dB = 20 * np.log10(A + 1e-12)
    return tt, ac, f, A, A_dB

#%% Process both files
tt1, ac1, f1, A1, A1_dB = process_data(file1)
tt2, ac2, f2, A2, A2_dB = process_data(file2)

# size of plot figure (think of it like the measuremetns of a sheet of paper)
plt.figure(figsize=(6.5,3))

# FFT vs Spectrogram: FFT -> what frequencies exist overall, Spectrogram -> how frequency changes over time
plt.figure(1)
plt.plot(f1, A1_dB, label = 'Color SD Card')
plt.plot(f2, A2_dB, label = 'Black SD Card')
plt.grid(True)
plt.ylabel('Amplitude (dB)')
plt.xlabel('Frequency (Hz)')
plt.title('DATA000 FFT Spectrum Comparison')
# Zoom near region of interest
plt.xlim(0,200) # up to Nyquist (fs/2 = 200)
plt.ylim(-170,-30)
#Find and mark peak
peak_idx1 = np.argmax(A1)
peak_idx2 = np.argmax(A2)
plt.plot(f1[peak_idx1], A1_dB[peak_idx1], 'ro')
plt.plot(f2[peak_idx2], A2_dB[peak_idx2], 'go')
plt.text(f1[peak_idx1] + 2, A1_dB[peak_idx1], f'{f1[peak_idx1]:.1f} Hz', color = 'red')
plt.text(f2[peak_idx2] + 2, A2_dB[peak_idx2], f'{f2[peak_idx2]:1} Hz', color = 'green')
plt.legend()
plt.tight_layout()
plt.savefig('C:/Users/giese/OneDrive/Documents/Work/Research/Shaker Data Collection/DATA000_FFT_Spectrum_Comparison.png')

plt.figure(2)
plt.plot(tt1, ac1, label = 'Color SD Card')
plt.plot(tt2, ac2, label = 'Black SD Card')
plt.xlabel('Time (s)')
plt.ylabel('Acceleration (m/s$^2$)')
plt.xlim(0,1)
plt.title('DATA000 Acceleration Comparison')
plt.legend()
plt.tight_layout() # makes sure plot is neat and sizings work together
plt.savefig('C:/Users/giese/OneDrive/Documents/Work/Research/Shaker Data Collection/DATA000_Acceleration_Comparison.png', dpi=300)