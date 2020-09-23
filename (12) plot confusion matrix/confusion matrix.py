from scipy.io import loadmat
import os
import sys

from plot_confusion_matrix import plot_confusion_matrix
from pandas import DataFrame

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.font_manager as fm
from matplotlib.collections import QuadMesh
import seaborn as sn

sys.path.insert(0, r".\pretty-print-confusion-matrix-master")
from confusion_matrix_pretty_print import pretty_plot_confusion_matrix


file = os.path.join(r'E:\sampleData4test', "confusion_matrices.mat")
x = loadmat(file)

#'blockFusion_M', 'blockS1_M', 'blockS2_M', 'randomFusion_M','randomS1_M', 'randomS2_M', 'c10_fusion_M', 'c10_S1_M', 'c10_S2_M'
for saveName in {'blockFusion_M', 'randomFusion_M', 'c10_fusion_M'}:
    #saveName = 'randomFusion_M'

    randomFusion_M = x[saveName]
    #print(randomFusion_M.shape)

    #method 1: summary included
    # get pandas dataframe
    df_cm = DataFrame(randomFusion_M, index=range(1, 18), columns=range(1, 18))
    cmap = 'Blues'#'PuRd'
    pretty_plot_confusion_matrix(df_cm, cmap=cmap, fz=64, figsize=[50, 50], pred_val_axis='x', file='E:/sampleData4test/'+saveName + '_.png')

    #method 2: normal
    #target_names = ['1','2','3','4','5','6','7','8','9','10','A','B','C','D','E','F','G']
    #plot_confusion_matrix(randomFusion_M, target_names, file=saveName + '.png')#, normalize=False

