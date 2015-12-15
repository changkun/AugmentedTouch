# this file do the classification on moment data: 1.1.csv 1.2.csv

import csv
import numpy as np
import matplotlib.pyplot as plt

from sklearn import svm
from sklearn.cross_validation import train_test_split
import time

#
# pre-process filepath
#
def prefix(folderName):
    folderNameStr = ''
    if folderName<10:
        folderNameStr = '0'+str(folderName)
    else:
        folderNameStr = str(folderName)
    return folderNameStr

def LargeDeviceMoment(folderName):
    return '../' + prefix(folderName) + '/1.1.csv'

def SmallDeviceMoment(folderName):
    return '../' + prefix(folderName) + '/1.2.csv'

# (x,y,roll,pitch,yaw) --> posture = {1,2,3,4}

def GetUsefulData(filePath, delimiter=','):
    csvfile = open(filePath)
    csv_reader = csv.reader(csvfile, delimiter=delimiter)
    data = np.array([row for row in csv_reader])
    length, feature = data.shape
    csvfile.close()
    # print data[1:length, 2:feature]
    return data[1:length, 2:feature]

def unique_rows(a):
    a = np.ascontiguousarray(a)
    unique_a = np.unique(a.view([('', a.dtype)]*a.shape[1]))
    return unique_a.view(a.dtype).reshape((unique_a.shape[0], a.shape[1]))

def delteIndexCondition(data, label):
    converLabel = [[value] for value in label]
    dataWithLabel = np.append(data, converLabel, axis=1)
    dataWithLabel = dataWithLabel[~(dataWithLabel[:,5]=='2'), :]
    dataWithLabel = dataWithLabel[~(dataWithLabel[:,5]=='3'), :]
    # reduceData = np.empty()
    # for i, row in enumerate(dataWithLabel):
    #     if (row[5] == '2') or (row[5] == '3'):
    #         pass
    #     else:
    #         reduceData.append(row, axis=0)
    return dataWithLabel[:,0:5], dataWithLabel[:,5]



def clfData(data, label, featureDimension=5):
    # print data.shape
    # print label.shape
    #
    # uniqueData = unique_rows(dataWithLabel)
    # print dataWithLabel.shape
    # print uniqueData.shape
    data, label = delteIndexCondition(data, label)

    X_train, X_test, y_train, y_test = train_test_split(data, label, test_size=0.1, random_state=42)

    # kernel='linear'
    # kernel='rbf'
    # decision_function_shape='ovo'
    clf = svm.SVC(kernel='rbf', max_iter=100000).fit(X_train[:,0:featureDimension], y_train)
    # print clf
    error_count = 0.0
    result = clf.predict(X_test[:,0:featureDimension])

    for i, l in enumerate(result):
    #print l, label[i]
        if l != y_test[i]:
            error_count += 1

    #print 'error_count: ' + str(error_count)
    #print 'total_count: ' + str(result.shape[0])
    #print 'error_rate: ' + str(error_count/result.shape[0])
    return error_count/result.shape[0] # error rate

def TraverFolderCSV(folderName):
    filePathList = [LargeDeviceMoment(folderName),
                    SmallDeviceMoment(folderName)]

    for i in xrange(0,2):
        print filePathList[i]
        data =  GetUsefulData(filePathList[i])
        #length, feature = data.shape
        postureLabel = data[:, 4]    #posture label

        positionData = data[:, 5:7]  #position x,y
        attitudeData = data[:, 9:12]
        acceleratorData = data[:, 12:15]
        gyroscopeData = data[:, 15:18]

        posWithAttiFeature = np.append(positionData, attitudeData, axis=1)
        posWithAcceFeature = np.append(positionData, acceleratorData, axis=1)
        posWithGyroFeature = np.append(positionData, gyroscopeData, axis=1)

        posWithAttiAndAcceFeature = np.append(posWithAttiFeature, acceleratorData, axis=1)
        posWithAttiAndGyroFeature = np.append(posWithAttiFeature, gyroscopeData, axis=1)
        posWithAcceAndGyroFeature = np.append(posWithAcceFeature, gyroscopeData, axis=1)

        featureDimension = 5

        attiErrorRate = clfData(posWithAttiFeature, postureLabel, featureDimension=featureDimension)
        print 'finish posWithAttiFeature...'
        acceErrorRate = clfData(posWithAcceFeature, postureLabel, featureDimension=featureDimension)
        print 'finish posWithAcceFeature...'
        gyroErrorRate = clfData(posWithGyroFeature, postureLabel, featureDimension=featureDimension)
        print 'finish posWithGyroFeature...'

        attiAndAcceErrorRate = clfData(posWithAttiAndAcceFeature, postureLabel, featureDimension=featureDimension)
        print 'finish posWithAttiAndAcceFeature...'
        attiAndGyroErrorRate = clfData(posWithAttiAndGyroFeature, postureLabel, featureDimension=featureDimension)
        print 'finish posWithAttiAndGyroFeature...'
        acceAndGyroErrorRate = clfData(posWithAcceAndGyroFeature, postureLabel, featureDimension=featureDimension)
        print 'finish posWithAcceAndGyroFeature...'

        print 'attiErrorRate: ' + str(folderName) + ',' + str(i) + ',' + str(attiErrorRate)
        print 'acceErrorRate: ' + str(folderName) + ',' + str(i) + ',' + str(acceErrorRate)
        print 'gyroErrorRate: ' + str(folderName) + ',' + str(i) + ',' + str(gyroErrorRate)

        print 'attiAndAcceErrorRate: ' + str(folderName) + ',' + str(i) + ',' + str(attiAndAcceErrorRate)
        print 'attiAndGyroErrorRate: ' + str(folderName) + ',' + str(i) + ',' + str(attiAndGyroErrorRate)
        print 'acceAndGyroErrorRate: ' + str(folderName) + ',' + str(i) + ',' + str(acceAndGyroErrorRate)

        if i==0:
            print 'finish process iphone 6 plus...'
        else:
            print 'finish process iphone 5...'

        # test
        # if i==2:
        #     print 'Process "' + filePathList[i] + '" ...'
        #     data = GetUsefulData(filePathList[i])
        #     for testCount in xrange(1, 5):
        #         for tapCount in xrange(0,360):
        #             plotSensorBuffer2(data, tapCount=tapCount, testCount=testCount, folderName=folderName)
        #             #print 'finish tap-' + str(tapCount) + '.'
        #         print 'finish user-' + str(folderName) + ' case-' + str(testCount) + '.'

def TraverAllFolderCSV():
    for i in xrange(0,16):
        start=time.time()
        TraverFolderCSV(i+1)
        finish=time.time()
        print 'spend ' + str((finish-start)/60.0)+ 'min process an user.'

def main():
    TraverAllFolderCSV()


if __name__ == '__main__':
    main()
