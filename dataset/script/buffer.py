# coding:utf-8
from loaddata import loadUserData
from moment import classify

import numpy as np
import matplotlib.pyplot as plt

from sklearn import svm
from sklearn.cross_validation import train_test_split

from sklearn.metrics import roc_curve, auc
from sklearn.preprocessing import label_binarize
from sklearn.multiclass import OneVsRestClassifier
from scipy import interp

import threading
import os.path
import math
import time

bufferSize = 50
sensorNumber = 3

userid = 1
device = 1

# basic parameters
my_kernel = 'linear'
my_max_iteration = 500000
my_test_size = 0.3
my_random_state = 42

def getBufferData(userid, device):
    data = loadUserData(userid, device, datatype=2)
    return data
def getFullBufferBy(data, tapCount, testCount, sensorFlag):
    """
    Return
    ------
    tuple data with 6 feature: (tapCount, sensorFlag, handPosture, x, y, z)
    tapCount, sensorFlag, handPosture is int value
    x, y, z is a list of floating value
    """
    # important
    start = tapCount*sensorNumber*sensorNumber + (testCount-1)*(sensorNumber*bufferSize)*(6*10*6) + sensorFlag*bufferSize

    buffer = data[start:start+bufferSize, 2:]

    #print buffer

    tap = int(buffer[0,0])
    flag = int(buffer[0,1])
    posture =  int(buffer[0,2])

    x = [float(value) for value in buffer[:,3]]
    y = [float(value) for value in buffer[:,4]]
    z = [float(value) for value in buffer[:,5]]
    return (tap, flag, posture, x, y, z)
def compressBufferToList(buffer, compressFunc=np.mean):
    """
    Parameters
    ---------
    buffer:
        a buffer tuple
    compressFunc:
        defines how to processing a list to a real number
        default function is numpy.mean

    Returns
    -------
    list of 6 feature in the same dimensions: [tapCount, sensorFlag, handPosture, xMean, yMean, zMean]
    """
    a,b,c,d,e,f = buffer
    d = compressFunc(d)
    e = compressFunc(e)
    f = compressFunc(f)
    return [a,b,c,d,e,f]

def getBufferTrainingDataAndLabelBy(userid, device):
    start_time = time.clock()
    data = getBufferData(userid, device)
    wow = np.array([])
    for testCount in xrange(1,5):
        for tapCount in xrange(0,360):
            singleBufferAtti = getFullBufferBy(data, tapCount, testCount, 0)
            singleBufferAcce = getFullBufferBy(data, tapCount, testCount, 1)
            singleBufferGyro = getFullBufferBy(data, tapCount, testCount, 2)

            _, _, posture, xAtti, yAtti, zAtti = compressBufferToList(singleBufferAtti)
            _, _, _, xAcce, yAcce, zAcce = compressBufferToList(singleBufferAcce)
            _, _, _, xGyro, yGyro, zGyro = compressBufferToList(singleBufferGyro)
            line = np.hstack((xAtti, yAtti, zAtti, xAcce, yAcce, zAcce, xGyro, yGyro, zGyro, posture))
            wow = np.append(wow, line)
    wow = wow.reshape((1440, 10))
    end_time = time.clock()
    #print 'The getDataAndLabelBy() function run time is : %.04f seconds' %(end_time-start_time)
    return wow[:, :-1], wow[:, -1]


def errorRateForAll():
    error_rate_list = []
    for userid in xrange(1,17):
        for device in xrange(1,3):
            data, label = getBufferTrainingDataAndLabelBy(userid, device)
            data, label = splitBufferDataByLabel(data, label, 4)
            trainingData, testData, trainingLabel, testLabel = train_test_split(data, label, test_size=my_test_size, random_state=my_random_state)

            err = classify(trainingData, trainingLabel, testData, testLabel, kernel=my_kernel, max_iter=my_max_iteration)
            error_rate_list.append(err)
            print 'userid' + str(userid) + ' device' + str(device) + ' done'
    print error_rate_list
    return error_rate_list

def splitBufferDataByLabel(rawdata, label, classificationCondition=1):
    """
    classificationCondition: int

        1: Thumb Classification (left thumb, right thumb)
        2: Index Finger Classification (left index, right index)
        3: Multi-Classification (left thumb, right thumb, left index, right index)
        4: Hand Classification (left thumb+index, right thumb+index)

    """
    converLabel = [[str(int(value))] for value in label]
    dataWithLabel = np.append(rawdata, converLabel, axis=1)

    leftThumbData  = dataWithLabel[(dataWithLabel[:,-1]=='0'), :]
    rightThumbData = dataWithLabel[(dataWithLabel[:,-1]=='1'), :]
    leftIndexData  = dataWithLabel[(dataWithLabel[:,-1]=='2'), :]
    rightIndexData = dataWithLabel[(dataWithLabel[:,-1]=='3'), :]

    if classificationCondition==1:
        dataWithLabel = np.vstack((leftThumbData, rightThumbData))
    elif classificationCondition==2:
        dataWithLabel = np.vstack((leftIndexData, rightIndexData))
    elif classificationCondition==3:
        pass
    else: # classificationCondition==4:

        leftHandData = np.vstack((leftThumbData, leftIndexData))
        (row, column) = leftHandData.shape
        leftHandLabel = np.zeros(row, dtype=int)
        leftHandLabel.shape = row, -1
        leftHandData = np.hstack((leftHandData[:, 0:-1], leftHandLabel))

        rightHandData = np.vstack((rightThumbData, rightIndexData))
        (row, column) = rightHandData.shape
        rightHandLabel = np.ones(row, dtype=int)
        rightHandLabel.shape = row, -1
        rightHandData = np.hstack((rightHandData[:, 0:-1], rightHandLabel))

        dataWithLabel = np.vstack((leftHandData, rightHandData))

    newData = dataWithLabel[:,0:-1]
    newLabel = dataWithLabel[:,-1]

    return newData, newLabel

def plotBufferFeatureROC(userid, device):
    data, label = getBufferTrainingDataAndLabelBy(userid, device)
    classes = [0,1,2,3]
    label = label_binarize(label, classes=classes)
    print label
    n_classes = label.shape[1]

    random_state = np.random.RandomState(my_random_state)
    n_samples, n_features = data.shape
    data = np.c_[data, random_state.randn(n_samples, 9 * n_features)]

    trainingData, testData, trainingLabel, testLabel = train_test_split(data, label, test_size=0.5, random_state=my_random_state)

    classifier = OneVsRestClassifier(svm.SVC(kernel=my_kernel, probability=True, random_state=my_random_state, max_iter=my_max_iteration))
    label_score = classifier.fit(trainingData, trainingLabel).decision_function(testData)

    fpr = dict()
    tpr = dict()
    roc_auc = dict()

    for i in range(n_classes):
        fpr[i], tpr[i], _ =roc_curve(testLabel[:, i], label_score[:, i])
        roc_auc[i] = auc(fpr[i], tpr[i])

    plt.figure()

    for i in range(n_classes):
        strLabel = 'ROC curve of class {0} (area = {1:0.2f})'''.format(i, roc_auc[i])
        plt.plot(fpr[i], tpr[i], label=strLabel)

    plt.plot([0, 1], [0, 1], 'k--')
    plt.xlim([0.0, 1.0])
    plt.ylim([0.0, 1.0])
    plt.xlabel('False Positive Rate')
    plt.ylabel('True Positive Rate')
    plt.title('Receiver operating characteristic')
    plt.legend(loc="lower right")
    plt.show()
    plt.close('all')


# data, label = getBufferTrainingDataAndLabelBy(userid, device)
# data, label = splitBifferDataByLabel(data, label)

# print data
# print label

#plotBufferFeatureROC(userid, device)
print 'average error rate: ' + repr(np.mean(errorRateForAll()))
