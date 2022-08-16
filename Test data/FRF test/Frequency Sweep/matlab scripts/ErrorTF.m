clc
clear all
close all

%% Import data

%Model Package data
D1 = dlmread('C:\Users\joud\OneDrive - University of South Carolina\Mech research\test\FRF test\Frequency Sweep\Test15 discrete frequency Test\DiscTestPkg10Hz.lvm',',',0);

%Model VI data
D2 = dlmread('C:\Users\joud\OneDrive - University of South Carolina\Mech research\test\FRF test\Frequency Sweep\Test15 discrete frequency Test\DiscTestVI10Hz.lvm',',',23);

%Validation Package data
D3 = dlmread('C:\Users\joud\OneDrive - University of South Carolina\Mech research\test\FRF test\Frequency Sweep\Test18 Single Frequency\10Pkg.lvm',',',0);

%Validation VI data
D4 = dlmread('C:\Users\joud\OneDrive - University of South Carolina\Mech research\test\FRF test\Frequency Sweep\Test18 Single Frequency\10VI.lvm',',',23);

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

%% Calibrate Package Acceleration
dd2Cal1 = mean(dd1); %Calibrates Time domain offset
PkgAccCal1=-(dd1-dd2Cal1); %Calibrate dimension) 
dd2Cal3 = mean(dd3); %Calibrates Time domain offset
PkgAccCal3=-(dd3-dd2Cal3); %Calibrate dimension) 

%% Generate time scale
Fs=1600;
Ts=1/Fs;
End=tt4(length(dd1));
tt40=0: 1/Fs : End; %time column for Fs=40Hz

%Model Time Compensation parameters
DeltaT_MI=(.048125-.035); % Model offset
PkgAccMod = interp1(tt1,PkgAccCal1,tt40); 
VIAccMod = interp1(tt2-DeltaT_MI,dd2,tt40);

%Validation Time Compensation parameters
DeltaT_VI=(.096875-.074375); % Validation offset
PkgAccVal = interp1(tt3,PkgAccCal3,tt40); 
VIAccVal = interp1(tt4-DeltaT_VI,dd4,tt40);

%% Calibrate trigger offset
%  tt401 = tt40(:,DeltaTIndx_MI:end);
%  PkgAccMod = PkgAccMod(:,DeltaTIndx_MI:(end));
%  
%  tt402 = tt40(:,DeltaTIndx_MO:end);
%  VIAccMod = VIAccMod(:,DeltaTIndx_MO:(end));
 
%  tt403 = tt40(:,DeltaTIndx_VI:end);
%  PkgAccVal = PkgAccMod(:,DeltaTIndx_VI:end);
%  
%  tt404 = tt40(:,DeltaTIndx_VO:end);
%  VIAccVal = VIAccMod(:,DeltaTIndx_VO:end);
%  
 %PkgAccVal = PkgAccVal(:,2000:end);
 %VIAccVal = VIAccVal(:,2000:end);

%% Plot Data

%Model Data Plot
figure(1);
plot(tt40,VIAccMod,tt40,PkgAccMod);
xlim([-.1,.2])
grid on
title('Data Interpolated to Fs=1600 Hz');
xlabel("time (s)");
ylabel("acceleration (m/s^2) ");
legend("Model VI Data","Model Package Data");

%Validation Data Plot
figure(2);
plot(tt40,VIAccVal,tt40,PkgAccVal);
xlim([-.1,.2])
grid on
title('Data Interpolated to Fs=1600 Hz');
xlabel("time (s)");
ylabel("acceleration (m/s^2) ");
legend("Val VI Data","Val Package Data");

%% Time Domain Error 

%Model Error
figure(100);
ErrMod=VIAccMod-PkgAccMod;
plot(tt40,VIAccMod-PkgAccMod,tt40,PkgAccMod,tt40,VIAccMod);
xlim([0,1])
grid on
title('Error extracted from Acceleration IO');
xlabel("time (s)");
ylabel("acceleration (m/s^2) ");
legend("Error","Model Package Data","Ref");

%Validation Error
figure(101);
ErrVal=VIAccVal-PkgAccVal;
plot(tt40,VIAccVal-PkgAccVal,tt40,PkgAccVal,tt40,VIAccVal);
xlim([0,1])
ylim([-1,1])
grid on
title('Error extracted from Acceleration IO');
xlabel("time (s)");
ylabel("acceleration (m/s^2) ");
legend("Error","Val Package Data","Ref");

%% FFT of model data 
%set up sampling Fs:
T2=tt40(2)-tt40(1);
F2Hz=1/T2;
Fs2=2*pi*F2Hz; %Rads/s
L2 = length(tt40);             % Length of signal
 
%VI FFT 
Y2 = fft(ErrVal); 
%Y2 = fft(VIAccMod);           
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
%% Average Frequency Responses
%Model Frequency response
AccOTX = movmean(P1,20);
AccINX = movmean(P12,20);
AccOTMod = movmean(AccOTX,30);
AccINMod = movmean(AccINX,30);

%Plot the averaged FFTs
figure(3);
plot(f/(2*pi),10*log10(AccOTMod),f2/(2*pi),10*log10(AccINMod));
%semilogx(f/(2*pi),(AccOTMod.\AccINMod));
title('FFT Model vs Err');
xlabel('frequency (Hz)');
ylabel('|G(f)|');
xlim([5,15]);
ylim([-40,-5]);
legend("Package FFT","VI FFT");

%Validation Frequency response

AccOTY = movmean(P1Val,20);
AccINY = movmean(P12Val,20);
AccOTVal = movmean(AccOTY,30);
AccINVal = movmean(AccINY,30);

%Plot the averaged FFTs
figure(4);
plot(fVal/(2*pi),10*log10(AccOTVal),f2Val/(2*pi),10*log10(AccINVal),f2/(2*pi),10*log10(AccINMod));
%plot(fVal/(2*pi),10*log10(AccOTVal));
%semilogx(fVal/(2*pi),(AccOTVal.\AccINVal));
title('FFT Error');
xlabel('frequency (Hz)');
ylabel('|G(f)|');
xlim([5,15]);
ylim([-50,-5]);
legend("Package FFT","Ref FFT","Error FFT");
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
%Freq domain model
MIF=AccINMod.';
MOF=AccOTMod.';
%Freq domain Validation
VIF=AccINVal.';
VOF=AccOTVal.';
%% Single Freq TF
figure(5);
%Contineous Model
numerator=[0.989807485569187,3.929030620787672e+02,1.759970328880611e+03];
denominator=[1,3.924227081285889e+02,0.031432143969415];
sys = tf(numerator,denominator);
%Discrete Model
% numerator=[0,0.448495260854921,-0.439139277899769];
% denominator=[[1,-1.530388086423004,0.540079889646064]];
% sys = tf(numerator,denominator,Ts);

u=PkgAccVal;
t=tt40;
Post=lsim(sys,u,t);
plot(t,PkgAccVal,tt40,Post,tt40,VIAccVal);
legend("Pkg Pre","Pkg Post","Ref");
xlim([-.1,.2])
%% Point wize FRF
Ref=VIAccVal.';
Pre=PkgAccVal.';
Post=Post;
%%
PreFRF = Pre.\Ref;
PostFRF = Post.\Ref;

figure(6);
plot(tt40,PreFRF,tt40,PostFRF)
legend("Pkg Pre","Pkg Post");
xlim([-.1,.2])
%% FFT Pre Post Filter
%set up sampling Fs:
T2Pre=tt40(2)-tt40(1);
F2HzPre=1/T2Pre;
Fs2Pre=2*pi*F2HzPre; %Rads/s
L2 = length(tt40);             % Length of signal
%VI FFT 
Y2Pre = fft(Pre);           
P22Pre = abs(Y2Pre/L2);
P12Pre = P22Pre(1:L2/2+1);
P12Pre(2:end-1) = 2*P12Pre(2:end-1);
f2Pre = Fs2Pre*(0:(L2/2))/L2;


%set up sampling Fs:
T2Post=tt40(2)-tt40(1);
F2HzPost=1/T2Post;
Fs2Post=2*pi*F2HzPost; %Rads/s
L2 = length(tt40);             % Length of signal
%Package FFT
YPost = fft(Post);           
P2Post = abs(YPost/L2);
P1Post = P2Post(1:L2/2+1);
P1Post(2:end-1) = 2*P1Post(2:end-1);
fPost = Fs2Post*(0:(L2/2))/L2;


figure(7);
plot(f2Pre/(2*pi),10*log10(P12Pre),fPost/(2*pi),10*log10(P1Post),f2Val/(2*pi),10*log10(AccINVal));
legend("Pkg Pre","Pkg Post","Ref");
xlim([9,11])

















