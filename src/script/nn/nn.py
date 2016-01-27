import theano
import theano.tensor as T
from theano.sandbox.rng_mrg import MRG_RandomStreams as RandomStreams

srng = RandomStreams()

import numpy as np
from load import mnist
from load_touch import touch_data

# hidden layer: sigmoid function
# output layer: softmax function
def model(X, w_h, w_o):
    '''
    input:
        X: input data
        w_h: hidden unit weights
        w_o: output unit weights
    output:
        Y: probability of y given X
    '''
    # hidden layer
    h = T.nnet.sigmoid(T.dot(X, w_h))
    # output layer
    pyx = T.nnet.softmax(T.dot(h, w_o))
    return pyx

# use stochastic gradient descent
def sgd(cost, params, lr=0.05):
    '''
    input:
        cost: cost function
        params: parameters
        lr: learning rate
    output:
        update rules
    '''
    grads = T.grad(cost=cost, wrt=params)
    updates = []
    for p, g in zip(params, grads):
        updates.append([p, p-g*lr])
    return updates

def floatX(X):
    return np.asarray(X, dtype=theano.config.floatX)
def init_weights(shape):
    return theano.shared(floatX(np.random.randn(*shape) * 0.01))
def dropout(X, prob=0.):
    if prob > 0:
        X *= srng.binomial(X.shape, p=1-prob, dtype=theano.config.floatX)
        X /= 1 - prob
    return X
def softmax(X):
    e_x = T.exp(X - X.max(axis=1).dimshuffle(0,'x'))
    return e_x / e_x.sum(axis=1).dimshuffle(0, 'x')
def model_complex(X, w_h1, w_h2, w_o, p_drop_input, p_drop_hidden):
    """
    input:
        X:             input data
        w_h1:          weights input layer to hidden layer 1
        w_h2:          weights hidden layer 1 to hidden layer 2
        w_o:           weights hidden layer 2 to output layer
        p_drop_input:  dropout rate for input layer
        p_drop_hidden: dropout rate for hidden layer
    output:
        h1:    hidden layer 1
        h2:    hidden layer 2
        py_x:  output layer
    """
    X = dropout(X, p_drop_input)
    h1 = T.nnet.relu(T.dot(X, w_h1))

    h1 = dropout(h1, p_drop_hidden)
    h2 = T.nnet.relu(T.dot(h1, w_h2))

    h2 = dropout(h2, p_drop_hidden)
    py_x = softmax(T.dot(h2, w_o))
    return h1, h2, py_x
def RMSprop(cost, params, accs, lr=0.001, rho=0.9, epsilon=1e-6):
    grads = T.grad(cost=cost, wrt=params)
    updates = []
    for p, g, acc in zip(params, grads, accs):
        acc_new = rho * acc + (1 - rho) * g ** 2
        gradient_scaling = T.sqrt(acc_new + epsilon)
        g = g / gradient_scaling
        updates.append((acc, acc_new))
        updates.append((p, p - lr * g))
    return updates


# loaddata
# trX, teX, trY, teY = mnist(onehot=True)
# print trX.shape
# print teX.shape
# print trY.shape
# print teY.shape

# print teY

trX, teX, trY, teY = touch_data(5, 1, 16, 1, True)

NtrY = []
NteY = []
for value in trY:
    if value == 1:
        NtrY.append([0, value])
    else:
        NtrY.append([1., 0])
for value in teY:
    if value == 1:
        NteY.append([0, value])
    else:
        NteY.append([1., 0])
NtrY = np.array(NtrY)
NteY = np.array(NteY)
print NtrY
print NteY

# trY = [[value] for value in trY]
# teY = [[value] for value in teY]

# print trX.shape
# print teX.shape
# print trY.shape
# print teY.shape

# i_n = 784
# h_n = 652
# o_n = 10

_, i_n = trX.shape
h_n = 11
o_n = 2

# init model
X = T.matrix()
Y = T.matrix()
w_h = init_weights((i_n, h_n))
w_o = init_weights((h_n, o_n))
# model output
py_x = model(X, w_h, w_o)
# model predict
y_x = T.argmax(py_x, axis=1)
# loss function
cost = T.mean(T.nnet.categorical_crossentropy(py_x, Y))
# updates rule
updates = sgd(cost, [w_h, w_o])
# define training and prediction function
training = theano.function(inputs=[X, Y], outputs=cost, updates=updates, allow_input_downcast=True)
predict  = theano.function(inputs=[X], outputs=y_x,  allow_input_downcast=True)

for i in xrange(1,100):
    for start, end in zip(range(0, len(trX), 128), range(128, len(trX), 128)):
        cost = training(trX[start:end], NtrY[start:end])
    # for j in range(len(trX)):
    # cost = training(trX, trY)
    print "{0:03d}".format(i), np.mean(np.argmax(NteY, axis=1) == predict(teX))


w_h1 = init_weights((i_n, h_n))
w_h2 = init_weights((h_n, h_n))
w_o = init_weights((h_n, o_n))
X = T.matrix()
Y = T.matrix()
# with dropout, use for training
noise_h1, noise_h2, noise_py_x = model_complex(X, w_h1, w_h2, w_o, 0.2, 0.5)
cost = T.mean(T.nnet.categorical_crossentropy(noise_py_x, Y))
params = [w_h1, w_h2, w_o]
accs = [theano.shared(p.get_value() * 0.) for p in params]
updates = RMSprop(cost, params, accs, lr=0.001)
# training function
train = theano.function(inputs=[X, Y], outputs=cost, updates=updates, allow_input_downcast=True)
# without dropout, use for predicting
h1, h2, py_x = model_complex(X, w_h1, w_h2, w_o, 0., 0.)
# predict results
y_x = T.argmax(py_x, axis=1)
predict = theano.function(inputs=[X], outputs=y_x, allow_input_downcast=True)

for i in range(100000):
    for start, end in zip(range(0, len(trX), 128), range(128, len(trX), 128)):
        cost = train(trX[start:end], NtrY[start:end])
    print "iter {:03d} accuracy:".format(i + 1), np.mean(np.argmax(NteY, axis=1) == predict(teX))
