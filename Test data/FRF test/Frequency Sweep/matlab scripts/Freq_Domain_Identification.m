clc
clear all
close all

%% Load VI Data 
D = dlmread('C:\Users\joud\OneDrive - University of South Carolina\Mech research\test\FRF test\Frequency Sweep\Test10 Fs 1480Hz FRF\FRF Test VI 3.lvm',',',23);

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

D2 = dlmread('C:\Users\joud\OneDrive - University of South Carolina\Mech research\test\FRF test\Frequency Sweep\Test10 Fs 1480Hz FRF\FRF Test Package 3.lvm',',',0);

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
VIAcc = interp1(tt,dd,tt2);

%time domain interpolated:
figure(3);
plot(tt2,VIAcc,tt2,dd2-.9415);
grid on
xlabel("time (s)");
ylabel("acceleration (m/s^2) ");
legend("VI Data","Package Data");
ylim([-.6,.6]);


%set up sampling Fs:
T2=tt2(2)-tt2(1);
Fs2=1/T2;
L2 = length(tt2);             % Length of signal
 
%VI FFT 
Y2 = fft(VIAcc*1000);           %THE FFT IS SCALED BY A 1000
P22 = abs(Y2/L2);
P12 = P22(1:L2/2+1);
P12(2:end-1) = 2*P12(2:end-1);
f2 = Fs2*(0:(L2/2))/L2;

%Package FFT
Y = fft(dd2*1000);           %THE FFT IS SCALED BY A 1000
P2 = abs(Y/L2);
P1 = P2(1:L2/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f = Fs2*(0:(L2/2))/L2;

%Plot interpolated FFTs
figure(4);
plot(f2,P12,f2,P1);
title('Single-Sided Amplitude Spectrum of X(t)');
xlabel('frequency (Hz)');
ylabel('|G(f)|');
ylim([0,20]);
xlim([0.1,20]);
legend("VI FFT","Package FFT");



%% Interpolate VI data onto the package's FFT

AccOT=P1;
AccIN=P12;

%FRF Response 
Err=(AccOT.\AccIN);
figure(6);
semilogx(f2,Err);
xlim([0.9,20]);
ylim([0,2.5]);
title('Frequency Response Function');
legend("AccOut/AccIn");
xlabel('frequency (Hz)');
ylabel('AccOut/AccIn');

%Averaged FRF
Avg = movmean(Err,30);


figure(7);
%plot(f2,Avg);
semilogx(f2,Avg);
xlim([0.02,20]);
ylim([-.1,2.5]);
title('Frequency Response Function');
legend("AccOut/AccIn");
xlabel('frequency (Hz)');
ylabel('AccOut/AccIn');

%% TF estimation function

%Avg = movmean(Err,30)%,'Endpoints','discard');

load demofr
figure(8);
subplot(211), loglog(W,AMP),title('Amplitude Response')
subplot(212), semilogx(W,PHA),title('Phase Response')


