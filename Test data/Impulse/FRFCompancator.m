%% Reset Code
clc
clear all
close all

%% Import files
D1 = dlmread('C:\Users\joud\OneDrive - University of South Carolina\Mech research\test\FRF test\Frequency Sweep\Synced datasets\Synced1.lvm',',',1);
D2 = dlmread('C:\Users\joud\OneDrive - University of South Carolina\Mech research\test\FRF test\Frequency Sweep\Synced datasets\Synced2.lvm',',',1);
D3 = dlmread('C:\Users\joud\OneDrive - University of South Carolina\Mech research\test\FRF test\Frequency Sweep\Synced datasets\Synced3.lvm',',',1);

%% Extract Time and Acc data
%time & Acc

tt1=D1(:,1); %Pkg 1 Time
dd1=D1(:,2); %Pkg 1 Acc
tt2=D1(:,3); %VI 1 Time
dd2=D1(:,4); %VI 1 Acc
tt3=D2(:,1); %Pkg 2 Time
dd3=D2(:,2); %Pkg 2 Acc
tt4=D2(:,3); %VI 2 Time
dd4=D2(:,4); %VI 2 Acc
tt5=D3(:,1); %Pkg 3 Time
dd5=D3(:,2); %Pkg 3 Acc
tt6=D3(:,3); %VI 3 Time
dd6=D3(:,4); %VI 3 Acc

%% Calibrate package data
ddCal1 = mean(dd1); %Calibrates Time domain offset
PkgAccCal1=dd1-ddCal1;
ddCal3 = mean(dd3); %Calibrates Time domain offset
PkgAccCal3=dd3-ddCal3;
ddCal5= mean(dd5); %Calibrates Time domain offset
PkgAccCal5=dd5-ddCal5;
%% Generate time scale
Fs=1600;
Ts=1/Fs;
End1= tt2(71390); %43.25312042;
End2= tt4(71430); %43.27735519;
End3= tt6(71718); %43.45185089;
MT=0: Ts : End1; %time column for Fs=1600Hz
PkgAccMod = interp1(tt1,PkgAccCal1,MT); 
VIAccMod = interp1(tt2,dd2,MT);
VT=0: Ts : End2; %time column for Fs=1600Hz
PkgAccVal = interp1(tt3,PkgAccCal3,VT); 
VIAccVal = interp1(tt4,dd4,VT);
TT=0: Ts : End3; %time column for Fs=1600Hz
PkgAccTst = interp1(tt5,PkgAccCal5,TT); 
VIAccTst = interp1(tt6,dd6,TT);

%% FFT of data 
%set up sampling Fs:
T2=Ts;
F2Hz=1/T2;
Fs=2*pi*F2Hz; %Rads/s
L2 = length(MT); % Length of signal

%Model Package FFT
Y = fft(PkgAccMod);           
P2 = abs(Y/L2);
PMod = P2(1:L2/2+1);
PMod(2:end-1) = 2*PMod(2:end-1);
fMod = Fs*(0:(L2/2))/L2;

%Model VI FFT
Y2 = fft(VIAccMod);           
P22 = abs(Y2/L2);
PMod2 = P22(1:L2/2+1);
PMod2(2:end-1) = 2*PMod2(2:end-1);
fMod2 = Fs*(0:(L2/2))/L2;

%Validation Package FFT
YVal = fft(PkgAccVal);           
P2Val = abs(YVal/L2);
PVal = P2Val(1:L2/2+1);
PVal(2:end-1) = 2*PVal(2:end-1);
fVal = Fs*(0:(L2/2))/L2;

%Validation VI FFT
Y2Val = fft(VIAccVal);           
P22Val = abs(Y2Val/L2);
PVal2 = P22Val(1:L2/2+1);
PVal2(2:end-1) = 2*PVal2(2:end-1);
fVal2 = Fs*(0:(L2/2))/L2;

%Test Package FFT
YTst = fft(PkgAccTst);           
P2Tst = abs(YTst/L2);
PTst = P2Tst(1:L2/2+1);
PTst(2:end-1) = 2*PTst(2:end-1);
fTst = Fs*(0:(L2/2))/L2;

%Test VI FFT
Y2Tst = fft(VIAccTst);           
P22Tst = abs(Y2Tst/L2);
PTst2 = P22Tst(1:L2/2+1);
PTst2(2:end-1) = 2*PTst2(2:end-1);
fTst2 = Fs*(0:(L2/2))/L2;
%% Fix parameters
% transpose Frequency columns
fMod=fMod.';
fVal=fVal.';
fTst=fTst.';

% transpose Magnitude columns
PMod=PMod.';
PMod2=PMod2.';
PVal=PVal.';
PVal2=PVal2.';
PTst=PTst.';
PTst2=PTst2.';
%% Average FFT

%Model
AccOT = movmean(PMod,10); AccOTMod = movmean(AccOT,20);
AccIN = movmean(PMod2,10); AccINMod = movmean(AccIN,20);

%Validation
AccOT2 = movmean(PVal,10); AccOTVal = movmean(AccOT2,20);
AccIN2 = movmean(PVal2,10); AccINVal = movmean(AccIN2,20);

%Validation
AccOT3 = movmean(PTst,10); AccOTTst = movmean(AccOT3,20);
AccIN3 = movmean(PTst2,10); AccINTst = movmean(AccIN3,20);

%% FRF construction

%No averaging Input
FRFMod= PMod./PMod2;
FRFVal= PVal./PVal2;
FRFTst= PTst./PTst2;

%Averaged FFT
% FRFMod= AccOTMod./AccINMod;
% FRFVal= AccOTVal./AccINVal;
% FRFTst= AccOTTst./AccINTst;

%Average FRF
%Model
FRFAvgMod1 = movmean(FRFMod,10); FRFMod = movmean(FRFAvgMod1,20);
%Validation
FRFAvgVal1 = movmean(FRFVal,10); FRFVal = movmean(FRFAvgVal1,20);
%Test
FRFAVgTst1 = movmean(FRFTst,10); FRFTst = movmean(FRFAVgTst1,20);

figure(1);
plot(fMod/(2*pi),FRFMod, fVal/(2*pi),FRFVal, fVal/(2*pi),FRFTst);
xlim([0.001,20]);
legend("FRF Mod","FRF Val","FRF Tst");
xlabel('frequency (Hz)');
ylabel('|G|');
xlim([0.001,20]);
ylim([0.0,3]);

%% Plot overall Model FFT

figure(2);
FRFMod= PMod./PMod2;
PostFRF=PMod./FRFMod;
plot(fMod/(2*pi),PMod,fMod/(2*pi),PostFRF,'*-',fMod/(2*pi),PMod2);
xlim([0.001,20]);
title('Model FFT')
legend("Pre-Filter","Post-Filter","Reference");
xlabel('frequency (Hz)');
ylabel('|G|');
xlim([0.001,1]);
%% FRF Compensation Model

figure(3);
plot(fMod/(2*pi),FRFMod,fVal/(2*pi),PostFRF);
xlim([0.001,20]);
title('Using Model FRF Conpensation on Model Set')
legend("Pre FRF Comp."," Post FRF comp.");
xlabel('frequency (Hz)');
ylabel('|G|');
xlim([0.001,20]);
ylim([0.0,3]);
%% Plot overall Validation FFT
figure(4);
FRFVal = PVal./PVal2;
PostFRF2 = PVal./FRFVal;
plot(fVal/(2*pi),PVal,fVal/(2*pi),PostFRF2,'*-',fVal/(2*pi),PVal2);
xlim([0.001,20]);
title('Validation FFT')
legend("Pre-Filter","Post-Filter","Reference");
xlabel('frequency (Hz)');
ylabel('|G|');
xlim([0.001,20]);
%% FRF Compensation validation 
PostFRFVal=PostFRF2./AccINVal;
figure(5);
plot(fVal/(2*pi),FRFVal,fVal/(2*pi),PostFRFVal);
xlim([0.001,20]);
legend("Pre FRF Comp."," Post FRF comp.");
title('Using Validation FRF Conpensation on Validation Set')
xlabel('frequency (Hz)');
ylabel('|G|');
xlim([0.001,20]);
ylim([0.0,3]);
%% Plot overall Test FFT

figure(6);
FRFTst = PTst./PTst2;
PostFRF3 = PTst./FRFTst;
plot(fTst/(2*pi),PTst,fTst/(2*pi),PostFRF3,'*-',fTst/(2*pi),PTst2);
xlim([0.001,20]);
title('Test FFT')
legend("Pre-Filter","Post-Filter","Reference");
xlabel('frequency (Hz)');
ylabel('|G|');
xlim([0.001,20]);
%% FRF Compensation Test
PostFRFTst=PostFRF3./AccINTst;
figure(7);
plot(fTst/(2*pi),FRFTst,fTst/(2*pi),PostFRFTst);
xlim([0.001,20]);
legend("Pre FRF Comp."," Post FRF comp.");
title('Using Test FRF Conpensation on Test Set')
xlabel('frequency (Hz)');
ylabel('|G|');
xlim([0.001,20]);
ylim([0.0,3]);

%% Plot overall Test FFT with average FRF
FRFAvg=(FRFMod+FRFVal)/2;
PostFRF4=AccOTTst./FRFAvg;
figure(7);
plot(fTst/(2*pi),AccOTTst,fTst/(2*pi),PostFRF4,fTst/(2*pi),AccINTst);
xlim([0.001,20]);
title('Test FFT with Average FRF')
legend("Pre-Filter","Post-Filter","Reference");
xlabel('frequency (Hz)');
ylabel('|G|');
xlim([0.001,20]);
%% FRF Compensation Test with Averaged FRF (Model+Validation)/2

PostFRFAvg=PostFRF4./AccINTst;
figure(8);
plot(fTst/(2*pi),FRFTst,fTst/(2*pi),PostFRFAvg);
xlim([0.001,20]);
legend("Pre FRF Comp."," Post FRF comp.");
title('Using Averaged FRF Conpensation on Test Set')
xlabel('frequency (Hz)');
ylabel('|G|');
xlim([0.001,20]);
ylim([0.0,3]);

%% IFFT
CompData=complex(PostFRF4);
IFFTMod=ifft(CompData);
N=1:length(IFFTMod);
figure(9);
plot(N*Ts,IFFTMod*1000,tt1,dd1)
title('Inverse FFT')
legend("time reconstruction","original signal");
xlabel('time(s)');
ylabel('Amplitude');
xlim([0.001,21.7]);










