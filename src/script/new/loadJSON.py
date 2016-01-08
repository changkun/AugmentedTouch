import pymongo
import json

from loaddata import prefix

def jsonPath(userid):
    return '../data/'+prefix(userid)+'/info.json'


def storeToMongo():
    dataList = []
    for x in xrange(1,17):
        with open(jsonPath(x)) as dataFile:
            dataList.append(json.load(dataFile))
    print dataList

storeToMongo()
