%read a geotiff;
%get the projection and coordinates (transformation);
%mark some points (from kml) on the plot and save figure

% rmpath('E:\OtherDisk\DL1.0\0LCZgit\Analysis\util')
addpath('.\kml2struct')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
f = 'E:\sampleData4test\';
%test data here:https://drive.google.com/drive/folders/1EPsBIkESTRdo8-wh3eNvAQeZ4z9yFa8o?usp=sharing
city = 'LCZ42_21711_Nairobi' ;

%s2 data
imgFile= [f city '.tif'];

%get the pixel values
[img, ~] = geotiffread(imgFile) ;

%only use the rgb bands
img = img(:,:,[4,3,2]) ;

%get the projection file
info_img = geotiffinfo(imgFile) ;

%band strech for visuaization
for j = 1:3
     img(:,:,j) = rgbBandStrech(img(:,:,j));    
end

%read the polygons from kml files
B_points = kml2struct( [f city '_check_B.kml'] ) ;

%get the center points of the polygons
for j =1:size(B_points,2)
    B_Lola(j,:)=mean(B_points(j).BoundingBox) ;
end

%get the utm X Y from the longitude and latitude
[X_u, Y_u] = projfwd(info_img, B_Lola(:,2), B_Lola(:,1)) ;

%get the r c in the image
[Row, Col] = map2pix(info_img.RefMatrix, X_u, Y_u) ;


figure
im = image(mat2gray(img),'CDataMapping','scaled');
axis equal
axis off

sz = 50;
lw = 1;
hold on
scatter(Col, Row,  sz, '+',...
               'r',...
              'LineWidth',lw)
          
export_fig([f city '_marked'], '-pdf', "-q101", "-transparent");
