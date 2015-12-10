import numpy as np
from sklearn import svm

# plot 3d
from mpl_toolkits.mplot3d import Axes3D
import matplotlib.pyplot as plt


def load_training_data(source_file_path):
    f_left = open(source_file_path+'pre-data_left.txt', 'r')
    f_right = open(source_file_path+'pre-data_right.txt', 'r')

    result = []
    while True:
        line = f_left.readline()
        l = len(line)
        if line:
            v = line[0:l-1].split(',')
            vv = [float(value) for value in v]
            result.append(vv)
        else:
            break
    while True:
        line = f_right.readline()
        l = len(line)
        if line:
            v = line[0:l-1].split(',')
            vv = [float(value) for value in v]
            result.append(vv)
        else:
            break

    a = np.array(result)
#    lenth, dimension = a.shape
#
#    x = a[0:lenth, 0:dimension-1]
#    y = a[0:lenth, -1]
#
    f_left.close()
    f_right.close()

    return a

def load_test_data(source_file_path):
    f_left = open(source_file_path+'pre-data_left.txt', 'r')
    f_right = open(source_file_path+'pre-data_right.txt', 'r')
    
    result = []
    while True:
        line = f_left.readline()
        l = len(line)
        if line:
            v = line[0:l-1].split(',')
            vv = [float(value) for value in v]
            result.append(vv)
        else:
            break
    while True:
        line = f_right.readline()
        l = len(line)
        if line:
            v = line[0:l-1].split(',')
            vv = [float(value) for value in v]
            result.append(vv)
        else:
            break

    a = np.array(result)
#    lenth, dimension = a.shape
#    
#    x = a[0:lenth, 0:dimension-1]
#    y = a[0:lenth, -1]
#    
    f_left.close()
    f_right.close()

    return a

def main(training, test):
    tr_lenth, tr_dimension = training.shape
    te_lenth, te_dimension = test.shape

    for i in range(1,100):
        clf = svm.SVC(gamma=0.014, C=0.01*i)
        clf.fit(training[0:tr_lenth, 0:2], training[0:tr_lenth, -1])
    
        error_count = 0
        for t in test:
            if clf.predict(t[0:2]) == t[-1]:
                continue
            else:
                error_count += 1

        print 'gamma=' + str(i) + ' error rate:' + str(float(error_count)/te_lenth)


# data==[x,y,roll,pitch,yaw,label]
# axis==1,2,3 means roll, pitch, yaw
def plot3D(data, axis):
    fig = plt.figure()
    ax = fig.add_subplot(111, projection='3d')

    lenth, dimension = data.shape

    x = data[0:lenth, 0]
    y = data[0:lenth, 1]
    z = data[0:lenth, axis+1]
    label = data[0:lenth, -1]

    i = 0
    for l in label:
        if l == 1: #left
            ax.scatter(x[i],y[i],z[i],c='r',marker='o')
        else:
            ax.scatter(x[i],y[i],z[i],c='b',marker='^')
        i+=1
    ax.set_xlabel('X')
    ax.set_ylabel('Y')
    if axis == 1:
        ax.set_zlabel('roll')
    elif axis == 2:
        ax.set_zlabel('pitch')
    else:
        ax.set_zlabel('yaw')

    # start trainig
    clf = svm.SVC(kernel='linear')
    print clf.fit(data[0:lenth, 0:2], data[0:lenth, -1])
#    for t in data:
#        if t[-1] == 1:
#            ax.scatter(t[0], t[1], clf.predict(t[0:1]), c='g', marker='x')
#        else:
#            ax.scatter(t[0], t[1], clf.predict(t[0:1]), c='g', marker='o')

    #get the separating hyperplane
#    print clf.coef_
#    w = clf.coef_[0]
#    print w
#    a = -w[0] / w[1]
#    print a
#    xx = np.linspace(-5,5)
#    print xx
#    yy = a*xx - (clf.intercept_[0]) / w[1]
#    print yy

    plt.show()




def plot2D(data, axis):
    
    lenth, dimension = data.shape
    
    #x = data[0:lenth, 0]
    #y = data[0:lenth, axis+1]
    X = data[0:lenth,0:2:1]
    label = data[0:lenth, -1]
#    plt.figure()
#    plt.scatter(x,y)
#
#    i = 0
#    for l in label:
#        if l == 1: #left
#            plt.scatter(x[i],y[i],c='r',marker='o')
#        else:
#            plt.scatter(x[i],y[i],c='b',marker='^')
#        i+=1



    #plot svm result in (x,roll)
    C=1.0
    print 'start...'
    #svc = svm.SVC(kernel='linear', C=C).fit(X, label)
    #print 'linear_done'
    rbf_svc = svm.SVC(kernel='rbf', gamma=0.7, C=C).fit(X, label)
    print 'rbf_done'
    #poly_svc = svm.SVC(kernel='poly', degree=2, C=C).fit(X, label)
    #print 'poly_done'
    #lin_svc = svm.LinearSVC(C=C).fit(X, label)
    #print 'linearSVC_done'
    
    h = 1
    
    # create a mesh to plot in
    x_min, x_max = X[:, 0].min() - 1, X[:, 0].max() + 1
    print x_min, x_max
    y_min, y_max = X[:, 1].min() - 1, X[:, 1].max() + 1
    print y_min, y_max

    xx, yy = np.meshgrid(np.arange(x_min, x_max, h),
                         np.arange(y_min, y_max, h))
    print 'done 1'
    
    print np.c_[xx.ravel(), yy.ravel()].shape
    
    #title for the plots
    titles = ['SVC with linear kernel',
              'LinearSVC (linear kernel)',
              'SVC with RBF kernel',
              'SVC with polynomial (degree 3) kernel']
    
    #plt.subplot(2, 2, i + 1)
    #plt.subplots_adjust(wspace=0.4, hspace=0.4)
    
    Z = rbf_svc.predict(np.c_[xx.ravel(), yy.ravel()])
    print 'done 2'
        
    # Put the result into a color plot
    Z = Z.reshape(xx.shape)
    plt.contourf(xx, yy, Z, cmap=plt.cm.Paired, alpha=0.8)
        
    # Plot also the training points
#    plt.scatter(X[:, 0], X[:, 1], c=y, cmap=plt.cm.Paired)
#    plt.xlabel('x')
#    plt.ylabel('roll')
#    plt.xlim(xx.min(), xx.max())
#    plt.ylim(yy.min(), yy.max())
#    plt.xticks(())
#    plt.yticks(())
    plt.title(titles[2])
    
#    for i, clf in enumerate((svc, lin_svc, rbf_svc, poly_svc)):
#        # Plot the decision boundary. For that, we will assign a color to each
#        # point in the mesh [x_min, m_max]x[y_min, y_max].
#        plt.subplot(2, 2, i + 1)
#        plt.subplots_adjust(wspace=0.4, hspace=0.4)
#    
#        Z = clf.predict(np.c_[xx.ravel(), yy.ravel()])
#    
#        # Put the result into a color plot
#        Z = Z.reshape(xx.shape)
#        plt.contourf(xx, yy, Z, cmap=plt.cm.Paired, alpha=0.8)
#    
#        # Plot also the training points
#        plt.scatter(X[:, 0], X[:, 1], c=y, cmap=plt.cm.Paired)
#        plt.xlabel('x')
#        plt.ylabel('roll')
#        plt.xlim(xx.min(), xx.max())
#        plt.ylim(yy.min(), yy.max())
#        plt.xticks(())
#        plt.yticks(())
#        plt.title(titles[i])

    plt.show()

training_file_path = '/Users/ouchangkun/Desktop/course/daniel-project/training-data/'
test_file_path = '/Users/ouchangkun/Desktop/course/daniel-project/test-data/'

training = load_training_data(training_file_path)
test = load_test_data(test_file_path)

# doing things
# main(training, test)

#plotTraining3D(training)
plot3D(test, 1)
#plot3D(test, 2)
#plot3D(test, 3)

#plot2D(training, 1)


