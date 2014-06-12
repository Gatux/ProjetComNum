%% Gabriel VERMEULEN - Maxime PETERLIN
clear all; close all;

%% Initialisation des variables

fe = 10000; % frequence d'echantillonnage : fe = 10 kHz
Ts = 0.001; % Ds = 1kSymboles/s => Ts = 1 ms

% Filtre g(t)
g = ones(1, Ts*fe);
g = (1/sqrt(Ts*fe))* g; % On normalise le fitre de tel façon que Eg = 1

% Filtre gt(t)
gt = ones(1, Ts*fe);
for i=1:Ts*fe
    gt(i) = 1/(sqrt(3.85)) * (1 - (i-1)/(Ts*fe));  % On normalise le fitre de tel façon que Eg = 1
end

% Filtre ga(t)
ga = g;

% Filtre gat(t)
gat = ones(1, Ts*fe);
for i=1:Ts*fe
    gat(i) = gt(end - i+1);
end

% A commenter si besoin pour utiliser soit g et ga, soit gt et gat
%g = gt;
%ga = gat;

nb_paquet = 1;
Ns = 5000;
sb = (rand(1,Ns * nb_paquet) > 0.5) * 1;
Fse = Ts * fe;
N = 512;

%% BBGC additif
mu = 0;
sigma = 0;

%% Emetteur
% Association bits->Symbole
ss = sb;
ss(ss == 0) = -1;

% Sur-échantillonnage
ss = upsample(ss, Fse);

% Filtrage de mise en forme
sl = conv(ss, g);

%% Canal
yl = sl + (mu + sigma * randn(1,length(sl)));

%% Récepteur
% Filtre de réception ga(t)
rl_t = conv(yl, ga);

% Echantillonnage au rythme Ts
rl_n = downsample(rl_t, Fse);

% Décision
An = rl_n;
An(An >= 0) = 1;
An(An < 0) = -1;

% Association Symbole->Bits
b = An;
b(b == -1) = 0;
b(b == 1) = 1;
b = b(2:end-1);

disp('Taux d''Erreur Binaire : '); disp(TEB(sb, b));
%% Figures des résultats
close all;
% 1. Allure temporelle du signal sl(t) pour t=[0, 50*Ts - Te]
figure(2);
N = 50 * (Ts-(1/fe)) * fe;
plot((0:N-1)/fe, sl(1:N), '-+');
title('Allure temporelle du signal sl(t)');
xlabel('Temps (s)'); ylabel('Symboles');
legend('sl(t)');

% 2. Diagramme de l'oeil de sl(t)
eyediagram(sl(1:1000), 3*Ts*fe);

% 3. Allure de rl(t) pour t=[0, 50*Ts - Te] en sortie du filtre adapté (non normalisé)
figure(3);
N = 50 * (Ts-(1/fe)) * fe;
plot((0:N-1)/fe, rl_t(1:N), '-+');
title('Allure temporelle du signal rl(t)');
xlabel('Temps (s)'); ylabel('Symboles');
legend('rl(t)');

%% 4. DSP de Ss(t) et Sl(t)
figure(4);
subplot 211;
pwelch(ss(1:1000));
title('DSP de Ss(t)');
subplot 212;
pwelch(sl(1:1000));
title('DSP de Sl(t)');
f=0:1:5000;
DSP_Sl_th = db(0.25*0.25*Ts*(sinc(f*Ts)).^2);
hold on;
plot((0:length(DSP_Sl_th)-1)/length(DSP_Sl_th), DSP_Sl_th, 'r');
legend('DSP expérimentale', 'DSP théorique');
ylim([-160 40]);

%% 5. Evolution du TEB en fonction du rapport Eb/N0 en dB
% 6. Ajout d'une erreur de synchronisation temporelle

% Relevé des données :
% SNR = Eb/No = Eg.^2 * sigma(ss).^2 / sigma(b).^2
% SNR varie de 0 à 10db
% Eg = 1 donc sigma(b).^2 = sigma(ss).^2 / SNR
% sigma(ss).^2 = 1
% donc sigma(b).^2 = 1/SNR

varB = zeros(1, 15);
r5 = zeros(1, 15);
r6 = zeros(1, 15);
SNR_l = ones(1, 15);
for n=1:15
    SNR_l(n) = 10.^(n/10);
    varB = 1/(2*SNR_l(n));
    sigma = sqrt(varB);
    yl = sl + (mu + sigma * randn(1,length(sl)));
    rl_t = conv(yl, ga);
    
    % Question 5
    rl_n = downsample(rl_t, Fse);
    An = rl_n;
    An(An >= 0) = 1;
    An(An < 0) = -1;
    b = An;
    b(b == -1) = 0;
    b(b == 1) = 1;
    b = b(2:end-1);
    r5(n) = TEB(sb, b);
    
     % Question 6
    rl_n = downsample(rl_t(1+0.1*Fse:end), Fse);
    An = rl_n;
    An(An >= 0) = 1;
    An(An < 0) = -1;
    b = An;
    b(b == -1) = 0;
    b(b == 1) = 1;
    b = b(2:end-1);
    r6(n) = TEB(sb, b);
end
%% Affichage
figure(5);
plot(r5);
title('TEB en fonction du SNR en db');
xlabel('SNR en db'); ylabel('TEB');
hold on
plot(r6, 'r');
%plot(0.001*ones(1,15), 'g');
plot(1/2 * erfc(sqrt(SNR_l)),'k');
legend('Sans erreur de synchronisation','Avec erreur de synchronisation', 'TEB théorique');