import dataLoader as dl

import numpy as np
from sklearn import svm
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
from sklearn import decomposition
from sklearn.lda import LDA

def pca(data, target):
    centers = [[1, 1], [-1, -1], [1, -1]]
    X = data
    yy=[]
    for i, l in enumerate(target):
        if l == 'left':
            yy.append(1);
        else:
            yy.append(0);
    y = np.array(yy)

    fig = plt.figure(1, figsize=(4, 3))
    plt.clf()
    ax = Axes3D(fig, rect=[0, 0, .95, 1], elev=48, azim=134)

    plt.cla()
    pca = decomposition.PCA(n_components=3)
    pca.fit(X)
    X = pca.transform(X)

    for name, label in [('Setosa', 0), ('Versicolour', 1), ('Virginica', 2)]:
        ax.text3D(X[y == label, 0].mean(),
                  X[y == label, 1].mean() + 1.5,
                  X[y == label, 2].mean(), name,
                  horizontalalignment='center',
                  bbox=dict(alpha=.5, edgecolor='w', facecolor='w'))
    # Reorder the labels to have colors matching the cluster results
    y = np.choose(y, [1, 2, 0]).astype(np.float)
    ax.scatter(X[:, 0], X[:, 1], X[:, 2], c=y, cmap=plt.cm.spectral)

    x_surf = [X[:, 0].min(), X[:, 0].max(),
              X[:, 0].min(), X[:, 0].max()]
    y_surf = [X[:, 0].max(), X[:, 0].max(),
              X[:, 0].min(), X[:, 0].min()]
    x_surf = np.array(x_surf)
    y_surf = np.array(y_surf)
    v0 = pca.transform(pca.components_[0])
    v0 /= v0[-1]
    v1 = pca.transform(pca.components_[1])
    v1 /= v1[-1]

    ax.w_xaxis.set_ticklabels([])
    ax.w_yaxis.set_ticklabels([])
    ax.w_zaxis.set_ticklabels([])

    plt.show()

#data = dl.nor(dl.loadData('datafew/'))
#
#test1 = dl.nor(dl.loadData('datalarge/training/'))
#
#test2 = dl.nor(dl.loadData('datalarge/test/'))
#
#
#dl.trainingSVC(test2, data, 0.00001, 2)

#dl.plot2DataSet(test2, test1, 1)

def acc_image(training_data, tarining_label, test_data, test_label):
    n_train = training_data.shape[0]  # samples for training
    n_test = test_data.shape[0]       # samples for testing
    n_averages = 50                   # how often to repeat classification
    n_features_max = 5  # maximum number of features
    step = 1  # step size for the calculation
    
    acc_clf1, acc_clf2 = [], []
    n_features_range = range(1, n_features_max + 1, step)
    for n_features in n_features_range:
        score_clf1, score_clf2 = 0, 0
        for _ in range(n_averages):
            X, y = training_data[:,0:n_features], tarining_label
        
            clf1 = LDA(solver='lsqr', shrinkage='auto').fit(X, y)
            clf2 = LDA(solver='lsqr', shrinkage=None).fit(X, y)
        
            X, y = test_data[:,0:n_features], test_label
            score_clf1 += clf1.score(X, y)
            score_clf2 += clf2.score(X, y)
    
        acc_clf1.append(score_clf1 / n_averages)
        acc_clf2.append(score_clf2 / n_averages)

    features_samples_ratio = np.array(n_features_range) / n_train

    plt.plot(features_samples_ratio, acc_clf1, linewidth=2,
             label="LDA with shrinkage", color='r')
    plt.plot(features_samples_ratio, acc_clf2, linewidth=2,
             label="LDA", color='g')

    plt.xlabel('n_features / n_samples')
    plt.ylabel('Classification accuracy')

    plt.legend(loc=1, prop={'size': 12})
    plt.suptitle('LDA vs. shrinkage LDA (1 discriminative feature)')
    plt.show()


path0 = 'datafew/'
path1 = 'datalarge/training/'
path2 = 'datalarge/test/'

data, label =  dl.loadDataStr(path2)
yy=[]
for i, l in enumerate(label):
    if l == 'left':
        yy.append(1);
    else:
        yy.append(0);
y = np.array(yy)

test_data, test_label = dl.loadDataStr(path2)

dimension = 3

clf = svm.SVC(kernel='linear').fit(data[:,0:dimension], label)

print clf
print clf.support_vectors_.shape
print clf.n_support_

error_count = 0.0
result = clf.predict(test_data[:,0:dimension])
for i, l in enumerate(result):
    #print l, label[i]
    if l != test_label[i]:
        error_count+=1

print 'error_count: ' + str(error_count)
print 'total_count: ' + str(result.shape[0])
#print result
#print test_label

print 'error_rate: ' + str(error_count/result.shape[0])

#pca(data[:,0:3], label)
#acc_image(data, label, test_data, test_label)


