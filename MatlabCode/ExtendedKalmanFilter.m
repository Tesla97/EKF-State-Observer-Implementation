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

%risposta al gradino unitario
u     = ones(N,1); 
sysIn = [t' u];
sim("modelloForKalman");
yv    = sysOut';        %uscita priva di rumore
figure(1),grid,plot(t,yv,'b');

%definizione rumore di misura e di processo
v1    = normrnd(0,0.8,2,N);
v2    = normrnd(0,0.01,1,N);

%uscita misurata
ym    = yv + v2;
figure(1),hold on,plot(t,ym,'r'),legend("uscita priva di rumore","uscita misurata");

%stato vero del sistema
xv(1,:) = x1';
xv(2,:) = x2';
figure(2),grid,plot(t,xv(1,:),'b');

%definizione matrici covarianza
V1      = cov(v1(1,:),v1(2,:));
V2      = var(v2);

%inizializzazione equazione di Riccati
P       = eye(2);

%definizione variabili stato stimato
Xkk       = zeros(2,N);                %x^(k|k)
Xkk1      = zeros(2,N);                %x^(k|k-1)
Xkk1(:,1) = xv(:,1);                   %x^(1|0) 

%vettore delle innovazioni
evect     = zeros(1,N);

%vettore dei guadagni
KK        = zeros(2,N);

%identità
I         = eye(2);

%implementazione filtro di Kalman esteso
for k     = 1 : N
    %generazione matrice H(k)
    H        = generaMatriceH(Xkk1,k,L);
    %generazione innovazione
    e        = ym(k) - h(Xkk1,k,L);
    %guadagno del Filtro Ko(k)
    Ko       = P*H'*inv(H*P*H' + V2);
    %stima dello stato al passo k
    Xkk(:,k) = Xkk1(:,k) + Ko*e;
    %measurement update
    Po       = (I-Ko*H)*P;
    %generazione matrice F
    F        = generaMatriceF(Xkk,k,L,Ts,m,g,b);
    %predizione stato al passo k + 1
    if k < N
        Xkk1(:,k+1) = f(Xkk,k,L,Ts,m,g,b,u(k));
        %riccati 
        P           = F*Po*F'+V1;
    end
    %memorizzazione innovazione
    evect(k) = e;
    %memorizzazione guadagni
    KK(:,k)  = Ko;
end

%rappresentazione stato stimato
figure(2),hold on,plot(t,Xkk(1,:),'r'),legend("stato vero sistema","stato stimato");

%rappresentazione innovazione
figure(3),grid,plot(t,evect,'b');
figure(4),autocorr(evect);

%rappresentazione guadagni
figure(5),grid,plot(t,KK);