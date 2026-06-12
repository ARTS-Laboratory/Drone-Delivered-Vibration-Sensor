import numpy as np
import pandas as pd
import matplotlib as mpl
import matplotlib.pyplot as plt
from scipy import signal


plt.close('all')


#%% Load data
file1 = 'D:/005.csv'


#%% Function to load + process data
def process_data(filepath):
# tt= time, ac = acceleration
    D = pd.read_csv(filepath)
    tt = D.iloc[:,0].to_numpy() / 1e6   # convert microseconds to seconds
    ac = D.iloc[:,1].to_numpy()
    ac = ac - np.mean(ac)

    # Sampling
    dt = np.mean(np.diff(tt))
    fs = 1/dt

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

# size of plot figure (think of it like the measuremetns of a sheet of paper)
plt.figure(figsize=(6.5,3))

# FFT vs Spectrogram: FFT -> what frequencies exist overall, Spectrogram -> how frequency changes over time
plt.figure(1)
plt.plot(f1, A1_dB)
plt.grid(True)
plt.ylabel('Amplitude (dB)')
plt.xlabel('Frequency (Hz)')
plt.title('005 FFT Spectrum Comparison')
# Zoom near region of interest
plt.xlim(0,200) # up to Nyquist (fs/2 = 200)
plt.ylim(-170,-30)
#Find and mark peak
peak_idx1 = np.argmax(A1)
plt.plot(f1[peak_idx1], A1_dB[peak_idx1], 'ro')
plt.text(f1[peak_idx1] + 2, A1_dB[peak_idx1], f'{f1[peak_idx1]:.1f} Hz', color = 'red')
plt.tight_layout()
plt.savefig('C:/Users/giese/OneDrive/Documents/GitHub/Drone-Delivered-Vibration-Sensor/system_design/International Gateway/V0.1/Software/Arduino/Shaker Data Collection/005_FFT_Spectrum_Comparison.png')

plt.figure(2)
plt.plot(tt1, ac1)
plt.xlabel('Time (s)')
plt.ylabel('Acceleration (g)')
plt.xlim(0,170)
plt.title('005  Acceleration Comparison')
plt.tight_layout() # makes sure plot is neat and sizings work together
plt.savefig('C:/Users/giese/OneDrive/Documents/GitHub/Drone-Delivered-Vibration-Sensor/system_design/International Gateway/V0.1/Software/Arduino/Shaker Data Collection/005_Acceleration_Comparison.png', dpi=300)

# # Spectrogram
# plt.figure(3, figsize=(6.5,3))
# f_spec, t_spec, Sxx = signal.spectrogram(ac1, fs=1/np.mean(np.diff(tt1)), nperseg=512, noverlap=256)
# plt.pcolormesh(t_spec, f_spec, 10*np.log10(Sxx + 1e-12), shading='gouraud')
# plt.colorbar(label='Power (dB)')
# plt.ylabel('Frequency (Hz)')
# plt.xlabel('Time (s)')
# plt.title('000 Spectrogram')
# plt.ylim(0,40)
# plt.tight_layout()
# plt.savefig('C:/Users/giese/OneDrive/Documents/GitHub/Drone-Delivered-Vibration-Sensor/system_design/International Gateway/V0.1/Software/Arduino/Shaker Data Collection/000Spectrogram.png', dpi=300)

# # Frequency Response Function (FRF)
# N = min(len(ac1), len(ac2))
# x = ac1[:N] # input
# y = ac2[:N] # output
# X = np.fft.fft(x)
# Y = np.fft.fft(y)
# f = np.fft.fftfreq(N, d=dt)
# # keep only positive frequencies
# mask = f >= 0 
# f_frf = f[mask]
# X = X[mask]
# Y = Y[mask]
# H = Y / (X + 1e-12)
# H_mag = np.abs(H)
# H_mag_dB = 20 * np.log10(H_mag + 1e-12)
# H_phase = np.angle(H, deg=True)

# # Plot FRF Magnitude
# plt.figure(3, figsize=(6.5,3))
# plt.plot(f_frf, H_mag_dB)
# plt.grid(True)
# plt.xlabel('Frequency (Hz)')
# plt.ylabel('Magnitude (dB)')
# plt.title('DATA014 Frequency Response Function (Magnitude)')
# plt.xscale('log')
# plt.xlim(0.1,21) # Nyquist Freq
# plt.tight_layout()
# plt.savefig('C:/Users/giese/OneDrive/Documents/GitHub/Drone-Delivered-Vibration-Sensor/system_design/International Gateway/V0.1/Software/Arduino/Shaker Data Collection/DATA014_FRF_Magnitude.png', dpi=300)

# Plot FRF Phase
# plt.figure(4, figsize=(6.5,3))
# plt.plot(f_frf, H_phase)
# plt.grid(True)
# plt.xlabel('Frequency (Hz)')
# plt.ylabel('Phase (degrees)')
# plt.title('DATA011 Frequency Response Function (Phase)')
# plt.xscale('log')
# plt.xlim(0.1,21)
# plt.ylim(-200, 200)
# plt.tight_layout()
# plt.savefig('C:/Users/giese/OneDrive/Documents/GitHub/Drone-Delivered-Vibration-Sensor/system_design/International Gateway/V0.1/Software/Arduino/Shaker Data Collection/DATA011_FRF_Phase.png', dpi=300)


window_size = 10
A1_smooth = np.convolve(A1_dB, np.ones(window_size)/window_size, mode='same')

plt.figure(5)
plt.plot(f1, A1_smooth)
plt.grid(True)
plt.ylabel('Amplitude (dB)')
plt.xlabel('Frequency (Hz)')
plt.title('005 FFT Smoothed Spectrum Comparison')
# Zoom near region of interest
plt.xlim(0,200) # up to Nyquist (fs/2 = 200)
plt.ylim(-170,-30)
#Find and mark peak
peak_idx1 = np.argmax(A1_smooth)
plt.plot(f1[peak_idx1], A1_smooth[peak_idx1], 'ro')
plt.text(f1[peak_idx1] + 2, A1_smooth[peak_idx1], f'{f1[peak_idx1]:.1f} Hz', color = 'red')
plt.tight_layout()
plt.savefig('C:/Users/giese/OneDrive/Documents/GitHub/Drone-Delivered-Vibration-Sensor/system_design/International Gateway/V0.1/Software/Arduino/Shaker Data Collection/005_FFT_Smoothed_Spectrum_Comparison.png')