%nb_c the number of calss, no matter it exists in the
%estim_label(true_label) or not

function [oa, ua, pa, K ,confu, aua, apa]=confusion(true_label, estim_label, nb_c)
% [oa ua pa K confu aua apa]
%
% function confusion(true_label,estim_label)
%
% This function compute the confusion matrix and extract the OA, AA
% and the Kappa coefficient.
%
% INPUT
% easy! just read

l=length(true_label);

confu=zeros(nb_c,nb_c);

for i=1:l
  confu(estim_label(i),true_label(i))= confu(estim_label(i),true_label(i))+1;
end
 
[oa K apa aua af1 pa ua f1]=accuracyReport(confu, 1) ;% here the calculated confu truthAxis is 1

%http://kappa.chez-alice.fr/kappa_intro.htm