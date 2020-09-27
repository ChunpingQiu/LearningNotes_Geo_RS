% @Date:   2018-08-02T13:37:51+02:00
% @Email:  chunping.qiu@tum.de
% @Last modified time: 2018-08-13T05:07:55+02:00


clear

DataDetail  = struct('city',{}) ;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%1: gt file:
lczDir = '/data/qiu/sampleData4test/' ;

%3: images to be cuted:
imgDir = '/data/qiu/sampleData4test/img2patch/LCZ42_21588_Rome/';%

%4: save patches to:
imgPatchDir0 = "/data/qiu/sampleData4test/img2patch_res/"

"half of the patch size"
% patchHalf = 4.5 ;
patchHalf =  15.5 ; %patch size 32

train_test = 1 %gt from train
%train_test = 0 %gt from test
%train_test = 2 ;%training and test

cityFs = dir(imgDir) ;
id = 1 ;
badImageNum=0 ;

DataDetail2 = zeros(size(cityFs,1), 4) ;%sample # of each season
for ii = 1:size(cityFs,1)

    city = cityFs(ii).name

    DataDetail1(id,1).city = city ;
    imgFs = dir([imgDir city '/']') ;
    DataDetail1(id,1).num = size(imgFs,1) ;

    for i = 1 :4%go through every file of this city
        indexTmp = find(city == '_') ;
        code=city(indexTmp(1)+1:indexTmp(2)-1) ;
        if i ==1
            fileImg =[imgDir city '/winter/' code '_winter.tif'] ;%1202
        elseif i==2
            fileImg =[imgDir city '/spring/' code '_spring.tif'] ;
        elseif i==3
            fileImg =[imgDir city '/summer/' code '_summer.tif'] ;
        elseif i==4
            fileImg =[imgDir city '/autumn/' code '_autumn.tif'] ;
        end

        try
            infolcz = geotiffinfo(fileImg) ;
        catch
            excInfo = 'this season no image';
            badImageNum=badImageNum+1
            continue;
        end

        [excInfo] = cutPatch2Mat(fileImg, lczDir, city, patchHalf, imgPatchDir0, train_test)

        if excInfo == 0
            break
        end

    end


    id = id + 1 ;
end
