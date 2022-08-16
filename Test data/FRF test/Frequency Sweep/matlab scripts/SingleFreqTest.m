clc
clear all
close all

%% Import data

%Model Package data
D1 = dlmread('C:\Users\joud\OneDrive - University of South Carolina\Mech research\test\FRF test\Frequency Sweep\Test19 SynthWhiteNoise\WhiteNoiseTestPkg.lvm',',',0);

%Model VI data
D2 = dlmread('C:\Users\joud\OneDrive - University of South Carolina\Mech research\test\FRF test\Frequency Sweep\Test19 SynthWhiteNoise\WhiteNoiseTestVI.lvm',',',23);

%Validation Package data
D3 = dlmread('C:\Users\joud\OneDrive - University of South Carolina\Mech research\test\FRF test\Frequency Sweep\Test16 synced sweep\SyncSweepPkg3.lvm',',',0);
                                                                                                                                                              
%Validation VI data                                                        
D4 = dlmread('C:\Users\joud\OneDrive - University of South Carolina\Mech research\test\FRF test\Frequency Sweep\Test16 synced sweep\SyncSweepVI3.lvm',',',23);
                                                                                                                                                                   
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
PkgAccCal1=(dd1-dd2Cal1); %Calibrate dimension) 
dd2Cal3 = mean(dd3); %Calibrates Time domain offset
PkgAccCal3=-(dd3-dd2Cal3); %Calibrate dimension) 

%% Generate time scale
Fs=1600;
Ts=1/Fs;
End=tt4(length(dd1));
tt40=0: 1/Fs : End; %time column for Fs=40Hz

%Model Time Compensation parameters
DeltaT_MI=0;%(.07-.259375+(0.266875-.27)); % Model offset
PkgAccMod = interp1(tt1,PkgAccCal1,tt40); 
VIAccMod = interp1(tt2-DeltaT_MI,dd2,tt40);

%Validation Time Compensation parameters
%DeltaT_VI=-(.276875-.068125)-0.0013%(0.066875-0.25375-(.265-.2625)+(.26125-.26375)-.000625);%(.074375-.26375) % Validation offset
DeltaT_VI=(1.3325-1.30375)-(.4031-.4006)%-(1.21063-.5075)%(0.066875-0.25375-(.265-.2625)+(.26125-.26375)-.000625); % Validation offset
PkgAccVal = interp1(tt3,PkgAccCal3,tt40); 
VIAccVal = interp1(tt4-DeltaT_VI,dd4,tt40);

%%Convert NAN to Zero
VIAccMod(isnan(VIAccMod))=0;
VIAccVal(isnan(VIAccVal))=0;



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
 
%% Low-Pass Filter
Fcut=50;
% PkgAccMod=lowpass(PkgAccMod,[Fcut],Fs);
% VIAccMod=lowpass(VIAccMod,[Fcut],Fs);
%PkgAccVal=lowpass(PkgAccVal,[Fcut],Fs);
%VIAccVal=lowpass(VIAccVal,[Fcut],Fs);
 
 
%% Plot Data

%Model Data Plot
figure(1);
plot(tt40,VIAccMod,tt40,PkgAccMod);
%xlim([-.1,.2])
grid on
title('Model Data');
xlabel("time (s)");
ylabel("acceleration (m/s^2) ");
legend("Model VI Data","Model Package Data");

%Validation Data Plot
figure(2);
plot(tt40,VIAccVal,tt40,PkgAccVal);
%xlim([-.1,.2])
grid on
title('Validation Data');
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


%% Average Frequency Responses
%Model Frequency response
AccOTX = movmean(P1,20);
AccINX = movmean(P12,20);
AccOTMod = movmean(AccOTX,30);
AccINMod = movmean(AccINX,30);

%Plot the averaged FFTs
figure(3);
plot(f/(2*pi),10*log10(AccOTMod),f2/(2*pi),10*log10(AccINMod));
title(' Averaged Model FFT ');
xlabel('frequency (Hz)');
ylabel('|G(f)|');
xlim([0.001,20]);
legend("Package FFT","VI FFT");

%Validation Frequency response

AccOTY = movmean(P1Val,20);
AccINY = movmean(P12Val,20);
AccOTVal = movmean(AccOTY,30);
AccINVal = movmean(AccINY,30);

%Plot the averaged FFTs
figure(4);
plot(fVal/(2*pi),10*log10(AccOTVal),f2Val/(2*pi),10*log10(AccINVal));
title(' Averaged Validation FFT ');
xlabel('frequency (Hz)');
ylabel('|G(f)|');
xlim([0.001,20]);
legend("Package FFT","VI FFT");

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

%Contineous Model
%++++++++++++++++++++++++++++++++++++++++++
%++++++++++++++++++++++++++++++++++++++++++
%d=[1,4.973701000475435e+02,1.163855783731649e+05,1.142413300689053e+06,1.519822161359035e+07,6.906772377165308e+05,1.837777599084717e+04];
%n=[1.015473500909422,5.477957593899695e+02,1.151199636354329e+05,7.698844687691662e+05,1.105894266368671e+07,-2.890258194066930e+06,9.639520717849102e+04];
%++++++++++++++++++++++++++++++++++++++++++
d=[1,4.492789230083302e+02,1.161948275611139e+05,1.115603156307797e+06,1.515390897236098e+07,1.844193242546123e+05];
n=[0.998764111013069,4.980673800286245e+02,1.150594186246254e+05,7.311761180961824e+05,1.091096646267856e+07,-3.682321162649629e+06];
%++++++++++++++++++++++++++++++++++++++++++
n=[1,2.455603685064564e+03,4.564068882670976e+04];
d=[1.330373311408007,2.313480790421754e+03,4.249729900997524e+04];
sys = tf(n,d);
u=PkgAccVal;
t=tt40;
Post=lsim(sys,u,t);

figure(5);
plot(tt40,VIAccVal,":",t,PkgAccVal,"--",tt40,Post);
legend("Ref","Pkg Pre","Pkg Post");
title('Time Domain Pre Post Ref');
xlabel('time(s)');
ylabel('acceleration (m/2^2)');
ylim([-.12,.12])
xlim([20,21])

%% Inverse Laplace to time domain TF
% syms  s
% %F = 1/(s)^2;
% F = ((1*s^2+2.455603685064564e+03*s+4.564068882670976e+04)/(1.330373311408007*s^2+2.313480790421754e+03*s+4.249729900997524e+04));
% fT=ilaplace(F)
% InvLp=['Time Domain TF = ',fT];
% disp(InvLp);

%% Error PreFilter vs PostFilter

NoisePre=PkgAccVal-VIAccVal;
SNRPre=snr(PkgAccVal,NoisePre);
PreSNR=['Pre Filter SNR = ',num2str(SNRPre),'dB '];
disp(PreSNR);

NoisePost=Post.'-VIAccVal;
SNRPost=snr(Post.',NoisePost);
PostSNR=['Post Filter SNR = ',num2str(SNRPost),'dB '];
disp(PostSNR);

DeltaSNR=SNRPost-SNRPre;
PrcntSNR=(DeltaSNR/SNRPre)*100;
RepSNR=['SNR increase = ',num2str(DeltaSNR),'dB = ',num2str(PrcntSNR),'%'];
disp(RepSNR);

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
title('FRF Pre Post');
xlim([0,20])
ylim([-1,1])
%% FFT Pre Post Filter
%set up sampling Fs:
T2Pre=tt40(2)-tt40(1);
F2HzPre=1/T2Pre;
Fs2Pre=2*pi*F2HzPre; %Rads/s
L2 = length(tt40);             % Length of signal
% %VI FFT 
% Y2Pre = fft(PkgAccVal);           
% P22Pre = abs(Y2Pre/L2);
% P12Pre = P22Pre(1:L2/2+1);
% P12Pre(2:end-1) = 2*P12Pre(2:end-1);
% f2Pre = Fs2Pre*(0:(L2/2))/L2;
% 
% 
% %set up sampling Fs:
% T2Post=tt40(2)-tt40(1);
% F2HzPost=1/T2Post;
% Fs2Post=2*pi*F2HzPost; %Rads/s
% L2 = length(tt40);             % Length of signal
% %Package FFT
% YPost = fft(Post);           
% P2Post = abs(YPost/L2);
% P1Post = P2Post(1:L2/2+1);
% P1Post(2:end-1) = 2*P1Post(2:end-1);
% fPost = Fs2Post*(0:(L2/2))/L2;
% 
% 
% figure(7);
% plot(f2Pre/(2*pi),10*log10(P12Pre),fPost/(2*pi),10*log10(P1Post),f2Val/(2*pi),10*log10(P1Val));
% legend("Pkg Pre","Pkg Post","Ref");
% title('Filter Pre Post Ref FFT');
% xlim([0,20])


Y3 = fft(VIAccVal);           
P23 = abs(Y3/L2);
P123 = P23(1:L2/2+1);
P123(2:end-1) = 2*P123(2:end-1);
f3 = Fs*(0:(L2/2))/L2;

Y3x = fft(PkgAccVal);           
P23x = abs(Y3x/L2);
P123x = P23x(1:L2/2+1);
P123x(2:end-1) = 2*P123x(2:end-1);
f3x = Fs*(0:(L2/2))/L2;

Y3y = fft(Post);           
P23y = abs(Y3y/L2);
P123y = P23y(1:L2/2+1);
P123y(2:end-1) = 2*P123y(2:end-1);
f3y = Fs*(0:(L2/2))/L2;



P123 = movmean(P123,20);
P123 = movmean(P123,30);

P123x = movmean(P123x,20);
P123x = movmean(P123x,30);

P123y = movmean(P123y,20);
P123y = movmean(P123y,30);

figure(100);
plot(f3,10*log10(P123),f3x,10*log10(P123x),f3y,10*log10(P123y));
xlabel('frequency (Hz)');
ylabel('|G(f)|');
legend("Ref","Pkg Pre","Pkg Post");
title('Averaged Filter Pre Post Ref FFT');
xlim([0,20])


%% SPIE plot
subplot(1,2,1)
plot(tt40,VIAccVal,":",tt40,PkgAccVal,"--",tt40,Post);
xlim([0,40.5])
%ylim([-.25,.12])
grid on
xlabel("time(s)");
ylabel("acceleration(g)");
legend("Ref data","Package data","Filter data");
subplot(1,2,2)
plot(f2Val/(2*pi),10*log10(AccINVal),fVal/(2*pi),10*log10(AccOTVal));
%plot(f2Val/(2*pi),(AccINVal),":",fVal/(2*pi),(AccOTVal),"--",f3y,(P123y));
xlabel('frequency (Hz)');
ylabel('|G(f)|');
grid on
xlim([-0.001,20]);
%ylim([-.0001,1.2e-3]);
legend("Ref FFT","Package FFT","Filter FFT");

%++++++++++++++++++++++++++++++++++
% subplot(1,2,1)
% plot(tt40,VIAccVal,":",tt40,PkgAccVal,"--");
% xlim([0,40.5])
% grid on
% title('Validation Data');
% xlabel("time (s)");
% ylabel("acceleration (m/s^2) ");
% legend("Val VI Data","Val Package Data");
% 
% subplot(1,2,2)
% plot(fVal/(2*pi),(AccOTVal),":",f2Val/(2*pi),(AccINVal),"--");
% title(' Averaged Validation FFT ');
% xlabel('frequency (Hz)');
% ylabel('|G(f)|');
% xlim([0.001,20]);
% grid on
% legend("Package FFT","VI FFT");