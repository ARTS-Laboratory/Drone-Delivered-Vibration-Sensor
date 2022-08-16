clc
clear all
close all

%% Import data

%Model Package data
D1 = dlmread('C:\Users\joud\OneDrive - University of South Carolina\Mech research\test\FRF test\Frequency Sweep\Test13 Floor Test 1650Hz\FRF Test Fs1650Hz Pkg.lvm',',',0);
%time & Acc
tt1=D1(:,1);
dd1=D1(:,2);

%Model VI data
D2 = dlmread('C:\Users\joud\OneDrive - University of South Carolina\Mech research\test\FRF test\Frequency Sweep\Test13 Floor Test 1650Hz\FRF Test Fs1650Hz VI.lvm',',',23);
%time & Acc
tt2=D2(:,1);
dd2=D2(:,2);

%Validation Package data
D3 = dlmread('C:\Users\joud\OneDrive - University of South Carolina\Mech research\test\FRF test\Frequency Sweep\Test14 model validation\FRF Test Fs pkg 1650Hz.lvm',',',0);
%time & Acc
tt3=D3(:,1);
dd3=D3(:,2);

%Validation VI data
D4 = dlmread('C:\Users\joud\OneDrive - University of South Carolina\Mech research\test\FRF test\Frequency Sweep\Test14 model validation\FRF Test Fs VI 1650Hz.lvm',',',23);
%time & Acc
tt4=D4(:,1);
dd4=D4(:,2);

%Test Package data
D5 = dlmread('C:\Users\joud\OneDrive - University of South Carolina\Mech research\test\FRF test\Frequency Sweep\Test14 model validation\FRF Test Fs pkg 1650Hz 1.lvm',',',0);
%time & Acc
tt5=D5(:,1);
dd5=D5(:,2);

%Test VI data
D6 = dlmread('C:\Users\joud\OneDrive - University of South Carolina\Mech research\test\FRF test\Frequency Sweep\Test14 model validation\FRF Test Fs VI 1650Hz 1.lvm',',',23);
%time & Acc
tt6=D6(:,1);
dd6=D6(:,2);

%% Calibrate Package data
dd2Cal1 = mean(dd1) %Calibrates Time domain offset
PkgAccCal1=dd1-dd2Cal1;
dd2Cal3 = mean(dd3) %Calibrates Time domain offset
PkgAccCal3=dd3-dd2Cal3;
dd2Cal5= mean(dd5) %Calibrates Time domain offset
PkgAccCal5=dd5-dd2Cal5;

%% Generate time scale
Fs=1600
Ts=1/Fs
End=tt4(74000)
tt40=0: 1/Fs : End; %time column for Fs=40Hz

PkgAccMod = interp1(tt1,PkgAccCal1,tt40); 
VIAccMod = interp1(tt2,dd2,tt40);
PkgAccVal = interp1(tt3,PkgAccCal3,tt40); 
VIAccVal = interp1(tt4,dd4,tt40);
PkgAccTst = interp1(tt5,PkgAccCal5,tt40); 
VIAccTst = interp1(tt6,dd6,tt40);

%% Plot Data

%Model Data Plot
figure(1);
plot(tt40,VIAccMod,tt40,PkgAccMod);
grid on
title('Training Data');
xlabel("time (s)");
ylabel("acceleration (m/s^2) ");
legend("Train VI Data","Train Package Data");

%Validation Data Plot
figure(2);
plot(tt40,VIAccVal,tt40,PkgAccVal);
grid on
title('Validation Data');
xlabel("time (s)");
ylabel("acceleration (m/s^2) ");
legend("Val VI Data","Val Package Data");

%Testing Data Plot
figure(3);
plot(tt40,VIAccTst,tt40,PkgAccTst);
grid on
title('Test Data');
xlabel("time (s)");
ylabel("acceleration (m/s^2) ");
legend("Test VI Data","Test Package Data");


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
Fs2Val=Fs2;
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

%% FFT of Test data 
Fs2Tst=Fs2;
%VI FFT 
Y2Tst = fft(VIAccTst);           
P22Tst = abs(Y2Tst/L2);
P12Tst = P22Tst(1:L2/2+1);
P12Tst(2:end-1) = 2*P12Tst(2:end-1);
f2Tst = Fs2*(0:(L2/2))/L2;

%Package FFT
YTst = fft(PkgAccTst);           
P2Tst = abs(YTst/L2);
P1Tst = P2Tst(1:L2/2+1);
P1Tst(2:end-1) = 2*P1Tst(2:end-1);
fTst = Fs2*(0:(L2/2))/L2;

%% Average Frequency Responses
%Model Frequency response
figure(4);
AccOTX = movmean(P1,10);
AccINX = movmean(P12,10);
AccOTMod = movmean(AccOTX,20);
AccINMod = movmean(AccINX,20);

%Plot the averaged FFTs

plot(f/(2*pi),mag2db(abs(AccOTMod.\AccINMod)));
title('Training FFT');
xlabel('frequency (Hz)');
ylabel('|G(dB)|');
xlim([0.001,20]);
legend("VI FFT","Package FFT");

%Validation Frequency response
figure(5);
AccOTY = movmean(P1Val,10);
AccINY = movmean(P12Val,10);
AccOTVal = movmean(AccOTY,20);
AccINVal = movmean(AccINY,20);

%Plot the averaged FFTs

%semilogx(fVal/(2*pi),(AccOTVal.\AccINVal));
plot(fVal/(2*pi),mag2db(abs(AccOTVal.\AccINVal)));
title('Validation FFT');
xlabel('frequency (Hz)');
ylabel('|G(dB)|');
xlim([0.001,20]);
%legend("VI FFT","Package FFT");

%Test Frequency response
figure(6);
AccOTZ = movmean(P1Tst,10);
AccINZ = movmean(P12Tst,10);
AccOTTst = movmean(AccOTZ,20);
AccINTst = movmean(AccINZ,20);

%Plot the averaged FFTs
%semilogx(fTst/(2*pi),(AccOTTst.\AccINTst));
plot(fTst/(2*pi),mag2db(abs((AccOTTst.\AccINTst))));
title('Testing FFT');
xlabel('frequency (Hz)');
ylabel('|G(dB)|');
xlim([0.001,20]);
%legend("VI FFT","Package FFT");

%% System Identification Toolbox
%Sampling time Domain:
ST=T2;
%Time domain model
MIT=VIAccMod;
MOT=PkgAccMod;
%Time domain Validation
VIT=VIAccVal;
VOT=PkgAccVal;
%Time domain Validation
TIT=VIAccTst;
TOT=PkgAccTst;

%Sampling Freq Domain:
FF=f2; %Frequency vector
SF=ST; %FFT Sampling peroiod
%Freq domain model
MIF=AccINMod;
MOF=AccOTMod;
%Freq domain Validation
VIF=AccINVal;
VOF=AccOTVal;
%Freq domain Validation
TIF=AccINTst;
TOF=AccOTTst;

