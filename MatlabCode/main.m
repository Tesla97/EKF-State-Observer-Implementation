clear
close all
clc

%% definizione parametri modello
L = 0.40;               %lunghezza asta rigida (m)
m = 0.55;               %massa del corpo (Kg)
g = 9.81;               %gravità (m/s^2)
b = 0.50;               %coefficiente d'attrito
I = m*L*L;              %inerzia

N  = 500;               %numero di campioni
Ts = 0.05;              %tempo di campionamento
t  = (0:N-1)*Ts;        %intervallo di osservazione

%risposta al gradino
u     = 1;
[t,x] = ode45(@generaSistema,t,[0 0],[],L,m,g,b,u);
y     = L*sin(x(:,1))';
figure(1),grid,plot(t,y,'b');

%calcolo tempo di campionamento
yreg(1,:) = ones(1,N)*(1.01*y(N));
yreg(2,:) = ones(1,N)*(0.99*y(N));
figure(1),hold on,plot(t,yreg,'r'),legend("risposta al gradino","1.01*yreg","0.99*yreg");

%identificazione modello sistema
u         = idinput(N,'prbs');
sysIn     = [t u];
sim("blackBoxModel");
yv        = sysOut';            %uscita rumorosa

%definizione rumore di misura
d         = normrnd(0,0.1,1,N);
ym        = yv + d;             %uscita rumorosa
figure(2),hold on,plot(t,ym,'b');

%modello arx
data      = [ym(1:N)' u];
system    = arx(data,[14 14 2]);
ys        = lsim(system,u,(0:N-1))'; %uscita stimata
figure(2),hold on,plot(t,ys,'r'),legend("uscita misurata","uscita stimata");

%valutazione errore di identificazione
e         = ym - ys;
figure(3),autocorr(e);

%confronto risposta al gradino
sysIn     = [t sin(2*t)];
sim("blackBoxModel");
rispSys   = sysOut';
ys        = lsim(system,sin(2*t),(0:N-1))';
figure(4),grid,plot(t,rispSys,'b',t,ys,'r'),legend("uscita vera","uscita stimata");