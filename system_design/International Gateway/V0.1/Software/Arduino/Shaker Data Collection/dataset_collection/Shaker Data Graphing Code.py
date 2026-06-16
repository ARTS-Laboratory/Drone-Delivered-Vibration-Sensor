# Copyright 2026 ARTS_LAB

import numpy as np
import pandas as pd
import matplotlib as mpl
import matplotlib.pyplot as plt
import tensorflow as tf
from scipy import signal
from scipy.signal import butter, filtfilt
from sklearn.preprocessing import StandardScaler
from tensorflow import keras # the package you are using for the LSTM is called tensorflow


plt.close('all')


#%% Load data
file1 = 'E:/006.csv'

def highpass_filter(signal, cutoff, fs, order=4):
    # note to self: signal as in acceleration values (ac), 
    # cutoff = freq where filtering starts (for us: 10 Hz)
    # fs = sampling frequency (for us: ~400 Hz, fs = 1/dt)
    nyquist = 0.5 * fs # fs = 400 so nyquist = 200 Hz
    normal_cutoff = cutoff / nyquist
    # 10 / 200 = 0.05; SciPy wants freqs between 0 and 1 instead of Hz
    b, a = butter(order, normal_cutoff, btype='high', analog=False)
    # butterworth filter: smooth response, common for vibration analysis
    filtered_signal = filtfilt(b, a, signal)
    # filtfilt runs the filter forward & backward: removes phase shift
    return filtered_signal

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

    # Apply high-pass filter
    ac_filtered = highpass_filter(ac, cutoff=10, fs=fs)

    # FFT computation
    N = len(ac)                                    # number of samples
    Y_ref = np.fft.fft(ac)
    Y_filtered = np.fft.fft(ac_filtered)           # FFT
    f = np.fft.fftfreq(N, d=dt)                    # frequency vector

    # Take only positive frequencies
    mask = f >= 0
    f = f[mask]
    Y_ref = Y_ref[mask]
    Y_filtered = Y_filtered[mask]

    # Amplitude (normalize)
    A_ref = np.abs(Y_ref) / N
    A_filtered = np.abs(Y_filtered) / N

    # Convert to dB scale
    A_ref_dB = 20 * np.log10(A_ref + 1e-12)
    A_filtered_dB = 20 * np.log10(A_filtered + 1e-12)
    return (tt, ac, ac_filtered, f, A_ref, A_filtered,
            A_ref_dB, A_filtered_dB)


#%% Process both files
(tt1, ac1, ac1_filtered, f1, 
A1_ref, A1_filtered,
A1_ref_dB, A1_filtered_dB) = process_data(file1)


ref = ac1
filtered = ac1_filtered
input_scaler = StandardScaler()
target_scaler = StandardScaler()
filtered_scaled = input_scaler.fit_transform(filtered.reshape(-1,1))
ref_scaled = target_scaler.fit_transform(ref.reshape(-1,1))

lstm_window_size = 400 # how much history the network sees
X = []
y = []
for i in range(lstm_window_size, len(filtered_scaled)):
    X.append(filtered_scaled[i-lstm_window_size:i])
    y.append(ref_scaled[i])

X = np.array(X)
y = np.array(y)
print("X shape:", X.shape)
print("y shape:", y.shape)
print("X[1000] shape:", X[1000].shape)
print("y[1000]:", y[1000])
print("First target value:")
print(y[0])


# [0]: total # of training examples, [1]: # of values per example, 1: 1 feature (acceleration)
X = np.reshape(X, (X.shape[0], X.shape[1], 1))

# Split train/test needed. if we train on everything, train = test, nothing is learned. train teaches, test evaluates
split = int(0.8 * len(X)) # train first 80%, test last 20%
    # if 69,000 samples & window size = 400, len(X) = 68600 training windows
X_train = X[:split] # X_train = Beginning -> split (# value)
X_test = X[split:] # X_test = split (# value) -> End

y_train = y[:split]
y_test = y[split:]

print("X_train:", X_train.shape)
print("X_test:", X_test.shape)

print("y_train:", y_train.shape)
print("y_test:", y_test.shape)

# lstm model
model = keras.models.Sequential()
# 50 units, 1 layer
model.add(keras.layers.LSTM(50, input_shape=(X_train.shape[1], 1)))
model.add(keras.layers.Dense(1))
model.compile(optimizer = 'adam', loss = 'MSE', metrics=[keras.metrics.RootMeanSquaredError()]) # tells it how to measure success so it can adjust it's answers
#Train
history = model.fit(X_train, y_train, epochs=5, batch_size=32)
predictions_all = model.predict(X)
# turns the units back to what we want
predictions_all = target_scaler.inverse_transform(predictions_all)
y_test_actual = target_scaler.inverse_transform(y_test.reshape(-1,1))
prediction_time_all = tt1[lstm_window_size:]
pred_fft = np.fft.fft(predictions.flatten())

#LSTM Predictions
N_pred = len(predictions)
f_pred = np.fft.fftfreq(N_pred, d=np.mean(np.diff(prediction_time)))
mask_pred = f_pred >= 0
f_pred = f_pred[mask_pred]
pred_fft = pred_fft[mask_pred]
A_pred = np.abs(pred_fft) / N_pred
A_pred_dB = 20 * np.log10(A_pred + 1e-12)




# size of plot figure (think of it like the measuremetns of a sheet of paper)
plt.figure(figsize=(6.5,3))

# FFT vs Spectrogram: FFT -> what frequencies exist overall, Spectrogram -> how frequency changes over time
plt.figure(1)
plt.plot(f1, A1_ref_dB, label='Reference')
plt.plot(f1, A1_filtered_dB, label='Filtered')
plt.plot(f_pred, A_pred_dB, label='LSTM Prediction')
plt.ylabel('Amplitude (dB)')
plt.xlabel('Frequency (Hz)')
plt.legend()
plt.title('006 FFT Spectrum Comparison')
plt.grid(True)
# Zoom near region of interest
plt.xlim(0,30) # up to Nyquist (fs/2 = 200)
plt.ylim(-170,-10)
#Find and mark peak
# peak_idx1 = np.argmax(A1_filtered)
# plt.plot(f1[peak_idx1], A1_filtered_dB[peak_idx1], 'ro')
# plt.text(f1[peak_idx1] + 2, A1_filtered_dB[peak_idx1], f'{f1[peak_idx1]:.1f} Hz', color = 'red')
plt.tight_layout()
plt.savefig('C:/Users/giese/OneDrive/Documents/GitHub/Drone-Delivered-Vibration-Sensor/system_design/International Gateway/V0.1/Software/Arduino/Shaker Data Collection/006_FFT_Spectrum_Comparison.png')
plt.show()

fft_smoothing_window = 10
A1_ref_smooth = np.convolve(A1_ref_dB, np.ones(fft_smoothing_window)/fft_smoothing_window, mode='same')
A1_filtered_smooth = np.convolve(A1_filtered_dB, np.ones(fft_smoothing_window)/fft_smoothing_window, mode='same')
A_pred_smooth = np.convolve(A_pred_dB, np.ones(fft_smoothing_window) / fft_smoothing_window, mode='same')

plt.figure(5)
plt.plot(f1, A1_ref_smooth, label='Reference')
plt.plot(f1, A1_filtered_smooth, label='Filtered')
plt.plot(f_pred, A_pred_smooth, label='LSTM Prediction')
plt.legend()
plt.grid(True)
plt.ylabel('Amplitude (dB)')
plt.xlabel('Frequency (Hz)')
plt.title('006 FFT Smoothed Spectrum Comparison')
# Zoom near region of interest
plt.xlim(0,30) # up to Nyquist (fs/2 = 200)
plt.ylim(-170,-10)
#Find and mark peak
# peak_idx1 = np.argmax(A1_filtered_smooth)
# plt.plot(f1[peak_idx1], A1_filtered_smooth[peak_idx1], 'ro')
# plt.text(f1[peak_idx1] + 2, A1_filtered_smooth[peak_idx1], f'{f1[peak_idx1]:.1f} Hz', color = 'red')
plt.tight_layout()
plt.savefig('C:/Users/giese/OneDrive/Documents/GitHub/Drone-Delivered-Vibration-Sensor/system_design/International Gateway/V0.1/Software/Arduino/Shaker Data Collection/006_FFT_Smoothed_Spectrum_Comparison.png')
plt.show()

# plt.figure(2)
# plt.plot(tt1, ac1, label='Reference')
# plt.plot(tt1, ac1_filtered, label='Filtered')
# plt.xlabel('Time (s)')
# plt.ylabel('Acceleration (g)')
# plt.xlim(0,170)
# plt.title('006 Acceleration Comparison')
# plt.legend()
# plt.grid(True)
# plt.tight_layout() # makes sure plot is neat and sizings work together
# plt.savefig('C:/Users/giese/OneDrive/Documents/GitHub/Drone-Delivered-Vibration-Sensor/system_design/International Gateway/V0.1/Software/Arduino/Shaker Data Collection/006_Acceleration_Comparison.png', dpi=300)

plt.figure(6)
plt.plot(tt1, ac1, label='Reference', alpha=0.7) # alpha controls transparency of lines
plt.plot(tt1, ac1_filtered, label='Filtered', alpha=0.7)
plt.plot(prediction_time_all, predictions_all, label = 'LSTM Prediction')
plt.xlabel('Time (s)')
plt.ylabel('Acceleration (g)')
plt.title('006 Acceleration Comparison')
plt.legend()
plt.tight_layout()
plt.savefig('C:/Users/giese/OneDrive/Documents/GitHub/Drone-Delivered-Vibration-Sensor/system_design/International Gateway/V0.1/Software/Arduino/Shaker Data Collection/006_Acceleration_Comparison.png', dpi=300)
plt.show()

# plt.figure(7)
# plt.plot(X[1000])
# plt.title("Example Filtered Window")
# plt.xlabel("Sample")
# plt.ylabel("Scaled Filtered Acceleration")
# plt.tight_layout()
# plt.show()

plt.figure(8)
plt.plot(history.history['loss'], label='MSE')
plt.plot(history.history['root_mean_squared_error'], label='RMSE')
plt.xlabel('Epoch')
plt.ylabel('Error')
plt.title('Training RMSE vs Epoch')
plt.legend()
plt.grid(True)
plt.tight_layout()
plt.show()