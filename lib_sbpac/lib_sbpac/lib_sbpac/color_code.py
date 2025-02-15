# -*- coding: utf-8 -*-
"""
Created on Thu Apr 19 14:19:09 2018

@author: Kyunghan
"""
import numpy as np
import matplotlib.pyplot as plt

def get_ColorSet():
    Color = {}
    Color['CP'] = [[0.23921569, 0.01960784, 0.14509804],
           [0.45490196, 0.09019608, 0.28235294],
           [0.51764706, 0.23529412, 0.04705882],
           [0.75294118, 0.        , 0.        ],
           [1.        , 0.01960784, 0.01960784],
           [0.9372549 , 0.48235294, 0.10588235],
           [1.        , 0.75294118, 0.        ],
           [1.        , 0.84313725, 0.        ],
           [1.        , 1.        , 0.        ],
           [0.9372549 , 0.9372549 , 0.58431373],
           [0.51764706, 0.50980392, 0.        ],
           [0.57254902, 0.81568627, 0.31372549],
           [0.        , 1.        , 0.        ],
           [0.        , 0.69019608, 0.31372549],
           [0.        , 0.39607843, 0.        ],
           [0.48235294, 1.        , 0.83921569],
           [0.12941176, 0.69803922, 0.67843137],
           [0.38431373, 0.61568627, 0.81960784],
           [0.        , 0.69019608, 0.94117647],
           [0.        , 0.        , 1.        ],
           [0.        , 0.43921569, 0.75294118],
           [0.        , 0.31764706, 0.58431373],
           [0.        , 0.1254902 , 0.37647059],
           [0.29019608, 0.        , 0.51764706],
           [0.78431373, 0.18823529, 0.8       ],
           [1.        , 0.        , 1.        ],
           [0.94509804, 0.82745098, 0.83921569],
           [0.5372549 , 0.44313725, 0.88235294],
           [0.60784314, 0.34117647, 0.82745098]]
    
    Color['RP'] = [[0.23921569, 0.01960784, 0.14509804],
           [0.57254902, 0.07843137, 0.17254902],
           [0.45490196, 0.09019608, 0.28235294],
           [0.76862745, 0.05490196, 0.01960784],
           [1.        , 0.01960784, 0.01960784],
           [0.9372549 , 0.48235294, 0.10588235],
           [0.6745098 , 0.42745098, 0.50980392],
           [1.        , 0.54901961, 0.65098039],
           [0.90980392, 0.01960784, 0.29411765],
           [1.        , 0.07843137, 0.58039216]]
    
    Color['YP'] = [[0.51764706, 0.23529412, 0.04705882],
           [0.8       , 0.4       , 0.        ],
           [1.        , 0.59607843, 0.14509804],
           [1.        , 0.79215686, 0.03137255],
           [1.        , 0.84313725, 0.        ],
           [1.        , 1.        , 0.        ],
           [0.9372549 , 0.9372549 , 0.58431373],
           [0.74117647, 0.71372549, 0.41960784],
           [0.69411765, 0.61176471, 0.49019608],
           [0.69803922, 0.49019608, 0.28627451]]
    
    Color['BP'] = [[0.10196078, 0.19607843, 0.37647059],
           [0.        , 0.31764706, 0.58431373],
           [0.05882353, 0.43529412, 0.77647059],
           [0.        , 0.        , 1.        ],
           [0.        , 0.61568627, 0.85098039],
           [0.00392157, 0.62745098, 0.91372549],
           [0.27058824, 0.79607843, 0.90980392],
           [0.04313725, 0.81568627, 0.85098039],
           [0.38431373, 0.61568627, 0.81960784],
           [0.49803922, 0.56078431, 0.6627451 ]]
    
    Color['GP'] = [[0.        , 0.39607843, 0.        ],
           [0.32156863, 0.41176471, 0.16078431],
           [0.51764706, 0.50980392, 0.        ],
           [0.        , 0.69019608, 0.31372549],
           [0.19215686, 0.81176471, 0.19215686],
           [0.        , 1.        , 0.        ],
           [0.67843137, 1.        , 0.16078431],
           [0.75294118, 0.81176471, 0.22745098],
           [0.48235294, 1.        , 0.83921569],
           [0.12941176, 0.69803922, 0.67843137]]
    
    
    Color['PP'] = [[0.4       , 0.        , 0.4       ],
           [0.57254902, 0.15294118, 0.56078431],
           [0.78431373, 0.18823529, 0.8       ],
           [1.        , 0.        , 1.        ],
           [0.9372549 , 0.50980392, 0.9372549 ],
           [0.61176471, 0.52156863, 0.75294118],
           [0.5372549 , 0.44313725, 0.88235294],
           [0.60784314, 0.34117647, 0.82745098],
           [0.43921569, 0.18823529, 0.62745098],
           [0.29019608, 0.        , 0.51764706]]
    
    Color['WP'] = [[0.        , 0.        , 0.        ],
           [0.16078431, 0.30196078, 0.29019608],
           [0.45098039, 0.50980392, 0.54901961],
           [0.45098039, 0.5254902 , 0.61176471],
           [0.51764706, 0.50980392, 0.51764706],
           [0.67843137, 0.66666667, 0.67843137],
           [0.74117647, 0.74509804, 0.74117647],
           [0.94509804, 0.82745098, 0.83921569],
           [0.85098039, 0.85098039, 0.85098039],
           [0.94901961, 0.94901961, 0.94901961]]
    
    Color['SP'] = [[0.45490196, 0.09019608, 0.28235294],
           [0.90980392, 0.01960784, 0.29411765],
           [0.9372549 , 0.48235294, 0.10588235],
           [1.        , 0.84313725, 0.        ],
           [0.67843137, 1.        , 0.16078431],
           [0.        , 0.69019608, 0.31372549],
           [0.12941176, 0.69803922, 0.67843137],
           [0.        , 0.61568627, 0.85098039],
           [0.        , 0.31764706, 0.58431373],
           [0.        , 0.1254902 , 0.37647059],
           [0.29019608, 0.        , 0.51764706],
           [0.78431373, 0.18823529, 0.8       ]]
    return Color

def dis_ColorSet():
    tmpLocColor = get_ColorSet()
    
    fig = plt.figure(figsize = (8,5))
    
    sub0 = fig.add_subplot(3,3,1);sub0.set_yticks([])
    tmpColor = tmpLocColor['SP']
    y_pos = np.arange(len(tmpColor))
    sub0.bar(y_pos,1,color=tmpColor);sub0.set_xticks(y_pos)
    sub0.set_title('SP')
    
    sub1 = fig.add_subplot(3,3,(2,3));sub1.set_yticks([])
    tmpColor = tmpLocColor['CP']
    y_pos = np.arange(len(tmpColor))
    sub1.bar(y_pos,1,color=tmpColor);sub1.set_xticks(y_pos)
    sub1.tick_params(labelsize = 8)
    sub1.set_title('CP')
    
    sub2 = fig.add_subplot(3,3,4);sub2.set_yticks([])
    tmpColor = tmpLocColor['RP']
    y_pos = np.arange(len(tmpColor))
    sub2.bar(y_pos,1,color=tmpColor);sub2.set_xticks(y_pos)
    sub2.set_title('RP')
    
    sub3 = fig.add_subplot(3,3,5);sub3.set_yticks([])
    tmpColor = tmpLocColor['BP']
    y_pos = np.arange(len(tmpColor))
    sub3.bar(y_pos,1,color=tmpColor);sub3.set_xticks(y_pos)
    sub3.set_title('BP')
    
    sub4 = fig.add_subplot(3,3,6);sub4.set_yticks([])
    tmpColor = tmpLocColor['GP']
    y_pos = np.arange(len(tmpColor))
    sub4.bar(y_pos,1,color=tmpColor);sub4.set_xticks(y_pos)
    sub4.set_title('GP')
    
    sub5 = fig.add_subplot(3,3,7);sub5.set_yticks([])
    tmpColor = tmpLocColor['YP']
    y_pos = np.arange(len(tmpColor))
    sub5.bar(y_pos,1,color=tmpColor);sub5.set_xticks(y_pos)
    sub5.set_title('YP')
    
    sub6 = fig.add_subplot(3,3,8);sub6.set_yticks([])
    tmpColor = tmpLocColor['PP']
    y_pos = np.arange(len(tmpColor))    
    sub6.bar(y_pos,1,color=tmpColor);sub6.set_xticks(y_pos)
    sub6.set_title('PP')
    
    sub7 = fig.add_subplot(3,3,9);sub7.set_yticks([])
    tmpColor = tmpLocColor['WP']
    y_pos = np.arange(len(tmpColor))
    sub7.bar(y_pos,1,color=tmpColor);sub7.set_xticks(y_pos)
    sub7.set_title('WP')
    
    fig.subplots_adjust(left=0.05, right=0.95,
                    top=0.9, bottom=0.1,
                    hspace=0.5, wspace=0.1)
    return 'True'
