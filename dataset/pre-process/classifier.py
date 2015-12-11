# this file do the classification on moment data: 1.1.csv 1.2.csv

import csv
import numpy as np
import matplotlib.pyplot as plt

from sklearn import svm
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

def clfData(data, label, featureDimension=5):

    # kernel='linear'
    clf = svm.SVC().fit(data[:,0:featureDimension], label)

    error_count = 0.0
    result = clf.predict(data[:,0:featureDimension])

    for i, l in enumerate(result):
    #print l, label[i]
        if l != label[i]:
            error_count += 1

    print 'error_count: ' + str(error_count)
    print 'total_count: ' + str(result.shape[0])
    print 'error_rate: ' + str(error_count/result.shape[0])

def TraverFolderCSV(folderName):
    filePathList = [LargeDeviceMoment(folderName),
                    SmallDeviceMoment(folderName)]
    for i in xrange(0,2):
        print filePathList[i]
        # process iphone 6 plus
        #
        data =  GetUsefulData(filePathList[i])
        length, feature = data.shape
        postureLabel = data[:, 4]    #posture label

        positionData = data[:, 5:7]  #position x,y
        attitudeData = data[:, 9:12]
        acceleratorData = data[:, 12:15]
        gyroscopeData = data[:, 15:18]

        posWithAttiFeature = np.append(positionData, attitudeData, axis=1)
        posWithAcceFeature = np.append(positionData, acceleratorData, axis=1)
        posWithGyroFeature = np.append(positionData, gyroscopeData, axis=1)

        clfData(posWithAcceFeature, postureLabel)

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
        print 'spend ' + str((finish-start)/60.0)+ 'min process a user.'

def main():
    TraverAllFolderCSV()


if __name__ == '__main__':
    main()
