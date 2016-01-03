# coding:utf-8
from loaddata import loadUserData
from loaddata import splitMomentDataByFeature
from loaddata import splitMomentDataByLabel
from loaddata import splitMomentDataByFeatureAndLabel

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

# basic parameters
my_kernel = 'linear'
my_max_iteration = 500000
my_test_size = 0.3
my_random_state = 42

def classifyModel(trainingData, trainingLabel, kernel='linear', max_iter=-1):
    clf = svm.SVC(kernel=kernel, max_iter=max_iter).fit(trainingData, trainingLabel)
    return clf
def testingWithModel(testData, testLabel, model):
    error_count = 0.0
    result = model.predict(testData)
    for i, la in enumerate(result):
        if la != testLabel[i]:
            error_count += 1
    return error_count/result.shape[0]
def classify(trainingData, trainingLabel, testData, testLabel, kernel='linear', max_iter=-1):
    clf = classifyModel(trainingData, trainingLabel, kernel=kernel, max_iter=max_iter)
    return testingWithModel(testData, testLabel, clf)

def processMethod1(userid, device, featureCondition=1, classificationCondition=1, offsetFeatureOn=False):
    """
    User-i Device-j hack in User-i Device-j Model (cross validation)
        i=1,2,...,16
        j=1,2
    Returns
    -------
    float : error rate
    """
    data, label = splitMomentDataByFeatureAndLabel(userid, device, featureCondition, classificationCondition, offsetFeatureOn=offsetFeatureOn)
    # rawData = loadUserData(userid, device, datatype)
    # data = splitMomentDataByFeature(rawData, featureCondition=featureCondition)
    # label = rawData[:, 4]
    # if featureCondition==0:
    #     pass
    trainingData, testData, trainingLabel, testLabel = train_test_split(data, label, test_size=my_test_size, random_state=my_random_state)

    return classify(trainingData, trainingLabel, testData, testLabel, kernel=my_kernel, max_iter=my_max_iteration)
def processMethod2(userid, featureCondition=1, classificationCondition=1, offsetFeatureOn=False):
    """ User-i Device-j hack in User-i Device-k Model: iphone5 hack iphone6plus

    Returns
    -------
    float : error rate
    """
    iPhone6Plus = 1
    iPhone5     = 2
    trainingData, trainingLabel = splitMomentDataByFeatureAndLabel(userid, iPhone6Plus, featureCondition, classificationCondition, offsetFeatureOn=offsetFeatureOn)
    testData, testLabel         = splitMomentDataByFeatureAndLabel(userid, iPhone5, featureCondition, classificationCondition, offsetFeatureOn=offsetFeatureOn)

    # rawDataiPhone6Plus = loadUserData(userid, 1, datatype=1) # moment data
    # rawDataiPhone5     = loadUserData(userid, 2, datatype=1) # moment data

    # trainingLabel = rawDataiPhone6Plus[:, 4]
    # testLabel = rawDataiPhone5[:, 4]
    # trainingData  = splitMomentDataByFeature(rawDataiPhone6Plus, featureCondition=featureCondition)
    # testData  = splitMomentDataByFeature(rawDataiPhone5, featureCondition=featureCondition)

    # use same test size with method1
    trainingDataIP6, testDataIP6, trainingLabelIP6, testLabelIP6 = train_test_split(trainingData, trainingLabel, test_size=my_test_size, random_state=my_random_state)
    trainingDataIP5, testDataIP5, trainingLabelIP5, testLabelIP5 = train_test_split(    testData,     testLabel, test_size=my_test_size, random_state=my_random_state)

    return classify(trainingDataIP6, trainingLabelIP6, testDataIP5, testLabelIP5, kernel=my_kernel, max_iter=my_max_iteration)
def processMethod3(userid, featureCondition=1, classificationCondition=1, offsetFeatureOn=False):
    """ User-i Device-j hack in User-i Device-k Model: iphone6plus hack iphone5

    Returns
    -------
    float : error rate
    """
    # rawDataiPhone6Plus = loadUserData(userid, 1, datatype=1) # moment data
    # rawDataiPhone5     = loadUserData(userid, 2, datatype=1) # moment data

    # trainingData  = splitMomentDataByFeature(rawDataiPhone5, featureCondition=featureCondition)
    # trainingLabel = rawDataiPhone5[:, 4]

    # testData  = splitMomentDataByFeature(rawDataiPhone6Plus, featureCondition=featureCondition)
    # testLabel = rawDataiPhone6Plus[:, 4]

    iPhone6Plus = 1
    iPhone5     = 2
    trainingData, trainingLabel = splitMomentDataByFeatureAndLabel(userid, iPhone5, featureCondition, classificationCondition, offsetFeatureOn=offsetFeatureOn)
    testData, testLabel         = splitMomentDataByFeatureAndLabel(userid, iPhone6Plus, featureCondition, classificationCondition, offsetFeatureOn=offsetFeatureOn)

    # use same test size with method1
    trainingDataIP5, testDataIP5, trainingLabelIP5, testLabelIP5 = train_test_split(trainingData, trainingLabel, test_size=my_test_size, random_state=my_random_state)
    trainingDataIP6, testDataIP6, trainingLabelIP6, testLabelIP6 = train_test_split(    testData,     testLabel, test_size=my_test_size, random_state=my_random_state)

    return classify(trainingDataIP5, trainingLabelIP5, testDataIP6, testLabelIP6, kernel=my_kernel, max_iter=my_max_iteration)
def processMethod4(userid, device, featureCondition=1, classificationCondition=1, offsetFeatureOn=False):
    """ User-i Device-j hack in User-k Device-j Model

    Returns
    -------
    float : error rate
    """
    trainingData, trainingLabel = splitMomentDataByFeatureAndLabel(userid, device, featureCondition, classificationCondition, offsetFeatureOn=offsetFeatureOn)
    trainingData, testData, trainingLabel, testLabel = train_test_split(trainingData, trainingLabel, test_size=my_test_size, random_state=my_random_state) # use same test size with method1
    clfModel = classifyModel(trainingData, trainingLabel, kernel=my_kernel, max_iter=my_max_iteration)

    hackErrorRateTextList = []
    hackErrorRateList     = []
    for testUser in xrange(1, 17):
        if testUser != userid :
            testData, testLabel = splitMomentDataByFeatureAndLabel(testUser, device, featureCondition, classificationCondition, offsetFeatureOn=offsetFeatureOn)
            trainingData, testData, trainingLabel, testLabel = train_test_split(testData, testLabel, test_size=my_test_size, random_state=my_random_state) # use same test size with method1
            error_rate = testingWithModel(testData, testLabel, clfModel)
            line = 'user ' + str(testUser) + ' hack ' + str(userid) + ', error rate: ' + str(error_rate) + '\n'
            hackErrorRateList.append(error_rate)
            hackErrorRateTextList.append(line)

    return hackErrorRateTextList, hackErrorRateList

def processMethod1ForAllUser(featureCondition, classificationCondition, offsetFeatureOn):
    lines = []
    for userid in xrange(1,17):
        for device in xrange(1,3):
            error_rate = processMethod1(userid, device, featureCondition=featureCondition, classificationCondition=classificationCondition, offsetFeatureOn=offsetFeatureOn)
            line =  'user' + str(userid) + ' device' + str(device) + ' error rate: ' + str(error_rate) + '\n'
            lines.append(line)

    filepath = '../result/moment/method1/clfCondition' + str(classificationCondition) + '/featureCondition' + str(featureCondition) + '.txt'
    f = open(filepath, 'w')
    f.writelines(lines)
    f.close()

    print 'Method 1 featureCondition' + str(featureCondition) + ' and clfCondition' + str(classificationCondition) + ' finished.'
def processMethod2ForAllUser(featureCondition, classificationCondition, offsetFeatureOn):
    lines = []
    for userid in xrange(1,17):
        error_rate = processMethod2(userid, featureCondition=featureCondition, classificationCondition=classificationCondition, offsetFeatureOn=offsetFeatureOn)
        line =  'user' + str(userid)+ ' iphone5 hack iphone6plus error rate: ' + str(error_rate) + '\n'
        lines.append(line)

    filepath = '../result/moment/method2/clfCondition' + str(classificationCondition) + '/featureCondition' + str(featureCondition) + '.txt'
    f = open(filepath, 'w')
    f.writelines(lines)
    f.close()

    print 'Method 2 featureCondition' + str(featureCondition) + ' and clfCondition' + str(classificationCondition) + ' finished.'
def processMethod3ForAllUser(featureCondition, classificationCondition, offsetFeatureOn):
    lines = []
    for userid in xrange(1,17):
        error_rate = processMethod2(userid, featureCondition=featureCondition, classificationCondition=classificationCondition, offsetFeatureOn=offsetFeatureOn)
        line =  'user' + str(userid)+ ' iphone6plus hack iphone5 error rate: ' + str(error_rate) + '\n'
        lines.append(line)
    filepath = '../result/moment/method3/clfCondition' + str(classificationCondition) + '/featureCondition' + str(featureCondition) + '.txt'
    f = open(filepath, 'w')
    f.writelines(lines)
    f.close()

    print 'Method 3 featureCondition' + str(featureCondition) + ' and clfCondition' + str(classificationCondition) + ' finished.'
def processMethod4ForAllUser(featureCondition, classificationCondition, offsetFeatureOn):

    for userid in xrange(1,17):
        for device in xrange(1,3):
            filepath = '../result/moment/method4/clfCondition' + str(classificationCondition) + '/featureCondition' + str(featureCondition) + '/user'
            if device == 1:
                filepath = filepath  + str(userid) + '_iphone6plus.txt'
            else:
                filepath = filepath  + str(userid) + '_iphone5.txt'
            # if os.path.exists(filepath)==True:
            #     continue
            # else:
            userHackRecord, _ = processMethod4(userid, device, featureCondition=featureCondition, classificationCondition=classificationCondition, offsetFeatureOn=offsetFeatureOn)
            f = open(filepath, 'w')
            f.writelines(userHackRecord)
            f.close()
            print 'finish user' + str(userid) + ' device' + str(device)

    print 'Method 4 featureCondition' + str(featureCondition) + ' and clfCondition' + str(classificationCondition) + ' finished.'

def Method1Threads(xyfeature):
    threads = []

    for clfCondition in xrange(1, 5):
        for featureCondition in xrange(0,17):
            t = threading.Thread()
            t = threading.Thread(target=processMethod1ForAllUser, args=(featureCondition, clfCondition, xyfeature))
            threads.append(t)
    print 'thread create success.'

    for i in xrange(0,17*4):
        threads[i].start()

    for i in xrange(0,17*4):
        threads[i].join()

    print 'Process 1 finished...'
def Method2Threads(xyfeature):
    threads = []

    for clfCondition in xrange(1, 5):
        for featureCondition in xrange(0,17):
            t = threading.Thread()
            t = threading.Thread(target=processMethod2ForAllUser, args=(featureCondition, clfCondition, xyfeature))
            threads.append(t)
    print 'thread create success.'

    for i in xrange(0,17*4):
        threads[i].start()
    for i in xrange(0,17*4):
        threads[i].join()

    print 'Process 2 finished...'
def Method3Threads(xyfeature):
    threads = []

    for clfCondition in xrange(1, 5):
        for featureCondition in xrange(0,17):
            t = threading.Thread()
            t = threading.Thread(target=processMethod3ForAllUser, args=(featureCondition, clfCondition, xyfeature))
            threads.append(t)
    print 'thread create success.'

    for i in xrange(0,17*4):
        threads[i].start()
    for i in xrange(0,17*4):
        threads[i].join()

    print 'Process 3 finished...'
def Method4Threads(xyfeature):
    threads = []

    for clfCondition in xrange(1, 5):
        for featureCondition in xrange(0,17):
            t = threading.Thread()
            t = threading.Thread(target=processMethod4ForAllUser, args=(featureCondition, clfCondition, xyfeature))
            threads.append(t)
    print 'thread create success.'

    for j in xrange(0,4):
        for i in xrange(0,17):
            threads[j*17+i].start()
        for i in xrange(0,17):
            threads[j*17+i].join()

    print 'Process 4 finished...'

def Method1DrawAllUser():
    for userid in xrange(1, 17):
        drawErrorRate(userid, True)
    print 'Draw process finished...'

# 画出每个用户在四个不同clf条件下，不同feature条件的error_rate
def drawErrorRate(userid, offset):
    featureAxis = np.arange(0, 17)

    plt.figure(figsize=(5,13))
    for clfCondition in xrange(1, 5):
        plt.subplot(4, 1, clfCondition)
        errorRateDict = { 1:[], 2:[] }
        for device in xrange(1,3):
            for featureCondition in xrange(0, 17):
                err = processMethod1(userid, device, featureCondition=featureCondition, classificationCondition=clfCondition, offsetFeatureOn=offset)
                errorRateDict[device].append(err)
            if device==1:
                plt.axhline(errorRateDict[device][0], color='red') # draw feature base line
                plt.plot(featureAxis, errorRateDict[device], label='iPhone 6 Plus', color='red', linestyle='dashdot', marker='v')
            elif device==2:
                plt.axhline(errorRateDict[device][0], color='blue') # draw base line
                plt.plot(featureAxis, errorRateDict[device], label='iPhone 5', color='blue', linestyle='dashdot', marker='o')
            plt.title('Classification condition ' + str(clfCondition), fontsize='small')
            plt.legend(loc='upper right', fontsize='small')
            plt.axis([0, 16, 0, 1])
            plt.ylabel('Error Rate')
            plt.axhline(0.05, color='green') # draw error rate base line
        print 'finish condition' + str(clfCondition)

    plt.xlabel('Feature Condition')
    plt.suptitle('User ' + str(userid))

    fileName = '../result/img/result/method1/'+str(userid)+'.png'
    #plt.show()
    plt.savefig(fileName, dpi=72)
    plt.close('all')
    print 'finish save user ' + str(userid) + '.'

def Method4DrawAllUser():
    for userid in xrange(1, 17):
        drawMethod4AverageErrorRate(userid, False)
    print 'Draw process finished...'
def drawMethod4AverageErrorRate(userid, offset):
    featureAxis = np.arange(0, 17)

    plt.figure(figsize=(5,13))
    for clfCondition in xrange(1, 5):
        plt.subplot(4, 1, clfCondition)
        errorRateDict = { 1:[], 2:[] }
        for device in xrange(1,3):
            for featureCondition in xrange(0, 17):
                _, errList = processMethod4(userid, device, featureCondition=featureCondition, classificationCondition=clfCondition, offsetFeatureOn=offset)
                err = np.mean(errList)
                errorRateDict[device].append(err)
            if device==1:
                plt.axhline(errorRateDict[device][0], color='red') # draw feature base line
                plt.plot(featureAxis, errorRateDict[device], label='iPhone 6 Plus', color='red', linestyle='dashdot', marker='v')
            elif device==2:
                plt.axhline(errorRateDict[device][0], color='blue') # draw base line
                plt.plot(featureAxis, errorRateDict[device], label='iPhone 5', color='blue', linestyle='dashdot', marker='o')
            plt.title('Classification condition ' + str(clfCondition), fontsize='small')
            plt.legend(loc='upper right', fontsize='small')
            plt.axis([0, 16, 0, 1])
            plt.ylabel('Error Rate')
            plt.axhline(0.05, color='green') # draw error rate base line
        print 'finish condition' + str(clfCondition)

    plt.xlabel('Feature Condition')
    plt.suptitle('User ' + str(userid))

    fileName = '../result/img/result/method4/'+str(userid)+'.png'
    #plt.show()
    plt.savefig(fileName, dpi=72)
    plt.close('all')
    print 'finish save user ' + str(userid) + '.'


def plotROC(userid, device, featureCondition, classificationCondition, offset=False, noisyOn=True):
    # userid = 1
    # device = 1
    # featureCondition = 10
    # classificationCondition = 3
    # offset = False
    # noisyOn = True
    #np.set_printoptions(threshold='nan')

    # import data to play with
    data, label = splitMomentDataByFeatureAndLabel(userid, device, featureCondition, classificationCondition, offsetFeatureOn=offset)

    # binarize the output
    classes = list()
    if classificationCondition==1:
        classes=['0','1']
    elif classificationCondition==2:
        classes=['2','3']
    elif classificationCondition==3:
        classes=['0','1','2','3']
    else: # classificationCondition==4
        classes=['0','1']
    label = label_binarize(label, classes=classes)

    n_classes = label.shape[1]

    # add noisy feature to make problem harder
    if noisyOn==True:
        random_state = np.random.RandomState(my_random_state)
        n_samples, n_features = data.shape
        data = np.c_[data, random_state.randn(n_samples, 200 * n_features)]

    #shuffle and split traning and test sets
    trainingData, testData, trainingLabel, testLabel = train_test_split(data, label, test_size=0.5, random_state=my_random_state)

    # learn to predict each class against the other
    classifier = OneVsRestClassifier(svm.SVC(kernel=my_kernel, probability=True, random_state=my_random_state, max_iter=my_max_iteration))
    label_score = classifier.fit(trainingData, trainingLabel).decision_function(testData)

    print 'decision success.'

    # Compute ROC curve and ROC area for each class
    fpr = dict()
    tpr = dict()
    roc_auc = dict()

    for i in range(n_classes):
        fpr[i], tpr[i], _ =roc_curve(testLabel[:, i], label_score[:, i])
        roc_auc[i] = auc(fpr[i], tpr[i])

    # # Compute micro-average ROC curve and ROC area
    # print testLabel
    # print label_score
    # fpr["micro"], tpr["micro"], _ = roc_curve(testLabel.ravel(), label_score.ravel())
    # roc_auc["micro"] = auc(fpr["micro"], tpr["micro"])

    # # Compute macro-average ROC curve and ROC area
    # # First aggregate all false positive rates
    # all_fpr = np.unique(np.concatenate([fpr[i] for i in range(n_classes)]))
    # # Then interpolate all ROC curves at this points
    # mean_tpr = np.zeros_like(all_fpr)
    # for i in range(n_classes):
    #     mean_tpr += interp(all_fpr, fpr[i], tpr[i])
    # # Finally average it and compute AUC
    # mean_tpr /= n_classes

    # fpr["macro"] = all_fpr
    # tpr["macro"] = mean_tpr
    # roc_auc["macro"] = auc(fpr["macro"], tpr["macro"])

    # Plot all ROC curves
    plt.figure()
    # plt.plot(fpr["micro"], tpr["micro"],
    #          label='micro-average ROC curve (area = {0:0.2f})'
    #                ''.format(roc_auc["micro"]),
    #          linewidth=2)

    # plt.plot(fpr["macro"], tpr["macro"],
    #          label='macro-average ROC curve (area = {0:0.2f})'
    #                ''.format(roc_auc["macro"]),
    #          linewidth=2)

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

    fileName = '../result/img/roc/clf'+str(classificationCondition)+'/featureCondition' + str(featureCondition) + '/device' + str(device) + '/user' + str(userid) + '.png'
    plt.savefig(fileName, dpi=72)
    print 'finish ' + fileName
    plt.close('all')

    #plt.show()
def plotROCforAll():
    for classificationCondition in xrange(1,5):
        for featureCondition in xrange(0,17):
            for device in xrange(1,3):
                for userid in xrange(1,17):
                    plotROC(userid, device, featureCondition, classificationCondition, offset=False, noisyOn=True)
                    #print 'finish clf' + str(classificationCondition) + ' feature' + str(featureCondition) + ' user' + str(userid)

def main():

    #Method1DrawAllUser()
    Method4DrawAllUser()

    # Method1Threads(True)
    # Method2Threads(True)
    # Method3Threads(True)
    # Method4Threads(True)
    #plotROCforAll()


if __name__ == '__main__':
    main()
