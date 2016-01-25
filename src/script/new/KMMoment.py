import time

import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D

from sklearn.cluster import MiniBatchKMeans
from sklearn.cross_validation import train_test_split

from loaddata import loadUserData
from loaddata import splitMomentDataByFeature
from loaddata import splitMomentDataByLabel
from loaddata import splitMomentDataByFeatureAndLabel

userid=1
device=1
featureCondition=3
classificationCondition=1
offsetFeatureOn=True

batch_size = 45
my_test_size = 0.3
my_random_state = 42

data, label = splitMomentDataByFeatureAndLabel(userid, device, featureCondition, classificationCondition, offsetFeatureOn=offsetFeatureOn)
trainingData, testData, trainingLabel, testLabel = train_test_split(data, label, test_size=my_test_size, random_state=my_random_state)

def plot3DLabel(data, label, trainLabel):
    print data.shape
    print label
    fig = plt.figure()
    ax = fig.add_subplot(211, projection='3d')
    x = [float(value)/736 for value in data[:,0]]
    y = [float(value)/414 for value in data[:,1]]
    z = [float(value) for value in data[:,2]]
    label = [1 if value=='1' else 0 for value in label]

    ax.scatter(x,y,z,c=label, marker='o')
    ax.set_xlabel('X')
    ax.set_ylabel('Y')
    ax.set_zlabel('roll')

    ax = fig.add_subplot(212, projection='3d')
    ax.scatter(x,y,z,c=trainLabel, marker='o')
    ax.set_xlabel('X')
    ax.set_ylabel('Y')
    ax.set_zlabel('roll')
    plt.show()



mbk = MiniBatchKMeans(init='k-means++', n_clusters=2,batch_size=batch_size,\
                      n_init=10, max_no_improvement=10, verbose=0)
t0 = time.time()
mbk.fit(trainingData)
t_mini_batch = time.time() - t0
mbk_means_labels = mbk.labels_
mbk_means_cluster_centers = mbk.cluster_centers_
mbk_means_labels_unique = np.unique(mbk_means_labels)

plot3DLabel(trainingData, trainingLabel, mbk_means_labels)

def testingWithModel(testData, testLabel, model):
    error_count = 0.0
    result = model.predict(testData)
    for i, la in enumerate(result):
        if la != testLabel[i]:
            error_count += 1
    return error_count/result.shape[0]

#print testingWithModel(testData, testLabel, mbk)

print mbk_means_labels_unique

# print trainingData[:,0], trainingData[:,1], trainingData[:,2]

# fig = plt.figure()
# ax = fig.add_subplot(111, projection='3d')
# ax.scatter(trainingData[:,0],trainingData[:,1],trainingData[:,2],color='red')

# plt.show()


