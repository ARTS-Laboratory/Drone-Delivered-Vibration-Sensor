clc
clear all
close all

%% Load VI Data 
D = dlmread('C:\Users\joud\OneDrive - University of South Carolina\Mech research\test\FRF test\Frequency Sweep\Test16 synced sweep\SyncSweepVI3.lvm',',',23);

%time & Acc
tt=D(:,1);
dd=D(:,2);

%Time Plot
figure(1);
plot(tt,dd);
grid on
xlabel("time (s)");
ylabel("acceleration (m/s^2)");
legend("VI Data");
%print(',dpng','plot_1.png')

%% Load Package Data

D2 = dlmread('C:\Users\joud\OneDrive - University of South Carolina\Mech research\test\FRF test\Frequency Sweep\Test16 synced sweep\SyncSweepPkg3.lvm',',',0);

%time & Acc
tt2=D2(:,1);
dd2=D2(:,2);

%Time plot
figure(2);
plot(tt2,dd2);
grid on
xlabel("time (s)");
ylabel("acceleration ");
legend("Package Data");

%% Interpolate VI time data onto the package's time data
Fs=1600;
Ts=1/Fs;
End=tt(74000);
tt40=0: 1/Fs : End; %time column for Fs=40Hz

VIAcc = interp1(tt,dd,tt40);
PkgAcc = interp1(tt2,dd2,tt40);
%time domain interpolated:
figure(3);
plot(tt40,VIAcc,tt40,PkgAcc);
grid on
xlabel("time (s)");
ylabel("acceleration (m/s^2) ");
legend("VI Data","Package Data");
ylim([-.6,.6]);


%set up sampling Fs:
T2=tt40(2)-tt40(1);
Fs2=1/T2;
L2 = length(tt40);             % Length of signal
 
%VI FFT 
Y2 = fft(VIAcc);           
P22 = abs(Y2/L2);
P12 = P22(1:L2/2+1);
P12(2:end-1) = 2*P12(2:end-1);
f2 = Fs*(0:(L2/2))/L2;

%Package FFT
Y = fft(PkgAcc);           
P2 = abs(Y/L2);
P1 = P2(1:L2/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f = Fs*(0:(L2/2))/L2;

%Plot interpolated FFTs
figure(3);
plot(f2,P12,f2,P1);
title('Single-Sided Amplitude Spectrum of X(t)');
xlabel('frequency (Hz)');
ylabel('|G(f)|');
%ylim([0,20]);
xlim([0.1,20]);
legend("VI FFT","Package FFT");



%% Interpolate VI data onto the package's FFT

AccOT=P1;
AccIN=P12;


%FRF 
Err=(AccOT.\AccIN);
figure(4);
plot(f2,Err);
xlim([0,20])
ylim([0,2.5])
%title('Frequency Response Function');
legend("AccOut/AccIn");
xlabel('frequency (Hz)');
ylabel('AccOut/AccIn');


%Averaged FRF 
Err = movmean(Err,10);%Err = movmean(Err,30);
%Err=abs(Err);
figure(5);
plot(f2,Err);
xlim([0,20])
ylim([0,2.5])
%title('Frequency Response Function');
legend("AccOut/AccIn");
xlabel('frequency (Hz)');
ylabel('AccOut/AccIn');

%Double Average FRF
Err = movmean(Err,10);Err = movmean(Err,10);
figure(6);
plot(f2,Err);
xlim([0,20])
ylim([0,2.5])
%title('Frequency Response Function');
legend("AccOut/AccIn");
xlabel('frequency (Hz)');
ylabel('AccOut/AccIn');













