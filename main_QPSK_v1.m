%% Gabriel VERMEULEN - Maxime PETERLIN
clear all; close all;

%% Initialisation des variables

Ts = 0.001;     % Temps symbole
Fe = 10000;     % Fr�quence d'�chantillonnage
F0 = 2500;      % Fr�quence de la porteuse
Tg = 4*Ts;      % Temps de propagation de groupe
alpha = 0.5;    % Facteur de roll-off
Ns = 5000;      % Nombre de symboles par paquet
nbPkt = 1;      % Nombre de paquets
Fse = Ts*Fe;    % Facteur de sur-�chantillonnage
N = 512;        % Nombre de points sur lesquels sont les TF sont faites
M = 4;          % Nombre de symboles dans la constellation

% BBGC additif
mu = 0;         % Esp�rance
sigma = 0;      % Variance

% Fonction de transfert
g = rcosfir(alpha, 4, Fse, Ts, 'sqrt');
g = g/(sum(g));


%% 2. Impl�mentation d'un modulateur et d'un d�modulateur

pkt = randi([0 1], Ns, M/2);            % Cr�ation d'un paquet contenant les bits � encoder en symboles
symb_tx = bi2de(pkt)';                  % Conversion bits->symbole

% Modulateur
s_s = pskmod(symb_tx, M, pi/4);

% D�modulateur
symb_rx = pskdemod(s_s, M, pi/4);


%% 3. V�rification du fonctionnement de la cha�ne de communication en BDB

%% Emetteur

% Association bits->symbole
pkt_tx = randi([0 1], Ns * nbPkt, M/2);             % Cr�ation d'un paquet contenant les bits � encoder en symboles
symb_tx = bi2de(pkt_tx)';                           % Conversion bits->symbole
pkt_tx = pkt_tx';
pkt_tx = pkt_tx(:)';

% Modulateur
phase_tx = pskmod(symb_tx, M, pi/4);
s_s = upsample(phase_tx, Fse);

% Filtre de mise en forme
g = rcosfir(alpha, 4, Ts*Fe, Ts, 'sqrt');
g = g/(sum(g));
s_l = conv(s_s, g);

%% Canal
y_l = s_l + (mu + sigma * randn(1, length(s_l)));

%% R�cepteur

% Filtre de r�ception
r_l = conv(y_l, g);

% Echantillonnage au rythme Ts
r_ln = downsample(r_l, Fse);

% D�modulateur
symb_rx = pskdemod(r_ln, M, pi/4);
symb_rx = symb_rx(9:end-8);

% D�cision
pkt_rx = de2bi(symb_rx)';
pkt_rx = pkt_rx(:)';

disp('Taux d''Erreur Binaire en BDB : ');
disp(sum((pkt_rx == pkt_tx)==0));


%% 8. Emission sur un canal � bande passante infinie

% G�n�ration de la porteuse complexe
nbTs = Ns * Ts;
t = 0:nbTs/(length(s_l)-1):nbTs;
carrier = exp(1i*2*pi*F0*t);
s = real(s_l.*carrier);

% Canal � bande passante infinie
y = filter([1], [1], s) + (mu + sigma * randn(1, length(s_l)));
figure(6);
plot(y)


%% 10. M�thode de reconstruction de l'enveloppe complexe au r�cepteur par projections orthogonales

%% Recepteur

% Etage RF->BDB
nbTs = Ns * Ts;
t = 0:nbTs/(length(s_l)-1):nbTs;
cosine = 2*cos(2*pi*F0*t);
sine = -2*sin(2*pi*F0*t);

y_i = y.*cosine;
y_q = y.*sine;

y_l = y_i + 1i*y_q;

% Filtre de r�ception
r_l = conv(y_l, g);

% Echantillonnage au rythme Ts
r_ln = downsample(r_l, Fse);

% D�modulateur
symb_rx = pskdemod(r_ln, M, pi/4);
symb_rx = symb_rx(9:end-8);

% D�cision
pkt_rx = de2bi(symb_rx)';
pkt_rx = pkt_rx(:)';

disp('Taux d''Erreur Binaire avec la m�thode par projections orthogonales : ');
disp(sum((pkt_rx == pkt_tx)==0)/length(pkt_tx));

%% Figures de r�sultats

% 1. Trac� de la r�ponse impulsionnelle et du module de la fonction de transfert du filtre en racine de cosinus sur-�lev�
figure(1)

subplot 211
impz(g);        % R�ponse du filtre � un dirac
title('R�ponse impulsionnelle de g(t)');

hold on;

subplot 212
plot(abs(g))    % Module de la fonction de transfert
title('Module de la fonction de transfert de g(t)');


% 4. Diagramme de l'oeil de s_l(t)
eyediagram(s_l(41:Ns/5), Ts*Fe);


% 5. Diagramme de l'oeil de r_l(t)
eyediagram(r_l(81:Ns/5), Ts*Fe);


% 6. Trac�s des constellations de s_l(t) et de r_l[n]
figure(4)

subplot 121
plot(s_l, 'r.', 'markersize', 1); 
title('Trac� de la constellation de s_l(t)');
axis([-0.5, 0.5, -0.5, 0.5]) 

hold on

subplot 122
plot(r_l, 'r.', 'markersize', 1); 
title('Trac� de la constellation de r_l[n]');
axis([-1.5, 1.5, -1.5, 1.5]) 


% 7. Allure de la partie r�elle de r_l(t)
figure(5);
r = 81;
n = 50 * Ts * Fe;
plot((0:n)/Fe, real(r_l(r:n+r)), '-+');
title('Allure temporelle du signal r_l(t)');


% 9. Comparaison entre la DSP th�orique et la DSP exp�rimentale
DSP_th_S=(1/(4*Ts))*(abs(fft(g, N)).^2+abs(fft(g, N)).^2);
DSP_S=fftshift(abs(fft(s_l, N)).^2);
plot((0:N-1)/N-0.5, DSP_S, 'r');
hold on
plot((0:N-1)/N-0.5, fftshift(DSP_th_S));
title('Comparaison entre la DSP th�orique et la DSP exp�rimentale');
xlabel('Fr�quence normalis�e');
ylabel('Amplitude');
legend('DSP exp�rimentale', 'DSP th�orique');


%% 11. Trac� et interpr�tation de la DSP de y_l(t) arp�s le m�langeur sur la voie en phase
figure(6)
DSP = fftshift(pwelch(y_i));
N = length(DSP);
plot((0:N-1)/N-0.5, DSP);
title('Voie en phase');
xlabel('Fr�quence normalis�e');
ylabel('Amplitude');