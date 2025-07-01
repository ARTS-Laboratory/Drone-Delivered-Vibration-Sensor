clc
clear all
close all

%% ++++++++++++ Shaker Chirp Excitation+++++++++++++++
clc
clear all
close all
    %% Import data

%Model Package data
D1 = dlmread('C:\Users\joud\OneDrive - University of South Carolina\Mech research\test\FRF test\Frequency Sweep\Test16 synced sweep\SyncSweepPkg3.lvm',',',0);

%Model VI data
D2 = dlmread('C:\Users\joud\OneDrive - University of South Carolina\Mech research\test\FRF test\Frequency Sweep\Test16 synced sweep\SyncSweepVI3.lvm',',',23);

%Validation Package data
D3 = dlmread('C:\Users\joud\OneDrive - University of South Carolina\Mech research\test\FRF test\Frequency Sweep\Test16 synced sweep\SyncSweepPkg2.lvm',',',0);
                                                                                                                                                              
%Validation VI data                                                        
D4 = dlmread('C:\Users\joud\OneDrive - University of South Carolina\Mech research\test\FRF test\Frequency Sweep\Test16 synced sweep\SyncSweepVI2.lvm',',',23);
                                                                                                                                                                                                                                                        
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
up=-1; %% accelerometer direction
dd2Cal1 = mean(dd1); %Calibrates Time domain offset
PkgAccCal1=up*(dd1-dd2Cal1); %Calibrate dimension) 
dd2Cal3 = mean(dd3); %Calibrates Time domain offset
PkgAccCal3=up*(dd3-dd2Cal3); %Calibrate dimension) 

    %% Generate time scale
Fs=1600;
Ts=1/Fs;
End=tt4(length(dd1));
tt40=0: 1/Fs : End; %time column for Fs=40Hz

%Model Time Compensation parameters
DeltaT_MI=0.0194% Model offset
PkgAccMod = interp1(tt1,PkgAccCal1,tt40); 
VIAccMod = interp1(tt2-DeltaT_MI,dd2,tt40);

%Validation Time Compensation parameters
DeltaT_VI= 0.0213  % Validation offset
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
Fcut=22;
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
ylabel("acceleration (g) ");
legend("Model VI Data","Model Package Data");

%Validation Data Plot
figure(2);
plot(tt40,VIAccVal,tt40,PkgAccVal);
%xlim([-.1,.2])
grid on
title('Validation Data');
xlabel("time (s)");
ylabel("acceleration (g) ");
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
    
    %% model TF
    
    %Contineous Model
    
    %Chirp Transfer function
    n=[1,6.647044624345086e+02,4.231976385361899e+04,6.159171477148423e+04];
    d=[1.014271025633458,6.456347600744411e+02,4.147792727331558e+04,1.002201153150017e+05];
    
    
    %white noise Transfer function
     %n=[1,7.856699765017453e+02,1.664554693859415e+05,2.197240955998747e+05];
     %d=[1.190180166224310,7.121581673736816e+02,1.686984819015598e+05,3.993669839529069e+05];
    
    
    % %Test
     %n=[1];
     %d=[1/(2*pi*22),1];
    
    sys = tf(n,d)
    u=PkgAccVal;
    t=tt40;
    Post=lsim(sys,u,t);
    
    %bode(tf(n,d))
    %prety(tf(n,d))
    
    %% Plot time domain of Reference Pre and Post filtering
    figure(5);
    plot(tt40,VIAccVal,":",t,PkgAccVal,"--",tt40,Post);
    legend("Ref","Pkg Pre","Pkg Post");
    title('Time Domain Pre Post Ref');
    xlabel('time (s)');
    ylabel('acceleration (g)');
    ylim([-.12,.12])
    xlim([20,21])
    
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
    
    %% Pointwise FRF
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
    
    %Reference
    Y3 = fft(VIAccVal);           
    P23 = abs(Y3/L2);
    P123 = P23(1:L2/2+1);
    P123(2:end-1) = 2*P123(2:end-1);
    f3 = Fs*(0:(L2/2))/L2;
    
    %Pre-Filter
    Y3x = fft(PkgAccVal);           
    P23x = abs(Y3x/L2);
    P123x = P23x(1:L2/2+1);
    P123x(2:end-1) = 2*P123x(2:end-1);
    f3x = Fs*(0:(L2/2))/L2;
    
    %Post-Filter
    Y3y = fft(Post);           
    P23y = abs(Y3y/L2);
    P123y = P23y(1:L2/2+1);
    P123y(2:end-1) = 2*P123y(2:end-1);
    f3y = Fs*(0:(L2/2))/L2;
    
    
    
    %% Average FFT results
    
    %Reference
    P123 = movmean(P123,20);
    P123 = movmean(P123,30);
    
    %Pre-Filter
    P123x = movmean(P123x,20);
    P123x = movmean(P123x,30);
    
    %Post-Filter
    P123y = movmean(P123y,20);
    P123y = movmean(P123y,30);
    
    %% Plot Averaged Filter Pre Post Ref FFT
    figure(7);
    plot(f3,10*log10(P123),f3x,10*log10(P123x),f3y,10*log10(P123y));
    xlabel('frequency (Hz)');
    ylabel('|G(f)|');
    legend("Ref","Pkg Pre","Pkg Post");
    title('Averaged Filter Pre Post Ref FFT');
    xlim([0,20])
    
    %% Construct FRF
    %PreFRF=(P123x)./P123;
    %PostFRF=(P123y.')./P123;
    P123y=P123y.';
    PreFRF=(P123-P123x)
    PreFRF=(PreFRF./P123)*100;
    PostFRF=(P123-P123y)
    PostFRF=(PostFRF./P123)*100;
    
    
    figure(1000);
    plot(f3x,PreFRF,f3y,PostFRF);
    xlabel('frequency (Hz)');
    ylabel('Error %');
    legend("Pkg Pre","Pkg Post");
    title('Averaged Filter Pre Post FRF');
    xlim([0,20])
    grid on
    
    
    %% SPIE plot

%Averaged Filter Pre & Ref Time & FFT
figure(8)
subplot(1,2,1)
plot(tt40,VIAccVal,":",tt40,PkgAccVal,"--");
xlim([0,40.5])
grid on
title('Validation Data');
xlabel("time (s)");
ylabel("acceleration (m/s^2) ");
legend("Val VI Data","Val Package Data");

subplot(1,2,2)
plot(fVal/(2*pi),10*log10(AccOTVal),":",f2Val/(2*pi),10*log10(AccINVal),"--");
%semilogx(fVal/(2*pi),10*log10(AccOTVal),":",f2Val/(2*pi),10*log10(AccINVal),"--");
title(' Averaged Validation FFT ');
xlabel('frequency (Hz)');
ylabel('|G(f)|');
xlim([0.1,20]);
grid on
legend("Package FFT","VI FFT");

% Averaged Filter Pre Post Ref FFT
figure(9)
subplot(1,2,1)
plot(tt40,VIAccVal,":",tt40,PkgAccVal,"--",tt40,Post);
xlim([0,40.5])
ylim([-.4,.4]);
grid on
xlabel("time (s)");
ylabel("acceleration (g)");
legend("Ref data","Package data","Filter data");

subplot(1,2,2)
plot(f2Val/(2*pi),10*log10(AccINVal),":",fVal/(2*pi),10*log10(AccOTVal),"--",f3y,10*log10(P123y));
%semilogx(f2Val/(2*pi),10*log10(AccINVal),":",fVal/(2*pi),10*log10(AccOTVal),"--",f3y,10*log10(P123y));
xlabel('frequency (Hz)');
ylabel('|G(f)|');
grid on
xlim([0.1,20]);
legend("Ref FFT","Package FFT","Filter FFT");

%Zoomed time domain plot
figure(10)
plot(tt40,VIAccVal,":",tt40,PkgAccVal,"--",tt40,Post,'LineWidth',2);
xlim([27,34])
ylim([-.075,.075]);
grid on
xlabel("time (s)");
ylabel("acceleration (g)");
legend("Ref data","Package data","Filter data");


%Zoomed time domain plot
figure(11)
plot(tt40,VIAccVal,":",tt40,Post,'LineWidth',2);
xlim([27,34])
ylim([-.075,.075]);
grid on
xlabel("time(s)");
ylabel("acceleration (g)");
legend("Ref data","Filter data");


%% ++++++++++++ Shaker white noise Excitation+++++++++++++++
% clc
% clear all
% close all
% %% Import data
% 
% %Model Package data
% D1 = dlmread('C:\Users\joud\OneDrive - University of South Carolina\Mech research\test\FRF test\Frequency Sweep\Test19 SynthWhiteNoise\WhiteNoiseTestPkg2.lvm',',',0);
% 
% %Model VI data
% D2 = dlmread('C:\Users\joud\OneDrive - University of South Carolina\Mech research\test\FRF test\Frequency Sweep\Test19 SynthWhiteNoise\WhiteNoiseTestVI2.lvm',',',23);
% 
% %Validation Package data
% D3 = dlmread('C:\Users\joud\OneDrive - University of South Carolina\Mech research\test\FRF test\Frequency Sweep\Test19 SynthWhiteNoise\WhiteNoiseTestPkg.lvm',',',0);
%                                                                                                                                                               
% %Validation VI data                                                        
% D4 = dlmread('C:\Users\joud\OneDrive - University of South Carolina\Mech research\test\FRF test\Frequency Sweep\Test19 SynthWhiteNoise\WhiteNoiseTestVI.lvm',',',23);
%                                                                                                                                                                                                                                                         
% %% Extract data
% %time & Acc 1
% tt1=D1(:,1);
% dd1=D1(:,2);
% %time & Acc 2
% tt2=D2(:,1);
% dd2=D2(:,2);
% %time & Acc 3
% tt3=D3(:,1);
% dd3=D3(:,2); 
% %time & Acc 4
% tt4=D4(:,1);
% dd4=D4(:,2);
% 
% %% Calibrate Package Acceleration
% up=-1; %% accelerometer direction
% dd2Cal1 = mean(dd1); %Calibrates Time domain offset
% PkgAccCal1=up*(dd1-dd2Cal1); %Calibrate dimension) 
% dd2Cal3 = mean(dd3); %Calibrates Time domain offset
% PkgAccCal3=up*(dd3-dd2Cal3); %Calibrate dimension) 
% 
% %% Generate time scale
% Fs=1600;
% Ts=1/Fs;
% End=tt4(length(dd1));
% tt40=0: 1/Fs : End; %time column for Fs=40Hz
% 
% %Model Time Compensation parameters
% DeltaT_MI= -0.1898% Model offset
% PkgAccMod = interp1(tt1,PkgAccCal1,tt40); 
% VIAccMod = interp1(tt2-DeltaT_MI,dd2,tt40);
% 
% %Validation Time Compensation parameters
% DeltaT_VI= -0.1924% Validation offset
% PkgAccVal = interp1(tt3,PkgAccCal3,tt40); 
% VIAccVal = interp1(tt4-DeltaT_VI,dd4,tt40);
% 
% %%Convert NAN to Zero
% VIAccMod(isnan(VIAccMod))=0;
% VIAccVal(isnan(VIAccVal))=0;
% 
% 
% 
% %% Calibrate trigger offset
% %  tt401 = tt40(:,DeltaTIndx_MI:end);
% %  PkgAccMod = PkgAccMod(:,DeltaTIndx_MI:(end));
% %  
% %  tt402 = tt40(:,DeltaTIndx_MO:end);
% %  VIAccMod = VIAccMod(:,DeltaTIndx_MO:(end));
%  
% %  tt403 = tt40(:,DeltaTIndx_VI:end);
% %  PkgAccVal = PkgAccMod(:,DeltaTIndx_VI:end);
% %  
% %  tt404 = tt40(:,DeltaTIndx_VO:end);
% %  VIAccVal = VIAccMod(:,DeltaTIndx_VO:end);
% %  
%  %PkgAccVal = PkgAccVal(:,2000:end);
%  %VIAccVal = VIAccVal(:,2000:end);
%  
% %% Low-Pass Filter
% Fcut=22;
% % PkgAccMod=lowpass(PkgAccMod,[Fcut],Fs);
% % VIAccMod=lowpass(VIAccMod,[Fcut],Fs);
% %PkgAccVal=lowpass(PkgAccVal,[Fcut],Fs);
% %VIAccVal=lowpass(VIAccVal,[Fcut],Fs);
%  
%  
% %% Plot Data
% 
% %Model Data Plot
% figure(1);
% plot(tt40,VIAccMod,tt40,PkgAccMod);
% %xlim([-.1,.2])
% grid on
% title('Model Data');
% xlabel("time (s)");
% ylabel("acceleration (g) ");
% legend("Model VI Data","Model Package Data");
% 
% %Validation Data Plot
% figure(2);
% plot(tt40,VIAccVal,tt40,PkgAccVal);
% %xlim([-.1,.2])
% grid on
% title('Validation Data');
% xlabel("time (s)");
% ylabel("acceleration (g) ");
% legend("Val VI Data","Val Package Data");
% 
% %% FFT of model data 
% %set up sampling Fs:
% T2=tt40(2)-tt40(1);
% F2Hz=1/T2;
% Fs2=2*pi*F2Hz; %Rads/s
% L2 = length(tt40);             % Length of signal
%  
% %VI FFT 
% Y2 = fft(VIAccMod);           
% P22 = abs(Y2/L2);
% P12 = P22(1:L2/2+1);
% P12(2:end-1) = 2*P12(2:end-1);
% f2 = Fs2*(0:(L2/2))/L2;
% 
% %Package FFT
% Y = fft(PkgAccMod);           
% P2 = abs(Y/L2);
% P1 = P2(1:L2/2+1);
% P1(2:end-1) = 2*P1(2:end-1);
% f = Fs2*(0:(L2/2))/L2;
% 
% 
% %% FFT of Validation data 
% %set up sampling Fs:
% T2Val=tt40(2)-tt40(1);
% F2HzVal=1/T2Val;
% Fs2Val=2*pi*F2HzVal; %Rads/s
% L2 = length(tt40);             % Length of signal
%  
% %VI FFT 
% Y2Val = fft(VIAccVal);           
% P22Val = abs(Y2Val/L2);
% P12Val = P22Val(1:L2/2+1);
% P12Val(2:end-1) = 2*P12Val(2:end-1);
% f2Val = Fs2Val*(0:(L2/2))/L2;
% 
% %Package FFT
% YVal = fft(PkgAccVal);           
% P2Val = abs(YVal/L2);
% P1Val = P2Val(1:L2/2+1);
% P1Val(2:end-1) = 2*P1Val(2:end-1);
% fVal = Fs2Val*(0:(L2/2))/L2;
% 
% 
% %% Average Frequency Responses
% %Model Frequency response
% AccOTX = movmean(P1,20);
% AccINX = movmean(P12,20);
% AccOTMod = movmean(AccOTX,30);
% AccINMod = movmean(AccINX,30);
% 
% %Plot the averaged FFTs
% figure(3);
% plot(f/(2*pi),10*log10(AccOTMod),f2/(2*pi),10*log10(AccINMod));
% title(' Averaged Model FFT ');
% xlabel('frequency (Hz)');
% ylabel('|G(f)|');
% xlim([0.001,20]);
% legend("Package FFT","VI FFT");
% 
% %Validation Frequency response
% 
% AccOTY = movmean(P1Val,20);
% AccINY = movmean(P12Val,20);
% AccOTVal = movmean(AccOTY,30);
% AccINVal = movmean(AccINY,30);
% 
% %Plot the averaged FFTs
% figure(4);
% plot(fVal/(2*pi),10*log10(AccOTVal),f2Val/(2*pi),10*log10(AccINVal));
% title(' Averaged Validation FFT ');
% xlabel('frequency (Hz)');
% ylabel('|G(f)|');
% xlim([0.001,20]);
% legend("Package FFT","VI FFT");
% 
% %% System Identification Toolbox
% %Sampling time Domain:
% ST=T2;
% %Time domain model
% MIT=VIAccMod.';
% MOT=PkgAccMod.';
% %Time domain Validation
% VIT=VIAccVal.';
% VOT=PkgAccVal.';
% 
% %Sampling Freq Domain:
% FF=f2; %Frequency vector
% %Freq domain model
% MIF=AccINMod.';
% MOF=AccOTMod.';
% %Freq domain Validation
% VIF=AccINVal.';
% VOF=AccOTVal.';
% 
% %% model TF
% 
% %Contineous Model
% 
% %Chirp Transfer function
% %n=[1,6.647044624345086e+02,4.231976385361899e+04,6.159171477148423e+04];
% %d=[1.014271025633458,6.456347600744411e+02,4.147792727331558e+04,1.002201153150017e+05];
% 
% 
% %white noise Transfer function
%  n=[1,7.856699765017453e+02,1.664554693859415e+05,2.197240955998747e+05];
%  d=[1.190180166224310,7.121581673736816e+02,1.686984819015598e+05,3.993669839529069e+05];
% 
% 
% % %Test
%  %n=[1];
%  %d=[1/(2*pi*22),1];
% 
% sys = tf(n,d)
% u=PkgAccVal;
% t=tt40;
% Post=lsim(sys,u,t);
% 
% %bode(tf(n,d))
% %prety(tf(n,d))
% 
% %% Plot time domain of Reference Pre and Post filtering
% figure(5);
% plot(tt40,VIAccVal,":",t,PkgAccVal,"--",tt40,Post);
% legend("Ref","Pkg Pre","Pkg Post");
% title('Time Domain Pre Post Ref');
% xlabel('time (s)');
% ylabel('acceleration (g)');
% ylim([-.12,.12])
% xlim([20,21])
% 
% %% Error PreFilter vs PostFilter
% 
% NoisePre=PkgAccVal-VIAccVal;
% SNRPre=snr(PkgAccVal,NoisePre);
% PreSNR=['Pre Filter SNR = ',num2str(SNRPre),'dB '];
% disp(PreSNR);
% 
% NoisePost=Post.'-VIAccVal;
% SNRPost=snr(Post.',NoisePost);
% PostSNR=['Post Filter SNR = ',num2str(SNRPost),'dB '];
% disp(PostSNR);
% 
% DeltaSNR=SNRPost-SNRPre;
% PrcntSNR=(DeltaSNR/SNRPre)*100;
% RepSNR=['SNR increase = ',num2str(DeltaSNR),'dB = ',num2str(PrcntSNR),'%'];
% disp(RepSNR);
% 
% %% Point wize FRF
% Ref=VIAccVal.';
% Pre=PkgAccVal.';
% Post=Post;
% 
% %% Pointwise FRF
% PreFRF = Pre.\Ref;
% PostFRF = Post.\Ref;
% 
% figure(6);
% plot(tt40,PreFRF,tt40,PostFRF)
% legend("Pkg Pre","Pkg Post");
% title('FRF Pre Post');
% xlim([0,20])
% ylim([-1,1])
% 
% %% FFT Pre Post Filter
% %set up sampling Fs:
% T2Pre=tt40(2)-tt40(1);
% F2HzPre=1/T2Pre;
% Fs2Pre=2*pi*F2HzPre; %Rads/s
% L2 = length(tt40);             % Length of signal
% 
% %Reference
% Y3 = fft(VIAccVal);           
% P23 = abs(Y3/L2);
% P123 = P23(1:L2/2+1);
% P123(2:end-1) = 2*P123(2:end-1);
% f3 = Fs*(0:(L2/2))/L2;
% 
% %Pre-Filter
% Y3x = fft(PkgAccVal);           
% P23x = abs(Y3x/L2);
% P123x = P23x(1:L2/2+1);
% P123x(2:end-1) = 2*P123x(2:end-1);
% f3x = Fs*(0:(L2/2))/L2;
% 
% %Post-Filter
% Y3y = fft(Post);           
% P23y = abs(Y3y/L2);
% P123y = P23y(1:L2/2+1);
% P123y(2:end-1) = 2*P123y(2:end-1);
% f3y = Fs*(0:(L2/2))/L2;
% 
% 
% 
% %% Average FFT results
% 
% %Reference
% P123 = movmean(P123,20);
% P123 = movmean(P123,30);
% 
% %Pre-Filter
% P123x = movmean(P123x,20);
% P123x = movmean(P123x,30);
% 
% %Post-Filter
% P123y = movmean(P123y,20);
% P123y = movmean(P123y,30);
% 
% %% Plot Averaged Filter Pre Post Ref FFT
% figure(7);
% plot(f3,10*log10(P123),f3x,10*log10(P123x),f3y,10*log10(P123y));
% xlabel('frequency (Hz)');
% ylabel('|G(f)|');
% legend("Ref","Pkg Pre","Pkg Post");
% title('Averaged Filter Pre Post Ref FFT');
% xlim([0,20])
% 
% 
% %% SPIE plot
% 
% 
% %Averaged Filter Pre & Ref Time & FFT
% figure(8)
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
% plot(fVal/(2*pi),10*log10(AccOTVal),":",f2Val/(2*pi),10*log10(AccINVal),"--");
% %semilogx(fVal/(2*pi),10*log10(AccOTVal),":",f2Val/(2*pi),10*log10(AccINVal),"--");
% title(' Averaged Validation FFT ');
% xlabel('frequency (Hz)');
% ylabel('|G(f)|');
% xlim([0.1,20]);
% grid on
% legend("Package FFT","VI FFT");
% 
% % Averaged Filter Pre Post Ref FFT
% figure(9)
% subplot(1,2,1)
% plot(tt40,VIAccVal,":",tt40,PkgAccVal,"--",tt40,Post);
% xlim([0,40.5])
% ylim([-.4,.4]);
% grid on
% xlabel("time (s)");
% ylabel("acceleration (g)");
% legend("Ref data","Package data","Filter data");
% 
% subplot(1,2,2)
% plot(f2Val/(2*pi),10*log10(AccINVal),":",fVal/(2*pi),10*log10(AccOTVal),"--",f3y,10*log10(P123y));
% %semilogx(f2Val/(2*pi),10*log10(AccINVal),":",fVal/(2*pi),10*log10(AccOTVal),"--",f3y,10*log10(P123y));
% xlabel('frequency (Hz)');
% ylabel('|G(f)|');
% grid on
% xlim([0.1,20]);
% legend("Ref FFT","Package FFT","Filter FFT");
% 
% %Zoomed time domain plot
% figure(10)
% plot(tt40,VIAccVal,":",tt40,PkgAccVal,"--",tt40,Post,'LineWidth',2);
% xlim([27,34])
% ylim([-.075,.075]);
% grid on
% xlabel("time (s)");
% ylabel("acceleration (g)");
% legend("Ref data","Package data","Filter data");
% 
% 
% %Zoomed time domain plot
% figure(11)
% plot(tt40,VIAccVal,":",tt40,Post,'LineWidth',2);
% xlim([27,34])
% ylim([-.075,.075]);
% grid on
% xlabel("time(s)");
% ylabel("acceleration (g)");
% legend("Ref data","Filter data");

%% ++++++++++++ Structure chirp Excitation+++++++++++++++
% clc
% clear all
% close all
% %% Import data
% 
% %Model Package data
% D1 = dlmread('C:\Users\joud\OneDrive - University of South Carolina\Mech research\test\FRF test\Frequency Sweep\Test23 Chirp Structure excitation\WhiteNoiseTestPkg.lvm',',',0);
% 
% %Model VI data
% D2 = dlmread('C:\Users\joud\OneDrive - University of South Carolina\Mech research\test\FRF test\Frequency Sweep\Test23 Chirp Structure excitation\WhiteNoiseTestVI.lvm',',',23);
% 
% %Validation Package data
% D3 = dlmread('C:\Users\joud\OneDrive - University of South Carolina\Mech research\test\FRF test\Frequency Sweep\Test23 Chirp Structure excitation\WhiteNoiseTestPkg.lvm',',',0);
%                                                                                                                                                               
% %Validation VI data                                                        
% D4 = dlmread('C:\Users\joud\OneDrive - University of South Carolina\Mech research\test\FRF test\Frequency Sweep\Test23 Chirp Structure excitation\WhiteNoiseTestVI.lvm',',',23);
%                                                                                                                                                                                                                                                         
% %% Extract data
% %time & Acc 1
% tt1=D1(:,1);
% dd1=D1(:,2);
% %time & Acc 2
% tt2=D2(:,1);
% dd2=D2(:,2);
% %time & Acc 3
% tt3=D3(:,1);
% dd3=D3(:,2); 
% %time & Acc 4
% tt4=D4(:,1);
% dd4=D4(:,2);
% 
% %% Calibrate Package Acceleration
% up=1; %% accelerometer direction
% dd2Cal1 = mean(dd1); %Calibrates Time domain offset
% PkgAccCal1=(dd1-dd2Cal1); %Calibrate dimension) 
% dd2Cal3 = mean(dd3); %Calibrates Time domain offset
% PkgAccCal3=up*(dd3-dd2Cal3); %Calibrate dimension) 
% 
% %% Generate time scale
% Fs=1600;
% Ts=1/Fs;
% End=tt4(length(dd1));
% tt40=0: 1/Fs : End; %time column for Fs=40Hz
% 
% %Model Time Compensation parameters
% DeltaT_MI=0%0.0194% Model offset
% PkgAccMod = interp1(tt1,PkgAccCal1,tt40); 
% VIAccMod = interp1(tt2-DeltaT_MI,dd2,tt40);
% 
% %Validation Time Compensation parameters
% DeltaT_VI=   -0.209375 % Validation offset
% PkgAccVal = interp1(tt3,PkgAccCal3,tt40); 
% VIAccVal = interp1(tt4-DeltaT_VI,dd4,tt40);
% 
% %%Convert NAN to Zero
% VIAccMod(isnan(VIAccMod))=0;
% VIAccVal(isnan(VIAccVal))=0;
% 
% 
% 
% %% Calibrate trigger offset
% %  tt401 = tt40(:,DeltaTIndx_MI:end);
% %  PkgAccMod = PkgAccMod(:,DeltaTIndx_MI:(end));
% %  
% %  tt402 = tt40(:,DeltaTIndx_MO:end);
% %  VIAccMod = VIAccMod(:,DeltaTIndx_MO:(end));
%  
% %  tt403 = tt40(:,DeltaTIndx_VI:end);
% %  PkgAccVal = PkgAccMod(:,DeltaTIndx_VI:end);
% %  
% %  tt404 = tt40(:,DeltaTIndx_VO:end);
% %  VIAccVal = VIAccMod(:,DeltaTIndx_VO:end);
% %  
%  %PkgAccVal = PkgAccVal(:,2000:end);
%  %VIAccVal = VIAccVal(:,2000:end);
%  
% %% Low-Pass Filter
% Fcut=22;
% % PkgAccMod=lowpass(PkgAccMod,[Fcut],Fs);
% % VIAccMod=lowpass(VIAccMod,[Fcut],Fs);
% %PkgAccVal=lowpass(PkgAccVal,[Fcut],Fs);
% %VIAccVal=lowpass(VIAccVal,[Fcut],Fs);
%  
%  
% %% Plot Data
% 
% %Model Data Plot
% figure(1);
% plot(tt40,VIAccMod,tt40,PkgAccMod);
% %xlim([-.1,.2])
% grid on
% title('Model Data');
% xlabel("time (s)");
% ylabel("acceleration (g) ");
% legend("Model VI Data","Model Package Data");
% 
% %Validation Data Plot
% figure(2);
% plot(tt40,VIAccVal,tt40,PkgAccVal);
% %xlim([-.1,.2])
% grid on
% title('Validation Data');
% xlabel("time (s)");
% ylabel("acceleration (g) ");
% legend("Val VI Data","Val Package Data");
% 
% %% FFT of model data 
% %set up sampling Fs:
% T2=tt40(2)-tt40(1);
% F2Hz=1/T2;
% Fs2=2*pi*F2Hz; %Rads/s
% L2 = length(tt40);             % Length of signal
%  
% %VI FFT 
% Y2 = fft(VIAccMod);           
% P22 = abs(Y2/L2);
% P12 = P22(1:L2/2+1);
% P12(2:end-1) = 2*P12(2:end-1);
% f2 = Fs2*(0:(L2/2))/L2;
% 
% %Package FFT
% Y = fft(PkgAccMod);           
% P2 = abs(Y/L2);
% P1 = P2(1:L2/2+1);
% P1(2:end-1) = 2*P1(2:end-1);
% f = Fs2*(0:(L2/2))/L2;
% 
% 
% %% FFT of Validation data 
% %set up sampling Fs:
% T2Val=tt40(2)-tt40(1);
% F2HzVal=1/T2Val;
% Fs2Val=2*pi*F2HzVal; %Rads/s
% L2 = length(tt40);             % Length of signal
%  
% %VI FFT 
% Y2Val = fft(VIAccVal);           
% P22Val = abs(Y2Val/L2);
% P12Val = P22Val(1:L2/2+1);
% P12Val(2:end-1) = 2*P12Val(2:end-1);
% f2Val = Fs2Val*(0:(L2/2))/L2;
% 
% %Package FFT
% YVal = fft(PkgAccVal);           
% P2Val = abs(YVal/L2);
% P1Val = P2Val(1:L2/2+1);
% P1Val(2:end-1) = 2*P1Val(2:end-1);
% fVal = Fs2Val*(0:(L2/2))/L2;
% 
% 
% %% Average Frequency Responses
% %Model Frequency response
% AccOTX = movmean(P1,20);
% AccINX = movmean(P12,20);
% AccOTMod = movmean(AccOTX,30);
% AccINMod = movmean(AccINX,30);
% 
% %Plot the averaged FFTs
% figure(3);
% plot(f/(2*pi),10*log10(AccOTMod),f2/(2*pi),10*log10(AccINMod));
% title(' Averaged Model FFT ');
% xlabel('frequency (Hz)');
% ylabel('|G(f)|');
% xlim([0.001,20]);
% legend("Package FFT","VI FFT");
% 
% %Validation Frequency response
% 
% AccOTY = movmean(P1Val,20);
% AccINY = movmean(P12Val,20);
% AccOTVal = movmean(AccOTY,30);
% AccINVal = movmean(AccINY,30);
% 
% %Plot the averaged FFTs
% figure(4);
% plot(fVal/(2*pi),10*log10(AccOTVal),f2Val/(2*pi),10*log10(AccINVal));
% title(' Averaged Validation FFT ');
% xlabel('frequency (Hz)');
% ylabel('|G(f)|');
% xlim([0.001,20]);
% legend("Package FFT","VI FFT");
% 
% %% System Identification Toolbox
% %Sampling time Domain:
% ST=T2;
% %Time domain model
% MIT=VIAccMod.';
% MOT=PkgAccMod.';
% %Time domain Validation
% VIT=VIAccVal.';
% VOT=PkgAccVal.';
% 
% %Sampling Freq Domain:
% FF=f2; %Frequency vector
% %Freq domain model
% MIF=AccINMod.';
% MOF=AccOTMod.';
% %Freq domain Validation
% VIF=AccINVal.';
% VOF=AccOTVal.';
% 
% %% model TF
% 
% %Contineous Model
% 
% %Chirp Transfer function
% n=[1,6.647044624345086e+02,4.231976385361899e+04,6.159171477148423e+04];
% d=[1.014271025633458,6.456347600744411e+02,4.147792727331558e+04,1.002201153150017e+05];
% 
% 
% %white noise Transfer function
%  %n=[1,7.856699765017453e+02,1.664554693859415e+05,2.197240955998747e+05];
%  %d=[1.190180166224310,7.121581673736816e+02,1.686984819015598e+05,3.993669839529069e+05];
% 
% 
% % %Test
%  %n=[1];
%  %d=[1/(2*pi*22),1];
% 
% sys = tf(n,d)
% u=PkgAccVal;
% t=tt40;
% Post=lsim(sys,u,t);
% 
% %bode(tf(n,d))
% %prety(tf(n,d))
% 
% %% Plot time domain of Reference Pre and Post filtering
% figure(5);
% plot(tt40,VIAccVal,":",t,PkgAccVal,"--",tt40,Post);
% legend("Ref","Pkg Pre","Pkg Post");
% title('Time Domain Pre Post Ref');
% xlabel('time (s)');
% ylabel('acceleration (g)');
% ylim([-.12,.12])
% xlim([20,21])
% 
% %% Error PreFilter vs PostFilter
% 
% NoisePre=PkgAccVal-VIAccVal;
% SNRPre=snr(PkgAccVal,NoisePre);
% PreSNR=['Pre Filter SNR = ',num2str(SNRPre),'dB '];
% disp(PreSNR);
% 
% NoisePost=Post.'-VIAccVal;
% SNRPost=snr(Post.',NoisePost);
% PostSNR=['Post Filter SNR = ',num2str(SNRPost),'dB '];
% disp(PostSNR);
% 
% DeltaSNR=SNRPost-SNRPre;
% PrcntSNR=(DeltaSNR/SNRPre)*100;
% RepSNR=['SNR increase = ',num2str(DeltaSNR),'dB = ',num2str(PrcntSNR),'%'];
% disp(RepSNR);
% 
% %% Point wize FRF
% Ref=VIAccVal.';
% Pre=PkgAccVal.';
% Post=Post;
% 
% %% Pointwise FRF
% PreFRF = Pre.\Ref;
% PostFRF = Post.\Ref;
% 
% figure(6);
% plot(tt40,PreFRF,tt40,PostFRF)
% legend("Pkg Pre","Pkg Post");
% title('FRF Pre Post');
% xlim([0,20])
% ylim([-1,1])
% 
% %% FFT Pre Post Filter
% %set up sampling Fs:
% T2Pre=tt40(2)-tt40(1);
% F2HzPre=1/T2Pre;
% Fs2Pre=2*pi*F2HzPre; %Rads/s
% L2 = length(tt40);             % Length of signal
% 
% %Reference
% Y3 = fft(VIAccVal);           
% P23 = abs(Y3/L2);
% P123 = P23(1:L2/2+1);
% P123(2:end-1) = 2*P123(2:end-1);
% f3 = Fs*(0:(L2/2))/L2;
% 
% %Pre-Filter
% Y3x = fft(PkgAccVal);           
% P23x = abs(Y3x/L2);
% P123x = P23x(1:L2/2+1);
% P123x(2:end-1) = 2*P123x(2:end-1);
% f3x = Fs*(0:(L2/2))/L2;
% 
% %Post-Filter
% Y3y = fft(Post);           
% P23y = abs(Y3y/L2);
% P123y = P23y(1:L2/2+1);
% P123y(2:end-1) = 2*P123y(2:end-1);
% f3y = Fs*(0:(L2/2))/L2;
% 
% 
% 
% %% Average FFT results
% 
% %Reference
% P123 = movmean(P123,20);
% P123 = movmean(P123,30);
% 
% %Pre-Filter
% P123x = movmean(P123x,20);
% P123x = movmean(P123x,30);
% 
% %Post-Filter
% P123y = movmean(P123y,20);
% P123y = movmean(P123y,30);
% 
% %% Plot Averaged Filter Pre Post Ref FFT
% figure(7);
% plot(f3,10*log10(P123),f3x,10*log10(P123x),f3y,10*log10(P123y));
% xlabel('frequency (Hz)');
% ylabel('|G(f)|');
% legend("Ref","Pkg Pre","Pkg Post");
% title('Averaged Filter Pre Post Ref FFT');
% xlim([0,20])
% 
% 
% %% SPIE plot
% 
% 
% %Averaged Filter Pre & Ref Time & FFT
% figure(8)
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
% plot(fVal/(2*pi),10*log10(AccOTVal),":",f2Val/(2*pi),10*log10(AccINVal),"--");
% %semilogx(fVal/(2*pi),10*log10(AccOTVal),":",f2Val/(2*pi),10*log10(AccINVal),"--");
% title(' Averaged Validation FFT ');
% xlabel('frequency (Hz)');
% ylabel('|G(f)|');
% xlim([0.1,20]);
% grid on
% legend("Package FFT","VI FFT");
% 
% % Averaged Filter Pre Post Ref FFT
% figure(9)
% subplot(1,2,1)
% plot(tt40,VIAccVal,":",tt40,PkgAccVal,"--",tt40,Post);
% xlim([0,40.5])
% ylim([-.4,.4]);
% grid on
% xlabel("time (s)");
% ylabel("acceleration (g)");
% legend("Ref data","Package data","Filter data");
% 
% subplot(1,2,2)
% plot(f2Val/(2*pi),10*log10(AccINVal),":",fVal/(2*pi),10*log10(AccOTVal),"--",f3y,10*log10(P123y));
% %semilogx(f2Val/(2*pi),10*log10(AccINVal),":",fVal/(2*pi),10*log10(AccOTVal),"--",f3y,10*log10(P123y));
% xlabel('frequency (Hz)');
% ylabel('|G(f)|');
% grid on
% xlim([0.1,20]);
% legend("Ref FFT","Package FFT","Filter FFT");
% 
% %Zoomed time domain plot
% figure(10)
% plot(tt40,VIAccVal,":",tt40,PkgAccVal,"--",tt40,Post,'LineWidth',2);
% xlim([27,34])
% ylim([-.075,.075]);
% grid on
% xlabel("time (s)");
% ylabel("acceleration (g)");
% legend("Ref data","Package data","Filter data");
% 
% 
% %Zoomed time domain plot
% figure(11)
% plot(tt40,VIAccVal,":",tt40,Post,'LineWidth',2);
% xlim([27,34])
% ylim([-.075,.075]);
% grid on
% xlabel("time(s)");
% ylabel("acceleration (g)");
% legend("Ref data","Filter data");

%% ++++++++++++ Structure white noise Excitation+++++++++++++++
%clc
%clear all
%close all
% %% Import data
% 
% %Model Package data
% D1 = dlmread('C:\Users\joud\OneDrive - University of South Carolina\Mech research\test\FRF test\Frequency Sweep\Test23 Chirp Structure excitation\WhiteNoiseTestPkg.lvm',',',0);
% 
% %Model VI data
% D2 = dlmread('C:\Users\joud\OneDrive - University of South Carolina\Mech research\test\FRF test\Frequency Sweep\Test23 Chirp Structure excitation\WhiteNoiseTestVI.lvm',',',23);
% 
% %Validation Package data
% D3 = dlmread('C:\Users\joud\OneDrive - University of South Carolina\Mech research\test\FRF test\Frequency Sweep\Test20 Structure white noise Test\WhiteNoiseTestPkg.lvm',',',0);
%                                                                                                                                                               
% %Validation VI data                                                        
% D4 = dlmread('C:\Users\joud\OneDrive - University of South Carolina\Mech research\test\FRF test\Frequency Sweep\Test20 Structure white noise Test\WhiteNoiseTestVI.lvm',',',23);
%                                                                                                                                                                                                                                                         
% %% Extract data
% %time & Acc 1
% tt1=D1(:,1);
% dd1=D1(:,2);
% %time & Acc 2
% tt2=D2(:,1);
% dd2=D2(:,2);
% %time & Acc 3
% tt3=D3(:,1);
% dd3=D3(:,2); 
% %time & Acc 4
% tt4=D4(:,1);
% dd4=D4(:,2);
% 
% %% Calibrate Package Acceleration
% dd2Cal1 = mean(dd1); %Calibrates Time domain offset
% PkgAccCal1=(dd1-dd2Cal1); %Calibrate dimension) 
% dd2Cal3 = mean(dd3); %Calibrates Time domain offset
% PkgAccCal3=(dd3-dd2Cal3); %Calibrate dimension) 
% 
% %% Generate time scale
% Fs=1600;
% Ts=1/Fs;
% End=tt4(length(dd1));
% tt40=0: 1/Fs : End; %time column for Fs=40Hz
% 
% %Model Time Compensation parameters
% DeltaT_MI=0%0.0194% Model offset
% PkgAccMod = interp1(tt1,PkgAccCal1,tt40); 
% VIAccMod = interp1(tt2-DeltaT_MI,dd2,tt40);
% 
% %Validation Time Compensation parameters
% DeltaT_VI = -0.0644% Validation offset
% PkgAccVal = interp1(tt3,PkgAccCal3,tt40); 
% VIAccVal = interp1(tt4-DeltaT_VI,dd4,tt40);
% 
% %%Convert NAN to Zero
% VIAccMod(isnan(VIAccMod))=0;
% VIAccVal(isnan(VIAccVal))=0;
% 
% 
% 
% %% Calibrate trigger offset
% %  tt401 = tt40(:,DeltaTIndx_MI:end);
% %  PkgAccMod = PkgAccMod(:,DeltaTIndx_MI:(end));
% %  
% %  tt402 = tt40(:,DeltaTIndx_MO:end);
% %  VIAccMod = VIAccMod(:,DeltaTIndx_MO:(end));
%  
% %  tt403 = tt40(:,DeltaTIndx_VI:end);
% %  PkgAccVal = PkgAccMod(:,DeltaTIndx_VI:end);
% %  
% %  tt404 = tt40(:,DeltaTIndx_VO:end);
% %  VIAccVal = VIAccMod(:,DeltaTIndx_VO:end);
% %  
%  %PkgAccVal = PkgAccVal(:,2000:end);
%  %VIAccVal = VIAccVal(:,2000:end);
%  
% %% Low-Pass Filter
% Fcut=22;
% % PkgAccMod=lowpass(PkgAccMod,[Fcut],Fs);
% % VIAccMod=lowpass(VIAccMod,[Fcut],Fs);
% %PkgAccVal=lowpass(PkgAccVal,[Fcut],Fs);
% %VIAccVal=lowpass(VIAccVal,[Fcut],Fs);
%  
%  
% %% Plot Data
% 
% %Model Data Plot
% figure(1);
% plot(tt40,VIAccMod,tt40,PkgAccMod);
% %xlim([-.1,.2])
% grid on
% title('Model Data');
% xlabel("time (s)");
% ylabel("acceleration (g) ");
% legend("Model VI Data","Model Package Data");
% 
% %Validation Data Plot
% figure(2);
% plot(tt40,VIAccVal,tt40,PkgAccVal);
% %xlim([-.1,.2])
% grid on
% title('Validation Data');
% xlabel("time (s)");
% ylabel("acceleration (g) ");
% legend("Val VI Data","Val Package Data");
% 
% %% FFT of model data 
% %set up sampling Fs:
% T2=tt40(2)-tt40(1);
% F2Hz=1/T2;
% Fs2=2*pi*F2Hz; %Rads/s
% L2 = length(tt40);             % Length of signal
%  
% %VI FFT 
% Y2 = fft(VIAccMod);           
% P22 = abs(Y2/L2);
% P12 = P22(1:L2/2+1);
% P12(2:end-1) = 2*P12(2:end-1);
% f2 = Fs2*(0:(L2/2))/L2;
% 
% %Package FFT
% Y = fft(PkgAccMod);           
% P2 = abs(Y/L2);
% P1 = P2(1:L2/2+1);
% P1(2:end-1) = 2*P1(2:end-1);
% f = Fs2*(0:(L2/2))/L2;
% 
% 
% %% FFT of Validation data 
% %set up sampling Fs:
% T2Val=tt40(2)-tt40(1);
% F2HzVal=1/T2Val;
% Fs2Val=2*pi*F2HzVal; %Rads/s
% L2 = length(tt40);             % Length of signal
%  
% %VI FFT 
% Y2Val = fft(VIAccVal);           
% P22Val = abs(Y2Val/L2);
% P12Val = P22Val(1:L2/2+1);
% P12Val(2:end-1) = 2*P12Val(2:end-1);
% f2Val = Fs2Val*(0:(L2/2))/L2;
% 
% %Package FFT
% YVal = fft(PkgAccVal);           
% P2Val = abs(YVal/L2);
% P1Val = P2Val(1:L2/2+1);
% P1Val(2:end-1) = 2*P1Val(2:end-1);
% fVal = Fs2Val*(0:(L2/2))/L2;
% 
% 
% %% Average Frequency Responses
% %Model Frequency response
% AccOTX = movmean(P1,20);
% AccINX = movmean(P12,20);
% AccOTMod = movmean(AccOTX,30);
% AccINMod = movmean(AccINX,30);
% 
% %Plot the averaged FFTs
% figure(3);
% plot(f/(2*pi),10*log10(AccOTMod),f2/(2*pi),10*log10(AccINMod));
% title(' Averaged Model FFT ');
% xlabel('frequency (Hz)');
% ylabel('|G(f)|');
% xlim([0.001,20]);
% legend("Package FFT","VI FFT");
% 
% %Validation Frequency response
% 
% AccOTY = movmean(P1Val,20);
% AccINY = movmean(P12Val,20);
% AccOTVal = movmean(AccOTY,30);
% AccINVal = movmean(AccINY,30);
% 
% %Plot the averaged FFTs
% figure(4);
% plot(fVal/(2*pi),10*log10(AccOTVal),f2Val/(2*pi),10*log10(AccINVal));
% title(' Averaged Validation FFT ');
% xlabel('frequency (Hz)');
% ylabel('|G(f)|');
% xlim([0.001,20]);
% legend("Package FFT","VI FFT");
% 
% %% System Identification Toolbox
% %Sampling time Domain:
% ST=T2;
% %Time domain model
% MIT=VIAccMod.';
% MOT=PkgAccMod.';
% %Time domain Validation
% VIT=VIAccVal.';
% VOT=PkgAccVal.';
% 
% %Sampling Freq Domain:
% FF=f2; %Frequency vector
% %Freq domain model
% MIF=AccINMod.';
% MOF=AccOTMod.';
% %Freq domain Validation
% VIF=AccINVal.';
% VOF=AccOTVal.';
% 
% %% model TF
% 
% %Contineous Model
% 
% %Chirp Transfer function
%  %n=[1,6.647044624345086e+02,4.231976385361899e+04,6.159171477148423e+04];
%  %d=[1.014271025633458,6.456347600744411e+02,4.147792727331558e+04,1.002201153150017e+05];
% 
% 
% %white noise Transfer function
% 
% 
% n=[1,7.856699765017453e+02,1.664554693859415e+05,2.197240955998747e+05];
% d=[1.190180166224310,7.121581673736816e+02,1.686984819015598e+05,3.993669839529069e+05];
% 
% 
% % %Test
%  %n=[1];
%  %d=[1/(2*pi*22),1];
% 
% sys = tf(n,d)
% u=PkgAccVal;
% t=tt40;
% Post=lsim(sys,u,t);
% 
% %bode(tf(n,d))
% %prety(tf(n,d))
% 
% %% Plot time domain of Reference Pre and Post filtering
% figure(5);
% plot(tt40,VIAccVal,":",t,PkgAccVal,"--",tt40,Post);
% legend("Ref","Pkg Pre","Pkg Post");
% title('Time Domain Pre Post Ref');
% xlabel('time (s)');
% ylabel('acceleration (g)');
% ylim([-.12,.12])
% xlim([20,21])
% 
% %% Error PreFilter vs PostFilter
% 
% NoisePre=PkgAccVal-VIAccVal;
% SNRPre=snr(PkgAccVal,NoisePre);
% PreSNR=['Pre Filter SNR = ',num2str(SNRPre),'dB '];
% disp(PreSNR);
% 
% NoisePost=Post.'-VIAccVal;
% SNRPost=snr(Post.',NoisePost);
% PostSNR=['Post Filter SNR = ',num2str(SNRPost),'dB '];
% disp(PostSNR);
% 
% DeltaSNR=SNRPost-SNRPre;
% PrcntSNR=(DeltaSNR/SNRPre)*100;
% RepSNR=['SNR increase = ',num2str(DeltaSNR),'dB = ',num2str(PrcntSNR),'%'];
% disp(RepSNR);
% 
% %% Point wize FRF
% Ref=VIAccVal.';
% Pre=PkgAccVal.';
% Post=Post;
% 
% %% Pointwise FRF
% PreFRF = Pre.\Ref;
% PostFRF = Post.\Ref;
% 
% figure(6);
% plot(tt40,PreFRF,tt40,PostFRF)
% legend("Pkg Pre","Pkg Post");
% title('FRF Pre Post');
% xlim([0,20])
% ylim([-1,1])
% 
% %% FFT Pre Post Filter
% %set up sampling Fs:
% T2Pre=tt40(2)-tt40(1);
% F2HzPre=1/T2Pre;
% Fs2Pre=2*pi*F2HzPre; %Rads/s
% L2 = length(tt40);             % Length of signal
% 
% %Reference
% Y3 = fft(VIAccVal);           
% P23 = abs(Y3/L2);
% P123 = P23(1:L2/2+1);
% P123(2:end-1) = 2*P123(2:end-1);
% f3 = Fs*(0:(L2/2))/L2;
% 
% %Pre-Filter
% Y3x = fft(PkgAccVal);           
% P23x = abs(Y3x/L2);
% P123x = P23x(1:L2/2+1);
% P123x(2:end-1) = 2*P123x(2:end-1);
% f3x = Fs*(0:(L2/2))/L2;
% 
% %Post-Filter
% Y3y = fft(Post);           
% P23y = abs(Y3y/L2);
% P123y = P23y(1:L2/2+1);
% P123y(2:end-1) = 2*P123y(2:end-1);
% f3y = Fs*(0:(L2/2))/L2;
% 
% 
% 
% %% Average FFT results
% 
% %Reference
% P123 = movmean(P123,20);
% P123 = movmean(P123,30);
% 
% %Pre-Filter
% P123x = movmean(P123x,20);
% P123x = movmean(P123x,30);
% 
% %Post-Filter
% P123y = movmean(P123y,20);
% P123y = movmean(P123y,30);
% 
% %% Plot Averaged Filter Pre Post Ref FFT
% figure(7);
% plot(f3,10*log10(P123),f3x,10*log10(P123x),f3y,10*log10(P123y));
% xlabel('frequency (Hz)');
% ylabel('|G(f)|');
% legend("Ref","Pkg Pre","Pkg Post");
% title('Averaged Filter Pre Post Ref FFT');
% xlim([0,20])
% 
% 
% %% SPIE plot
% 
% 
% %Averaged Filter Pre & Ref Time & FFT
% figure(8)
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
% plot(fVal/(2*pi),10*log10(AccOTVal),":",f2Val/(2*pi),10*log10(AccINVal),"--");
% %semilogx(fVal/(2*pi),10*log10(AccOTVal),":",f2Val/(2*pi),10*log10(AccINVal),"--");
% title(' Averaged Validation FFT ');
% xlabel('frequency (Hz)');
% ylabel('|G(f)|');
% xlim([0.1,20]);
% grid on
% legend("Package FFT","VI FFT");
% 
% % Averaged Filter Pre Post Ref FFT
% figure(9)
% subplot(1,2,1)
% plot(tt40,VIAccVal,":",tt40,PkgAccVal,"--",tt40,Post);
% xlim([0,40.5])
% ylim([-.4,.4]);
% grid on
% xlabel("time (s)");
% ylabel("acceleration (g)");
% legend("Ref data","Package data","Filter data");
% 
% subplot(1,2,2)
% plot(f2Val/(2*pi),10*log10(AccINVal),":",fVal/(2*pi),10*log10(AccOTVal),"--",f3y,10*log10(P123y));
% %semilogx(f2Val/(2*pi),10*log10(AccINVal),":",fVal/(2*pi),10*log10(AccOTVal),"--",f3y,10*log10(P123y));
% xlabel('frequency (Hz)');
% ylabel('|G(f)|');
% grid on
% xlim([0.1,20]);
% legend("Ref FFT","Package FFT","Filter FFT");
% 
% %Zoomed time domain plot
% figure(10)
% plot(tt40,VIAccVal,":",tt40,PkgAccVal,"--",tt40,Post,'LineWidth',2);
% xlim([27,34])
% ylim([-.075,.075]);
% grid on
% xlabel("time (s)");
% ylabel("acceleration (g)");
% legend("Ref data","Package data","Filter data");
% 
% 
% %Zoomed time domain plot
% figure(11)
% plot(tt40,VIAccVal,":",tt40,Post,'LineWidth',2);
% xlim([27,34])
% ylim([-.075,.075]);
% grid on
% xlabel("time(s)");
% ylabel("acceleration (g)");
% legend("Ref data","Filter data");



%% ++++++++++++ Structure Random excitation with white noise filter+++++++++++++++
% clc
% clear all 
% close all
% 
% %% Import data
% 
% %Model Package data
% D1 = dlmread('C:\Users\joud\OneDrive - University of South Carolina\Mech research\test\FRF test\Frequency Sweep\Test23 Chirp Structure excitation\WhiteNoiseTestPkg.lvm',',',0);
% 
% %Model VI data
% D2 = dlmread('C:\Users\joud\OneDrive - University of South Carolina\Mech research\test\FRF test\Frequency Sweep\Test23 Chirp Structure excitation\WhiteNoiseTestVI.lvm',',',23);
% 
% %Validation Package data
% D3 = dlmread('C:\Users\joud\OneDrive - University of South Carolina\Mech research\test\FRF test\Frequency Sweep\Test22 Random Structure Excitation\WhiteNoiseTestPkg.lvm',',',0);
%                                                                                                                                                               
% %Validation VI data                                                        
% D4 = dlmread('C:\Users\joud\OneDrive - University of South Carolina\Mech research\test\FRF test\Frequency Sweep\Test22 Random Structure Excitation\WhiteNoiseTestVI.lvm',',',23);
%                                                                                                                                                                                                                                                         
% %% Extract data
% %time & Acc 1
% tt1=D1(:,1);
% dd1=D1(:,2);
% %time & Acc 2
% tt2=D2(:,1);
% dd2=D2(:,2);
% %time & Acc 3
% tt3=D3(:,1);
% dd3=D3(:,2); 
% %time & Acc 4
% tt4=D4(:,1);
% dd4=D4(:,2);
% 
% %% Calibrate Package Acceleration
% dd2Cal1 = mean(dd1); %Calibrates Time domain offset
% PkgAccCal1=(dd1-dd2Cal1); %Calibrate dimension) 
% dd2Cal3 = mean(dd3); %Calibrates Time domain offset
% PkgAccCal3=(dd3-dd2Cal3); %Calibrate dimension) 
% 
% %% Generate time scale
% Fs=1600;
% Ts=1/Fs;
% End=tt4(length(dd1));
% tt40=0: 1/Fs : End; %time column for Fs=40Hz
% 
% %Model Time Compensation parameters
% DeltaT_MI=0%0.0194% Model offset
% PkgAccMod = interp1(tt1,PkgAccCal1,tt40); 
% VIAccMod = interp1(tt2-DeltaT_MI,dd2,tt40);
% 
% %Validation Time Compensation parameters
% DeltaT_VI=(0.00188-.2)%-(.2806-.2794)%0.0213 % Validation offset
% PkgAccVal = interp1(tt3,PkgAccCal3,tt40); 
% VIAccVal = interp1(tt4-DeltaT_VI,dd4,tt40);
% 
% %%Convert NAN to Zero
% VIAccMod(isnan(VIAccMod))=0;
% VIAccVal(isnan(VIAccVal))=0;
% 
% 
% 
% %% Calibrate trigger offset
% %  tt401 = tt40(:,DeltaTIndx_MI:end);
% %  PkgAccMod = PkgAccMod(:,DeltaTIndx_MI:(end));
% %  
% %  tt402 = tt40(:,DeltaTIndx_MO:end);
% %  VIAccMod = VIAccMod(:,DeltaTIndx_MO:(end));
%  
% %  tt403 = tt40(:,DeltaTIndx_VI:end);
% %  PkgAccVal = PkgAccMod(:,DeltaTIndx_VI:end);
% %  
% %  tt404 = tt40(:,DeltaTIndx_VO:end);
% %  VIAccVal = VIAccMod(:,DeltaTIndx_VO:end);
% %  
%  %PkgAccVal = PkgAccVal(:,2000:end);
%  %VIAccVal = VIAccVal(:,2000:end);
%  
% %% Low-Pass Filter
% Fcut=22;
% % PkgAccMod=lowpass(PkgAccMod,[Fcut],Fs);
% % VIAccMod=lowpass(VIAccMod,[Fcut],Fs);
% %PkgAccVal=lowpass(PkgAccVal,[Fcut],Fs);
% %VIAccVal=lowpass(VIAccVal,[Fcut],Fs);
%  
%  
% %% Plot Data
% 
% %Model Data Plot
% figure(1);
% plot(tt40,VIAccMod,tt40,PkgAccMod);
% %xlim([-.1,.2])
% grid on
% title('Model Data');
% xlabel("time (s)");
% ylabel("acceleration (g) ");
% legend("Model VI Data","Model Package Data");
% 
% %Validation Data Plot
% figure(2);
% plot(tt40,VIAccVal,tt40,PkgAccVal);
% %xlim([-.1,.2])
% grid on
% title('Validation Data');
% xlabel("time (s)");
% ylabel("acceleration (g) ");
% legend("Val VI Data","Val Package Data");
% 
% %% FFT of model data 
% %set up sampling Fs:
% T2=tt40(2)-tt40(1);
% F2Hz=1/T2;
% Fs2=2*pi*F2Hz; %Rads/s
% L2 = length(tt40);             % Length of signal
%  
% %VI FFT 
% Y2 = fft(VIAccMod);           
% P22 = abs(Y2/L2);
% P12 = P22(1:L2/2+1);
% P12(2:end-1) = 2*P12(2:end-1);
% f2 = Fs2*(0:(L2/2))/L2;
% 
% %Package FFT
% Y = fft(PkgAccMod);           
% P2 = abs(Y/L2);
% P1 = P2(1:L2/2+1);
% P1(2:end-1) = 2*P1(2:end-1);
% f = Fs2*(0:(L2/2))/L2;
% 
% 
% %% FFT of Validation data 
% %set up sampling Fs:
% T2Val=tt40(2)-tt40(1);
% F2HzVal=1/T2Val;
% Fs2Val=2*pi*F2HzVal; %Rads/s
% L2 = length(tt40);             % Length of signal
%  
% %VI FFT 
% Y2Val = fft(VIAccVal);           
% P22Val = abs(Y2Val/L2);
% P12Val = P22Val(1:L2/2+1);
% P12Val(2:end-1) = 2*P12Val(2:end-1);
% f2Val = Fs2Val*(0:(L2/2))/L2;
% 
% %Package FFT
% YVal = fft(PkgAccVal);           
% P2Val = abs(YVal/L2);
% P1Val = P2Val(1:L2/2+1);
% P1Val(2:end-1) = 2*P1Val(2:end-1);
% fVal = Fs2Val*(0:(L2/2))/L2;
% 
% 
% %% Average Frequency Responses
% %Model Frequency response
% AccOTX = movmean(P1,20);
% AccINX = movmean(P12,20);
% AccOTMod = movmean(AccOTX,30);
% AccINMod = movmean(AccINX,30);
% 
% %Plot the averaged FFTs
% figure(3);
% plot(f/(2*pi),10*log10(AccOTMod),f2/(2*pi),10*log10(AccINMod));
% title(' Averaged Model FFT ');
% xlabel('frequency (Hz)');
% ylabel('|G(f)|');
% xlim([0.001,20]);
% legend("Package FFT","VI FFT");
% 
% %Validation Frequency response
% 
% AccOTY = movmean(P1Val,20);
% AccINY = movmean(P12Val,20);
% AccOTVal = movmean(AccOTY,30);
% AccINVal = movmean(AccINY,30);
% 
% %Plot the averaged FFTs
% figure(4);
% plot(fVal/(2*pi),10*log10(AccOTVal),f2Val/(2*pi),10*log10(AccINVal));
% title(' Averaged Validation FFT ');
% xlabel('frequency (Hz)');
% ylabel('|G(f)|');
% xlim([0.001,20]);
% legend("Package FFT","VI FFT");
% 
% %% System Identification Toolbox
% %Sampling time Domain:
% ST=T2;
% %Time domain model
% MIT=VIAccMod.';
% MOT=PkgAccMod.';
% %Time domain Validation
% VIT=VIAccVal.';
% VOT=PkgAccVal.';
% 
% %Sampling Freq Domain:
% FF=f2; %Frequency vector
% %Freq domain model
% MIF=AccINMod.';
% MOF=AccOTMod.';
% %Freq domain Validation
% VIF=AccINVal.';
% VOF=AccOTVal.';
% 
% %% model TF
% 
% %Contineous Model
% 
% %Chirp Transfer function
%  %n=[1,6.647044624345086e+02,4.231976385361899e+04,6.159171477148423e+04];
%  %d=[1.014271025633458,6.456347600744411e+02,4.147792727331558e+04,1.002201153150017e+05];
% 
% 
% %white noise Transfer function
%  n=[1,7.856699765017453e+02,1.664554693859415e+05,2.197240955998747e+05];
%  d=[1.190180166224310,7.121581673736816e+02,1.686984819015598e+05,3.993669839529069e+05];
% 
% 
% % %Test
%  %n=[1];
%  %d=[1/(2*pi*22),1];
% 
% sys = tf(n,d)
% u=PkgAccVal;
% t=tt40;
% Post=lsim(sys,u,t);
% 
% %bode(tf(n,d))
% %prety(tf(n,d))
% 
% %% Plot time domain of Reference Pre and Post filtering
% figure(5);
% plot(tt40,VIAccVal,":",t,PkgAccVal,"--",tt40,Post);
% legend("Ref","Pkg Pre","Pkg Post");
% title('Time Domain Pre Post Ref');
% xlabel('time (s)');
% ylabel('acceleration (g)');
% ylim([-.12,.12])
% xlim([20,21])
% 
% %% Error PreFilter vs PostFilter
% 
% NoisePre=PkgAccVal-VIAccVal;
% SNRPre=snr(PkgAccVal,NoisePre);
% PreSNR=['Pre Filter SNR = ',num2str(SNRPre),'dB '];
% disp(PreSNR);
% 
% NoisePost=Post.'-VIAccVal;
% SNRPost=snr(Post.',NoisePost);
% PostSNR=['Post Filter SNR = ',num2str(SNRPost),'dB '];
% disp(PostSNR);
% 
% DeltaSNR=SNRPost-SNRPre;
% PrcntSNR=(DeltaSNR/SNRPre)*100;
% RepSNR=['SNR increase = ',num2str(DeltaSNR),'dB = ',num2str(PrcntSNR),'%'];
% disp(RepSNR);
% 
% %% Point wize FRF
% Ref=VIAccVal.';
% Pre=PkgAccVal.';
% Post=Post;
% 
% %% Pointwise FRF
% PreFRF = Pre.\Ref;
% PostFRF = Post.\Ref;
% 
% figure(6);
% plot(tt40,PreFRF,tt40,PostFRF)
% legend("Pkg Pre","Pkg Post");
% title('FRF Pre Post');
% xlim([0,20])
% ylim([-1,1])
% 
% %% FFT Pre Post Filter
% %set up sampling Fs:
% T2Pre=tt40(2)-tt40(1);
% F2HzPre=1/T2Pre;
% Fs2Pre=2*pi*F2HzPre; %Rads/s
% L2 = length(tt40);             % Length of signal
% 
% %Reference
% Y3 = fft(VIAccVal);           
% P23 = abs(Y3/L2);
% P123 = P23(1:L2/2+1);
% P123(2:end-1) = 2*P123(2:end-1);
% f3 = Fs*(0:(L2/2))/L2;
% 
% %Pre-Filter
% Y3x = fft(PkgAccVal);           
% P23x = abs(Y3x/L2);
% P123x = P23x(1:L2/2+1);
% P123x(2:end-1) = 2*P123x(2:end-1);
% f3x = Fs*(0:(L2/2))/L2;
% 
% %Post-Filter
% Y3y = fft(Post);           
% P23y = abs(Y3y/L2);
% P123y = P23y(1:L2/2+1);
% P123y(2:end-1) = 2*P123y(2:end-1);
% f3y = Fs*(0:(L2/2))/L2;
% 
% 
% 
% %% Average FFT results
% 
% %Reference
% P123 = movmean(P123,20);
% P123 = movmean(P123,30);
% 
% %Pre-Filter
% P123x = movmean(P123x,20);
% P123x = movmean(P123x,30);
% 
% %Post-Filter
% P123y = movmean(P123y,20);
% P123y = movmean(P123y,30);
% 
% %% Plot Averaged Filter Pre Post Ref FFT
% figure(7);
% plot(f3,10*log10(P123),f3x,10*log10(P123x),f3y,10*log10(P123y));
% xlabel('frequency (Hz)');
% ylabel('|G(f)|');
% legend("Ref","Pkg Pre","Pkg Post");
% title('Averaged Filter Pre Post Ref FFT');
% xlim([0,20])
% 
% 
% %% SPIE plot
% 
% 
% %Averaged Filter Pre & Ref Time & FFT
% figure(8)
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
% plot(fVal/(2*pi),10*log10(AccOTVal),":",f2Val/(2*pi),10*log10(AccINVal),"--");
% %semilogx(fVal/(2*pi),10*log10(AccOTVal),":",f2Val/(2*pi),10*log10(AccINVal),"--");
% title(' Averaged Validation FFT ');
% xlabel('frequency (Hz)');
% ylabel('|G(f)|');
% xlim([0.1,20]);
% grid on
% legend("Package FFT","VI FFT");
% 
% % Averaged Filter Pre Post Ref FFT
% figure(9)
% subplot(1,2,1)
% plot(tt40,VIAccVal,":",tt40,PkgAccVal,"--",tt40,Post);
% xlim([0,40.5])
% ylim([-.4,.4]);
% grid on
% xlabel("time (s)");
% ylabel("acceleration (g)");
% legend("Ref data","Package data","Filter data");
% 
% subplot(1,2,2)
% plot(f2Val/(2*pi),10*log10(AccINVal),":",fVal/(2*pi),10*log10(AccOTVal),"--",f3y,10*log10(P123y));
% %semilogx(f2Val/(2*pi),10*log10(AccINVal),":",fVal/(2*pi),10*log10(AccOTVal),"--",f3y,10*log10(P123y));
% xlabel('frequency (Hz)');
% ylabel('|G(f)|');
% grid on
% xlim([0.1,20]);
% legend("Ref FFT","Package FFT","Filter FFT");
% 
% %Zoomed time domain plot
% figure(10)
% plot(tt40,VIAccVal,":",tt40,PkgAccVal,"--",tt40,Post,'LineWidth',2);
% xlim([27,34])
% ylim([-.075,.075]);
% grid on
% xlabel("time (s)");
% ylabel("acceleration (g)");
% legend("Ref data","Package data","Filter data");
% 
% 
% %Zoomed time domain plot
% figure(11)
% plot(tt40,VIAccVal,":",tt40,Post,'LineWidth',2);
% xlim([27,34])
% ylim([-.075,.075]);
% grid on
% xlabel("time(s)");
% ylabel("acceleration (g)");
% legend("Ref data","Filter data");
% 


%% ++++++++++++ Structure Random excitation  with chirp filter+++++++++++++++
%clc
%clear all
%close all

% %% Import data
% 
% %Model Package data
% D1 = dlmread('C:\Users\joud\OneDrive - University of South Carolina\Mech research\test\FRF test\Frequency Sweep\Test23 Chirp Structure excitation\WhiteNoiseTestPkg.lvm',',',0);
% 
% %Model VI data
% D2 = dlmread('C:\Users\joud\OneDrive - University of South Carolina\Mech research\test\FRF test\Frequency Sweep\Test23 Chirp Structure excitation\WhiteNoiseTestVI.lvm',',',23);
% 
% %Validation Package data
% D3 = dlmread('C:\Users\joud\OneDrive - University of South Carolina\Mech research\test\FRF test\Frequency Sweep\Test22 Random Structure Excitation\WhiteNoiseTestPkg.lvm',',',0);
%                                                                                                                                                               
% %Validation VI data                                                        
% D4 = dlmread('C:\Users\joud\OneDrive - University of South Carolina\Mech research\test\FRF test\Frequency Sweep\Test22 Random Structure Excitation\WhiteNoiseTestVI.lvm',',',23);
%                                                                                                                                                                                                                                                         
% %% Extract data
% %time & Acc 1
% tt1=D1(:,1);
% dd1=D1(:,2);
% %time & Acc 2
% tt2=D2(:,1);
% dd2=D2(:,2);
% %time & Acc 3
% tt3=D3(:,1);
% dd3=D3(:,2); 
% %time & Acc 4
% tt4=D4(:,1);
% dd4=D4(:,2);
% 
% %% Calibrate Package Acceleration
% dd2Cal1 = mean(dd1); %Calibrates Time domain offset
% PkgAccCal1=(dd1-dd2Cal1); %Calibrate dimension) 
% dd2Cal3 = mean(dd3); %Calibrates Time domain offset
% PkgAccCal3=(dd3-dd2Cal3); %Calibrate dimension) 
% 
% %% Generate time scale
% Fs=1600;
% Ts=1/Fs;
% End=tt4(length(dd1));
% tt40=0: 1/Fs : End; %time column for Fs=40Hz
% 
% %Model Time Compensation parameters
% DeltaT_MI=0%0.0194% Model offset
% PkgAccMod = interp1(tt1,PkgAccCal1,tt40); 
% VIAccMod = interp1(tt2-DeltaT_MI,dd2,tt40);
% 
% %Validation Time Compensation parameters
% DeltaT_VI=(0.00188-.2)%-(.2806-.2794)%0.0213 % Validation offset
% PkgAccVal = interp1(tt3,PkgAccCal3,tt40); 
% VIAccVal = interp1(tt4-DeltaT_VI,dd4,tt40);
% 
% %%Convert NAN to Zero
% VIAccMod(isnan(VIAccMod))=0;
% VIAccVal(isnan(VIAccVal))=0;
% 
% 
% 
% %% Calibrate trigger offset
% %  tt401 = tt40(:,DeltaTIndx_MI:end);
% %  PkgAccMod = PkgAccMod(:,DeltaTIndx_MI:(end));
% %  
% %  tt402 = tt40(:,DeltaTIndx_MO:end);
% %  VIAccMod = VIAccMod(:,DeltaTIndx_MO:(end));
%  
% %  tt403 = tt40(:,DeltaTIndx_VI:end);
% %  PkgAccVal = PkgAccMod(:,DeltaTIndx_VI:end);
% %  
% %  tt404 = tt40(:,DeltaTIndx_VO:end);
% %  VIAccVal = VIAccMod(:,DeltaTIndx_VO:end);
% %  
%  %PkgAccVal = PkgAccVal(:,2000:end);
%  %VIAccVal = VIAccVal(:,2000:end);
%  
% %% Low-Pass Filter
% Fcut=22;
% % PkgAccMod=lowpass(PkgAccMod,[Fcut],Fs);
% % VIAccMod=lowpass(VIAccMod,[Fcut],Fs);
% %PkgAccVal=lowpass(PkgAccVal,[Fcut],Fs);
% %VIAccVal=lowpass(VIAccVal,[Fcut],Fs);
%  
%  
% %% Plot Data
% 
% %Model Data Plot
% figure(1);
% plot(tt40,VIAccMod,tt40,PkgAccMod);
% %xlim([-.1,.2])
% grid on
% title('Model Data');
% xlabel("time (s)");
% ylabel("acceleration (g) ");
% legend("Model VI Data","Model Package Data");
% 
% %Validation Data Plot
% figure(2);
% plot(tt40,VIAccVal,tt40,PkgAccVal);
% %xlim([-.1,.2])
% grid on
% title('Validation Data');
% xlabel("time (s)");
% ylabel("acceleration (g) ");
% legend("Val VI Data","Val Package Data");
% 
% %% FFT of model data 
% %set up sampling Fs:
% T2=tt40(2)-tt40(1);
% F2Hz=1/T2;
% Fs2=2*pi*F2Hz; %Rads/s
% L2 = length(tt40);             % Length of signal
%  
% %VI FFT 
% Y2 = fft(VIAccMod);           
% P22 = abs(Y2/L2);
% P12 = P22(1:L2/2+1);
% P12(2:end-1) = 2*P12(2:end-1);
% f2 = Fs2*(0:(L2/2))/L2;
% 
% %Package FFT
% Y = fft(PkgAccMod);           
% P2 = abs(Y/L2);
% P1 = P2(1:L2/2+1);
% P1(2:end-1) = 2*P1(2:end-1);
% f = Fs2*(0:(L2/2))/L2;
% 
% 
% %% FFT of Validation data 
% %set up sampling Fs:
% T2Val=tt40(2)-tt40(1);
% F2HzVal=1/T2Val;
% Fs2Val=2*pi*F2HzVal; %Rads/s
% L2 = length(tt40);             % Length of signal
%  
% %VI FFT 
% Y2Val = fft(VIAccVal);           
% P22Val = abs(Y2Val/L2);
% P12Val = P22Val(1:L2/2+1);
% P12Val(2:end-1) = 2*P12Val(2:end-1);
% f2Val = Fs2Val*(0:(L2/2))/L2;
% 
% %Package FFT
% YVal = fft(PkgAccVal);           
% P2Val = abs(YVal/L2);
% P1Val = P2Val(1:L2/2+1);
% P1Val(2:end-1) = 2*P1Val(2:end-1);
% fVal = Fs2Val*(0:(L2/2))/L2;
% 
% 
% %% Average Frequency Responses
% %Model Frequency response
% AccOTX = movmean(P1,20);
% AccINX = movmean(P12,20);
% AccOTMod = movmean(AccOTX,30);
% AccINMod = movmean(AccINX,30);
% 
% %Plot the averaged FFTs
% figure(3);
% plot(f/(2*pi),10*log10(AccOTMod),f2/(2*pi),10*log10(AccINMod));
% title(' Averaged Model FFT ');
% xlabel('frequency (Hz)');
% ylabel('|G(f)|');
% xlim([0.001,20]);
% legend("Package FFT","VI FFT");
% 
% %Validation Frequency response
% 
% AccOTY = movmean(P1Val,20);
% AccINY = movmean(P12Val,20);
% AccOTVal = movmean(AccOTY,30);
% AccINVal = movmean(AccINY,30);
% 
% %Plot the averaged FFTs
% figure(4);
% plot(fVal/(2*pi),10*log10(AccOTVal),f2Val/(2*pi),10*log10(AccINVal));
% title(' Averaged Validation FFT ');
% xlabel('frequency (Hz)');
% ylabel('|G(f)|');
% xlim([0.001,20]);
% legend("Package FFT","VI FFT");
% 
% %% System Identification Toolbox
% %Sampling time Domain:
% ST=T2;
% %Time domain model
% MIT=VIAccMod.';
% MOT=PkgAccMod.';
% %Time domain Validation
% VIT=VIAccVal.';
% VOT=PkgAccVal.';
% 
% %Sampling Freq Domain:
% FF=f2; %Frequency vector
% %Freq domain model
% MIF=AccINMod.';
% MOF=AccOTMod.';
% %Freq domain Validation
% VIF=AccINVal.';
% VOF=AccOTVal.';
% 
% %% model TF
% 
% %Contineous Model
% 
% %Chirp Transfer function
% n=[1,6.647044624345086e+02,4.231976385361899e+04,6.159171477148423e+04];
% d=[1.014271025633458,6.456347600744411e+02,4.147792727331558e+04,1.002201153150017e+05];
% 
% 
% %white noise Transfer function
%  %n=[1,7.856699765017453e+02,1.664554693859415e+05,2.197240955998747e+05];
%  %d=[1.190180166224310,7.121581673736816e+02,1.686984819015598e+05,3.993669839529069e+05];
% 
% 
% % %Test
%  %n=[1];
%  %d=[1/(2*pi*22),1];
% 
% sys = tf(n,d)
% u=PkgAccVal;
% t=tt40;
% Post=lsim(sys,u,t);
% 
% %bode(tf(n,d))
% %prety(tf(n,d))
% 
% %% Plot time domain of Reference Pre and Post filtering
% figure(5);
% plot(tt40,VIAccVal,":",t,PkgAccVal,"--",tt40,Post);
% legend("Ref","Pkg Pre","Pkg Post");
% title('Time Domain Pre Post Ref');
% xlabel('time (s)');
% ylabel('acceleration (g)');
% ylim([-.12,.12])
% xlim([20,21])
% 
% %% Error PreFilter vs PostFilter
% 
% NoisePre=PkgAccVal-VIAccVal;
% SNRPre=snr(PkgAccVal,NoisePre);
% PreSNR=['Pre Filter SNR = ',num2str(SNRPre),'dB '];
% disp(PreSNR);
% 
% NoisePost=Post.'-VIAccVal;
% SNRPost=snr(Post.',NoisePost);
% PostSNR=['Post Filter SNR = ',num2str(SNRPost),'dB '];
% disp(PostSNR);
% 
% DeltaSNR=SNRPost-SNRPre;
% PrcntSNR=(DeltaSNR/SNRPre)*100;
% RepSNR=['SNR increase = ',num2str(DeltaSNR),'dB = ',num2str(PrcntSNR),'%'];
% disp(RepSNR);
% 
% %% Point wize FRF
% Ref=VIAccVal.';
% Pre=PkgAccVal.';
% Post=Post;
% 
% %% Pointwise FRF
% PreFRF = Pre.\Ref;
% PostFRF = Post.\Ref;
% 
% figure(6);
% plot(tt40,PreFRF,tt40,PostFRF)
% legend("Pkg Pre","Pkg Post");
% title('FRF Pre Post');
% xlim([0,20])
% ylim([-1,1])
% 
% %% FFT Pre Post Filter
% %set up sampling Fs:
% T2Pre=tt40(2)-tt40(1);
% F2HzPre=1/T2Pre;
% Fs2Pre=2*pi*F2HzPre; %Rads/s
% L2 = length(tt40);             % Length of signal
% 
% %Reference
% Y3 = fft(VIAccVal);           
% P23 = abs(Y3/L2);
% P123 = P23(1:L2/2+1);
% P123(2:end-1) = 2*P123(2:end-1);
% f3 = Fs*(0:(L2/2))/L2;
% 
% %Pre-Filter
% Y3x = fft(PkgAccVal);           
% P23x = abs(Y3x/L2);
% P123x = P23x(1:L2/2+1);
% P123x(2:end-1) = 2*P123x(2:end-1);
% f3x = Fs*(0:(L2/2))/L2;
% 
% %Post-Filter
% Y3y = fft(Post);           
% P23y = abs(Y3y/L2);
% P123y = P23y(1:L2/2+1);
% P123y(2:end-1) = 2*P123y(2:end-1);
% f3y = Fs*(0:(L2/2))/L2;
% 
% 
% 
% %% Average FFT results
% 
% %Reference
% P123 = movmean(P123,20);
% P123 = movmean(P123,30);
% 
% %Pre-Filter
% P123x = movmean(P123x,20);
% P123x = movmean(P123x,30);
% 
% %Post-Filter
% P123y = movmean(P123y,20);
% P123y = movmean(P123y,30);
% 
% %% Plot Averaged Filter Pre Post Ref FFT
% figure(7);
% plot(f3,10*log10(P123),f3x,10*log10(P123x),f3y,10*log10(P123y));
% xlabel('frequency (Hz)');
% ylabel('|G(f)|');
% legend("Ref","Pkg Pre","Pkg Post");
% title('Averaged Filter Pre Post Ref FFT');
% xlim([0,20])
% 
% 
% %% SPIE plot
% 
% 
% %Averaged Filter Pre & Ref Time & FFT
% figure(8)
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
% plot(fVal/(2*pi),10*log10(AccOTVal),":",f2Val/(2*pi),10*log10(AccINVal),"--");
% %semilogx(fVal/(2*pi),10*log10(AccOTVal),":",f2Val/(2*pi),10*log10(AccINVal),"--");
% title(' Averaged Validation FFT ');
% xlabel('frequency (Hz)');
% ylabel('|G(f)|');
% xlim([0.1,20]);
% grid on
% legend("Package FFT","VI FFT");
% 
% % Averaged Filter Pre Post Ref FFT
% figure(9)
% subplot(1,2,1)
% plot(tt40,VIAccVal,":",tt40,PkgAccVal,"--",tt40,Post);
% xlim([0,40.5])
% ylim([-.4,.4]);
% grid on
% xlabel("time (s)");
% ylabel("acceleration (g)");
% legend("Ref data","Package data","Filter data");
% 
% subplot(1,2,2)
% plot(f2Val/(2*pi),10*log10(AccINVal),":",fVal/(2*pi),10*log10(AccOTVal),"--",f3y,10*log10(P123y));
% %semilogx(f2Val/(2*pi),10*log10(AccINVal),":",fVal/(2*pi),10*log10(AccOTVal),"--",f3y,10*log10(P123y));
% xlabel('frequency (Hz)');
% ylabel('|G(f)|');
% grid on
% xlim([0.1,20]);
% legend("Ref FFT","Package FFT","Filter FFT");
% 
% %Zoomed time domain plot
% figure(10)
% plot(tt40,VIAccVal,":",tt40,PkgAccVal,"--",tt40,Post,'LineWidth',2);
% xlim([27,34])
% ylim([-.075,.075]);
% grid on
% xlabel("time (s)");
% ylabel("acceleration (g)");
% legend("Ref data","Package data","Filter data");
% 
% 
% %Zoomed time domain plot
% figure(11)
% plot(tt40,VIAccVal,":",tt40,Post,'LineWidth',2);
% xlim([27,34])
% ylim([-.075,.075]);
% grid on
% xlabel("time(s)");
% ylabel("acceleration (g)");
% legend("Ref data","Filter data");


%% ++++++++++++ CHIRP WAVEFORM +++++++++++++++
% 
% f1=21; %End Freq
% f0=.1; %Start Freq
% T=40; %Test Time
% 
% c=(f1-f0)/T;
% Phi=1;
% %Chirp=0;
% Ts=1/1600;
% 
% 
% t = (0:Ts:T);
% 
% Chirp = (sin(Phi+(2*pi*((c/2)*t.^2+f0*t))))
% 
% %Chirp FFT 
% %set up sampling Fs:
% T2Val=t(2)-t(1);
% F2HzVal=1/T2Val;
% Fs2Val=2*pi*F2HzVal; %Rads/s
% L2 = length(t);             % Length of signal
% 
% Y2Val = fft(Chirp);           
% P22Val = abs(Y2Val/L2);
% P12Val = P22Val(1:L2/2+1);
% P12Val(2:end-1) = 2*P12Val(2:end-1);
% f2Val = Fs2Val*(0:(L2/2))/L2;
% 
% %plot(t,(1 - t/T).*Chirp);
% subplot(1,2,1)
% plot(t,Chirp);
% grid on
% ylim([-1.2,1.5]);
% legend("excitation signal")
% ylabel('voltage(V)');
% xlabel('time(s)');
% subplot(1,2,2)
% semilogx(f2Val/(2*pi),10*log10(P12Val));
% grid on
% xlabel('frequency (Hz)');
% ylabel('|G(f)|');
% xlim([0.1,100]);
% ylim([-50,-5]);
% legend("excitation signal FFT")

%% ++++++++++++ WHITE NOISE WAVEFORM +++++++++++++++
% Fs = 1600; %Hz
% Ts = 1/Fs;
% TestTime=40; %seconds
% t = (0:Ts:TestTime);
% 
% WhiteNoise=0
% for Freq = 0:.05:21
%    WhiteNoise=WhiteNoise+sin(Freq*2*pi*t);
% end
% 
% % Normalize signal
% Min = min(WhiteNoise)
% Max = max(WhiteNoise)
% WhiteNoiseNorm=2*(WhiteNoise-Min)/(Max-Min)-1;
% Data=[WhiteNoiseNorm];
% 
% Noise=randn(1,length(t));
% RandomWhiteNoise=Noise+WhiteNoise;
% 
% Min = min(RandomWhiteNoise)
% Max = max(RandomWhiteNoise)
% RandomWhiteNoiseNorm=2*(RandomWhiteNoise-Min)/(Max-Min)-1;
% 
% % White Noise FFT
% %Chirp FFT 
% %set up sampling Fs:
% T2Val=t(2)-t(1);
% F2HzVal=1/T2Val;
% Fs2Val=2*pi*F2HzVal; %Rads/s
% L2 = length(t);             % Length of signal
% 
% Y2Val = fft(WhiteNoiseNorm);           
% P22Val = abs(Y2Val/L2);
% P12Val = P22Val(1:L2/2+1);
% P12Val(2:end-1) = 2*P12Val(2:end-1);
% f2Val = Fs2Val*(0:(L2/2))/L2;
% 
% subplot(1,2,1)
% plot(t,WhiteNoiseNorm);
% grid on
% ylim([-1.2,1.5]);
% legend("excitation signal")
% ylabel('voltage(V)');
% xlabel('time(s)');
% subplot(1,2,2)
% semilogx(f2Val/(2*pi),10*log10(P12Val));
% grid on
% xlabel('frequency (Hz)');
% ylabel('|G(f)|');
% xlim([0.1,100]);
% ylim([-45,-20]);
% legend("excitation signal FFT")

