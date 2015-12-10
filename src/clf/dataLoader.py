# filepath: '/Users/ouchangkun/Desktop/course/daniel-project/clf/data/training/'

# data format:
# 0 <= x <= 414, 0 <= y <= 736
# -3 <= roll, pitch, yaw <= 3
# label: 1 == left, 0 == right
# return: [x, y, roll, pitch, yaw, label]

import numpy as np
from sklearn import svm

# plot 3d
from mpl_toolkits.mplot3d import Axes3D
import matplotlib.pyplot as plt
from matplotlib import cm

def loadData(filepath):
    f_left = open(filepath+'data-left.txt', 'r')
    f_right = open(filepath+'data-right.txt', 'r')

    result = []
    while True:
        line = f_left.readline()
        if line:
            v = [float(value) for value in line[0:len(line)-1].split(',')]
            result.append(v)
        else:
            break
    while True:
        line = f_right.readline()
        if line:
            v = [float(value) for value in line[0:len(line)-1].split(',')]
            result.append(v)
        else:
            break
    a = np.array(result)
    f_left.close()
    f_right.close()
    return a

def loadDataStr(filepath):
    tmp_left = np.loadtxt(filepath+'data-left-str.txt', dtype=np.str, delimiter=',')
    tmp_right = np.loadtxt(filepath+'data-right-str.txt', dtype=np.str, delimiter=',')

    data_left = tmp_left[:,0:-1].astype(np.float)
    data_right = tmp_right[:,0:-1].astype(np.float)
    
    label_left = tmp_left[:,-1].astype(np.str)
    label_right = tmp_right[:,-1].astype(np.str)

    data = np.append(data_left, data_right, axis = 0)
    label = np.append(label_left, label_right, axis = 0)
    return data, label

#normalization
def nor(data):
    #lenth, dimension = data.shape
    nor_x = data[:, 0]/414.0
    nor_y = data[:, 1]/736.0
    new = np.c_[nor_x.ravel(), nor_y.ravel(), data[:, 2:]]
    return new


# data==[x,y,roll,pitch,yaw,label]
# axis==1,2,3 means roll, pitch, yaw
def plot3Ddata(data, axis):
    fig = plt.figure()
    ax = fig.add_subplot(111, projection='3d')
    
    x = data[:, 0]
    y = data[:, 1]
    z = data[:, axis+1]
    label = data[:, -1]
    
    i = 0
    for l in label:
        if l == 1: #left hand
            ax.scatter(x[i],y[i],z[i],c='r',marker='o')
        else:
            ax.scatter(x[i],y[i],z[i],c='b',marker='^')
        i+=1
    ax.set_xlabel('touch X')
    ax.set_ylabel('touch Y')

    if axis == 1:
        ax.set_zlabel('roll value')
    elif axis == 2:
        ax.set_zlabel('pitch value')
    else:
        ax.set_zlabel('yaw value')
    plt.show()

def plot2DataSet(data1, data2, axis):
    fig = plt.figure()
    ax = fig.add_subplot(111, projection='3d')
    
    #plot data1
    x1 = data1[:, 0]
    y1 = data1[:, 1]
    z1 = data1[:, axis+1]
    label1 = data1[:, -1]
    
    i = 0
    for l in label1:
        if l == 1: #left hand
            ax.scatter(x1[i],y1[i],z1[i],c='r',marker='o')
        else:
            ax.scatter(x1[i],y1[i],z1[i],c='b',marker='^')
        i+=1
    
    #plot data2
    x2 = data2[:, 0]
    y2 = data2[:, 1]
    z2 = data2[:, axis+1]
    label2 = data2[:, -1]
    
    i = 0
    for l in label2:
        if l == 1: #left hand
            ax.scatter(x2[i],y2[i],z2[i],c='black',marker='o')
        else:
            ax.scatter(x2[i],y2[i],z2[i],c='white',marker='^')
        i+=1

    ax.set_xlabel('touch X')
    ax.set_ylabel('touch Y')

    if axis == 1:
        ax.set_zlabel('roll value')
    elif axis == 2:
        ax.set_zlabel('pitch value')
    else:
        ax.set_zlabel('yaw value')
    plt.show()


def trainingSVC(data, test, gamma, C):
    x = data[:, 0:2]
    label = data[:, -1]
    
    print x.shape
    print label

    clf = svm.SVC(kernel='linear').fit(x, label)
    
    print clf
    print clf.support_vectors_.shape
    print clf.n_support_

    error_count = 0
    for t in test:
        print 'pridict:' + str(clf.predict(t[0:2])) + ' truevalue:' + str(t[-1])
        if clf.predict(t[0:2]) == t[-1]:
            continue
        else:
            error_count += 1

#print error_count
#print test.shape
    print 'error rate:' + str(float(error_count)/test.shape[0])

