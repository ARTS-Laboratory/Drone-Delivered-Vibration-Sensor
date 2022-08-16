clc
clear all
close all

%% Import Data
D1 = dlmread('C:\Users\joud\OneDrive - University of South Carolina\LCR\2.437nF_1Hz.lvm',',',23);
%D1 = dlmread('C:\Users\joud\OneDrive - University of South Carolina\LCR\LCRdat_470uFCap.lvm',',',23);
f=1; %input driving frequency in Hz

Rref=3299.4; % Reference Resistance in Ohm
%isolate columns
t1=D1(:,1);
Vin=D1(:,2);
Vot=D1(:,3);

%% Plot time doamin signal
figure(1);
plot(t1,Vin,t1,Vot);
xlim([0,(10/f)]);
grid on
title('Raw data');
xlabel("time (s)");
ylabel("voltage (v) ");
legend("Vin","Vout");

%% Intepolate
Fs=100*f;
Ts=1/Fs;
End=t1(length(t1));
t=t1(1): 1/Fs : End; %time column for Fs=40Hz

Vin = interp1(t1,Vin,t);
Vot = interp1(t1,Vot,t);

%% filter data
%bandpassPass Filter Parameters
Fs=1/(t(2)-t(1)); %inverse period
VinF=lowpass(Vin,f+1,Fs);
VotF=lowpass(Vot,f+1,Fs);

%% Plot post-filter time domain
figure(2);
plot(t,VinF,t,VotF);
xlim([0,(10/f)]);
grid on
title('Interpolation');
xlabel("time (s)");
ylabel("voltage (v) ");
legend("Vin Filtered","Vout Filtered");

%% Peak detection
%Vin Peak detection
figure(3);
findpeaks(VinF,t);
xlim([0,(10/f)]);
grid on
title('Voltage I/O');
xlabel("time (s)");
ylabel("voltage (v) ");
legend("Vin Filtered");

%Vout Peak detection
figure(4);
findpeaks(VotF,t);
xlim([0,(10/f)]);
grid on
title('Voltage I/O');
xlabel("time (s)");
ylabel("voltage (v) ");
legend("Vout Filtered");

[Pk,T]=findpeaks(VinF,t);
[Pk2,T2]=findpeaks(VotF,t);

%% Calculate phase
DeltaT=(T(5)-T2(5)); % Time shift
Phase=360*f*DeltaT % Phase angle in degrees

%% Calculate Amplitude
Amp=(Pk(5)-Pk2(5)) % Amplitude change
VPkIn=Pk(5);
VPkOt=Pk2(5);

%Example inut for valdiation
% Phase=-79.95
% VPkIn=1.929
% VPkOt=.310
% Rref=1000
% f=100

Z= (VPkOt*Rref)/sqrt((VPkIn^2)-(2*VPkIn*VPkOt*cosd(Phase))+(VPkOt^2));
%Z= (.310*1000)/(sqrt(1.929^2-2*1.929*.310*cos(-79.95)+.310^2))
alpha=Phase-atand((-VPkOt*sind(Phase))/(VPkIn-(VPkOt*cosd(Phase))));
%alpha=-97.95-atan((-.310*sin(-79.95))/(1.929-(.310*cos(-79.95))))

%% Capacitance measurement
C = (-1/(2*pi*f*Z*sind(alpha)))*10^6;
Cap=['Capacitance = ', num2str(C) ,' uF'];
disp(Cap) 














