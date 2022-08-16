clc
clear all
close all



%%
Fs = 1600; %Hz
Ts = 1/Fs;
TestTime=40; %seconds
t = (0:Ts:TestTime);

%WhiteNoise=sin(.1*2*pi*t)+sin(.2*2*pi*t)+sin(.3*2*pi*t)+sin(.4*2*pi*t)+sin(.5*2*pi*t)+sin(.6*2*pi*t)+sin(.7*2*pi*t)+sin(.8*2*pi*t)+sin(.9*2*pi*t)+sin(1*2*pi*t)+sin(1.1*2*pi*t)+sin(1.2*2*pi*t)+sin(1.3*2*pi*t)+sin(1.4*2*pi*t)+sin(1.5*2*pi*t)+sin(1.6*2*pi*t)+sin(1.7*2*pi*t)+sin(1.8*2*pi*t)+sin(1.9*2*pi*t)+sin(2*2*pi*t)+sin(2.1*2*pi*t)+sin(2.2*2*pi*t)+sin(2.3*2*pi*t)+sin(2.4*2*pi*t)+sin(2.5*2*pi*t)+sin(2.6*2*pi*t)+sin(2.7*2*pi*t)+sin(2.8*2*pi*t)+sin(2.9*2*pi*t)+sin(3*2*pi*t)+sin(3.1*2*pi*t)+sin(3.2*2*pi*t)+sin(3.3*2*pi*t)+sin(3.4*2*pi*t)+sin(3.5*2*pi*t)+sin(3.6*2*pi*t)+sin(3.7*2*pi*t)+sin(3.8*2*pi*t)+sin(3.9*2*pi*t)+sin(4*2*pi*t)+sin(4.1*2*pi*t)+sin(4.2*2*pi*t)+sin(4.3*2*pi*t)+sin(4.4*2*pi*t)+sin(4.5*2*pi*t)+sin(4.6*2*pi*t)+sin(4.7*2*pi*t)+sin(4.8*2*pi*t)+sin(4.9*2*pi*t)+sin(5*2*pi*t)+sin(5.1*2*pi*t)+sin(5.2*2*pi*t)+sin(5.3*2*pi*t)+sin(5.4*2*pi*t)+sin(5.5*2*pi*t)+sin(5.6*2*pi*t)+sin(5.7*2*pi*t)+sin(5.8*2*pi*t)+sin(5.9*2*pi*t)+sin(6*2*pi*t)+sin(6.1*2*pi*t)+sin(6.2*2*pi*t)+sin(6.3*2*pi*t)+sin(6.4*2*pi*t)+sin(6.5*2*pi*t)+sin(6.6*2*pi*t)+sin(6.7*2*pi*t)+sin(6.8*2*pi*t)+sin(6.9*2*pi*t)+sin(7*2*pi*t)+sin(7.1*2*pi*t)+sin(7.2*2*pi*t)+sin(7.3*2*pi*t)+sin(7.4*2*pi*t)+sin(7.5*2*pi*t)+sin(7.6*2*pi*t)+sin(7.7*2*pi*t)+sin(7.8*2*pi*t)+sin(7.9*2*pi*t)+sin(8*2*pi*t)+sin(8.1*2*pi*t)+sin(8.2*2*pi*t)+sin(8.3*2*pi*t)+sin(8.4*2*pi*t)+sin(8.5*2*pi*t)+sin(8.6*2*pi*t)+sin(8.7*2*pi*t)+sin(8.8*2*pi*t)+sin(8.9*2*pi*t)+sin(9*2*pi*t)+sin(9.1*2*pi*t)+sin(9.2*2*pi*t)+sin(9.3*2*pi*t)+sin(9.4*2*pi*t)+sin(9.5*2*pi*t)+sin(9.6*2*pi*t)+sin(9.7*2*pi*t)+sin(9.8*2*pi*t)+sin(9.9*2*pi*t)+sin(10*2*pi*t)+sin(10.1*2*pi*t)+sin(10.2*2*pi*t)+sin(10.3*2*pi*t)+sin(10.4*2*pi*t)+sin(10.5*2*pi*t)+sin(10.6*2*pi*t)+sin(10.7*2*pi*t)+sin(10.8*2*pi*t)+sin(10.9*2*pi*t)+sin(11*2*pi*t)+sin(11.1*2*pi*t)+sin(11.2*2*pi*t)+sin(11.3*2*pi*t)+sin(11.4*2*pi*t)+sin(11.5*2*pi*t)+sin(11.6*2*pi*t)+sin(11.7*2*pi*t)+sin(11.8*2*pi*t)+sin(11.9*2*pi*t)+sin(12*2*pi*t)+sin(12.1*2*pi*t)+sin(12.2*2*pi*t)+sin(12.3*2*pi*t)+sin(12.4*2*pi*t)+sin(12.5*2*pi*t)+sin(12.6*2*pi*t)+sin(12.7*2*pi*t)+sin(12.8*2*pi*t)+sin(12.9*2*pi*t)+sin(13*2*pi*t)+sin(13.1*2*pi*t)+sin(13.2*2*pi*t)+sin(13.3*2*pi*t)+sin(13.4*2*pi*t)+sin(13.5*2*pi*t)+sin(13.6*2*pi*t)+sin(13.7*2*pi*t)+sin(13.8*2*pi*t)+sin(13.9*2*pi*t)+sin(14*2*pi*t)+sin(14.1*2*pi*t)+sin(14.2*2*pi*t)+sin(14.3*2*pi*t)+sin(14.4*2*pi*t)+sin(14.5*2*pi*t)+sin(14.6*2*pi*t)+sin(14.7*2*pi*t)+sin(14.8*2*pi*t)+sin(14.9*2*pi*t)+sin(15*2*pi*t)+sin(15.1*2*pi*t)+sin(15.2*2*pi*t)+sin(15.3*2*pi*t)+sin(15.4*2*pi*t)+sin(15.5*2*pi*t)+sin(15.6*2*pi*t)+sin(15.7*2*pi*t)+sin(15.8*2*pi*t)+sin(15.9*2*pi*t)+sin(16*2*pi*t)+sin(16.1*2*pi*t)+sin(16.2*2*pi*t)+sin(16.3*2*pi*t)+sin(16.4*2*pi*t)+sin(16.5*2*pi*t)+sin(16.6*2*pi*t)+sin(16.7*2*pi*t)+sin(16.8*2*pi*t)+sin(16.9*2*pi*t)+sin(17*2*pi*t)+sin(17.1*2*pi*t)+sin(17.2*2*pi*t)+sin(17.3*2*pi*t)+sin(17.4*2*pi*t)+sin(17.5*2*pi*t)+sin(17.6*2*pi*t)+sin(17.7*2*pi*t)+sin(17.8*2*pi*t)+sin(17.9*2*pi*t)+sin(18*2*pi*t)+sin(18.1*2*pi*t)+sin(18.2*2*pi*t)+sin(18.3*2*pi*t)+sin(18.4*2*pi*t)+sin(18.5*2*pi*t)+sin(18.6*2*pi*t)+sin(18.7*2*pi*t)+sin(18.8*2*pi*t)+sin(18.9*2*pi*t)+sin(19*2*pi*t)+sin(19.1*2*pi*t)+sin(19.2*2*pi*t)+sin(19.3*2*pi*t)+sin(19.4*2*pi*t)+sin(19.5*2*pi*t)+sin(19.6*2*pi*t)+sin(19.7*2*pi*t)+sin(19.8*2*pi*t)+sin(19.9*2*pi*t)+sin(20*2*pi*t)+sin(20.1*2*pi*t)+sin(20.2*2*pi*t)+sin(20.3*2*pi*t)+sin(20.4*2*pi*t)+sin(20.5*2*pi*t)+sin(20.6*2*pi*t)+sin(20.7*2*pi*t)+sin(20.8*2*pi*t)+sin(20.9*2*pi*t);      

WhiteNoise=0
for Freq = 0:.05:21
   WhiteNoise=WhiteNoise+sin(Freq*2*pi*t);
end

%%

Min = min(WhiteNoise)
Max = max(WhiteNoise)
WhiteNoiseNorm=2*(WhiteNoise-Min)/(Max-Min)-1;
Data=[WhiteNoiseNorm];

Noise=randn(1,length(t));
RandomWhiteNoise=Noise+WhiteNoise;

Min = min(RandomWhiteNoise)
Max = max(RandomWhiteNoise)
RandomWhiteNoiseNorm=2*(RandomWhiteNoise-Min)/(Max-Min)-1;


figure(1)
plot(t,WhiteNoiseNorm);
title('Reference');
figure(2)
plot(t,RandomWhiteNoiseNorm);
title('Noise injected');



%% Construct TF
u=RandomWhiteNoise;
t=t;
n=[1,2.455603685064564e+03,4.564068882670976e+04];
d=[1.330373311408007,2.313480790421754e+03,4.249729900997524e+04];
sys = tf(n,d);
Post=lsim(sys,u,t).';

figure(3);
plot(t,RandomWhiteNoise,t,Post,t,WhiteNoise);
legend("Pkg Pre","Pkg Post","Ref");
title('Time domain of Pre post vs ref');
%xlim([43,43.5])

%% Error PreFilter vs PostFilter


NoisePre=RandomWhiteNoise-WhiteNoise;
SNRPre=snr(WhiteNoise,NoisePre);
PreSNR=['Pre SNR = ',num2str(SNRPre),'dB '];
disp(PreSNR);

NoisePost=Post-WhiteNoise;
SNRPost=snr(WhiteNoise,NoisePost);
PostSNR=['Post SNR = ',num2str(SNRPost),'dB '];
disp(PostSNR);

DeltaSNR=SNRPost-SNRPre;
PrcntSNR=(DeltaSNR/SNRPre)*100;
RepSNR=['SNR increase = ',num2str(DeltaSNR),'dB = ',num2str(PrcntSNR),'%'];
disp(RepSNR);


%% Construct an FFT
%set up sampling Fs:
T2=t(2)-t(1);
L2 = length(t);             % Length of signal
 
%Pre Filter FFT
Y = fft(RandomWhiteNoise);           
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
Y3 = fft(WhiteNoise);           
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
plot(f,PreFRF,f2,PostFRF);
title('FRF Pre vs Post Filter');
xlabel('frequency (Hz)');
ylabel('|G(f)|');
xlim([0.1,22]);
legend("Pre","Post");

%% SPIE PLOT
subplot(1,2,1)
plot(t,WhiteNoiseNorm);
xlabel('time(s)');
ylabel('voltage(V)');
legend('excitation signal');
xlim([0,40]);
ylim([-1.2,1.2]);
grid on
%make here your first plot
subplot(1,2,2)
%make here your second plot
Y3 = fft(WhiteNoise);           
P23 = abs(Y3/L2);
P123 = P23(1:L2/2+1);
P123(2:end-1) = 2*P123(2:end-1);
f3 = Fs*(0:(L2/2))/L2;
%figure(5);
plot(f3,P123);
%title('FFT Pre post vs Ref');
xlabel('frequency (Hz)');
ylabel('|G(f)|');
legend('excitation signal FFT');
grid on
xlim([0,25]);













