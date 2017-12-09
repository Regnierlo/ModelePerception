function [rappel, precision] = test()
%     % on part de zero afin de s'assurer que toutes les variables et toutes
%     % les images soient réinitialisées
        clear all; close all;
%     % Le chemin relation de la base de référence
%     img_path = './dbr/';
% 
%     % les noms des images de référence
%     img_list = glob([img_path, '*.gif']); 
% 
%     % nombre d'images de référence
%     num_ref = numel(img_list); 
% 
%     % par objet (image de ref) il y a 19 images requête
%     found_max = 19; 
% 
%     % matrice de rappel :chaque ligne correspond à la courbe de rappel
%     % d'une image de référence
%     rappel = zeros(num_ref, found_max ); 
% 
%     % matrice de précision
%     precision = zeros(num_ref, found_max ); 

    %for im = 1:numel(img_list);
        % TODO
    %end
    
    %nombre de pts à prendre pour le contour
    n = 50;
    
    I = imread(uigetimagefile());
    [centrex centrey] = centre(I);
    contourM = contour(I,centrex,centrey,n);
    F = TF1D(contourM);
    affiche(I,centrex,centrey,contourM,F);
end

%%Fonction permettant de trouver le centre d'un objet dans une image
function [x,y] = centre(I)
    Ibw = im2bw(I);
    Ibw = imfill(Ibw,'holes');
    Ilabel = bwlabel(Ibw);
    stat = regionprops(Ilabel,'centroid');
    imshow(I); hold on;
    x = floor(stat(1).Centroid(1));
    y = floor(stat(1).Centroid(2));
end

%%Fonction permettant de calculer les contours d'une image en partant de
%%son centre
function [contourM] = contour(I,centrex,centrey,n)
    angle = rad2deg((2*pi)/n);
    pente = angle;
    contourM = zeros(2,n);
    for i=1:n
        if pente >= tan(rad2deg(pi/2)) && pente <= tan(rad2deg(pi))
            [x,y] = bresenhamHD(I,pente,centrex,centrey,0);
            contourM(1,i) = pente;
            contourM(2,i) = pdist2([centrex,centrey],[x,y],'euclidean');
        end
        pente = pente + angle;
    end
    contourM;
end

%%Fonction permettant de tracer une ligne
function [x,y] = bresenhamHD (I,d,midx,midy,posi)
    S=2*d-1;
    inc1=2*d;
    inc2=2*d-2;
    y=midy;
    x=midx;
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

%%Fonction permettant de calculer la TF 1D du contour
function [F] = TF1D (contourM)
    F= fft(contourM);
end

%%Fonction d'affichage
function [] = affiche(I,centrex,centrey,contourM,F)
    %centre
    subplot(3,5,1)
    imshow(I);hold on;
    %Affichage du centre via une croix rouge sur l'image
    plot(centrex, centrey,'r+');
    title('Objet de référence')

    %contours
    subplot(3,5,[2 3])
    plot(contourM);
    title('Coordonnées polaire')
    xlabel('Angles')
    ylabel('Rayon')
    
    %FFT
    subplot(3,5,[4 5])
    plot(F);
    title('Calcul de TF 1D')
    xlabel('Amplitude')
    ylabel('Fréquences')
    
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
    title('Courbe de la précision sur le rappel')
    xlabel('Précision')
    ylabel('Rappel')
    
    %courbe precision moyenne/rappel
    subplot(3,5,[14 15])
    plot(1,1);
    title('Courbe de la précision moyenne sur le rappel')
    xlabel('Précision')
    ylabel('Rappel')
end