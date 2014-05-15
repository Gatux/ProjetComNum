%% Gabriel VERMEULEN - Maxime PETERLIN
clear all; close all;

%% Initialisation des variables

fe = 10000; % frequence d'echantillonnage : fe = 10 kHz
Ts = 0.001; % Ds = 1kSymboles/s => Ts = 1 ms
g = ones(1, Ts*fe);
ga = g;
nb_paquet = 1;
Ns = 5000;
sb = (rand(1,Ns * nb_paquet) > 0.5) * 1;
Fse = Ts * fe;
N = 512;

% BBGC additif
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

for n=1:10
    SNR = n; % en db
    

%plot(1/2 * erfc(



%%
error = 0;
for i=1:4999
    if(sb(i) ~= b(i))
        error = error +1;
    end
end
error

