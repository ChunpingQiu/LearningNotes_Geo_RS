%plot confusion matrix using confusion mat

clear
clc
close all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%confusion matrix
c=[[677,121,0,154,16,23,1,6,0,15,0,0,0,0,0,0,1;129,4097,340,66,199,55,7,62,0,7,0,0,0,0,0,0,1;42,540,6314,36,133,670,100,78,18,13,0,3,0,0,0,1,3;211,75,27,2252,322,12,2,24,2,32,1,16,1,6,1,0,2;35,677,109,271,2284,162,1,83,18,22,0,2,0,0,0,2,10;6,225,924,19,811,6957,10,58,729,21,2,12,38,2,0,3,6;0,61,94,0,0,1,852,4,0,5,0,0,0,0,0,0,0;66,182,219,96,224,112,10,9479,7,856,1,0,1,12,33,66,4;0,5,44,1,41,620,4,35,3666,38,19,88,1,47,0,2,1;16,20,16,31,41,16,7,289,2,1899,0,0,0,10,6,9,10;0,5,0,6,10,34,1,3,41,2,10763,256,169,135,6,21,24;1,3,1,6,10,18,1,11,108,14,72,1401,104,177,43,21,0;0,0,0,0,0,1,0,0,15,0,48,61,1719,94,104,32,1;0,1,8,11,6,52,4,47,100,54,37,426,307,10048,12,105,15;0,0,0,0,0,0,0,127,0,15,0,0,31,1,421,23,0;0,5,0,1,30,7,0,31,6,33,0,22,125,38,14,1818,12;1,1,8,0,7,12,0,21,2,14,0,5,10,43,0,3,12353]];

tit='E:\sampleData4test\confusion matrix of XXX';
picConfu(c, tit, 1)

function picConfu(c, tit, truthAxis) 

classLabels = {'1','2','3','4','5','6','7','8','9','10','A','B','C','D','E','F','G'};
if truthAxis~=1
    c=c';
end

figure
x0=100;
y0=10;
width=1000;
height=900;
set(gcf,'position',[x0,y0,width,height])

cm=confusionchart('Parent',gcf, c', classLabels, 'RowSummary','row-normalized', 'ColumnSummary','column-normalized') ;
cm.ColumnSummary = 'column-normalized' ;%'column-normalized';
cm.RowSummary = 'row-normalized';
cm.FontSize = 13 ;
cm.FontName = 'Times New Roman' ;
cm.Title = tit;

export_fig(tit, '-pdf', "-q101", "-transparent");

end