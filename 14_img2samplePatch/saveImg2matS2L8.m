% @Date:   2018-08-02T13:47:35+02:00
% @Email:  chunping.qiu@tum.de
% @Last modified time: 2018-08-11T08:45:32+02:00

%correct the band order



% function: cut image into patches, and save to folders by city: image band
% input:
%         [row,col, X_u, Y_u, lat, lon, label] the row and colum , X_utm, Y_utm, of a label in image
%         img: image matrix
%         train_test: if 1, means Gt file is from train
%         imgPatchDir: dir to save produced patches
%         cityMonth: name to save the patch
%         patchHalf: (the size of patch)/2

% output:
%         numData: # of each in this saved file
%         label_RC: Label, RC of the actually used label
function [numData, label_RC] = saveImg2matS2L8(centerRCLable, img, train_test, imgPatchDir, cityMonth, patchHalf)

num = size(centerRCLable, 1) ;

y_tra = centerRCLable(:,7) ;

patchPos = centerRCLable ;


%%%%%%%%%%%%%%%%
patchSize = patchHalf*2 + 1 ;

% if sat=='l8'
%     x_tra = zeros(num,patchSize,patchSize, 19) ;
% else
x_tra = zeros(num,patchSize,patchSize, 17) ; % no guf no osm
% end

indicator = ones(num,1) ; % to indicate if nodata
clear j

% for each pixel get one patch
for j = 1: num
    
    if (round(centerRCLable(j,1)+patchHalf)>size(img,1) | round(centerRCLable(j,2)+patchHalf)>size(img,2)  | round(centerRCLable(j,1)-patchHalf)<1 | round(centerRCLable(j,2)-patchHalf)<1  )
        continue;
    end
    
    row = centerRCLable(j,1) ;
    col = centerRCLable(j,2) ;
    
    rowPatch = round((row - patchHalf):(row + patchHalf)) ;
    colPatch = round((col - patchHalf):(col + patchHalf)) ;
    
    %     if sat=='s2'
    B04 = single(img(rowPatch, colPatch, 4) )/10000.0 ;%reflectance
    B03 = single(img(rowPatch, colPatch, 3) )/10000.0 ;
    B02 = single(img(rowPatch, colPatch, 2) )/10000.0 ;
    B08 = single(img(rowPatch, colPatch, 8) )/10000.0 ;
    B11 = single(img(rowPatch, colPatch, 12) )/10000.0 ;
    B12 = single(img(rowPatch, colPatch, 13) )/10000.0 ;
    
    EVI = 2.5*(B08 - B04) ./ (B08 + 6*B04 - 7.5*B02 + 1) ; % EVI (Enhanced Vegetation Index) VALUE = 2.5*(B08 - B04) / (B08 + 6*B04 - 7.5*B02 + 1)
    MNDWI = (B03 - B11)./(B03 + B11) ;
    NDBI = (B11 - B08)./(B11 + B08) ;%https://www.sentinel-hub.com/develop/documentation/eo_products/Sentinel2EOproducts
    NDVI  = (B08 - B04) ./ (B08 + B04) ;
    BSI = (B11 + B04 - (B08 + B02) ) ./ (B11 + B04+B08 + B02) ;
    
    BRBA = B03./ B08 ;
    NBAI = (B12-B08./B02)./(B12+B08./B02) ;
    
    
    x_tra(j,:,:,11) = EVI ;
    x_tra(j,:,:,12) = MNDWI ;
    x_tra(j,:,:,13) = NDBI ;
    x_tra(j,:,:,14) = NDVI ;
    x_tra(j,:,:,15) = BSI ;
    
    x_tra(j,:,:,16) = BRBA ;
    x_tra(j,:,:,17) = NBAI ;
    
    
    x_tra(j, :,:, 1:10) = img(rowPatch, colPatch,[2,3,4,5,6,7,8,9,12,13]) ;
    %indicator(j) =  min(min(min( img(rowPatch, colPatch,:)))) ;
    
    %         x_tra(j,:,:,18) =  matGuf(rowPatchGuf, colPatchGuf) ;
    %         x_tra(j,:,:,19) =  matOsm1(rowPatchOsm1, colPatchOsm1) ;
    %         x_tra(j,:,:,20) =  matOsm2(rowPatchOsm2, colPatchOsm2) ;
    
    ind1 = find(img(rowPatch, colPatch,1)==0) ;
    %     end
    
    %
    %     if sat=='l8'
    %         R = single(img(rowPatch, colPatch, 4) ) ;
    %         NIR = single(img(rowPatch, colPatch, 5) ) ;
    %         NDVI  = (NIR - R) ./ (NIR + R) ;%https://landsat.usgs.gov/sites/default/files/documents/si_product_guide.pdf
    %
    %         B = single(img(rowPatch, colPatch, 2) ) ;
    %         EVI = 2.5*(NIR - R) ./ (NIR + 6*R - 7.5*B + 1) ; % EVI
    %
    %         B6 = single(img(rowPatch, colPatch, 6) ) ;%Shortwave Infrared 1
    %         BSI = ( (B6+R)-(NIR+B))./ ( (B6+R)+(NIR+B)) ;
    %
    %         B3 = single(img(rowPatch, colPatch, 3) ) ;
    %         B7 = single(img(rowPatch, colPatch, 7) ) ;%Shortwave Infrared 2
    %
    %         BRBA = B3./ NIR ;
    %         NBAI = (B7-NIR./B)./(B7+NIR./B) ;
    %
    %         NDBI=(B6-NIR)./(B6+NIR) ;
    %         MNDWI= (B3-B6)./(B3+B6) ;
    %
    %         x_tra(j,:,:,10) = EVI ;
    %         x_tra(j,:,:,11) = MNDWI ;
    %         x_tra(j,:,:,12) = NDBI ;
    %         x_tra(j,:,:,13) = NDVI ;
    %         x_tra(j,:,:,14) = BSI ;
    %         x_tra(j,:,:,15) = BRBA ;
    %         x_tra(j,:,:,16) = NBAI ;
    %
    %         %size(img)
    %         x_tra(j, :,:, 1:9) = img(rowPatch, colPatch,:) ;
    %
    %         x_tra(j,:,:,17) =  matGuf(rowPatchGuf, colPatchGuf) ;
    %         x_tra(j,:,:,18) =  matOsm1(rowPatchOsm1, colPatchOsm1) ;
    %         x_tra(j,:,:,19) =  matOsm2(rowPatchOsm2, colPatchOsm2) ;
    %
    %         ind1 = find(img(rowPatch, colPatch,1)==0) ;
    %
    %     end
    %     indicator(j) =  size(ind1,1) ;%if there is 0, indicatine that possible no data area
end

%exclude no data area(pixel value is 0 is 30% area)
indexOut2 = find(indicator> (patchSize*patchSize)*0.1 ) ; clear indicator
inform='indexOut2 should be empty'
size(indexOut2)

%exclude no data area(pixel value is 0)
%indexOut2 = find(indicator<0.000001) ; clear indicator

% some points outside the image
indexOut1 = find(round(centerRCLable(:,1)+patchHalf)>size(img,1) | round(centerRCLable(:,2)+patchHalf)>size(img,2)  | round(centerRCLable(:,1)-patchHalf)<1 | round(centerRCLable(:,2)-patchHalf)<1  ) ;
excludedIndex = unique([indexOut1; indexOut2]) ;

y_tra(excludedIndex,:) = [] ;
x_tra(excludedIndex,:,:,:) = [] ;
patchPos(excludedIndex,:) = [] ;

clear centerRCLable

if size(x_tra,1)==0
    info='all excluded'
    numData=zeros(1,17);
    return
end



%normalization be done later when training
% if sat=='s2'
for j = 1:10
    x_tra(:, :,:,j)  = single( x_tra(:, :,:,j)/10000.0   ) ;
end

for j = 11:size(x_tra,4)%1:5, indices not normalized because it has physical meaning
    x_tra(:, :,:,j)  = single( mat2gray(x_tra(:, :,:,j)) ) ;
end

% end

% if sat=='l8'
%     %   for j = 6:14
%     %     %x_tra(:, :,:,j)  = single( mat2gray(x_tra(:, :,:,j) , [0 double(max(max(img(:,:,j-5))))]) ) ;
%     %   end
%     for j = 10:size(x_tra,4)
%         x_tra(:, :,:,j)  = single( mat2gray(x_tra(:, :,:,j)) ) ;
%     end
% end

file0=[imgPatchDir  cityMonth] ;

if train_test==1 % there are 8 folds in the training samples, save them into 8 parts class wisely
    numFold=8 ;
    numData = split2nFold(x_tra, y_tra, patchPos, numFold, file0) ;
    
elseif train_test==0 % there are 1 fold in the test samples, save them into 1 part
    matName = [file0 '_' num2str(9) '.mat'] ;
    save(matName,'x_tra','y_tra','-v7.3') ;
    matName = [file0 '_' num2str(9) 'patchPos.mat'] ;
    save(matName, 'patchPos','-v7.3') ;
    
    for j=1:17
        tmp=find(patchPos(:,7)==j);
        numData(1,j) =  size(tmp, 1) ;%# sample of each class
    end
    
else%save all the samples, together
    
    matName = [file0 '_all'  '.mat'] ;
    save(matName,'x_tra','y_tra','-v7.3') ;
    matName = [file0 '_all' 'patchPos.mat'] ;
    save(matName, 'patchPos','-v7.3') ;
    
    for j=1:17
        tmp=find(patchPos(:,7)==j);
        numData(1,j) =  size(tmp, 1) ;%# sample of each class
    end
end

%in ordor to save the used ground truth as geotiff
label_RC=patchPos(:,7:9);


end
