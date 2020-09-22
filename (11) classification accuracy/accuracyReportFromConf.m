
% function: accuracy assessment
% input:
%         confu: confusion matrix
%         truthAxis: if truthAxis=1, sum(matrix) = # of the GT
% output:

function [oa K apa aua af1 pa ua f1]=accuracyReport(confu, truthAxis)


oa=trace(confu)/sum(confu(:)); %overall accuracy

TruthNumEachClass=( sum(confu,truthAxis) );
TruthNumEachClass= reshape(TruthNumEachClass, [],1) ;

pa=diag(confu)./TruthNumEachClass; % recall

pa(find(TruthNumEachClass==0))=nan; % if there are no samples for one class, then recall is meangingless

axisPre=setdiff([1 2],truthAxis) ;
PreNumEachClass=sum(confu,axisPre) ;
PreNumEachClass= reshape(PreNumEachClass, [],1) ;

ua=diag(confu)./PreNumEachClass;  %user accuracy( precision)
 
CorrectPre=diag(confu);

f1=nan(size(pa));
idx=(find(CorrectPre~=0)) ;
%if==0, then pa==0, then the next calculation is wrong
%if~=0, then neither pa nor ua is 0

f1(idx) =2./(1./pa(idx)+1./ua(idx));
af1=mean(f1(idx));

Po=oa;
Pe=(sum(confu)*sum(confu,2))/(sum(confu(:))^2);
K=(Po-Pe)/(1-Pe);%kappa coefficient

%maybe not all classes exist
groundTClassNum = size(find(TruthNumEachClass),1) ;

%maybe not all classes exist
preClassNum = size(find(PreNumEachClass),1) ;

%maybe not all classes exist, then the mean should not coniser that class
apa = sum(pa(:), 'omitnan')/groundTClassNum ;
aua = sum(ua(:), 'omitnan')/preClassNum ;

end