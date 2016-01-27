import numpy as np
import csv
from sklearn.cross_validation import train_test_split

datasets_dir = './'
my_test_size = 0.5
my_random_state = 42

def __prefix(userid):
    if userid < 10:
        return '0'+str(userid)
    else:
        return str(userid)

def __path(userid, device, datatype):
    if device==1:
        if datatype==1:
            return '../data/' + __prefix(userid) + '/1.1.csv'
        else:
            return '../data/' + __prefix(userid) + '/2.1.csv'
    else:
        if datatype==1:
            return '../data/' + __prefix(userid) + '/1.2.csv'
        else:
            return '../data/' + __prefix(userid) + '/2.2.csv'

def loadUserData(userid, device, datatype=1):
    '''
    device   == 1 : iphone 6 plus
             == 2 : iphone 5
    datatype == 1 : moment data
             == 2 : buffer data

     Return Value
     ------------
     data format:
     when datatype == 1:
          column:
              0 test_count,
              1 test_case,
              2 tap_count,
              3 moving_flag,
              4 hand_posture,
              5 x,
              6 y,
              7 offset_x,
              8 offset_y,
              9 roll,
             10 pitch,
             11 yaw,
             12 acc_x,
             13 acc_y,
             14 acc_z,
             15 rotation_x,
             16 rotation_y,
             17 rotation_z,
             18 touch_time
    when datatype == 2:
        column:
              0 test_count,
              1 test_case,
              2 tap_count,
              3 sensor_flag,
              4 hand_posture,
              5 x,
              6 y,
              7 z
    '''
    f = open(__path(userid, device, datatype))
    reader = csv.reader(f, delimiter=',')
    data   = np.array([row for row in reader])
    f.close()
    return data[1:, 2:]
def splitMomentDataByLabel(rawdata, label, classificationCondition=1):
    """
    classificationCondition: int

        1: Thumb Classification (left thumb, right thumb)
        2: Index Finger Classification (left index, right index)
        3: Multi-Classification (left thumb, right thumb, left index, right index)
        4: Hand Classification (left thumb+index, right thumb+index)

    when classificationCondition>=5, only get one labeled data, this is only used for authentication.
        5: leftThumbData
        6: rightThumbData
        7: leftIndexData
        8: rightIndexData
    """
    converLabel = [[value] for value in label]
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
    elif classificationCondition==4:
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
    elif classificationCondition==5:
        dataWithLabel = leftThumbData
    elif classificationCondition==6:
        dataWithLabel = rightThumbData
    elif classificationCondition==7:
        dataWithLabel = leftIndexData
    elif classificationCondition==8:
        dataWithLabel = rightIndexData

    newData = dataWithLabel[:,0:-1]
    newLabel = dataWithLabel[:,-1]

    return newData, newLabel

def splitMomentDataByFeature(rawdata, offsetFeatureOn=False, featureCondition=1):
    """
    Parameters
    ----------
    offsetOn: Bool

        False: do not use offset feature
         True: use offset position features

    featureCondition: int

        0: (x, y)               # baseline
        1: (x, y, atti_roll)
        2: (x, y, atti_pitch)
        3: (x, y, atti_yaw)
        4: (x, y, acce_x)
        5: (x, y, acce_y)
        6: (x, y, acce_z)
        7: (x, y, gyro_x)
        8: (x, y, gyro_y)
        9: (x, y, gyro_z)
       10: (x, y, atti_{roll,pitch,yaw})
       11: (x, y, acce_{x,y,z})
       12: (x, y, gyro_{x,y,z})
       13: (x, y, atti{roll,pitch,yaw}, acce{x,y,z})
       14: (x, y, atti{roll,pitch,yaw}, gyro{x,y,z})
       15: (x, y, acce{x,y,z}, gyro{x,y,z})
       16: (x, y, atti_{roll,pitch,yaw}, acce_{x,y,z}, gyro_{x,y,z})
    """
    # TODO: applying data normalization
    # positionData    = normalization(rawdata[:, 5:7], device=device)

    offset=0
    if offsetFeatureOn==True:
        offset=2

    if featureCondition==0: # baseline
        return rawdata[:, [5+offset,6+offset]]
    elif featureCondition==1:
        return rawdata[:, [5+offset,6+offset,9]]
    elif featureCondition==2:
        return rawdata[:, [5+offset,6+offset,10]]
    elif featureCondition==3:
        return rawdata[:, [5+offset,6+offset,11]]
    elif featureCondition==4:
        return rawdata[:, [5+offset,6+offset,12]]
    elif featureCondition==5:
        return rawdata[:, [5+offset,6+offset,13]]
    elif featureCondition==6:
        return rawdata[:, [5+offset,6+offset,14]]
    elif featureCondition==7:
        return rawdata[:, [5+offset,6+offset,15]]
    elif featureCondition==8:
        return rawdata[:, [5+offset,6+offset,16]]
    elif featureCondition==9:
        return rawdata[:, [5+offset,6+offset,17]]
    elif featureCondition==10:
        return rawdata[:, [5+offset,6+offset,9,10,11]]
    elif featureCondition==11:
        return rawdata[:, [5+offset,6+offset,12,13,14]]
    elif featureCondition==12:
        return rawdata[:, [5+offset,6+offset,15,16,17]]
    elif featureCondition==13:
        return rawdata[:, [5+offset,6+offset,9,10,11,12,13,14]]
    elif featureCondition==14:
        return rawdata[:, [5+offset,6+offset,9,10,11,15,16,17]]
    elif featureCondition==15:
        return rawdata[:, [5+offset,6+offset,12,13,14,15,16,17]]
    else: #featureCondition==16
        return rawdata[:, [5+offset,6+offset,9,10,11,12,13,14,15,16,17]]

def splitMomentDataByFeatureAndLabel(userid, device, featureCondition, classificationCondition, offsetFeatureOn):
    rawData = loadUserData(userid, device, datatype=1)
    data = splitMomentDataByFeature(rawData, offsetFeatureOn=offsetFeatureOn, featureCondition=featureCondition)
    label = rawData[:, 4] # hand posture column
    data, label = splitMomentDataByLabel(data, label, classificationCondition=classificationCondition)
    return data, label

def touch_data(userid, device, feature, clf, offset):
    data, label = splitMomentDataByFeatureAndLabel(userid, device, feature, clf, offset)
    data  = data.astype(float)
    label = label.astype(float)
    return train_test_split(data, label, test_size=my_test_size, random_state=my_random_state)
