clc
clear all
close all

%% Import data

%Model Package data
D1 = dlmread('C:\Users\joud\OneDrive - University of South Carolina\Mech research\test\FRF test\Frequency Sweep\SynthWhiteNoisePkg.lvm',',',0);

%Model VI data
D2 = dlmread('C:\Users\joud\OneDrive - University of South Carolina\Mech research\test\FRF test\Frequency Sweep\SynthWhiteNoiseVI.lvm',',',23);

%Val Package data
D3 = dlmread('C:\Users\joud\OneDrive - University of South Carolina\Mech research\test\FRF test\Frequency Sweep\SynthWhiteNoisePkg.lvm',',',0);

%Val VI data
D4 = dlmread('C:\Users\joud\OneDrive - University of South Carolina\Mech research\test\FRF test\Frequency Sweep\SynthWhiteNoiseVI.lvm',',',23);

%% Extract data

%Model Data:
%Package time & Acc 
tt1=D1(:,1);
dd1=D1(:,2);
%VI time & Acc 
tt2=D2(:,1);
dd2=D2(:,2);

%Validation Data:
%Package time & Acc 
tt3=D3(:,1);
dd3=D3(:,2);
%VI time & Acc 
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
End=tt2(length(dd1));
tt40=0: 1/Fs : End; %time column for Fs=40Hz

%% Trigger Time Compensation parameters
DeltaT_VI_Mod=0.2038; % VI Model offset
DeltaT_VI_Val=0.2038; %VI Validation offset

PkgAccMod = interp1(tt1-DeltaT_VI_Mod,PkgAccCal1,tt40); 
VIAccMod = interp1(tt2,dd2,tt40);

PkgAccVal = interp1(tt3-DeltaT_VI_Val,PkgAccCal3,tt40); 
VIAccVal = interp1(tt4,dd4,tt40); 

%%Grab Synced window
tt40 = tt40(:,1:end-300);

PkgAccMod = PkgAccMod(:,1:end-300);
VIAccMod = VIAccMod(:,1:end-300);

PkgAccVal = PkgAccVal(:,1:end-300);
VIAccVal = VIAccVal(:,1:end-300);

%% BandPass filter
%BandPass Filter Parameters
Fin=0.1; %Hz
Fot=20; %Hz

PkgAccModFltr=bandpass(PkgAccMod,[Fin Fot],Fs).';
VIAccModFltr=bandpass(VIAccMod,[Fin Fot],Fs).';

PkgAccValFltr=bandpass(PkgAccVal,[Fin Fot],Fs).';
VIAccValFltr=bandpass(VIAccVal,[Fin Fot],Fs).';

%% Peak Detection
% figure(101);
% findpeaks(PkgAccModFltr,tt40);
% figure(202);
% findpeaks(VIAccModFltr,tt40);
% 
% [Pk,TPk]=findpeaks(PkgAccModFltr,tt40);
% [Pk2,TPk2]=findpeaks(VIAccModFltr,tt40);
% timeCompMod=TPk(1)-TPk2(1);
% 
% [Pk,TPk]=findpeaks(PkgAccValFltr,tt40);
% [Pk2,TPk2]=findpeaks(VIAccValFltr,tt40);
% timeCompVal=TPk(1)-TPk2(1);


%% Plot Time Domain 
figure(1);
plot(tt40,VIAccMod,tt40,PkgAccMod,tt40,VIAccVal,tt40,PkgAccVal);
%plot(tt40,VIAccModFltr,tt40,PkgAccModFltr,tt40,VIAccValFltr,tt40,PkgAccValFltr);
%xlim([0,3])
grid on
title('Single Frequency 1Hz');
xlabel("time (s)");
ylabel("acceleration (m/s^2) ");
legend("VI Mod","Package Mod","VI Val","Package Val");


%% System identification toolbox
% Prepare data:
%Lowpass filter Hz<20
%Sampling time Domain:
Ts=Ts;
%Time domain model
MIT=lowpass(VIAccMod.',25,1/Ts);
MOT=lowpass(PkgAccMod.',25,1/Ts);
%Time domain Validation
VIT=lowpass(VIAccVal.',25,1/Ts);
VOT=lowpass(PkgAccVal.',25,1/Ts);

%% Plot Time Domain 
figure(2);
plot(tt40,MIT,tt40,MOT,tt40,VIT,tt40,VOT);
%plot(tt40,VIAccModFltr,tt40,PkgAccModFltr,tt40,VIAccValFltr,tt40,PkgAccValFltr);
%xlim([0,3])
grid on
title('Lowpass filter');
xlabel("time (s)");
ylabel("acceleration (m/s^2) ");
legend("VI Mod","Package Mod","VI Val","Package Val");


%% Construct TF
u=VOT;
t=tt40;
d=[1.332325693606103,9.968705577123579e+02,1.643851770249687e+04];
n=[1,9.928061514588932e+02,1.585852148035904e+04];
sys = tf(n,d);
Post=lsim(sys,u,t);

figure(3);
plot(t,MOT,tt40,Post,tt40,MIT);
legend("Pkg Pre","Pkg Post","Ref");
title('Time domain of Pre post vs ref');
%xlim([43,43.5])

%% Error PreFilter vs PostFilter

PreErr=abs((MOT-MIT).\(MIT))*100;
PreErrMean = mean(PreErr);
NoisePre=VOT-VIT;
SNRPre=snr(VIT,NoisePre);

PostErr=abs((Post-MIT).\(MIT))*100;
PostErrMean = mean(PostErr);
NoisePost=Post-VIT;
SNRPost=snr(VIT,NoisePost);

DeltaSNR=SNRPost-SNRPre;
PrcntSNR=(DeltaSNR/SNRPre)*100;
RepSNR=['SNR increase = ',num2str(DeltaSNR),'dB = ',num2str(PrcntSNR),'%'];
disp(RepSNR);

figure(4);
plot(tt40,PreErr,t,PostErr);
title('Time domain of Pre vs post filter error');
legend("Pkg Pre Error","Pkg Post Error");
xlabel('time (s)');
ylabel('|Error|');
%xlim([.1,.2])

%% Construct an FFT
%set up sampling Fs:
T2=tt40(2)-tt40(1);
L2 = length(tt40);             % Length of signal
 
%Pre Filter FFT
Y = fft(MOT);           
P2 = abs(Y/L2);
P1 = P2(1:L2/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f = Fs*(0:(L2/2))/L2;

%Post Filter FFT
Y2 = fft(Post);           
P22 = abs(Y2/L2);
P12 = P22(1:L2/2+1);
P12(2:end-1) = 2*P12(2:end-1);
f2 = Fs*(0:(L2/2))/L2;

%Reference FFT
Y3 = fft(MIT);           
P23 = abs(Y3/L2);
P123 = P23(1:L2/2+1);
P123(2:end-1) = 2*P123(2:end-1);
f3 = Fs*(0:(L2/2))/L2;

% P1 = movmean(P1,10); P1 = movmean(P1,20);
% P12 = movmean(P12,10); P12 = movmean(P12,20);
% P123 = movmean(P123,10); P123 = movmean(P123,20);


%Plot interpolated FFTs
figure(5);
plot(f,P1,f2,P12,f3,P123);
title('FFT Pre post vs Ref');
xlabel('frequency (Hz)');
ylabel('|G(f)|');
xlim([0.1,25]);
legend("Pre","Post","Ref");

%% Construct FRF
PreFRF=P1.\P123;
PostFRF=P12.\P123;

%Average FRF
figure(6);
plot(f,PreFRF)%,f2,PostFRF);
%title('FRF Pre vs Post Filter');
xlabel('frequency (Hz)');
ylabel('AccIn/AccOut');
ylim([0,2]);
xlim([0,20]);
legend("FRF","Post","Ref");

 
%Model
PreFRF = movmean(PreFRF,10); PreFRF = movmean(PreFRF,20);
PostFRF = movmean(PostFRF,10); PostFRF = movmean(PostFRF,20);

figure(7);
plot(f,PreFRF,f2,PostFRF);
title('FRF Pre vs Post Filter Averaged');
xlabel('frequency (Hz)');
ylabel('|G(f)|');
xlim([0.1,20]);
legend("Pre","Post","Ref");



















