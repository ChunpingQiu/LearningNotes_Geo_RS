
%split a data into n part, class wisely
function split2nFold(x_tra, y_tra, patchPos, numFold, file0)

index = randperm(size(y_tra,1)) ;
x_Tra = x_tra(index,:,:,:) ;
y_Tra = y_tra(index,:) ;
patchPos0= patchPos(index,:) ;

clear x_tra y_tra patchPos

for j=1:17
    classIdx(j).Idx=find(patchPos0(:,7)==j);
    numEachClass(1,j) =  size(classIdx(j).Idx, 1) ;%# sample of each class
end
numEachClass

iStart=ones(17);
for idFold=1:numFold
    x_tra=[] ;
    y_tra=[] ;
    patchPos=[] ;

    for j = 1:17

        if numEachClass(1,j)==0
            continue;
        end

        if idFold==numFold
            iEnd(j)=numEachClass(1,j);
        else
            iEnd(j)=iStart(j)+floor(numEachClass(1,j)/numFold)-1;
        end

        % if j==1
        %     x_tra=x_Tra(classIdx(j).Idx(iStart(j):iEnd(j),1),:,:,:) ;
        %     y_tra=y_Tra(classIdx(j).Idx(iStart(j):iEnd(j),1),:) ;
        % else
        if numEachClass(1,j)<numFold%all samples less than numFold, then all samples are used for each fold
            x_tra=[x_tra; x_Tra(classIdx(j).Idx(:,1),:,:,:)] ;
            y_tra=[y_tra; y_Tra(classIdx(j).Idx(:,1),:)] ;

            patchPos=[patchPos; patchPos(classIdx(j).Idx(:,1),:)] ;

        else
            x_tra=[x_tra; x_Tra(classIdx(j).Idx(iStart(j):iEnd(j),1),:,:,:)] ;
            y_tra=[y_tra; y_Tra(classIdx(j).Idx(iStart(j):iEnd(j),1),:)] ;

            patchPos=[patchPos; patchPos0(classIdx(j).Idx(iStart(j):iEnd(j),1),:)] ;
        end

    end

    iStart=iEnd+1;

    for testID=1:17
        test0=find(y_tra(:,1)==testID);
        test(1,testID) =  size(test0, 1) ;%# sample of each class
    end
    test

    matName = [file0 '_' num2str(idFold) '.mat'] ;
    save(matName,'x_tra','y_tra','-v7.3') ;

    matName = [file0 '_' num2str(idFold) 'patchPos.mat'] ;
    save(matName, 'patchPos','-v7.3') ;

end


end
