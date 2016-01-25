from loaddata import splitMomentDataByFeatureAndLabel

import numpy
import theano
import theano.tensor as T


userid=1
device=1
featureCondition=16
classificationCondition=1
offsetFeatureOn=False
data, label = splitMomentDataByFeatureAndLabel(userid, device, featureCondition, classificationCondition, offsetFeatureOn=offsetFeatureOn)

data = numpy.array(data, dtype='float32')
label = numpy.array(label, dtype='float32')

training_steps = 10000

x = T.matrix("x")
y = T.vector("y")
w = theano.shared(numpy.random.randn(data.shape[1]), name="w")
b = theano.shared(0., name="b")

print "init model:"
print w.get_value()
print b.get_value()


p_1 = 1 / (1+T.exp(-T.dot(x,w)-b))
prediction = p_1 > 0.5
xent = -y * T.log(p_1) - (1-y) * T.log(1-p_1)
cost = xent.mean() + 0.01 * (w ** 2).sum()
gw, gb = T.grad(cost, [w, b])

train = theano.function(
          inputs=[x,y],
          outputs=[prediction, xent],
          updates=((w, w - 0.1 * gw), (b, b - 0.1 * gb)))
predict = theano.function(inputs=[x], outputs=prediction)


for i in range(training_steps):
    pred, err = train(data, label)

print "Final model:"
print w.get_value()
print b.get_value()
print "target values for data:"
print label
print "prediction on data:"
print predict(data)

# count = 0
# for index, value in enumerate(predict(data)):
#     print index, value
#     if label[index] != value:
#         count += 1
# print "error rate: "
# print float(count)/len(label)
