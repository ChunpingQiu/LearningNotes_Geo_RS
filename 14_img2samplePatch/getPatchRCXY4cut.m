% @Date:   2018-08-02T13:44:12+02:00
% @Email:  chunping.qiu@tum.de
% @Last modified time: 2018-08-02T13:47:29+02:00



% function: get information of the label: R C in the image, ground coord,
% and label
% input:
%         infolcz: lcz file info
%         infoImg: image file info
%         lcz: LCZ matrix
%         class: the relevent class

% output:
%         centerRCLable: [row, col, x, y, lat, lon, label] the row and colum , label_UTM, lat, lon, label f a label in image

function centerRCLable = getPatchRCXY4cut(infolcz, infoImg, lcz, class)

centerRCLable = [] ;

for i = 1: length(class)

    %the pixel of a label
    [r, c ] =  find( lcz ==class(i) ) ;

    % the coordinates of a label in label_UTM
    [x,y] = pix2map(infolcz.RefMatrix, r, c) ;

    % the coordinates of a label in long-lat
    [lat,lon] = projinv(infolcz, x,y) ;

%     % the coordinates of a label in image_UTM
     [X_u, Y_u] = projfwd(infoImg, lat, lon) ;

    % the row and colum of a label in image
    [row,col] = map2pix(infoImg.RefMatrix, X_u, Y_u) ;

    if class(i)>100
        class(i) =  class(i)-90 ;
    end

    centerRCLable = [centerRCLable ; row, col, x, y, lat, lon, double(class(i))*(ones(size(x))), r,  c ] ;

    clear r c x y row col
end


info='size of centerRCLable in function getPatchRCXY4cut:'
size(centerRCLable)


end
