from loaddata import splitMomentDataByFeatureAndLabel

import numpy
from sknn.mlp import Classifier, Layer
from sklearn.cross_validation import train_test_split

userid=1
device=1
featureCondition=16
classificationCondition=1
offsetFeatureOn=False
my_test_size = 0.3
my_random_state = 42

data, label = splitMomentDataByFeatureAndLabel(userid, device, featureCondition, classificationCondition, offsetFeatureOn=offsetFeatureOn)
data = data.astype(float)
label = label.astype(int)

trainingData, testData, trainingLabel, testLabel = train_test_split(data, label, test_size=my_test_size, random_state=my_random_state)

nn = Classifier(
    layers=[
        Layer("Softmax", units=100, pieces=2),
        Layer("Softmax")],
    learning_rate=0.001,
    n_iter=10000)

nn.fit(trainingData, trainingLabel)

y_valid = nn.predict(testData)

print testLabel
print y_valid
