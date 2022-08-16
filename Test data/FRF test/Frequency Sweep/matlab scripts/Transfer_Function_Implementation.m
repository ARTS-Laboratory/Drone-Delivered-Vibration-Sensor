clc
clear all
close all

%% Load VI Data 
D = dlmread('C:\Users\joud\OneDrive - University of South Carolina\Mech research\test\FRF test\Frequency Sweep\Test13 Floor Test 1650Hz\FRF Test Fs1650Hz VI.lvm',',',23);

%time & Acc
tt=D(:,1);
dd=D(:,2);

%Time Plot
figure(1);
plot(tt,dd);
grid on
xlabel("time (s)");
ylabel("acceleration (m/s^2)");
legend("VI Data");

%Print Sampling Freq
FsVI=1/(tt(2)-tt(1))



%% Load Package Data

D2 = dlmread('C:\Users\joud\OneDrive - University of South Carolina\Mech research\test\FRF test\Frequency Sweep\Test13 Floor Test 1650Hz\FRF Test Fs1650Hz Pkg.lvm',',',0);

%time & Acc
tt2=D2(:,1);
dd2=D2(:,2);

%Time plot
figure(2);
plot(tt2,dd2);
grid on
xlabel("time (s)");
ylabel("acceleration ");
legend("Package Data");

FsPkg=1/(tt2(2)-tt2(1))
dd2Cal = mean(dd2) %Calibrates Time domain offset
PkgAccCal=dd2-dd2Cal;




%% Interpolate VI time data onto the package's time data
VIAcc = interp1(tt,dd,tt2);

%time domain interpolated:
figure(3);
plot(tt2,VIAcc,tt2,PkgAccCal);
grid on
xlabel("time (s)");
ylabel("acceleration (m/s^2) ");
legend("VI Data","Package Data");
ylim([-.6,.6]);


%set up sampling Fs:

T2=tt2(2)-tt2(1);
F2Hz=1/T2;
Fs2=2*pi*F2Hz;
L2 = length(tt2);             % Length of signal
 
%VI FFT 
Y2 = fft(VIAcc*1000);           %THE FFT IS SCALED BY A 1000
P22 = abs(Y2/L2);
P12 = P22(1:L2/2+1);
P12(2:end-1) = 2*P12(2:end-1);
f2 = Fs2*(0:(L2/2))/L2;

%Package FFT
Y = fft(dd2*1000);           %THE FFT IS SCALED BY A 1000
P2 = abs(Y/L2);
P1 = P2(1:L2/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f = Fs2*(0:(L2/2))/L2;

%% Average Frequency Responses
figure(4);
AccOT = movmean(P1,30);
AccIN = movmean(P12,30);

%Plot the averaged FFTs
plot(f2,AccIN,f,AccOT);
title('Single-Sided Amplitude Spectrum of X(t)');
xlabel('frequency (Rad/s)');
ylabel('|G(f)|');
ylim([0,20]);
xlim([0.1,160]);
legend("VI FFT","Package FFT");



%% Generate and Plot Frequency Response Function
%FRF Response 
Err=(AccOT.\AccIN);
figure(6);
plot(f2,Err);
%semilogx(f2,Err);
ylim([0,2.5]);
xlim([0.1,160]);
title('Frequency Response Function');
legend("AccOut/AccIn");
xlabel('frequency (Rad/s)');
ylabel('AccOut/AccIn');


%% Average FRF
Avg = movmean(Err,10);
figure(7);
plot(f2,Avg);
%semilogx(f2,Avg);
xlim([0.02,160]);
ylim([-.1,2.5]);
title('Averaged Frequency Response Function');
legend("AccOut/AccIn");
xlabel('frequency (Rad/s)');
ylabel('AccOut/AccIn');

%%  Compare Input Output
% y=AccOT;
% u=AccIN;
% Ts= f2(2)-f2(1);
% W=f2;
% data = iddata(y,u,Ts,'Frequency',W)
% type = 'P1D';
% sysP1D = procest(data,type);
% figure(8);
% %compare(data,sysP1D)
% plot(sysP1D);
% xlim([0.4,22]);

%% System Identification Toolbox

Input=AccIN;
Output=AccOT;
W=2*pi*f2;
FFT_Ts=2*pi*(f2(2)-f2(1))


%% Recondstruct time scale for 40Hz Nyquist

% IntT=0: 1/40 :49.9404; %time column for Fs=40Hz
% IntVIAcc = interp1(tt,dd,IntT);
% IntPkgAcc = interp1(tt2,dd2,IntT);
% IntFs=40;
% 
% figure(8);
% plot(IntT,IntVIAcc,IntT,IntPkgAcc);
% title('Interpolated time domain');
% legend("VI FFT","Package FFT");
% xlabel('Time (s)');
% ylabel('Acc');
% 
% 
% %set up sampling Fs:
% IntT2=IntT(2)-IntT(1);
% IntF2Hz=1/IntT2;
% IntFs2=2*pi*IntF2Hz;
% IntL2 = length(IntT);             % Length of signal
% 
% %Package FFT
% IntY = fft(IntPkgAcc*1000);           %THE FFT IS SCALED BY A 1000
% IntP2 = abs(IntY/IntL2);
% IntP1 = IntP2(1:IntL2/2+1);
% IntP1(2:end-1) = 2*IntP1(2:end-1);
% Intf = IntFs2*(0:(IntL2/2))/IntL2;
% 
% %VI FFT 
% IntY2 = fft(IntVIAcc*1000);           %THE FFT IS SCALED BY A 1000
% IntP22 = abs(IntY2/IntL2);
% IntP12 = IntP22(1:IntL2/2+1);
% IntP12(2:end-1) = 2*IntP12(2:end-1);
% Intf2 = IntFs2*(0:(IntL2/2))/IntL2;



%% Average Frequency Responses
% figure(9);
% IntAccOTX = movmean(IntP1,20);
% IntAccINX = movmean(IntP12,20);
% IntAccOT = movmean(IntAccOTX,40);
% IntAccIN = movmean(IntAccINX,40);
% 
% %Plot the averaged FFTs
% plot(Intf2,IntAccIN,Intf,IntAccOT);
% title('Interpolated FFT');
% xlabel('frequency (Rad/s)');
% ylabel('|G(f)|');
% ylim([0,20]);
% xlim([0.1,160]);
% legend("Int VI FFT","Int Package FFT");

%% Generate and Plot Frequency Response Function
% %FRF Response 
% IntErr=(IntAccOT.\IntAccIN);
% figure(10);
% plot(Intf2,IntErr);
% %semilogx(f2,Err);
% ylim([0,2.5]);
% xlim([0.1,160]);
% title('Interpolated Frequency Response Function');
% legend("AccOut/AccIn");
% xlabel('frequency (Rad/s)');
% ylabel('AccOut/AccIn');

%% System Identification Toolbox parameters

% IntInput=IntAccIN;
% IntOutput=IntAccOT;
% IntW=2*pi*Intf2;
% IntFFT_Ts= 2*pi*(Intf2(2)-Intf2(1))

%% MATLAB Answers Example:


T2=tt2(2)-tt2(1);
%d = load('td_data.mat');
Fs = 1/T2;  % Hz
tdu = VIAcc;
tdy = PkgAccCal;
L = numel(tdu);
t = linspace(0, L, L)/Fs;
figure
plot(t, tdu,    t, tdy)
grid
Fn = Fs/2;
FTy = fft(tdy)/L;
FTu = fft(tdu)/L;
FTH = FTy./FTu;                                                         % Empirical Transfer Function
Fv = linspace(0, 1, fix(L/2)+1)*Fn;
Iv = 1:numel(Fv);
figure
semilogy(Fv, abs(FTy(Iv))*2,  Fv, abs(FTu(Iv))*2, Fv, abs(FTH(Iv))*2)
grid
xlim([0 5E+3])
legend('Output', 'Input', '‘Transfer Function’', 'Location','E')
figure
plot(Fv, imag(FTH(Iv)))                                                 % Poles, Zeros On Imaginary Axis
grid
xlim([0 5E+3])
figure
plot(Fv, abs(FTH(Iv))*2)
grid
xlim([0 5E+3])
D = iddata(tdy, tdu, 1/Fs);
sys = tfest(D, 5, 5);
figure
bode(sys)







