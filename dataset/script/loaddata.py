import csv
import numpy as np

def prefix(userid):
    if userid<10:
        return '0'+str(userid)
    else:
        return str(userid)


# device   == 1 : iphone 6 plus
#          == 2 : iphone 5
# datatype == 1 : moment data
#          == 2 : buffer data
def filePath(userid, device, datatype):
    if device==1:
        if datatype==1:
            return '../data/' + prefix(userid) + '/1.1.csv'
        else:
            return '../data/' + prefix(userid) + '/2.1.csv'
    else:
        if datatype==1:
            return '../data/' + prefix(userid) + '/1.2.csv'
        else:
            return '../data/' + prefix(userid) + '/2.2.csv'

# device   == 1 : iphone 6 plus
#          == 2 : iphone 5
# datatype == 1 : moment data
#          == 2 : buffer data
def loadUserData(userid=1, device=1, datatype=1, delimiter=','):
    filepath = filePath(userid, device=device, datatype=datatype)
    csvfile = open(filepath)
    csv_reader = csv.reader(csvfile, delimiter=delimiter)
    data = np.array([row for row in csv_reader])
    csvfile.close()
    return data[1:, 2:]


# TODO: normalization module
def normalization(positionData, device):
    #if device==1: #iphone 6 plus
        #nor_x = positionData[:, 0]/414.0
        #nor_y = positionData[:, 1]/736.0
    #else:
        #nor_x = positionData[:, 0]/320.0
        #nor_y = positionData[:, 1]/568.0
    #print np.append(nor_x, nor_y, axis=1)
    #norData = np.c_[nor_x.ravel(), nor_y.ravel(), data[:, 2:]]
    return 1

def splitMomentDataByLabel(rawdata, label, classificationCondition=1):
    # classificationCondition: int
    #     1: Thumb Classification (left thumb, right thumb)
    #     2: Index Finger Classification (left index, right index)
    #     3: Multi-Classification (left thumb, right thumb, left index, right index)
    return 1# data, label;

def splitMomentDataByFeature(rawdata, featureCondition=1):
    """
    Parameters
    ----------
    featureCondition: int
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
    # positionData    = normalization(rawdata[:, 5:7], device=device)
    # offsetData      = rawdata[:, 7:9]

    # attitudeData    = rawdata[:, 9:12]
    # acceleratorData = rawdata[:, 12:15]
    # gyroscopeData   = rawdata[:, 15:18]

    if   featureCondition==1:
        return rawdata[:, [5,6,9]]
    elif featureCondition==2:
        return rawdata[:, [5,6,10]]
    elif featureCondition==3:
        return rawdata[:, [5,6,11]]
    elif featureCondition==4:
        return rawdata[:, [5,6,12]]
    elif featureCondition==5:
        return rawdata[:, [5,6,13]]
    elif featureCondition==6:
        return rawdata[:, [5,6,14]]
    elif featureCondition==7:
        return rawdata[:, [5,6,15]]
    elif featureCondition==8:
        return rawdata[:, [5,6,16]]
    elif featureCondition==9:
        return rawdata[:, [5,6,17]]
    elif featureCondition==10:
        return rawdata[:, [5,6,9,10,11]]
    elif featureCondition==11:
        return rawdata[:, [5,6,12,13,14]]
    elif featureCondition==12:
        return rawdata[:, [5,6,15,16,17]]
    elif featureCondition==13:
        return rawdata[:, [5,6,9,10,11,12,13,14]]
    elif featureCondition==14:
        return rawdata[:, [5,6,9,10,11,15,16,17]]
    elif featureCondition==15:
        return rawdata[:, [5,6,12,13,14,15,16,17]]
    else: #featureCondition==16
        return rawdata[:, [5,6,9,10,11,12,13,14,15,16,17]]
