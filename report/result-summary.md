# AugmentedTouch: A Study in Sensors Augment Classification Accuracy of Using Touch Position or Touch Offset Features

## Introduction

This report aims to summary four parts of exploring in human touch behavior and  sensor features influence classification accuracy in posture predicting:

1. Dynamic UI with different hand posture;
2. App Prototyping for predict user's posture of hold their device;
3. Result and feedback from participants of an User Study in using PIN Entry Design;
4. Performance and conclution of sensor augment touch position ( or touch offset) features.

> All the results and commit history can be download on the Github: [https://github.com/changkun/AugmentedTouch](https://github.com/changkun/AugmentedTouch)

## Implementation

### Dynamic UI

> Youtube: https://www.youtube.com/watch?v=voyEDZ6Awzw

### Prototyping App for Testing

### Applying User Study


## Evaluation

## Discussion

## Conclusion

## References

[1] 这篇文章探究了 Gyro 结合 touch 行为的手势探究
没有完成的:
1. 只分析了 Thumb
2. buffer size 不同.

@inproceedings{Goel2012,
author = {Goel, Mayank and Wobbrock, Jacob O. and Patel, Shwetak N.},
booktitle = {Proceedings of the 25th annual ACM symposium on User interface software and technology},
file = {:Users/ouchangkun/Documents/Mendeley Desktop/Goel, Wobbrock, Patel/Proceedings of the 25th annual ACM symposium on User interface software and technology/Goel, Wobbrock, Patel - 2012 - GripSense Using built-in sensors to detect hand posture and pressure on commodity mobile phones.pdf:pdf},
isbn = {9781450315807},
keywords = {a user to perform,figure 1,gripsense senses,hand,infers pressure exerted on,interactions,it is difficult for,left,like pinch-to-zoom with one,mobile,right,s hand posture and,situational impairments,the screen,touchscreen,user},
pages = {545--554},
title = {{GripSense: Using built-in sensors to detect hand posture and pressure on commodity mobile phones}},
url = {http://dl.acm.org/citation.cfm?id=2380184},
year = {2012}
}

[2] 这篇文章探究了 Touch 和 Motion 类型的
@article{Hinckley2011a,
abstract = {We explore techniques for hand-held devices that leverage the multimodal combination of touch and motion. Hybrid touch + motion gestures exhibit interaction properties that combine the strengths of multi-touch with those of motion- sensing. This affords touch-enhanced motion gestures, such as one-handed zooming by holding ones thumb on the screen while tilting a device. We also consider the reverse perspective, that of motion-enhanced touch, which uses motion sensors to probe what happens underneath the surface of touch. Touching the screen induces secondary accelerations and angular velocities in the sensors. For example, our prototype uses motion sensors to distinguish gently swiping a finger on the screen from drags with a hard onset to enable more expressive touch interactions.},
author = {Hinckley, Ken and Song, Hyunyoung},
doi = {10.1145/1978942.1979059},
file = {:Users/ouchangkun/Documents/Mendeley Desktop/Hinckley, Song/Human Factors/Hinckley, Song - 2011 - Sensor Synaesthesia Touch in Motion , and Motion in Touch.pdf:pdf},
isbn = {9781450302678},
journal = {Human Factors},
pages = {801--810},
title = {{Sensor Synaesthesia : Touch in Motion , and Motion in Touch}},
url = {http://portal.acm.org/citation.cfm?id=1979059},
year = {2011}
}

[3]@inproceedings{Buschek2013b,
abstract = {We present a machine learning approach to train user-specific offset models, which map actual to intended touch locations to improve accuracy. We propose a flexible framework to adapt and apply models trained on touch data from one device and user to others. This paper presents a study of the first published experimental data from multiple devices per user, and indicates that models not only improve accuracy between repeated sessions for the same user, but across devices and users, too. Device-specific models outperform unadapted user-specific models from different devices. However, with both user- and device-specific data, we demonstrate that our approach allows to combine this information to adapt models to the targeted device resulting in significant improvement. On average, adapted models improved accuracy by over 8{\%}. We show that models can be obtained from a small number of touches (� 60). We also apply models to predict input-styles and identify users.},
address = {New York, New York, USA},
author = {Buschek, Daniel and Rogers, Simon and Murray-Smith, Roderick},
booktitle = {Proceedings of the 15th international conference on Human-computer interaction with mobile devices and services},
doi = {10.1145/2493190.2493206},
isbn = {9781450322737},
pages = {382--391},
publisher = {ACM Press},
title = {{User-Specific Touch Models in a Cross-Device Context}},
url = {http://eprints.gla.ac.uk/80621/},
year = {2013}
}
