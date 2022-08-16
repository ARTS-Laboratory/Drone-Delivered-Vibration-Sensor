clc
clear all
close all

%Model Package data
D1 = dlmread('C:\Users\joud\OneDrive - University of South Carolina\Mech research\test\FRF test\Frequency Sweep\Synced datasets\Synced1.lvm',',',1);
D2 = dlmread('C:\Users\joud\OneDrive - University of South Carolina\Mech research\test\FRF test\Frequency Sweep\Synced datasets\Synced2.lvm',',',1);
D3 = dlmread('C:\Users\joud\OneDrive - University of South Carolina\Mech research\test\FRF test\Frequency Sweep\Synced datasets\Synced3.lvm',',',1);

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

%% Calibrate
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

%% FFT of model data 
%set up sampling Fs:
T2=Ts;
F2Hz=1/T2;
Fs=2*pi*F2Hz; %Rads/s
L2 = length(VT); % Length of signal

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
%Test VI FFT


%% Average FFT

%Model
AccOT = movmean(PMod,10); AccOTMod = movmean(AccOT,20);
AccIN = movmean(PMod2,10); AccINMod = movmean(AccIN,20);

%Validation
AccOT2 = movmean(PVal,10); AccOTVal = movmean(AccOT2,20);
AccIN2 = movmean(PVal2,10); AccINVal = movmean(AccIN2,20);

%Test


%% System Identification Toolbox inputs
%Sampling time Domain:
Ts=Ts;
%Frequency Vector
FF=fMod(1,1:866).';
%Time domain model
MIT=VIAccMod.';   MIF=AccINMod(1,1:866).';
MOT=PkgAccMod.';  MOF=AccOTMod(1,1:866).';
%Time domain Validation
VIT=VIAccVal.';   VIF=AccINVal(1,1:866).';
VOT=PkgAccVal.';  VOF=AccOTVal(1,1:866).';
%Time domain Test
TIT=VIAccTst;
TOT=PkgAccTst;

%% Plot FFT 
figure(5);
plot(fMod/(2*pi),AccOTMod,fMod2/(2*pi),AccINMod,fVal/(2*pi),AccOTVal,fVal2/(2*pi),AccINVal);
xlim([0.001,20]);
legend("Average Package","Average VI","Average Package 2", "Average VI 2");
xlabel('frequency (Hz)');
ylabel('|G|');

%% Import Transfer function from system identification toolbox
den=[0,8.226767310629583,-21.162257459273260,18.894841951548276,-5.873461568472794];
num=[1,-0.913151889913093];
Gz = tf(num,den,Ts);
%Gs = tf(num,den);
Gz2=tf4;

%%
[TFOut,t]=lsim(Gz2,PkgAccVal,VT);
plot(VT,PkgAccVal,VT,TFOut,VT,VIAccVal)
legend("Pre-Filter","Post-Filter","Reference");
xlabel('time (s)');
ylabel('amplitude');
xlim([0.001,45]);
ylim([-7,10]);
grid on


%% FFT parameters 
%set up sampling Fs:
T2=VT(2)-VT(1);
F2Hz=1/T2;
Fs2=2*pi*F2Hz; %Rads/s
L2 = length(VT);             % Length of signal

%% pre filter FFT
Y23 = fft(PkgAccVal);           
P223 = abs(Y23/L2);
PreTF = P223(1:L2/2+1);
PreTF(2:end-1) = 2*PreTF(2:end-1);
f23 = Fs2*(0:(L2/2))/L2;

%% post filter FFT
Y = fft(TFOut);           
P2 = abs(Y/L2);
PostTF = P2(1:L2/2+1);
PostTF(2:end-1) = 2*PostTF(2:end-1);
f = Fs2*(0:(L2/2))/L2;

%% VI FFT 

Y2 = fft(VIAccVal);           
P22 = abs(Y2/L2);
Ref = P22(1:L2/2+1);
Ref(2:end-1) = 2*Ref(2:end-1);
f2 = Fs2*(0:(L2/2))/L2;


%% Plot overall FFT
figure(6);
plot(f/(2*pi),PreTF,f/(2*pi),PostTF,f/(2*pi),Ref);
xlim([0.001,20]);
legend("Pre-Filter","Post-Filter","Reference");
xlabel('frequency (Hz)');
ylabel('|G|');

%% Construct FRF

%Fix dimensions:
f=f.';
PreTF=PreTF.';
Ref=Ref.';

PreFRF=PreTF./Ref;
PostFRF=PreTF.*PreFRF;

figure(7);
plot(f/(2*pi),PreFRF,f/(2*pi),PostFRF);
xlim([0.001,20]);
legend("Pre-Filter","Post-Filter");
xlabel('frequency (Hz)');
ylabel('|G|');







