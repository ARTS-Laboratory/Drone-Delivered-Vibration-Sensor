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
dd2Cal1 = mean(dd1); %Calibrates Time domain offset
PkgAccCal1=dd1-dd2Cal1;
dd2Cal3 = mean(dd3); %Calibrates Time domain offset
PkgAccCal3=dd3-dd2Cal3;
dd2Cal5= mean(dd5); %Calibrates Time domain offset
PkgAccCal5=dd5-dd2Cal5;


%% Generate time scale
Fs=1600;
Ts=1/Fs;
End=tt4(74000);
tt40=0: 1/Fs : End; %time column for Fs=40Hz

PkgAccMod = interp1(tt1,PkgAccCal1,tt40); 
VIAccMod = interp1(tt2,dd2,tt40);
PkgAccVal = interp1(tt3,PkgAccCal3,tt40); 
VIAccVal = interp1(tt4,dd4,tt40);
PkgAccTst = interp1(tt5,PkgAccCal5,tt40); 
VIAccTst = interp1(tt6,dd6,tt40);

%% Input data into filter transfer function
% 
% den = [0.957128298508050,8.463567866218746,7.408943472333956];
% num = [1,9.301227302845060,12.259074911685397];
% 
% % num = [1, 241.4, 1.703e7, 1.171e9, 6.206e12];
% % den = [2.741e7, -1.506e9, 6.171e12];
% 
% Gs = tf(num,den)
% 
% [TFOut,t]=lsim(Gs,PkgAccVal,tt40);
% plot(tt40,PkgAccVal,tt40,TFOut,tt40,VIAccVal)
% legend("Pre-Filter","Post-Filter","Reference");
% xlabel('time (s)');
% ylabel('amplitude');
% xlim([0.001,45]);
% ylim([-7,10]);
% grid on
% 
%plot(t,TFOut)


%% FFT of model data 
%set up sampling Fs:
T2=tt40(2)-tt40(1);
F2Hz=1/T2;
Fs2=2*pi*F2Hz; %Rads/s
L2 = length(tt40);             % Length of signal

%% pre filter FFT

Y23 = fft(PkgAccVal);           
P223 = abs(Y23/L2);
P123 = P223(1:L2/2+1);
P123(2:end-1) = 2*P123(2:end-1);
f23 = Fs2*(0:(L2/2))/L2;

%% post filter FFT
% Y = fft(TFOut);           
% P2 = abs(Y/L2);
% P1 = P2(1:L2/2+1);
% P1(2:end-1) = 2*P1(2:end-1);
% f = Fs2*(0:(L2/2))/L2;

%% VI FFT 

Y2 = fft(VIAccVal);           
P22 = abs(Y2/L2);
P12 = P22(1:L2/2+1);
P12(2:end-1) = 2*P12(2:end-1);
f2 = Fs2*(0:(L2/2))/L2;



%%

%AccOTY = movmean(P1,10); AccOTVal = movmean(AccOTY,20);
AccINY = movmean(P12,10); AccINVal = movmean(AccINY,20);
AccOTYX = movmean(P123,10); AccOTValYX = movmean(AccOTYX,20);

%%

figure(5);
%plot(f2/(2*pi),P1,f2/(2*pi),P123,f2/(2*pi),P12);
plot(f2/(2*pi),P123,f2/(2*pi),P12);
xlim([0.001,20]);
legend("Pre-Filter","Post-Filter","Reference");
xlabel('frequency (Hz)');
ylabel('|G|');

%%
TAccOTValYX=AccOTValYX.';
TAccINVal=AccINVal.';
Tf2=f2.';

%%
FRF= AccOTVal/TAccINVal;
%%
plot(f/(2*pi),FRF)
title('Validation FFT');
xlabel('frequency (Hz)');
ylabel('|G(dB)|');
xlim([0.001,20]);



% %% Plot FRF from LVM
% D7 = dlmread('C:\Users\joud\OneDrive - University of South Carolina\Mech research\test\FRF test\Frequency Sweep\FRFFilterPlot.lvm',',',1);
% %time & Acc
% F=D7(:,1);
% UnFltr=D7(:,2);
% Fltr=D7(:,3);
% 
% plot(F,UnFltr-1,F,Fltr-1)
% xlim([0.1,20]);
% ylim([-1,5]);
% legend("Pre-Filter","Post-Filter");
% xlabel('frequency (Hz)');
% ylabel('Error');


