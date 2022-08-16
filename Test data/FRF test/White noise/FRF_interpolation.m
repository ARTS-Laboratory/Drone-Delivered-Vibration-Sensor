clc
clear all
close all

%% Load VI Data 
%D = dlmread('Package_FrequencySweepTest.txt',',',23);
D = dlmread('C:\Users\joud\OneDrive - University of South Carolina\Mech research\test\FRF test\Frequency Sweep\Test9 Resonant Frequency\.1-2.1kHz.lvm',',',23);
%time & Acc
tt=D(:,1);
dd=D(:,2);

%plot
figure(1);
plot(tt,dd);
grid on
xlabel("time (s)")
ylabel("acceleration (m/s^2)")
ylim([-5,5])
xlim([0.575,0.585])
%print(',dpng','plot_1.png')

%%plot an fft
%Fs = 1000;            % Sampling frequency     
%T = 1/Fs;             % Sampling period       
T=tt(2)-tt(1);
Fs=1/T
L = length(tt);             % Length of signal
figure(2);
Y = fft(dd*1000);              %THE FFT IS SCALED BY A 1000
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f = Fs*(0:(L/2))/L;

plot(f,P1) 
title('Single-Sided Amplitude Spectrum of X(t)')
xlabel('f (Hz)')
ylabel('|P1(f)|')
xlim([0,2000])


%% Load Package Data
D2 = dlmread('Package_FrequencySweepTest.txt',',');

%time & Acc
tt2=D2(:,1);
dd2=D2(:,2);

%plot
figure(3);
plot(tt2,dd2);
grid on
xlabel("time (s)")
ylabel("acceleration (m/s^2)")

%%plot an fft
%Fs = 1000;            % Sampling frequency     
%T = 1/Fs;             % Sampling period       
T2=tt2(2)-tt2(1);
Fs2=1/T2
L2 = length(tt2);             % Length of signal
Y2 = fft(dd2*1000);           %THE FFT IS SCALED BY A 1000
P22 = abs(Y2/L2);
P12 = P22(1:L2/2+1);
P12(2:end-1) = 2*P12(2:end-1);
f2 = Fs2*(0:(L2/2))/L2;
figure(4);
plot(f2,P12) 
title('Single-Sided Amplitude Spectrum of X(t)')
xlabel('f (Hz)')
ylabel('|P1(f)|')
ylim([0,1])
xlim([0.1,100])

figure(5);
vq1 = interp1(f,P1,f2);
plot(f2,vq1,'o',f2,P12,':.');
xlim([0.1,100])
ylim([0,1])
title('(Default) Linear Interpolation');
length(vq1);
length(P12);

%%Correct dimensions
AccOT=P12(:,1);
vq1Trans=vq1.'
f2Trans=f2.'
AccIN=vq1Trans(:,1);


%Err=(AccOT.\AccIN)*10000;
 writematrix(AccOT,'C:\Users\joud\OneDrive - University of South Carolina\Mech research\test\FRF test\White noise\AccOut.csv') 
 writematrix(AccIN,'C:\Users\joud\OneDrive - University of South Carolina\Mech research\test\FRF test\White noise\AccIN.csv') 
 writematrix(f2Trans,'C:\Users\joud\OneDrive - University of South Carolina\Mech research\test\FRF test\White noise\FHz.csv') 
% figure(6);
% plot(f2,Err);
% xlim([0.1,100])
% ylim([0,2])
% title('FRF');