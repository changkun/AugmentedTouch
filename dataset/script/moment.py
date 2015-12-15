from loaddata import loadUserData
from loaddata import splitMomentDataByFeature

from sklearn import svm
from sklearn.cross_validation import train_test_split

import numpy as np

import threading

def classify(trainingData, trainingLabel, testData, testLabel,
             kernel='linear', max_iter=-1):
    clf = svm.SVC(kernel=kernel, max_iter=max_iter).fit(trainingData, trainingLabel)
    error_count = 0.0
    result = clf.predict(testData)
    for i, la in enumerate(result):
        if la != testLabel[i]:
            error_count += 1
    return error_count/result.shape[0]

def classifyMOdel(trainingData, trainingLabel, kernel='linear', max_iter=-1):
    clfModel = svm.SVC(kernel=kernel, max_iter=max_iter).fit(trainingData, trainingLabel)
    return clfModel



def processMethod1(userid, device, datatype=1, featureCondition=1, classificationCondition=1):
    """ User-i Device-j hack in User-i Device-j Model (cross validation)
        i=1,2,...,16
        j=1,2
    Returns
    -------
    float : error rate
    """
    rawData = loadUserData(userid, device, datatype)

    data = splitMomentDataByFeature(rawData, featureCondition=featureCondition)
    label = rawData[:, 4]

    trainingData, testData, trainingLabel, testLabel = train_test_split(data, label, test_size=0.1, random_state=42)

    return classify(trainingData, trainingLabel, testData, testLabel, kernel='linear', max_iter=500000)

def processMethod2(userid, featureCondition=1, classificationCondition=1):
    """ User-i Device-j hack in User-i Device-k Model: iphone5 hack iphone6plus

    Returns
    -------
    float : error rate
    """
    rawDataiPhone6Plus = loadUserData(userid, 1, datatype=1) # moment data
    rawDataiPhone5     = loadUserData(userid, 2, datatype=1) # moment data

    trainingLabel = rawDataiPhone6Plus[:, 4]
    testLabel = rawDataiPhone5[:, 4]
    trainingData  = splitMomentDataByFeature(rawDataiPhone6Plus, featureCondition=featureCondition)
    testData  = splitMomentDataByFeature(rawDataiPhone5, featureCondition=featureCondition)

    trainingDataIP6, testDataIP6, trainingLabelIP6, testLabelIP6 = train_test_split(trainingData, trainingLabel, test_size=0.1, random_state=42)
    trainingDataIP5, testDataIP5, trainingLabelIP5, testLabelIP5 = train_test_split(    testData,     testLabel, test_size=0.1, random_state=42)

    return classify(trainingDataIP6, trainingLabelIP6, testDataIP5, testLabelIP5, kernel='linear', max_iter=500000)

def processMethod3(userid, featureCondition=1, classificationCondition=1):
    """ User-i Device-j hack in User-i Device-k Model: iphone6plus hack iphone5

    Returns
    -------
    float : error rate
    """
    rawDataiPhone6Plus = loadUserData(userid, 1, datatype=1) # moment data
    rawDataiPhone5     = loadUserData(userid, 2, datatype=1) # moment data

    trainingData  = splitMomentDataByFeature(rawDataiPhone5, featureCondition=featureCondition)
    trainingLabel = rawDataiPhone5[:, 4]

    testData  = splitMomentDataByFeature(rawDataiPhone6Plus, featureCondition=featureCondition)
    testLabel = rawDataiPhone6Plus[:, 4]

    return classify(trainingData, trainingLabel, testData, testLabel, kernel='linear', max_iter=5000000)

def processMethod4(userid, device, featureCondition=1, classificationCondition=1):
    """ User-i Device-j hack in User-k Device-j Model

    Returns
    -------
    float : error rate
    """
    rawDataList = []
    for i in xrange(1,17):
        rawDataList.append(loadUserData(i, device, datatype=1)) # moment data

    trainingData  = splitMomentDataByFeature(rawDataList[userid-1], featureCondition=featureCondition)
    trainingLabel = rawDataList[userid-1][:, 4]

    clfModel = classifyMOdel(trainingData, trainingLabel);

    hackErrorRateList = []

    for i in xrange(0,16):
        if (i+1)!=userid:

            error_count = 0.0
            result = clfModel.predict(splitMomentDataByFeature(rawDataList[i], featureCondition=featureCondition))

            for j, la in enumerate(result):
                if la != rawDataList[i][:,4][j]:
                    error_count += 1
            #hackErrorRateList.append(error_count/result.shape[0])
            print 'user ' + str(i) + ' hack ' + str(userid) + ', error rate: ' + str(error_count/result.shape[0]) + '\n'

    #return hackErrorRateList


def processMethod1ForAllUser(featureCondition):

    lines = []
    for i in xrange(1,17):
        for j in xrange(1,3):
            line =  'user' + str(i) + ' device' + str(j) + ' error rate: ' + str(processMethod1(i, j, featureCondition=featureCondition)) + '\n'
            lines.append(line)
    #print lines

    filepath = '../result/moment/method1/featureCondition' + str(featureCondition) + '.txt'
    f = open(filepath, 'w')
    f.writelines(lines)
    f.close()

    print 'featureCondition '+str(featureCondition) + ' finished..'

def processMethod2ForAllUser(featureCondition):

    lines = []
    for i in xrange(1,17):
        line =  'user' + str(i)+ ' iphone5 hack iphone6plus error rate: ' + str(processMethod2(i, featureCondition=featureCondition)) + '\n'
        lines.append(line)
    #print lines

    filepath = '../result/moment/method2/featureCondition' + str(featureCondition) + '.txt'
    f = open(filepath, 'w')
    f.writelines(lines)
    f.close()

    print 'featureCondition '+str(featureCondition) + ' finished..'

def processMethod3ForAllUser(featureCondition):

    lines = []
    for i in xrange(1,17):
        line =  'user' + str(i)+ ' iphone6plus hack iphone5 error rate: ' + str(processMethod3(i, featureCondition=featureCondition)) + '\n'
        lines.append(line)
    #print lines

    filepath = '../result/moment/method3/featureCondition' + str(featureCondition) + '.txt'
    f = open(filepath, 'w')
    f.writelines(lines)
    f.close()

    print 'featureCondition '+str(featureCondition) + ' finished..'

def threads(method):

    threads = []
    for featureCondition in xrange(1,17):
        t = threading.Thread()
        if method==1:
            t = threading.Thread(target=processMethod1ForAllUser, args=(featureCondition,))
        elif method==2:
            t = threading.Thread(target=processMethod2ForAllUser, args=(featureCondition,))
        elif method==3:
            t = threading.Thread(target=processMethod3ForAllUser, args=(featureCondition,))
        threads.append(t)

    print 'thread create sucess.'

    for i in xrange(0,16):
        threads[i].start()

    for i in xrange(0,16):
        threads[i].join()

    print 'Process method ' + str(method) + ' finished.'

def thread2():
    for i in xrange(1,17):
        print 'user' + str(i)+ ' iphone6plus hack iphone5 error rate: ' + str(processMethod2(i))

def thread3():
    for i in xrange(1,17):
        print 'user' + str(i)+ ' iphone5 hack iphone6plus error rate: ' + str(processMethod3(i))

#print 'method1 start...'
#threads(1)
#print 'method2 start...'
#threads(2)
#print 'method3 start...'
#threads(3)

#processMethod4(1, 1)
