function [rappel, precision] = test()
%     % on part de zero afin de s'assurer que toutes les variables et toutes
%     % les images soient r�initialis�es
        clear all; close all;
%     % Le chemin relation de la base de r�f�rence
%     img_path = './dbr/';
% 
%     % les noms des images de r�f�rence
%     img_list = glob([img_path, '*.gif']); 
% 
%     % nombre d'images de r�f�rence
%     num_ref = numel(img_list); 
% 
%     % par objet (image de ref) il y a 19 images requ�te
%     found_max = 19; 
% 
%     % matrice de rappel :chaque ligne correspond � la courbe de rappel
%     % d'une image de r�f�rence
%     rappel = zeros(num_ref, found_max ); 
% 
%     % matrice de pr�cision
%     precision = zeros(num_ref, found_max ); 

    %for im = 1:numel(img_list);
        % TODO
    %end
    
    %nombre de pts � prendre pour le contour
    n = 2000;
    
    %on lit l'image choisie par l'utilisateur
    I = imread(uigetimagefile());
    
    %on r�cup�re sa taille via les variables m lignes et n colonnes
    [ligne,colonne]=size(I);
    
    %appel de la fonction centre avec l'image I en param�tre
    [centrex centrey] = centre(I);
    
    %appel de la fonction contour avec l'img I en param�tre et les
    %centres x et y ainsi que le nb de pts pour le contour de l'img
    contourM = contour(I,centrex,centrey,n);
    
    %appel de la fonction de la transform�e de fourier 1D
    F = TF1D(contourM);
    
    %appel de la fonction d'affichage
    affiche(I,centrex,centrey,contourM,F);
end

%%
%Fonction permettant de trouver le centre d'un objet dans une image
function [x,y] = centre(I)
    %binarisation de l'image 
    Ibw = imbinarize(I);
    
    %remplissage des "trous" pour permettre une lecture de l'image sans
    %d�faut, cela am�liore la qualit� du contour
    Ibw = imfill(Ibw,'holes');
    
    %permet de labeliser une image
    Ilabel = bwlabel(Ibw);
    
    %permet de calculer le centre d'un objet labelis� 
    stat = regionprops(Ilabel,'centroid');
   
    %on l'affiche et on le maintien car cela permettra pour plus tard de
    %superposer le centre dans la fonction affichage
    imshow(I); hold on;
    
    %permet de faire une approximation � 1 afin d'avoir un pixel d�fini 
    x = floor(stat(1).Centroid(1));
    y = floor(stat(1).Centroid(2));
end

%%
%Fonction permettant de calculer les contours d'une image en partant de
%son centre
function [contourM] = contour(I,centrex,centrey,n)
%   definition des variables : 
%   angle = angle qui d�fini le d�calage entre chaque point
%   x1|y1 = centre de l'img
%   x2|y2 = centre du point qui d�fini un contour (intersection entre blanc
%   et noir)
%   contourM = tableau 2D qui permet de r�cup�rer les coordonn�es de x2|y2
%   afin de les relier gr�ce � la fonction de tracage
    
    contourM = zeros(2,n);
    
    for i=1:n  
        
        %calcul du coef directeur (� revoir parce que je n'arrive pas �
        %tracer l'ensemble des traits, genre �a va de 3pi/2 � 11pi/6 et je
        %ne sais pas pourquoi... 
        alpha = tan(rad2deg(i/2*n*pi));
        
        %le 1 est arbitraire car coefDirecteur = y / tan(alpha), or ici y
        %est le pdist2([centrex, centrey], [???,???]) en gros c'est la
        %droite qui fait l'angle alpha avec l'abscisse/ordonn�e suivant le
        %cadran du cercle trigo... Donc ici c'est le point obscure qui faut
        %travailler mais l� il est 3h30 du mat et je vais dormir lel
        coefD = 1/alpha;
        %fin du calcul du coef directeur
         
        %appel de la fonction bresenham
        [x2,y2] = bresenham(I,coefD,centrex,centrey);
        
        %on met dans la 1e ligne de la matrice contour m : l'angle �
        %l'indice i 
        % et dans la 2e ligne : 
        contourM(1,i) = i/n*360;
        contourM(2,i) = pdist2([centrex,centrey],[x2,y2],'euclidean');
        
        %Affichage des traits trac�s via les angles + vecteurs associ�s �
        %chaques traits (cf function line between 2 pts)
        A = [centrex y2];
        B = [centrey x2];
        plot(A,B,'b*');
        plot(centrex, centrey,'r+');
        line(A,B);
    end
    
    %affichage de l'image avec l'ensemble des trac�s
    figure,imshow(I);hold on;
end

%%
%Fonction permettant de d�terminer le contour d'un objet
function [x,y] = bresenham(I,d,midx,midy)    
     S=2*d-1;
     inc1=2*d;
     inc2=2*d-2;
     y=midy;
     x=midx;
     
     %tant que les coordonn�es du pixel sont diff�rentes de 0, � savoir
     %blanc
     while I(x,y)~=0
         if S < 0
             S = S + inc1;
         else
             S = S + inc2;
             y = y + 1;
         end
         x=x+1;
     end
end

%%
%Fonction permettant de calculer la TF 1D du contour
function [F] = TF1D (contourM)
    F= fft(contourM);
    %F= fft(contourM(1,:),contourM(2,:));
end

%%
%Fonction d'affichage
function [] = affiche(I,centrex,centrey,contourM,F)
    %centre
    subplot(3,5,1)
    imshow(I);hold on;
    %Affichage du centre via une croix rouge sur l'image
    plot(centrex, centrey,'r+');
    title('Objet de r�f�rence')

    %contours
    subplot(3,5,[2 3])
    plot(contourM(1,:),contourM(2,:));
    title('Coordonn�es polaire')
    xlabel('Angles')
    ylabel('Rayon')
    
    %FFT
    subplot(3,5,[4 5])
    plot(F);
    title('Calcul de TF 1D')
    xlabel('Fr�quences')
    ylabel('Amplitude')
    
    %TOP5 score
        %1
        subplot(3,5,6)
        imshow(I);
        title('Top 1')
        %2
        subplot(3,5,7)
        imshow(I);
        title('Top 2')
        %3
        subplot(3,5,8)
        imshow(I);
        title('Top 3')
        %4
        subplot(3,5,9)
        imshow(I);
        title('Top 4')
        %5
        subplot(3,5,10)
        imshow(I);
        title('Top 5')
        
    %courbe precision/rappel
    subplot(3,5,[11 12 13])
    plot(1,1);
    title('Courbe de la pr�cision sur le rappel')
    xlabel('Pr�cision')
    ylabel('Rappel')
    
    %courbe precision moyenne/rappel
    subplot(3,5,[14 15])
    plot(1,1);
    title('Courbe de la pr�cision moyenne sur le rappel')
    xlabel('Pr�cision')
    ylabel('Rappel')
end