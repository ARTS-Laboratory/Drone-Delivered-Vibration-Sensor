%Under Damped Case Model
clc
clear all
close all
 
%% Given:
k=301250; %N/m
b=5.10227645396; %N/(m/s)

%Mass of PCB:
m=5.868*10^-3; %kg
%Mass of PCB + Mag:
%m=;

%% Construct State-Space
A=[0 1; -k/m -b/m];
B=[0; 1/m];
C=[1 0];
D=[0];

sys=ss(A,B,C,D)
figure(1);
impulse(sys);
grid on
[Dis,t] = impulse(sys);
legend('impulse response');


%% FFT 

%set up sampling Fs:
T2=t(2)-t(1);
Fs2=1/T2;
L2 = length(t);             % Length of signal
 

Y2 = fft(Dis);           %THE FFT IS SCALED BY A 1000
P22 = abs(Y2/L2);
P12 = P22(1:L2/2+1);
P12(2:end-1) = 2*P12(2:end-1);
f2 = Fs2*(0:(L2/2))/L2;

%% Plot The FFT
figure(2);
plot(f2,P12);
grid on
title('Single-Sided Amplitude Spectrum of X(t)');
xlabel('frequency (Hz)');
ylabel('|G(f)|');
legend('frequency response');
%ylim([0,20]);
xlim([0.1,2000]);
legend("FFT");

%% Construct a Transfer function

s = tf('s');
sysTF = 1/(m*s^2+b*s+k)
figure(3);
bode(sysTF);
grid on

