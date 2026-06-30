# Copyright 2026 ARTS_LAB

import numpy as np
import pandas as pd
import matplotlib as mpl
import matplotlib.pyplot as plt
import tensorflow as tf
import os
from scipy import signal
from scipy.signal import butter, filtfilt
from sklearn.preprocessing import StandardScaler
from tensorflow import keras # the package you are using for the LSTM is called tensorflow


plt.close('all')

# Font specifications
plt.rcParams['font.family'] = 'Times New Roman'
plt.rcParams['font.size'] = 12
plt.rcParams['axes.titlesize'] = 16
plt.rcParams['axes.labelsize'] = 14
plt.rcParams['xtick.labelsize'] = 12
plt.rcParams['ytick.labelsize'] = 12
plt.rcParams['legend.fontsize'] = 12

#%% Load data
train_files = [
    'C:/Users/giese/OneDrive/Documents/GitHub/Drone-Delivered-Vibration-Sensor/system_design/International Gateway/V0.1/Software/Arduino/Shaker Data Collection/dataset_collection/Color SD Card (Top Sensor Package)/006.csv',
    'C:/Users/giese/OneDrive/Documents/GitHub/Drone-Delivered-Vibration-Sensor/system_design/International Gateway/V0.1/Software/Arduino/Shaker Data Collection/dataset_collection/Color SD Card (Top Sensor Package)/008.csv',
    'C:/Users/giese/OneDrive/Documents/GitHub/Drone-Delivered-Vibration-Sensor/system_design/International Gateway/V0.1/Software/Arduino/Shaker Data Collection/dataset_collection/Color SD Card (Top Sensor Package)/009.csv',
    'C:/Users/giese/OneDrive/Documents/GitHub/Drone-Delivered-Vibration-Sensor/system_design/International Gateway/V0.1/Software/Arduino/Shaker Data Collection/dataset_collection/Color SD Card (Top Sensor Package)/010.csv',
    'C:/Users/giese/OneDrive/Documents/GitHub/Drone-Delivered-Vibration-Sensor/system_design/International Gateway/V0.1/Software/Arduino/Shaker Data Collection/dataset_collection/Color SD Card (Top Sensor Package)/011.csv',
    'C:/Users/giese/OneDrive/Documents/GitHub/Drone-Delivered-Vibration-Sensor/system_design/International Gateway/V0.1/Software/Arduino/Shaker Data Collection/dataset_collection/Color SD Card (Top Sensor Package)/012.csv',
    'C:/Users/giese/OneDrive/Documents/GitHub/Drone-Delivered-Vibration-Sensor/system_design/International Gateway/V0.1/Software/Arduino/Shaker Data Collection/dataset_collection/Color SD Card (Top Sensor Package)/013.csv'
]
test_file = 'C:/Users/giese/OneDrive/Documents/GitHub/Drone-Delivered-Vibration-Sensor/system_design/International Gateway/V0.1/Software/Arduino/Shaker Data Collection/dataset_collection/Color SD Card (Top Sensor Package)/014.csv'

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


# Process test file
(tt_test, ac_test, ac_test_filtered, f_test,
 A_test_ref, A_test_filtered, A_test_ref_dB,
 A_test_filtered_dB) = process_data(test_file)

base_folder = (
    r"C:\Users\giese\Dropbox\Satme_2026_IEEE_Edge_Processing_Compensator"
    r"\Data\Benchtop Test\dataset_collection"
)
run_number = 1
while any(
    name.startswith(f"Run_{run_number:03d}")
    for name in os.listdir(base_folder)
):
    run_number += 1

epochs = 20
batch_size = 16
window_size = 1200
hidden_units = 50

run_folder = (
    f"{base_folder}/"
    f"Run_{run_number:03d}"
    f"_Epoch{epochs}"
    f"_Batch{batch_size}"
    f"_Window{window_size}"
)
os.makedirs(run_folder)

lstm_window_size = window_size # how much history the network sees

####### TRAIN
input_scaler = StandardScaler()
target_scaler = StandardScaler()

all_filtered = []
all_ref = []
for file in train_files:
    (tt, ac, ac_filtered, f, A_ref, A_filtered, A_ref_dB, A_filtered_dB) = process_data(file)
    all_filtered.extend(ac_filtered)
    all_ref.extend(ac)

all_filtered = np.array(all_filtered).reshape(-1,1)
all_ref = np.array(all_ref).reshape(-1,1)
input_scaler.fit(all_filtered)
target_scaler.fit(all_ref)

X_train = []
y_train = []
for file in train_files:
    (tt,ac, ac_filtered, f, A_ref, A_filtered, A_ref_dB, A_filtered_dB) = process_data(file)
    filtered_scaled = input_scaler.transform(ac_filtered.reshape(-1,1))
    ref_scaled = target_scaler.transform(ac.reshape(-1,1))
    for i in range(lstm_window_size, len(filtered_scaled)):
        X_train.append(filtered_scaled[i-lstm_window_size:i])
        y_train.append(ref_scaled[i])

X_train = np.array(X_train)
y_train = np.array(y_train)
print("X_train shape:", X_train.shape)
print("y_train shape:", y_train.shape)
print("X_train[1000] shape:", X_train[1000].shape)
print("y_train[1000]:", y_train[1000])
print("First target value:")
print(y_train[0])
# [0]: total # of training examples, [1]: # of values per example, 1: 1 feature (acceleration)
X_train = np.reshape(X_train, (X_train.shape[0], X_train.shape[1], 1))

####### TEST
filtered_test = ac_test_filtered
ref_test = ac_test
filtered_test_scaled = input_scaler.transform(filtered_test.reshape(-1,1))
ref_test_scaled = target_scaler.transform(ref_test.reshape(-1,1))
X_test = []
y_test = []
for i in range(lstm_window_size, len(filtered_test_scaled)):
    X_test.append(filtered_test_scaled[i-lstm_window_size:i])
    y_test.append(ref_test_scaled[i])
X_test = np.array(X_test)
y_test = np.array(y_test)
X_test = np.reshape(X_test, (X_test.shape[0], X_test.shape[1], 1))

print("X_train:", X_train.shape)
print("X_test:", X_test.shape)
print("y_train:", y_train.shape)
print("y_test:", y_test.shape)

# lstm model
model = keras.models.Sequential()
# 50 units, 1 layer
model.add(keras.layers.LSTM(hidden_units, input_shape=(X_train.shape[1], 1)))
model.add(keras.layers.Dense(1))
model.compile(optimizer = 'adam', loss = 'MSE', metrics=[keras.metrics.RootMeanSquaredError()]) # tells it how to measure success so it can adjust it's answers
#Train
history = model.fit(X_train, y_train, epochs=epochs, batch_size=batch_size)
print(f"\nRun saved to:\n{run_folder}\n")
model.save(f"{run_folder}/LSTM_Model.keras")
history_df = pd.DataFrame(history.history)
history_df.to_csv(f"{run_folder}/TrainingHistory.csv", index=False)
# model.save('lstm_model.keras')
# model = keras.models.load_model('lstm_model.keras')
predictions = model.predict(X_test)

for i, weight in enumerate(model.get_weights()):
    np.savetxt(f"{run_folder}/weights_layer_{i}.csv",weight,delimiter=',')

settings = {
    "Window Size": window_size,
    "Epochs": epochs,
    "Batch Size": batch_size,
    "Training Files": len(train_files),
    "Hidden Units": hidden_units,
    "Optimizer": "Adam",
    "Loss": "MSE",
}
settings["Test File"] = os.path.basename(test_file)
settings["Training Files"] = ", ".join(os.path.basename(f) for f in train_files)

settings_df = pd.DataFrame([settings])
settings_df.to_csv(f"{run_folder}/Model_Settings.csv", index=False)

results = {
    "Final Loss": history.history['loss'][-1],
    "Final RMSE": history.history['root_mean_squared_error'][-1],
    "Epochs": epochs,
    "Batch Size": batch_size,
    "Window Size": window_size,
    "Hidden Units": hidden_units,
    "Training Files": len(train_files),
    "Test File": os.path.basename(test_file)
}
pd.DataFrame([results]).to_csv(f"{run_folder}/RunSummary.csv", index=False)

# Load previously saved model outputs
# predictions = np.load('predictions.npy')
# prediction_time = np.load('prediction_time.npy')

# turns the units back to what we want
predictions = target_scaler.inverse_transform(predictions)
y_test_actual = target_scaler.inverse_transform(y_test.reshape(-1,1))
prediction_time = tt_test[lstm_window_size:]

np.save(f"{run_folder}/predictions.npy", predictions)
np.save(f"{run_folder}/prediction_time.npy", prediction_time)

prediction_df = pd.DataFrame({
    "Time": prediction_time,
    "Reference": y_test_actual.flatten(),
    "Prediction": predictions.flatten()
})
prediction_df.to_csv(f"{run_folder}/Predictions.csv", index=False)
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
plt.plot(f_test, A_test_ref_dB, color='blue', label='Target Structural Response')
plt.plot(f_test, A_test_filtered_dB, color='black', label='Attenuated Sensor Signal')
plt.plot(f_pred, A_pred_dB, color='green', label='LSTM Compensation')
plt.ylabel('Amplitude (dB)')
plt.xlabel('Frequency (Hz)')
plt.legend()
# plt.title('014 FFT Spectrum Comparison')
plt.grid(True)
# Zoom near region of interest
plt.xlim(0,30) # up to Nyquist (fs/2 = 200)
plt.ylim(-170,-10)
#Find and mark peak
# peak_idx1 = np.argmax(A1_filtered)
# plt.plot(f1[peak_idx1], A1_filtered_dB[peak_idx1], 'ro')
# plt.text(f1[peak_idx1] + 2, A1_filtered_dB[peak_idx1], f'{f1[peak_idx1]:.1f} Hz', color = 'red')
plt.tight_layout()
plt.savefig(f"{run_folder}/014_{epochs}Epoch_FFT_Spectrum_Comparison.png", dpi=300)

fft_smoothing_window = 10
A_test_ref_smooth = np.convolve(A_test_ref_dB, np.ones(fft_smoothing_window)/fft_smoothing_window, mode='same')
A_test_filtered_smooth = np.convolve(A_test_filtered_dB, np.ones(fft_smoothing_window)/fft_smoothing_window, mode='same')
A_pred_smooth = np.convolve(A_pred_dB, np.ones(fft_smoothing_window) / fft_smoothing_window, mode='same')

plt.figure(5)
plt.plot(f_test, A_test_ref_smooth, color='blue', label='Target Structural Response')
plt.plot(f_test, A_test_filtered_smooth, color='black', label='Attenuated Sensor Signal')
plt.plot(f_pred, A_pred_smooth, color='green', label='LSTM Compensation')
plt.legend()
plt.grid(True)
plt.ylabel('Amplitude (dB)')
plt.xlabel('Frequency (Hz)')
# plt.title('014 FFT Smoothed Spectrum Comparison')
# Zoom near region of interest
plt.xlim(0,30) # up to Nyquist (fs/2 = 200)
plt.ylim(-170,-10)
#Find and mark peak
# peak_idx1 = np.argmax(A1_filtered_smooth)
# plt.plot(f1[peak_idx1], A1_filtered_smooth[peak_idx1], 'ro')
# plt.text(f1[peak_idx1] + 2, A1_filtered_smooth[peak_idx1], f'{f1[peak_idx1]:.1f} Hz', color = 'red')
plt.tight_layout()
plt.savefig(f"{run_folder}/014_{epochs}Epoch_FFT_Smoothed_Spectrum_Comparison.png", dpi=300)


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
plt.plot(tt_test, ac_test, color='blue', label='Target Structural Response', alpha=0.7) # alpha controls transparency of lines
plt.plot(tt_test, ac_test_filtered, color='black', label='Attenuated Sensor Signal', alpha=0.7)
plt.plot(prediction_time, predictions, color='green', label = 'LSTM Compensation')
plt.xlabel('Time (s)')
plt.ylabel('Acceleration (g)')
# plt.title('014 Acceleration Comparison')
plt.legend()
plt.grid(True)
plt.tight_layout()
plt.savefig(f"{run_folder}/014_{epochs}Epoch_Acceleration_Comparison.png", dpi=300)


plt.figure(7)
plt.plot(tt_test, ac_test, color='blue', label='Target Structural Response', alpha=0.7) # alpha controls transparency of lines
plt.plot(tt_test, ac_test_filtered, color='black', label='Attenuated Sensor Signal', alpha=0.7)
plt.plot(prediction_time, predictions, color='green', label = 'LSTM Compensation')
plt.xlabel('Time (s)')
plt.ylabel('Acceleration (g)')
plt.xlim(100,100.5)
# plt.title('014 Zoom Acceleration Comparison')
plt.legend()
plt.grid(True)
plt.tight_layout()
plt.savefig(f"{run_folder}/014_{epochs}Epoch_Zoom_Acceleration_Comparison.png", dpi=300)


plt.figure(8)
plt.plot(history.history['loss'], label='MSE')
plt.plot(history.history['root_mean_squared_error'], label='RMSE')
plt.xlabel('Epoch')
plt.ylabel('Error')
# plt.title('Training RMSE vs Epoch')
plt.legend()
plt.grid(True)
plt.tight_layout()
plt.savefig(f"{run_folder}/014_{epochs}Epoch_Training_Error_vs_Epoch.png", dpi=300)

# Frequency Response Function (FRF) Ref vs Filt
N = min(len(ac_test), len(ac_test_filtered))
Y_ref = np.fft.fft(ac_test[:N])
Y_filtered = np.fft.fft(ac_test_filtered[:N])
f_frf = np.fft.fftfreq(N, d=np.mean(np.diff(tt_test)))
mask = f_frf >= 0
f_frf = f_frf[mask]
Y_ref = Y_ref[mask]
Y_filtered = Y_filtered[mask]
H_filtered = Y_filtered / (Y_ref + 1e-12)
H_filtered_mag = np.abs(H_filtered)

# Frequency Response Function (FRF) Ref vs LSTM
N_pred = min(len(predictions), len(y_test_actual))
Y_pred = np.fft.fft(predictions[:N_pred].flatten())
Y_ref_pred = np.fft.fft(y_test_actual[:N_pred].flatten())
f_pred_frf = np.fft.fftfreq(N_pred, d=np.mean(np.diff(prediction_time)))
mask_pred = f_pred_frf >= 0
f_pred_frf = f_pred_frf[mask_pred]
Y_pred = Y_pred[mask_pred]
Y_ref_pred = Y_ref_pred[mask_pred]
H_lstm = Y_pred / (Y_ref_pred + 1e-12)
H_lstm_mag = np.abs(H_lstm)


# Plot FRF, Ref vs Filt
plt.figure(9, figsize=(6.5,3))
threshold = 1e-6
valid = np.abs(Y_ref) > threshold
plt.plot(f_frf[valid], H_filtered_mag[valid], color='black', label='Attenuated Sensor Signal / Target Structural Response')
plt.plot(f_pred_frf[valid], H_lstm_mag[valid], color='green', label='LSTM Compensation / Target Structural Response')
plt.xlabel('Frequency (Hz)')
plt.ylabel('Amplitude Ratio')
# plt.title('FRF Magnitude Comparison')
# plt.xscale('log')
plt.xlim(0.1,30)
plt.legend()
plt.grid(True)
plt.tight_layout()
plt.savefig(f"{run_folder}/014_{epochs}Epoch_FRF_Magnitude_Comparison.png", dpi=300)


# Plot FRF, Ref vs Filt
plt.figure(10, figsize=(6.5,3))
plt.plot(f_frf[valid], H_filtered_mag[valid], color='black', label='Attenuated Sensor Signal / Target Structural Response')
plt.plot(f_pred_frf[valid], H_lstm_mag[valid], color='green', label='LSTM Compensation / Target Structural Response')
plt.xlabel('Frequency (Hz)')
plt.ylabel('Amplitude Ratio')
# plt.title('FRF Magnitude Comparison')
plt.grid(True)
plt.xlim(1,21)
plt.legend()
plt.tight_layout()
plt.savefig(f"{run_folder}/014_{epochs}Epoch_Zoomed_FRF_Magnitude_Comparison.png", dpi=300)
plt.show()