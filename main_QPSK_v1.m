%% Gabriel VERMEULEN - Maxime PETERLIN
clear all; close all;

%% Etude th�orique

% 1. Fonctionnement d'un modulateur et d'un d�modulateur QPSK
%       Pour tout k>=1, le modulateur va d�phaser la porteuse en fonction
%       du k-i�me symbole � encoder, en prendre les Ts premi�res secondes,
%       puis va reporter ce signal dans le signal � envoyer entre les
%       instant (k-1)Ts et kTs
%       
%       Le d�modulateur va faire l'�tape inverse en analysant les phases
%       des signaux r�cup�r�s entre les instants (k-1)Ts et Ts du signal
%       r�ceptionn� pour tout k>=1.
%       Il fait ensuite la correspondance entre ces phases et les symboles.

% 2. Fonction de transfert
%       A enlever, mais voir : http://www.scicos.org/ScicosModNum/modnum_web/src/modnum_422/interf/scicos/help/fr/htm/SRRCF_c.htm

% 3. 

%% Initialisation des variables

Ts = 0.001;     % Temps symbole
Fe = 10000;     % Fr�quence d'�chantillonnage
F0 = 2500;      % Fr�quence de la porteuse
Tg = 4*Ts;      % Temps de propagation de groupe
alpha = 0.5;    % Facteur de roll-off
Ns = 5000;      % Nombre de symboles par paquet
Fse = Ts*Fe;    % Facteur de sur-�chantillonnage
N = 512;        % Nombre de points sur lesquels sont les TF sont faites
M = 4;          % Nombre de symboles dans la constellation

% BBGC additif
mu = 0;         % Esp�rance
sigma = 0;      % Variance

%% 1. Trac� de la r�ponse impulsionnelle et du module de la fonction de transfert du filtre en racine de cosinus sur-�lev�

% Fonction de transfert
g = rcosfir(alpha, 1, [], Ts, 'sqrt');

figure(1)
subplot 211
impz(g);        % R�ponse du filtre � un dirac
hold on;
subplot 212
plot(abs(g))    % Module de la fonction de transfert


%% 2. Impl�mentation d'un modulateur et d'un d�modulateur

pkt = randi([0 1], Ns, M/2);            % Cr�ation d'un paquet contenant les bits � encoder en symboles
symb_tx = bi2de(pkt)';                  % Conversion bits->symbole


% Modulateur
s_s = pskmod(symb_tx, M, pi/4);

% D�modulateur
symb_rx = pskdemod(s_s, M, pi/4);


%% 3. V�rification du fonctionnement de la cha�ne de communication en BDB

% Association bits->symbole
pkt = randi([0 1], Ns, M/2);            % Cr�ation d'un paquet contenant les bits � encoder en symboles
symb_tx = bi2de(pkt)';                  % Conversion bits->symbole

% Modulateur
phase_tx = pskmod(symb_tx, M, pi/4)
s_s = real(phase_tx)

% % G�n�ration du signal s_s
% t = 0:Ts;
% carrier = exp(i*2*pi/Ts*t)
% s_s = phase_tx'*carrier;
% s_s = s_s';
% s_s = s_s(:)';

% Filtre de mise en forme
g = rcosfir(alpha, Tg/Ts, [], Ts, 'sqrt');
s_l = conv(s_s, g);

% Filtre de r�ception
r_l = conv(s_l, g);

% Echantillonnage au rythme Ts
% r_ln = downsample(r_l, 1);
% plot(r_ln)

% symb_tx
% symb_rx = pskdemod(r_l, M, pi/4)
% length(symb_rx)
% length(symb_tx)
% sum( (symb_rx == symb_tx) == 0 )