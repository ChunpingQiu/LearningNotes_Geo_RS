% @Date:   2018-08-02T13:37:51+02:00
% @Email:  chunping.qiu@tum.de
% @Last modified time: 2018-08-13T05:07:55+02:00


clear
clc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%sample test data:https://drive.google.com/drive/folders/1EPsBIkESTRdo8-wh3eNvAQeZ4z9yFa8o?usp=sharing
%1: gt file:
lczDir = 'E:\sampleData4test\img2patch\gt\' ;

%3: images to be cuted:
imgDir = 'E:\sampleData4test\img2patch\img\';%

%4: save patches to:
imgPatchDir0 = 'E:\sampleData4test\img2patch\img2patch_res\'; %

%"half of the patch size"
% patchHalf = 4.5 ;
patchHalf =  15.5 ; %patch size 32

train_test = 1 %gt from train
%train_test = 0 %gt from test

cityFs = dir(imgDir) ;

id = 1 ;
badImageNum=0 ;

for ii = 3:size(cityFs,1)

    city = cityFs(ii).name

    DataDetail1(id,1).city = city ;
    imgFs = dir([imgDir city '\']') ;
    DataDetail1(id,1).num = size(imgFs,1) ;

    for i = 1 :4%go through every file of this city
        indexTmp = find(city == '_') ;
        code=city(indexTmp(1)+1:indexTmp(2)-1) ;
        if i ==1
            fileImg =[imgDir city '\winter\' code '_winter.tif'] ;
        elseif i==2
            fileImg =[imgDir city '\spring\' code '_spring.tif'] ;
        elseif i==3
            fileImg =[imgDir city '\summer\' code '_summer.tif'] ;
        elseif i==4
            fileImg =[imgDir city '\autumn\' code '_autumn.tif'] ;
        end

        try
            infolcz = geotiffinfo(fileImg) ;
        catch
            excInfo = 'this season no image';
            badImageNum=badImageNum+1
            continue;
        end

        display("processing image:")
        display(fileImg)
        
        excInfo = cutPatch2Mat(fileImg, lczDir, city, patchHalf, imgPatchDir0, train_test);

        if excInfo == 0
            break
        end

    end


    id = id + 1 ;
end
