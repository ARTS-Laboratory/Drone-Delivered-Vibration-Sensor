clc
clear all
close all

%% Import data

%Model Package data
D1 = dlmread('C:\Users\joud\OneDrive - University of South Carolina\Mech research\test\FRF test\Frequency Sweep\Test15 discrete frequency Test\DiscTestPkg5Hz.lvm',',',0);

%Model VI data
D2 = dlmread('C:\Users\joud\OneDrive - University of South Carolina\Mech research\test\FRF test\Frequency Sweep\Test15 discrete frequency Test\DiscTestVI5Hz.lvm',',',23);

%Val Package data
D1 = dlmread('C:\Users\joud\OneDrive - University of South Carolina\Mech research\test\FRF test\Frequency Sweep\Test15 discrete frequency Test\DiscTestPkg5Hz.lvm',',',0);

%Val VI data
D2 = dlmread('C:\Users\joud\OneDrive - University of South Carolina\Mech research\test\FRF test\Frequency Sweep\Test15 discrete frequency Test\DiscTestVI5Hz.lvm',',',23);


%% Extract data
%Package time & Acc 
tt1=D1(:,1);
dd1=D1(:,2);
%VI time & Acc 
tt2=D2(:,1);
dd2=D2(:,2);

%% Calibrate Package Acceleration
dd2Cal1 = mean(dd1); %Calibrates Time domain offset
PkgAccCal1=-(dd1-dd2Cal1); %Calibrate dimension) 

%% Generate time scale
Fs=1600;
Ts=1/Fs;
End=tt2(length(dd1));
tt40=0: 1/Fs : End; %time column for Fs=40Hz

%% Trigger Time Compensation parameters
DeltaT_VI=0; % Validation offset
PkgAccMod = interp1(tt1,PkgAccCal1,tt40); 
%VIAccMod = interp1(tt2,dd2,tt40);
VIAccMod = interp1(tt2-DeltaT_VI,dd2,tt40);

%% BandPass filter
%BandPass Filter Parameters
Fin=0.01; %Hz
Fot=2; %Hz
PkgAccModFltr=bandpass(PkgAccMod,[Fin Fot],Fs);
VIAccModFltr=bandpass(VIAccMod,[Fin Fot],Fs);

%% Peak Detection
% figure(1);
% findpeaks(PkgAccModFltr,tt40);
% figure(2);
% findpeaks(VIAccModFltr,tt40);
[Pk,TPk]=findpeaks(PkgAccModFltr,tt40);
[Pk2,TPk2]=findpeaks(VIAccModFltr,tt40);
timeComp=TPk(1)-TPk2(1)

%% Calculate Error at given Frequency
Err=VIAccModFltr-PkgAccModFltr;

%% Plot Time Domain 
figure(4);
plot(tt40,VIAccModFltr,tt40,PkgAccModFltr,tt40,Err);
xlim([0,3])
grid on
title('Single Frequency 1Hz');
xlabel("time (s)");
ylabel("acceleration (m/s^2) ");
legend("VI Data","Package Data","Error");

%% Construct an FFT
%set up sampling Fs:
T2=tt40(2)-tt40(1);
Fs2=1/T2;
L2 = length(tt40);             % Length of signal
 
%VI FFT 
Y2 = fft(VIAccModFltr);           
P22 = abs(Y2/L2);
P12 = P22(1:L2/2+1);
P12(2:end-1) = 2*P12(2:end-1);
f2 = Fs*(0:(L2/2))/L2;

%Package FFT
Y = fft(Err);           
P2 = abs(Y/L2);
P1 = P2(1:L2/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f = Fs*(0:(L2/2))/L2;

%Plot interpolated FFTs
figure(5);
plot(f2,P12,f2,P1);
title('Single-Sided Amplitude Spectrum of X(t)');
xlabel('frequency (Hz)');
ylabel('|G(f)|');
%ylim([0,20]);
xlim([0.1,20]);
legend("Post","Error");



























