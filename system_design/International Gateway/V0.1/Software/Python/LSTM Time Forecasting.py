# Imports
from tensorflow import keras
import pandas as pd # used to load our data
import numpy as np # used to create 3D arrays for our sequential model
from sklearn.preprocessing import StandardScaler
import matplotlib.pyplot as plt
import seaborn as sns
import os 
from datetime import datetime

os.environ['TF_CPP_MIN_LOG_LEVEL'] = '2'

data = pd.read_csv(r"C:\Users\giese\OneDrive\Documents\GitHub\Drone-Delivered-Vibration-Sensor\system_design\International Gateway\V0.1\Software\Arduino\Shaker Data Collection\dataset_collection\MicrosoftStock.csv")
print(data.head())
print(data.info())
print(data.describe())

# Initial Data Visualization
# Plot 1 - Open and Close Prices of time
plt.figure(figsize=(6.5,3))
plt.plot(data['date'], data['open'], label="Open", color="blue")
plt.plot(data['date'], data['close'], label="Close", color="red")
plt.title("Open-Close Price over Time")
plt.legend()
# plt.show()


#Plot 2 - Trading Volume (Check for outliers)
plt.figure(figsize=(6.5,3))
plt.plot(data['date'], data['volume'], label="Volume", color="orange")
plt.title("Stock Volume over Time")
# plt.show()

# Drop non-numeric columns
numeric_data = data.select_dtypes(include=["int64","float64"])

# Plot 3 - Check for correlation between features
plt.figure(figsize=(6.5,3))
sns.heatmap(numeric_data.corr(), annot=True, cmap="coolwarm")
plt.title(" Feature Correlation Heatmap")
# plt.show()

# Convert the Data into Date time then create a date filter
data['date'] = pd.to_datetime(data['date'])

prediction = data.loc[
    (data['date'] > datetime(2013,1,1)) & 
    (data['date'] < datetime(2018,1,1))
]

plt.figure(figsize=(6.5,3))
plt.plot(data['date'], data['close'], color="blue")
plt.xlabel("Date")
plt.ylabel("Close")
plt.title("Price over Time")


# Prepare for the LSTM Model (Sequential)
stock_close = data.filter(["close"])
dataset = stock_close.values # convert to numpy array
training_data_len = int(np.ceil(len(dataset) * 0.95))

# Preprocessing Stages
scaler = StandardScaler()
scaled_data = scaler.fit_transform(dataset)

training_data = scaled_data[:training_data_len] # 95% of all our data

X_train, y_train = [], []

# Create a sliding window for our stock (60 days)
for i in range(60, len(training_data)):
    X_train.append(training_data[i-60:i, 0])
    y_train.append(training_data[i, 0])

X_train, y_train = np.array(X_train), np.array(y_train)

X_train = np.reshape(X_train, (X_train.shape[0], X_train.shape[1], 1))


# Build the model
model = keras.models.Sequential()

# LSTM Layer 1
model.add(keras.layers.LSTM(64, return_sequences = True, input_shape=(X_train.shape[1], 1)))

# LSTM Layer 2
model.add(keras.layers.LSTM(64, return_sequences = False))

# Dense Layer
model.add(keras.layers.Dense(128, activation="relu"))

# Dropout Layer
model.add(keras.layers.Dropout(0.5))

# Final Output Layer
model.add(keras.layers.Dense(1))

model.summary()
model.compile(optimizer="adam", loss="mae", metrics=[keras.metrics.RootMeanSquaredError()])

training = model.fit(X_train, y_train, epochs=20, batch_size=32)

# Prep the test data
test_data = scaled_data[training_data_len - 60:]
x_test, y_test = [], dataset[training_data_len:]

for i in range(60, len(test_data)):
    x_test.append(test_data[i-60:i, 0])

x_test = np.array(x_test)
x_test = np.reshape(x_test, (x_test.shape[0], x_test.shape[1], 1))


# Make a prediction
predictions = model.predict(x_test)
predictions = scaler.inverse_transform(predictions)

# Plotting data
train = data[:training_data_len]
test = data[training_data_len:]

test = test.copy()

test['Predictions'] = predictions

plt.figure(figsize=(6.5,3))
plt.plot(train['date'], train['close'], label="Train (Actual)", color='blue')
plt.plot(test['date'], test['close'], label="Test (Actual)", color='orange')
plt.plot(test['date'], test['Predictions'], label="Predictions", color='red')
plt.title("Our Stock Predictions")
plt.xlabel("Date")
plt.ylabel("Close Price")
plt.legend()
plt.show()