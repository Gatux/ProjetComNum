%% Gabriel VERMEULEN - Maxime PETERLIN
clear all; close all;

%% Initialisation des variables

fe = 10000; % frequence d'echantillonnage : fe = 10 kHz
Ts = 0.001; % Ds = 1kSymboles/s => Ts = 1 ms
g = ones(1, Ts*fe);
g = g/(1/sqrt(0.1)); % On normalise le fitre de tel façon que Eg = 1
ga = g;
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

ss = upsample(ss, Fse);

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

%% 3. Allure de rl(t) pour t=[0, 50*Ts - Te] en sortie du filtre adapté (non normalisé)
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

%% 5. Evolution du TEB en fonction du rapport Eb/N0 en dB
% Relevé des données :
% SNR = Eb/No = Eg.^2 * sigma(ss).^2 / sigma(b).^2
% SNR varie de 0 à 10db
% Eg = 1 donc sigma(b).^2 = sigma(ss).^2 / SNR
% sigma(ss).^2 = 1
% donc sigma(b).^2 = 1/SNR

varB = zeros(1, 10);
for n=1:10
    SNR_l = 10.^(n/10);
    varB(n) = 1/(SNR_l);
end

% Résultats :
r = [0.1458 0.1356 0.1054 0.0758 0.0546 0.0424 0.0232 0.0178 0.0078 0.0036 ];

plot((1:10), r);
title('TEB en fonction du SNR en db');
xlabel('SNR en db'); ylabel('TEB');

%%
error = 0;
for i=1:4999
    if(sb(i) ~= b(i))
        error = error +1;
    end
end
error
