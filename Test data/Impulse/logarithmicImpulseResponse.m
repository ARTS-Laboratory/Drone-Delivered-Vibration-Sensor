clc
clear all
close all

%% Import data

%Model Package data
D1 = dlmread('C:\Users\joud\OneDrive - University of South Carolina\Mech research\test\Impulse\SlabSteelImpulse.lvm',',',0);
%time & Acc
tt1=D1(:,1);
dd1=D1(:,2);
figure(1);
plot(tt1,dd1);

tt2=D1(:,3);
dd2=D1(:,4);
figure(2);
plot(tt2,dd2);

tt3=D1(:,5);
dd3=D1(:,6);
figure(3);
plot(tt3,dd3);

tt4=D1(:,7);
dd4=D1(:,8);
figure(4);
plot(tt4,dd4);

%% Calibrate Package data
dd2Cal1 = mean(dd1); %Calibrates Time domain offset
PkgAccCal1=dd1-dd2Cal1;
dd2Cal2 = mean(dd2); %Calibrates Time domain offset
PkgAccCal2=dd3-dd2Cal2;
dd2Cal3= mean(dd3); %Calibrates Time domain offset
PkgAccCal3=dd3-dd2Cal3;
dd2Cal4= mean(dd4); %Calibrates Time domain offset
PkgAccCal4=dd4-dd2Cal4;


%% Generate time scale
Fs=1600;
Ts=1/Fs;
End=tt4(74000);
tt40=0: 1/Fs : End; %time column for Fs=40Hz

PkgAcc1 = interp1(tt1,PkgAccCal1,tt40); 
PkgAcc2 = interp1(tt2,PkgAccCal2,tt40); 
PkgAcc3 = interp1(tt3,PkgAccCal3,tt40); 
PkgAcc4 = interp1(tt4,PkgAccCal4,tt40); 


%% FFT of model data 
%set up sampling Fs:
T2=tt40(2)-tt40(1);
F2Hz=1/T2;
%Fs2=2*pi*F2Hz; %Rads/s
Fs2=F2Hz; %Hz
L2 = length(tt40);             % Length of signal

%% FFT PkgAcc1
Y1 = fft(PkgAccCal1);           
P11 = abs(Y1/L2);
P1 = P11(1:L2/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f1 = Fs2*(0:(L2/2))/L2;
figure(5);
plot(f1,P1) 


%% FFT PkgAcc2
Y2 = fft(PkgAccCal2);           
P22 = abs(Y2/L2);
P2 = P22(1:L2/2+1);
P2(2:end-1) = 2*P2(2:end-1);
f2 = Fs2*(0:(L2/2))/L2;
figure(6);
plot(f2,P2) 

%% FFT PkgAcc3
Y3 = fft(PkgAccCal3);           
P33 = abs(Y2/L2);
P3 = P33(1:L2/2+1);
P3(2:end-1) = 2*P3(2:end-1);
f3 = Fs2*(0:(L2/2))/L2;
figure(7);
plot(f3,P3) 

%% FFT PkgAcc4
Y4 = fft(PkgAccCal4);           
P44 = abs(Y2/L2);
P4 = P44(1:L2/2+1);
P4(2:end-1) = 2*P4(2:end-1);
f4 = Fs2*(0:(L2/2))/L2;
figure(8);
plot(f4,P4) 

%% Overall FFT Plot
figure(9)
plot(f1,P1,f2,P2+.1,f3,P3+.2,f4,P4+.3)
legend("itr 1","itr 2","itr 3","itr 4");
xlabel('Frequency (Hz)');
ylabel('Magnitude');
grid on

%% Average responses
% 
% AccOTY = movmean(P1,10); AccOTVal = movmean(AccOTY,20);
% AccINY = movmean(P12,10); AccINVal = movmean(AccINY,20);
% AccOTYX = movmean(P123,10); AccOTValYX = movmean(AccOTYX,20);


