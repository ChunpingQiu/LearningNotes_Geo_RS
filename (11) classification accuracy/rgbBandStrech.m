function [ rgb_out ] = rgbBandStrech( rgb )
%This function preprocess sentinel 2 into rgb. The final feature is
%scaled into [0,1]. 0.5% of lower boundary and high boundary are masked out
%due to the extreme low or high sar value will squaze the feature values.
%   Detailed explanation goes here

% edge elimination percentage 0.5%

rgb = double(rgb);
rgb_out = uint8(zeros(size(rgb)));
mask = ones(size(rgb,1),size(rgb,2));
for i = 1:size(rgb,3)
    mask = mask.*(rgb(:,:,i)>0);
end
mask = sum(rgb,3)>0;

for i = 1:size(rgb,3)
    temp = rgb(:,:,i);

    boundary = quantile(temp(mask(:)),[0.02,0.98]);
    low = boundary(1);
    high = boundary(2);
    temp(temp<low) = low;
    temp(temp>high) = high;
    
    rgb_out(:,:,i) = uint8((temp - low)./(high - low) * 255);



end

% figure,imshow(rgb_out);
end

