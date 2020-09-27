% @Date:   2018-08-02T13:42:51+02:00
% @Email:  chunping.qiu@tum.de
% @Last modified time: 2018-10-27T17:04:07+02:00



% function: cut image into patches, and save to folders by city
% input:
%         fileImg: image dir
%         roiDir: LCZ dir
%         city: city name
%         patchHalf: (the size of patch)/2
%         imgPatchDir0: dir to save produced patches
%         train_test: if 1, means Gt file is from train
% output:
%         excInfo:

function excInfo= cutPatch2Mat(fileImg, roiDir, city, patchHalf, imgPatchDir0, train_test)

idx=find(city=='_') ;
city0=city(idx(end)+2:end)
fileROI = [roiDir '/'] ;

indexTmp = find(fileImg == '_') ;
Season = fileImg(indexTmp(end)+1:(end-4)) ;
cityMonth = [city '_' Season] ;

imgPatchDir = [imgPatchDir0 city '/'] ;
mkdir(imgPatchDir)

try
  if train_test==1
    roiF = dir([fileROI '*' city0 '_lcz_GT_train.tif']) ;

  elseif train_test==0
    roiF = dir([fileROI '*' city0 '_lcz_GT_test.tif']) ;

  else
    roiF = dir([fileROI '*' city0 '_lcz_GT.tif']) ;

  end

    display("Gt file: ")
    display(roiF)

    lczF =  [fileROI roiF(1).name] ;

    infolcz = geotiffinfo(lczF) ;
    [lcz, Rlcz] = geotiffread(lczF) ;

catch
    Info = 'lczF open failed.'
    return
end


class = unique(lcz)
class(find(class==0)) = [];
class(find(class==-99999)) = [];

% tmpIndex = find(class>100) ;
% class(tmpIndex) = class(tmpIndex)-90 ;
allClass = [1:10, 11:17, 101:107] ;
% % class = int( class) ;
if ~isempty(setdiff(class, allClass))
    Info = ['lcz wrong labels']
    excInfo = 0
    return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
    infoImg = geotiffinfo(fileImg) ;
    [img, Ref] = geotiffread(fileImg) ;

    img0 = img ;%img0 as a indicator aboout the nodata area later
    clear img;

catch
    Info = ['image open failed:' fileImg]
    excInfo = 0
    return
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

info='gt from LCZ geotiff !!!'
centerRCLable = getPatchRCXY4cut(infolcz, infoImg, lcz, class) ;
clear lcz  infolcz infolcz


if size(centerRCLable,1)==0
  Info = 'no samples, may be the additional cities!'
  excInfo = 0
  return
end

%check some points outside the image
indexOut1 = find(round(centerRCLable(:,1)+patchHalf)>size(img0,1) | round(centerRCLable(:,2)+patchHalf)>size(img0,2)  | round(centerRCLable(:,1)-patchHalf)<1 | round(centerRCLable(:,2)-patchHalf)<1  ) ;

info='part of samples excluded:'
size(indexOut1,1)/ size(centerRCLable,1)
% if size(indexOut1,1)>0.8* size(centerRCLable,1)
%     excInfo = ['lcz wrong possibly']
%     return
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
numEachClass = zeros(1, 17) ;% # of patches
GT_RC_used =[] ;

%save to numPart part
numPart = 1 ;
rStart = 1 ;
for i = 1:numPart
    if i ==numPart
        rEnd = size(centerRCLable,1) ;
    else
        rEnd = rStart + round(size(centerRCLable,1)/numPart) ;
    end

    [numData, label_RC] =  saveImg2matS2L8(centerRCLable(rStart:rEnd,:), img0, train_test, imgPatchDir, cityMonth, patchHalf,  i, city) ;
    numEachClass(1,1:17) =  numEachClass(1,1:17)+numData;
    GT_RC_used=[GT_RC_used; label_RC];


    rStart = rEnd  + 1;
end

if train_test==1 %training samples

  save([imgPatchDir0 cityMonth '_numEachClassTrain.mat'],'numEachClass','-v7.3')

elseif train_test==0%test samples

  save([imgPatchDir0 cityMonth '_numEachClassTest.mat'],'numEachClass','-v7.3')

% else% all samples
%
%   save([imgPatchDir0 cityMonth '_numEachClass.mat'],'numEachClass','-v7.3')
%
%   %save the used GT to geotiff
% UsedGT= zeros(size(lcz));
%   linearInd = sub2ind(size(UsedGT), GT_RC_used(:,2), GT_RC_used(:,3)) ;
%   UsedGT(linearInd)=GT_RC_used(:,1);
%   geotiffwrite([imgPatchDir0 cityMonth '_GT_S2.tif'], UsedGT, Rlcz,  ...
%       'GeoKeyDirectoryTag', infolcz.GeoTIFFTags.GeoKeyDirectoryTag);
%
end

excInfo = 1 ;

end
