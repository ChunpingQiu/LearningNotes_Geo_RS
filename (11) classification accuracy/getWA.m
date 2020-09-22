% function: calculate weighted accuracy
% input:
%         weight: the weight corresponding to the confusions
%         confusionM: confusion matrix, with the x-axis as the ground
%         truth, i.e.: sum(confusionM,1) = samples # of ground truth
% output:
%         WA: weighted accuracy
%         Wrecall: weighted recall of each class
function [WA, Wrecall] = getWA(weight, confusionM)

% please, always use the provided weight matrix:
% load 'LCZweight'
% [WA, Wrecall] = getWA(LCZweight, confusionM) ;


%total number of samples
totalNum = sum(confusionM(:)) ;
numEachClass = sum(confusionM,1) ;

Wconfu = weight.*confusionM ;
WA = sum(Wconfu(:))/totalNum ;

WCorrectPrediction=sum(Wconfu,1) ;
Wrecall = WCorrectPrediction./numEachClass;

%if there is no samples for one class, then there is no recall
Wrecall(find(numEachClass==0))=nan ;

end

