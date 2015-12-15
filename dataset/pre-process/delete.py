# This script draw the buffer picture
import csv
import numpy as np
import matplotlib.pyplot as plt

import scipy.fftpack

import time
#
# pre-process filepath
#
def prefix(folderName):
    folderNameStr = ''
    if folderName<10:
        folderNameStr = '0'+str(folderName)
    else:
        folderNameStr = str(folderName)
    return folderNameStr

def LargeDeviceMoment(folderName):
    return '../' + prefix(folderName) + '/1.1.csv'

def SmallDeviceMoment(folderName):
    return '../' + prefix(folderName) + '/1.2.csv'

def LargeDeviceBuffer(folderName):
    return '../' + prefix(folderName) + '/2.1.csv'

def SmallDeviceBuffer(folderName):
    return '../' + prefix(folderName) + '/2.2.csv'

#
# load data form csv file
#
def GetUsefulData(filePath, delimiter=','):
    csvfile = open(filePath)
    csv_reader = csv.reader(csvfile, delimiter=delimiter)
    data = np.array([row for row in csv_reader])
    length, feature = data.shape
    csvfile.close()
    # print data[1:length, 2:feature]
    return data[1:length, 2:feature]

def GetNumberSeries(filePath='./number.csv'):
    csvfile = open(filePath)
    csv_reader = csv.reader(csvfile, delimiter=',')
    numbers = np.array([row for row in csv_reader])
    #print numbers
    return numbers
#
# operation reference:
# ../01/1.1.csv   0
# test_count, test_case, tap_count, sensor_flag, hand_posture,x,y,z
# [['1' '1' '0' ..., '-0.350501' '0.048121' '2015-11-16 14:58:36']
#  ['1' '1' '0' ..., '-0.015154' '0.08487' '2015-11-16 14:58:36']
#  ['1' '1' '1' ..., '-0.941729' '-0.184106' '2015-11-16 14:58:37']
#  ...,
#  ['4' '1' '358' ..., '-0.337083' '0.033292' '2015-11-16 15:13:11']
#  ['4' '1' '359' ..., '-0.023458' '-0.001184' '2015-11-16 15:13:11']
#  ['4' '1' '359' ..., '0.249502' '0.07114' '2015-11-16 15:13:11']]
# ../01/1.2.csv   1
# [['1' '1' '0' ..., '-0.383154' '0.005003' '2015-11-16 15:13:38']
#  ['1' '1' '0' ..., '0.233178' '0.183647' '2015-11-16 15:13:38']
#  ['1' '1' '0' ..., '0.052499' '0.329843' '2015-11-16 15:13:38']
#  ...,
#  ['4' '1' '358' ..., '-0.235225' '-0.019915' '2015-11-16 15:23:29']
#  ['4' '1' '359' ..., '-0.07835' '0.001245' '2015-11-16 15:23:29']
#  ['4' '1' '359' ..., '-0.164145' '0.015946' '2015-11-16 15:23:29']]
# ../01/2.1.csv   2
# [['1' '1' '0' ..., '-0.125498' '0.379324' '-2.069037']
#  ['1' '1' '0' ..., '-0.120947' '0.383838' '-2.069236']
#  ['1' '1' '0' ..., '-0.115527' '0.388858' '-2.069189']
#  ...,
#  ['4' '1' '359' ..., '-0.037367' '-0.019952' '0.028541']
#  ['4' '1' '359' ..., '0.00097' '-0.02329' '0.014727']
#  ['4' '1' '359' ..., '0.028665' '-0.023396' '0.005188']]
# ../01/2.2.csv   3
# [['1' '1' '0' ..., '0.06973' '0.463859' '-1.578298']
#  ['1' '1' '0' ..., '0.065027' '0.462491' '-1.577442']
#  ['1' '1' '0' ..., '0.061537' '0.461861' '-1.576002']
#  ...,
#  ['4' '1' '359' ..., '-0.052735' '-0.010829' '0.039643']
#  ['4' '1' '359' ..., '-0.034035' '-6.4e-05' '0.029649']
#  ['4' '1' '359' ..., '-0.028824' '0.009675' '0.019843']]

# testCount can be 1,2,3,4 means left thumb
#                                right thumb
#                                left index
#                                right index
#                  start from 1
#
#  tapCount start from 0 to 359
#
# tapCount%6 is numberIndex of Number Serise
def plotSensorBuffer2(data, tapCount=0, testCount=1, folderName=1):

    bufferSize = 50
    seriesArray = [(value-49)*0.01 for value in xrange(0,50)]
    N = 50
    T = 0.01

    numList = GetNumberSeries()

    #print 'tapCount/60: ' + str(tapCount/60)
    #print 'tapCount%6: ' + str(tapCount%6)
    #print 'numList[index]: ' + str(numList[tapCount/60, tapCount%6])

    plt.figure(figsize=(10,13))
    num = numList[tapCount/60, tapCount%6]
    plt.suptitle('Current Input Number: ' + str(num))

    # important
    #start = ((tapCount%6 + (tapCount/6)*50*3*6)*5*3) + (testCount-1)*(3*50)*(6*10*6)
    start = tapCount*150 + (testCount-1)*(3*50)*(6*10*6)

    #print 'start line: ' + str(start)
    #print 'data shape: ' + str(data.shape)

    plt.subplot(3, 2, 1)
    x = data[start:start+bufferSize, -3]
    y = data[start:start+bufferSize, -2]
    z = data[start:start+bufferSize, -1]
    plt.plot(seriesArray, x, color='r', linewidth=2.5, label='roll')
    plt.plot(seriesArray, y, color='g', linewidth=2.5, label='pitch')
    plt.plot(seriesArray, z, color='b', linewidth=2.5, label='yaw')
    plt.title('Device.Attitude Time Domain')
    plt.axis([-0.5, 0, -2.5, 2.5])
    plt.legend(loc='upper right')

    plt.subplot(3, 2, 2)
    yfft1 = scipy.fftpack.fft(x)
    yfft2 = scipy.fftpack.fft(y)
    yfft3 = scipy.fftpack.fft(z)
    xfft = np.linspace(0.0, 1.0/(2.0*T), N/2)
    plt.plot(xfft, 2.0/N * np.abs(yfft1[:N/2]), color='r', linewidth=2.5, label='roll')
    plt.plot(xfft, 2.0/N * np.abs(yfft2[:N/2]), color='g', linewidth=2.5, label='pitch')
    plt.plot(xfft, 2.0/N * np.abs(yfft3[:N/2]), color='b', linewidth=2.5, label='yaw')
    plt.title('Device.Attitude Frequency Domain')
    #plt.axis([-0.5, 0, -2.5, 2.5])
    plt.legend(loc='upper right')

    start += 50
    plt.subplot(3, 2, 3)
    x = data[start:start+bufferSize, -3]
    y = data[start:start+bufferSize, -2]
    z = data[start:start+bufferSize, -1]
    plt.plot(seriesArray, x, color='r', linewidth=2.5, label='x')
    plt.plot(seriesArray, y, color='g', linewidth=2.5, label='y')
    plt.plot(seriesArray, z, color='b', linewidth=2.5, label='z')
    plt.title('Device.Accelerator Time Domain')
    plt.axis([-0.5, 0, -2.5, 2.5])
    plt.ylabel('Value')
    plt.legend(loc='upper right')

    plt.subplot(3, 2, 4)
    yfft1 = scipy.fftpack.fft(x)
    yfft2 = scipy.fftpack.fft(y)
    yfft3 = scipy.fftpack.fft(z)
    xfft = np.linspace(0.0, 1.0/(2.0*T), N/2)
    plt.plot(xfft, 2.0/N * np.abs(yfft1[:N/2]), color='r', linewidth=2.5, label='x')
    plt.plot(xfft, 2.0/N * np.abs(yfft2[:N/2]), color='g', linewidth=2.5, label='y')
    plt.plot(xfft, 2.0/N * np.abs(yfft3[:N/2]), color='b', linewidth=2.5, label='z')
    plt.title('Device.Accelerator Frequency Domain')
    #plt.axis([-0.5, 0, -2.5, 2.5])
    plt.legend(loc='upper right')

    start += 50
    plt.subplot(3, 2, 5)
    x = data[start:start+bufferSize, -3]
    y = data[start:start+bufferSize, -2]
    z = data[start:start+bufferSize, -1]
    plt.plot(seriesArray, x, color='r', linewidth=2.5, label='x')
    plt.plot(seriesArray, y, color='g', linewidth=2.5, label='y')
    plt.plot(seriesArray, z, color='b', linewidth=2.5, label='z')
    plt.title('Device.Gyroscope Time Domain')
    plt.axis([-0.5, 0, -2.5, 2.5])
    plt.xlabel('Time(s)')
    plt.legend(loc='upper right')

    plt.subplot(3, 2, 6)
    yfft1 = scipy.fftpack.fft(x)
    yfft2 = scipy.fftpack.fft(y)
    yfft3 = scipy.fftpack.fft(z)
    xfft = np.linspace(0.0, 1.0/(2.0*T), N/2)
    plt.plot(xfft, 2.0/N * np.abs(yfft1[:N/2]), color='r', linewidth=2.5, label='x')
    plt.plot(xfft, 2.0/N * np.abs(yfft2[:N/2]), color='g', linewidth=2.5, label='y')
    plt.plot(xfft, 2.0/N * np.abs(yfft3[:N/2]), color='b', linewidth=2.5, label='z')
    plt.title('Device.Gyroscope Frequency Domain')
    #plt.axis([-0.5, 0, -2.5, 2.5])
    plt.legend(loc='upper right')
    #plt.show()

    if folderName<10:
        folderNameStr = '0'+str(folderName)
    else:
        folderNameStr = str(folderName)
    fileName =  '../'+ folderNameStr + '/2.1/' + str(testCount) + '/' + str(tapCount) + '-' + str(tapCount%6)+ '-' + str(num) + '.png'
    plt.savefig(fileName, dpi=72)
    plt.close('all')


# def plotSensorBuffer(data, featureFlag=0, tapCount=0):
#     bufferSize = 50
#     seriesArray = [(value-49)*0.01 for value in xrange(0,50)]



#     f, (ax1, ax2, ax3) = plt.subplots(3, sharex=True, sharey=False)
#     # f.set_figheight(1000)
#     # f.set_figwidth(400)
#     ax = [ax1, ax2, ax3]

#     start = 0
#     x = data[start:start+bufferSize, -3]
#     y = data[start:start+bufferSize, -2]
#     z = data[start:start+bufferSize, -1]

#     ax[0].plot(seriesArray, x, color='r', linewidth=2.5, label='roll')
#     ax[0].plot(seriesArray, y, color='g', linewidth=2.5, label='pitch')
#     ax[0].plot(seriesArray, z, color='b', linewidth=2.5, label='yaw')
#     ax[0].set_title('Device.Attitute')
#     # ax[0].legend(loc='upper right')

#     start = start + 50
#     x = data[start:start+bufferSize, -3]
#     y = data[start:start+bufferSize, -2]
#     z = data[start:start+bufferSize, -1]

#     ax[1].plot(seriesArray, x, color='r', linewidth=2.5, label='x')
#     ax[1].plot(seriesArray, y, color='g', linewidth=2.5, label='y')
#     ax[1].plot(seriesArray, z, color='b', linewidth=2.5, label='z')
#     ax[1].set_title('Device.Accelerator')
#     # ax[1].legend(loc='upper right')

#     start = start + 50
#     x = data[start:start+bufferSize, -3]
#     y = data[start:start+bufferSize, -2]
#     z = data[start:start+bufferSize, -1]

#     ax[2].plot(seriesArray, x, color='r', linewidth=2.5, label='x')
#     ax[2].plot(seriesArray, y, color='g', linewidth=2.5, label='y')
#     ax[2].plot(seriesArray, z, color='b', linewidth=2.5, label='z')
#     ax[2].set_title('Device.Gyroscope')
#     # ax[2].legend(loc='upper right')


#     #plt.xticks( [-np.pi, -np.pi/2, 0, np.pi/2, np.pi])
#     #
#     for _ax in ax:
#         _ax.legend(loc='upper right')
#         #_ax.set_ylabel('Value')
#         #_ax.set_xlabel('Time(s)')
#         _ax.axis([-0.5, 0, -2.5, 2.5])
#         # _ax.set_yticklabels([-2, -1.5, -1, -0.5, 0, +0.5, +1, +1.5, +2])


#     # f.xlabel('Time(s)')
#     #plt.figure(figsize=(400, 100))
#     f.show()

#
# process a file data
#
def TraverFolderCSV(folderName):
    filePathList = [LargeDeviceMoment(folderName),
                    SmallDeviceMoment(folderName),
                    LargeDeviceBuffer(folderName),
                    SmallDeviceBuffer(folderName)]
    for i in xrange(0,4):
        #print filePathList[i]
        # test
        if i==2:
            print 'Process "' + filePathList[i] + '" ...'
            data = GetUsefulData(filePathList[i])
            for testCount in xrange(1, 5):
                for tapCount in xrange(0,360):
                    plotSensorBuffer2(data, tapCount=tapCount, testCount=testCount, folderName=folderName)
                    #print 'finish tap-' + str(tapCount) + '.'
                print 'finish user-' + str(folderName) + ' case-' + str(testCount) + '.'


def TraverAllFolderCSV():
    for i in xrange(0,16):
        start=time.time()
        TraverFolderCSV(i+1)
        finish=time.time()
        print 'spend ' + str((finish-start)/60.0)+ 'min process a user.'
#
# main function
#
def main():
    TraverAllFolderCSV()


if __name__ == '__main__':
    main()

