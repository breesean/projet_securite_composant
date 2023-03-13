% Projet Sécurité des Composants
% ENSTA Bretagne - S2 - Mars 2023
% Auteur : Antoine BREESE - FISE24 CSN 

clear all;
clc;
close all;

warning off;

%%
% Enregistrement des fichiers CSV
data_cto = csvread('cto.csv');
data_key = csvread('key.csv');
data_pti = csvread('pti.csv');
data_traces = csvread('traces.csv');

% Enregistrement des matrices dans des fichiers MAT
save('cto.mat', 'data_cto');
save('key.mat', 'data_key');
save('pti.mat', 'data_pti');
save('traces.mat', 'data_traces');

%%
Nt = 20000; %Nombre de traces utilisées
%Chargement des fichiers.mat
load('cto.mat');
load('key.mat');
load('pti.mat');
load('traces.mat');

key = data_key(1,:);

%%
%Q1 - Tracé d'une courbe de consommation

L1 = data_traces(1,:);
figure
plot(L1)
title("Affichage de la première trace de courant")
xlabel('premier échantillon')
ylabel('courant')

%début du chiffrement : 797 | fin du chiffrement : 3285

%% 
%Q2 - Tracé de la courbe moyenne de consommation

L1_mean = mean(data_traces,1);
figure
plot(L1_mean)
title("Affichage de la courbe moyenne de courant")
xlabel('Moyenne des échantillons')
ylabel('Courant')

%%
%Q4 Implémentation AES - Représentation 4x4 de la clé attendue par
%l'algorithme d'inversion

S_box = gen_s_box;

all_w = keysched2(uint32(reshape(key,[],4)));

w10_attendue = all_w(:,:,11);

disp('w10 attendue : ')

disp(w10_attendue);

%%
shiftrow=reshape([1,6,11,16,5,10,15,4,9,14,3,8,13,2,7,12],4,4);

SBox=[99,124,119,123,242,107,111,197,48,1,103,43,254,215,171,118,202,130,201,125,250,89,71,240,173,212,162,175,156,164,114,192,183,253,147,38,54,63,247,204,52,165,229,241,113,216,49,21,4,199,35,195,24,150,5,154,7,18,128,226,235,39,178,117,9,131,44,26,27,110,90,160,82,59,214,179,41,227,47,132,83,209,0,237,32,252,177,91,106,203,190,57,74,76,88,207,208,239,170,251,67,77,51,133,69,249,2,127,80,60,159,168,81,163,64,143,146,157,56,245,188,182,218,33,16,255,243,210,205,12,19,236,95,151,68,23,196,167,126,61,100,93,25,115,96,129,79,220,34,42,144,136,70,238,184,20,222,94,11,219,224,50,58,10,73,6,36,92,194,211,172,98,145,149,228,121,231,200,55,109,141,213,78,169,108,86,244,234,101,122,174,8,186,120,37,46,28,166,180,198,232,221,116,31,75,189,139,138,112,62,181,102,72,3,246,14,97,53,87,185,134,193,29,158,225,248,152,17,105,217,142,148,155,30,135,233,206,85,40,223,140,161,137,13,191,230,66,104,65,153,45,15,176,84,187,22];

invSBox = zeros(1, 256);
for i = 1:256
    invSBox(SBox(i)+1) = i-1;
end

Weight_Hamming_vect =[0 1 1 2 1 2 2 3 1 2 2 3 2 3 3 4 1 2 2 3 2 3 3 4 2 3 3 4 3 4 4 5 1 2 2 3 2 3 3 4 2 3 3 4 3 4 4 5 2 3 3 4 3 4 4 5 3 4 4 5 4 5 5 6 1 2 2 3 2 3 3 4 2 3 3 4 3 4 4 5 2 3 3 4 3 4 4 5 3 4 4 5 4 5 5 6 2 3 3 4 3 4 4 5 3 4 4 5 4 5 5 6 3 4 4 5 4 5 5 6 4 5 5 6 5 6 6 7 1 2 2 3 2 3 3 4 2 3 3 4 3 4 4 5 2 3 3 4 3 4 4 5 3 4 4 5 4 5 5 6 2 3 3 4 3 4 4 5 3 4 4 5 4 5 5 6 3 4 4 5 4 5 5 6 4 5 5 6 5 6 6 7 2 3 3 4 3 4 4 5 3 4 4 5 4 5 5 6 3 4 4 5 4 5 5 6 4 5 5 6 5 6 6 7 3 4 4 5 4 5 5 6 4 5 5 6 5 6 6 7 4 5 5 6 5 6 6 7 5 6 6 7 6 7 7 8];

w10_calculee = uint32(zeros(1,16)); %sera remplie au fur et à mesure avec les bonnes hypothèses de clef


%%
%Le code final pour toutes les sous clefs
%itérer sur chacune des 16 colonnes de la matrice
figure
for i = 1:16 
    assumption_etendue = repmat(linspace(0, 255, 256), Nt, 1);
    
    %Calcul de Z
    Z0 = uint8(repmat(data_cto(:,shiftrow(i)),1,256));

    cto_etendue = repmat(data_cto(:,i),1,256);

    Z1 = uint8(bitxor(cto_etendue, assumption_etendue));
    
    Z3 = uint8(invSBox(Z1+1)); %décalage car indice différent en Matlab
    
    %Poids de Hamming
    
    HW = uint8(Weight_Hamming_vect(bitxor(Z0,Z3)+1));
    
    %Calcul de la matrice de correlation
    L = data_traces(:, 3065:3268); %on restreint les données au dernier round
    
    cor=corr(single(HW),L);   
    
    % -> Calcul de meilleur coefficient de correlation
    %    RK maximum correlation en valeur absolue
    %    IK index des cles asssociees
    [RK,IK] = sort(max(abs(cor),[],2),'descend');
    sprintf('Sous clef  (%d) : meilleur candidat : k = %d',i,IK(1)-1);
    best_candidate=IK(1)-1;

    %On stocke la valeur dans la matrice de cle estimée

    w10_calculee(i)=best_candidate;
    
    % -> Correlation du meilleur candidat en rouge
    
    subplot(4,4,i);
    plot((0:size(cor,2)-1),cor(IK(1),:),'r')
    hold on
    if IK(1)==1   
        plot((0:size(cor,2)-1),cor(2:end,:),'b')
    else
        if IK(1)==16
            plot((0:size(cor,2)-1),cor(1:end-1,:),'b')
        else
            plot((0:size(cor,2)-1),cor(1:IK(1)-1,:),'b')
            plot((0:size(cor,2)-1),cor(IK(1)+1:end,:),'b')
        end
    end
        title(sprintf('Sous clef  (%d) : k = %d',i,IK(1)-1));

end

disp("W10 calculée :")
disp(reshape(w10_calculee,4,4));
%close all %mettre en commentaire pour afficher les graphiques

%%
% Q9 - Détermination de l'entropie de devinette

%Faire varier Nt
for Nt = 11900:-10:11800
    data_cto_nt = data_cto(1:Nt,:);
    data_traces_nt = data_traces(1:Nt,:);

    %figure
    for i = 1:16 
        assumption_etendue = repmat(linspace(0, 255, 256), Nt, 1);
        
        %Calcul de Z
        Z0 = uint8(repmat(data_cto_nt(:,shiftrow(i)),1,256));
    
        cto_etendue = repmat(data_cto_nt(:,i),1,256);
    
        Z1 = uint8(bitxor(cto_etendue, assumption_etendue));
        
        Z3 = uint8(invSBox(Z1+1)); %décalage car indice différent en Matlab
        
        %Poids de Hamming
        
        HW = uint8(Weight_Hamming_vect(bitxor(Z0,Z3)+1));
        
        %Calcul de la matrice de correlation
        L = data_traces_nt(:, 3065:3268); %on restreint les données au dernier round
        
        cor=corr(single(HW),L);   
        
        % -> Calcul de meilleur coefficient de correlation
        %    RK maximum correlation en valeur absolue
        %    IK index des cles asssociees
        [RK,IK] = sort(max(abs(cor),[],2),'descend');
        sprintf('Sous clef  (%d) : meilleur candidat : k = %d',i,IK(1)-1);
        best_candidate=IK(1)-1;
    
        %On stocke la valeur dans la matrice de cle estimée
    
        w10_calculee(i)=best_candidate;
        
        % -> Correlation du meilleur candidat en rouge
        
        %subplot(4,4,i);
        %plot((0:size(cor,2)-1),cor(IK(1),:),'r')
        hold on
        if IK(1)==1   
            %plot((0:size(cor,2)-1),cor(2:end,:),'b')
        else
            if IK(1)==16
                %plot((0:size(cor,2)-1),cor(1:end-1,:),'b')
            else
                %plot((0:size(cor,2)-1),cor(1:IK(1)-1,:),'b')
                %plot((0:size(cor,2)-1),cor(IK(1)+1:end,:),'b')
            end
        end
            %title(sprintf('Sous clef  (%d) : k = %d',i,IK(1)-1));
    
    end
    
    if reshape(w10_calculee,4,4) == w10_attendue
        fprintf('Nt = (%d) : clef trouvée avec succès !\n', Nt);
    else 
        fprintf('Nt = (%d) : échec !\n', Nt);
    end
end

