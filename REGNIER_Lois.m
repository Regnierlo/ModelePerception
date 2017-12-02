%1.- acquire image
A=imread(uigetimagefile());
imshow(A)
[size_y size_x s3]=size(A);
A(A<120)=0;A(A>120)=255;     % clean image a bit
%A2=A(:,:,1)+A(:,:,2)+A(:,:,3);   % carry on with binary map, no need for RGB 3 layers

%2.- scan columns and find point a with:
i=1;
all_black=1;
while all_black
	%L=A2(:,i)
    L=A(:,i);
	if (max(L)==255) 
		all_black=0; 
              end
	i=i+1;
end

b=[i-1 floor(mean(find(L==255)))];

%3.- repeat now scanning rows to find point a:
j=1;
all_black=1;
while all_black
	%L=A2(j,:);
    L=A(j,:);
	if (max(L)==255) 
		all_black=0; 
              end
	j=j+1;
end
a=[floor(mean(find(L==255))) j-1];

%4.- repeat to find c:
k=size_y;
all_black=1;
while all_black
	%L=A2(k,:);
    L=A(k,:);
	if (max(L)==255) 
		all_black=0; 
              end
	k=k-1;
end
    c=[floor(mean(find(L==255))) k+1];
    
%5.- the 4th point of interest, not to be confused with point c, the center K:
K=[231 234];   % however you find it, i just used the marker to get the coordinates

imshow(binaryImage);
title('Binary Image with Centroid Marked', 'FontSize', fontSize); 
hold on;
plot(xCentroid, yCentroid, 'r*', 'MarkerSize', 30, 'LineWidth', 2);