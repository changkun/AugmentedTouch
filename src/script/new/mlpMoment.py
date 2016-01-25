from loaddata import splitMomentDataByFeatureAndLabel
from mlp import MLP

import numpy
from sklearn.cross_validation import train_test_split
from sklearn.cross_validation import cross_val_score
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


clf = MLP(n_hidden=10, n_deep=3, l1_norm=0, drop=0.1, verbose=0).fit(trainingData, trainingLabel)

print testLabel
print clf.predict(testData)



