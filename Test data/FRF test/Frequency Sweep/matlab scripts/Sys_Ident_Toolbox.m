clc
clear all
close all

%% Import data

%Model Package data
D1 = dlmread('C:\Users\joud\OneDrive - University of South Carolina\Mech research\test\FRF test\Frequency Sweep\WhiteNoisePkg3.lvm',',',0);

%Model VI data
D2 = dlmread('C:\Users\joud\OneDrive - University of South Carolina\Mech research\test\FRF test\Frequency Sweep\WhiteNoiseVI3.lvm',',',23);

%Validation Package data
D3 = dlmread('C:\Users\joud\OneDrive - University of South Carolina\Mech research\test\FRF test\Frequency Sweep\WhiteNoisePkg5.lvm',',',0);

%Validation VI data
D4 = dlmread('C:\Users\joud\OneDrive - University of South Carolina\Mech research\test\FRF test\Frequency Sweep\WhiteNoiseVI5.lvm',',',23);

%% Extract data
%time & Acc 1
tt1=D1(:,1);
dd1=D1(:,2);
%time & Acc 2
tt2=D2(:,1);
dd2=D2(:,2);
%time & Acc 3
tt3=D3(:,1);
dd3=D3(:,2); 
%time & Acc 4
tt4=D4(:,1);
dd4=D4(:,2);

%% Calibrate Package data
dd2Cal1 = mean(dd1) %Calibrates Time domain offset
PkgAccCal1=-(dd1-dd2Cal1); %Calibrate dimension) 
dd2Cal3 = mean(dd3) %Calibrates Time domain offset
PkgAccCal3=-(dd3-dd2Cal3); %Calibrate dimension) 

%% Generate time scale
Fs=1600
Ts=1/Fs
End=tt4(length(dd1))
tt40=0: 1/Fs : End; %time column for Fs=40Hz
%Package Compensation
DeltaT=0;%-(2.250625000000000-2.058125000000000);% (Seconds)Sensor package time calibration
PkgAccMod = interp1(tt1+DeltaT,PkgAccCal1,tt40); 
VIAccMod = interp1(tt2,dd2,tt40);
PkgAccVal = interp1(tt3+DeltaT,PkgAccCal3,tt40); 
VIAccVal = interp1(tt4,dd4,tt40);

%Delete Transient
% tt40 = tt40(:,2000:end);
% PkgAccMod = PkgAccMod(:,2000:end);
% VIAccMod = VIAccMod(:,2000:end);
% PkgAccVal = PkgAccVal(:,2000:end);
% VIAccVal = VIAccVal(:,2000:end);

%% Plot Data

%Model Data Plot
figure(1);
plot(tt40,VIAccMod,tt40,PkgAccMod);
grid on
title('Data Interpolated to Fs=1600 Hz');
xlabel("time (s)");
ylabel("acceleration (m/s^2) ");
legend("Model VI Data","Model Package Data");

%Validation Data Plot
figure(2);
plot(tt40,VIAccVal,tt40,PkgAccVal);
grid on
title('Data Interpolated to Fs=1600 Hz');
xlabel("time (s)");
ylabel("acceleration (m/s^2) ");
legend("Val VI Data","Val Package Data");

%% FFT of model data 
%set up sampling Fs:
T2=tt40(2)-tt40(1);
F2Hz=1/T2;
Fs2=2*pi*F2Hz; %Rads/s
L2 = length(tt40);             % Length of signal
 
%VI FFT 
Y2 = fft(VIAccMod);           
P22 = abs(Y2/L2);
P12 = P22(1:L2/2+1);
P12(2:end-1) = 2*P12(2:end-1);
f2 = Fs2*(0:(L2/2))/L2;

%Package FFT
Y = fft(PkgAccMod);           
P2 = abs(Y/L2);
P1 = P2(1:L2/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f = Fs2*(0:(L2/2))/L2;


%% FFT of Validation data 
%set up sampling Fs:
T2Val=tt40(2)-tt40(1);
F2HzVal=1/T2Val;
Fs2Val=2*pi*F2HzVal; %Rads/s
L2 = length(tt40);             % Length of signal
 
%VI FFT 
Y2Val = fft(VIAccVal);           
P22Val = abs(Y2Val/L2);
P12Val = P22Val(1:L2/2+1);
P12Val(2:end-1) = 2*P12Val(2:end-1);
f2Val = Fs2Val*(0:(L2/2))/L2;

%Package FFT
YVal = fft(PkgAccVal);           
P2Val = abs(YVal/L2);
P1Val = P2Val(1:L2/2+1);
P1Val(2:end-1) = 2*P1Val(2:end-1);
fVal = Fs2Val*(0:(L2/2))/L2;

TFFT=f2(2)-f2(1);%System Identification Toolbox input

%% Average Frequency Responses
%Model Frequency response
AccOTX = movmean(P1,20);
AccINX = movmean(P12,20);
AccOTMod = movmean(AccOTX,30);
AccINMod = movmean(AccINX,30);

%Plot the averaged FFTs
figure(4);
plot(f/(2*pi),10*log10(AccOTMod),f2/(2*pi),10*log10(AccINMod));
%semilogx(f/(2*pi),(AccOTMod.\AccINMod));
title('FFT Model');
xlabel('frequency (Hz)');
ylabel('|G(f)|');
xlim([0.001,20]);

%legend("VI FFT","Package FFT");

%Validation Frequency response

AccOTY = movmean(P1Val,20);
AccINY = movmean(P12Val,20);
AccOTVal = movmean(AccOTY,30);
AccINVal = movmean(AccINY,30);

%Plot the averaged FFTs
figure(5);
plot(fVal/(2*pi),10*log10(AccOTVal),f2Val/(2*pi),10*log10(AccINVal));
%plot(fVal/(2*pi),10*log10(AccOTVal));
%semilogx(fVal/(2*pi),(AccOTVal.\AccINVal));
title('FFT Validation');
xlabel('frequency (Hz)');
ylabel('|G(f)|');
xlim([0.001,20]);

%legend("VI FFT","Package FFT");

%% System Identification Toolbox
%Sampling time Domain:
ST=T2;
%Time domain model
MIT=VIAccMod.';
MOT=PkgAccMod.';
%Time domain Validation
VIT=VIAccVal.';
VOT=PkgAccVal.';

%Sampling Freq Domain:
FF=f2; %Frequency vector
SF=TFFT; %FFT Sampling peroiod
%Freq domain model
MIF=AccINMod.';
MOF=AccOTMod.';
%Freq domain Validation
VIF=AccINVal.';
VOF=AccOTVal.';

%% time domain filter
% invFFTMod=(AccOTMod.\AccINMod);
% invFFTVal=(AccOTVal.\AccINVal);
% 
% n=35844;
% InvFFT = ifft(invFFTMod,n);
% 
% figure(10);
% k=0:1:n-1;
% plot(k,abs(InvFFT));
% grid on
% title('Data Interpolated to Fs=48 Hz');
% xlabel("time (s)");
% ylabel("acceleration (m/s^2) ");
% legend("Model inverse FFT");











