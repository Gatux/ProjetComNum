%% Gabriel VERMEULEN - Maxime PETERLIN
clear all; close all;

%% Initialisation des variables

fe = 10000; % frequence d'echantillonnage : fe = 10 kHz
Ts = 0.001; % Ds = 1kSymboles/s => Ts = 1 ms
g = ones(1, Ts*fe);
nb_paquet = 1;
Ns = 5000;
Sb = (rand(1,Ns * nb_paquet) > 0.5) * 1;
Fse = Ts * fe;
N = 512;

%% Emetteur

% Association bits->Symbole
Ss = Sb;
Ss(Ss == 0) = -1;

Ss = upsample(Ss, Fse);

Sl = conv(Ss, g)
plot(Sl(1:((50*Ts-(1/fe))*fe)));

%% Canal

%% Récepteur

%% Figures des résultats