# Touch Motion

## User Study

### Participants



### Description

1. When participants applying the user study, we randomly ask few questions to participants and the question are follows:
	
	* What influenced you make mistakes?
		- The most anwsers: "I didn't realize the number has changed.";
		- Six numbers as a PIN code is too complex for input quick.	
	* What do you think of the function of background color?
		- The most anwsers: "may be nonsense";
		
	* What's the special meaning of the input number series?
	   - The most anwsers: "no idea";
	   
	* What's the study study in?
		- A kind of game, count mistakes to find out how users concentrate on something;
		- Find out which hand simple for users;
		- Find out which number series is easy for input.

2. Participants Comments
	
	* The last number series always much easier than others
	* Finger movement is easy to remember
	* They alway use

## Posture Classifier

### Problem description

In the User Study,**Participant i** *use posture k* **input number j** and generate a moment data when they touch screen:
	
	(p_i, n_j, posture_k) --> (touch_position, touch_position_offset, atti, acce, gyro, time)

in detail:
	
	touch_position        --> (x, y)
	touch_position_offset --> (offset_x, offset_y)
	atti                  --> (atti_roll, atti_pitch, atti_yaw)
	acce                  --> (acce_x, acce_y, acce_z)
	gyro                  --> (gyro_x, gyro_y, gyro_z)
	
and the classfication problem can be described as following form:

	(x, y, roll)    --> posture_set = {1, 2, 3, 4} = {left thumb, right thumb, left index finger, right index finger}
	
### Feature Table

#### 1. Traning and Testing Method

1. 使用 user-i 的 device-j 训练模型，用 user-i 的 device-j 进行 test, i=1,2,...,16; j=1,2
    - User-i Device-j hack in User-i Device-j Model (cross validation), error rate: 0.x%

2. 使用 user-i 的 device-j 训练模型，用 user-i 的 device-k 进行 test, j!=k; i=1,2,...,16; j,k=1,2
    - User-i Device-j hack in User-i Device-k Model, error rate: 0.x%

3. 使用 user-i 的 device-j 训练模型，用 user-k 的 device-j 进行 test, i!=k; i,k=1,2,...,16; j=1,2
    - User-i Device-j hack in User-k Device-l Model, error rate: 0.x%

4. 使用 user-i 的 device-j 训练模型，用 user-k 的 device-l 进行 test, i!=k; j!=l; i,k=1,2,...,16; j,l=1,2
    - User-i Device-j hack in User-k Device-l Model, error rate: 0.x%

#### 2. Binary Classification

base line
(x,y) --> (1,2,3,4)

left hand(left thumb+left index) right hand(right thumb+ right index)

offset_position + sensor


receiver operating 

##### Thumb Classification

1. (x, y, atti_roll)    --> (left thumb, right thumb)
* (x, y, atti_pitch)   --> (left thumb, right thumb)
* (x, y, atti_yaw)     --> (left thumb, right thumb)
* (x, y, acce_x)       --> (left thumb, right thumb)
* (x, y, acce_y)       --> (left thumb, right thumb)
* (x, y, acce_z)       --> (left thumb, right thumb)
* (x, y, gyro_x)       --> (left thumb, right thumb)
* (x, y, gyro_y)       --> (left thumb, right thumb)
* (x, y, gyro_z)       --> (left thumb, right thumb)
* (x, y, atti_roll, atti_pitch, atti_yaw) --> (left thumb, right thumb)
* (x, y, acce_x, acce_y, acce_z)          --> (left thumb, right thumb)
* (x, y, gyro_x, gyro_y, gyro_z)          --> (left thumb, right thumb)
* (x, y, atti{roll,pitch,yaw}, acce{x,y,z}) --> (left thumb, right thumb)
* (x, y, atti{roll,pitch,yaw}, gyro{x,y,z}) --> (left thumb, right thumb)
* (x, y, acce{x,y,z}, gyro{x,y,z})          --> (left thumb, right thumb)
* (x, y, atti\_{roll,pitch,yaw}, acce\_{x,y,z}, gyro\_{x,y,z}) --> (left thumb, right thumb)

##### Index Finger Classification

* (x, y, atti_roll)    --> (left index, right index)
* (x, y, atti_pitch)   --> (left index, right index)
* (x, y, atti_yaw)     --> (left index, right index)
* (x, y, acce_x)       --> (left index, right index)
* (x, y, acce_y)       --> (left index, right index)
* (x, y, acce_z)       --> (left index, right index)
* (x, y, gyro_x)       --> (left index, right index)
* (x, y, gyro_y)       --> (left index, right index)
* (x, y, gyro_z)       --> (left index, right index)

* (x, y, atti_roll, atti_pitch, atti_yaw) --> (left index, right index)
* (x, y, acce_x, acce_y, acce_z)          --> (left index, right index)
* (x, y, gyro_x, gyro_y, gyro_z)          --> (left index, right index)

* (x, y, atti{roll,pitch,yaw}, acce{x,y,z}) --> (left index, right index)
* (x, y, atti{roll,pitch,yaw}, gyro{x,y,z}) --> (left index, right index)
* (x, y, acce{x,y,z}, gyro{x,y,z})          --> (left index, right index)

* (x, y, atti\_{roll,pitch,yaw}, acce\_{x,y,z}, gyro\_{x,y,z}) --> (left thumb, right thumb)

#### 3. Multi-Classification

* (x, y, atti_roll)    --> (left thumb, right thumb, left index, right index)
* (x, y, atti_pitch)   --> (left thumb, right thumb, left index, right index)
* (x, y, atti_yaw)     --> (left thumb, right thumb, left index, right index)
* (x, y, acce_x)       --> (left thumb, right thumb, left index, right index)
* (x, y, acce_y)       --> (left thumb, right thumb, left index, right index)
* (x, y, acce_z)       --> (left thumb, right thumb, left index, right index)
* (x, y, gyro_x)       --> (left thumb, right thumb, left index, right index)
* (x, y, gyro_y)       --> (left thumb, right thumb, left index, right index)
* (x, y, gyro_z)       --> (left thumb, right thumb, left index, right index)

* (x, y, atti_roll, atti_pitch, atti_yaw) --> (left thumb, right thumb, left index, right index)
* (x, y, acce_x, acce_y, acce_z)          --> (left thumb, right thumb, left index, right index)
* (x, y, gyro_x, gyro_y, gyro_z)          --> (left thumb, right thumb, left index, right index)

* (x, y, atti{roll,pitch,yaw}, acce{x,y,z}) --> (left thumb, right thumb, left index, right index)
* (x, y, atti{roll,pitch,yaw}, gyro{x,y,z}) --> (left thumb, right thumb, left index, right index)
* (x, y, acce{x,y,z}, gyro{x,y,z})          --> (left thumb, right thumb, left index, right index)

* (x, y, atti\_{roll,pitch,yaw}, acce\_{x,y,z}, gyro\_{x,y,z}) --> (left thumb, right thumb, left index, right index)


## Verification
In the test, 
Participant i 
use posture k 
input number j 
and generate three buffer(50 records per each item)

	(p_i, n_j, posture_k) --> (atti, acce, gyro)

buffer series:

	atti --> (x, y, z)  <--> (row, pitch, yaw)
	acce --> (x, y, z)
	gyro --> (x, y, z)

	x = [xt0, xt1, ... , xt50]^T
	y = [yt0, yt1, ... , yt50]^T
	z = [yt0, yt1, ... , yt50]^T
	
Still a classification problem:
	
	(atti, acce, gyro, posture_k, n_j, p_i) --> Y = {yes, no}
	
	(atti, acce, gyro, posture_k, n_j) --> user_id

## Preprocessing Idea

### Weight of Postures
The operation from questionnaire maybe could as a weight to vote data's value for every user:

	Operation = {
       W_{leftthumb},
       W_{rightthumb},
       W_{leftindex},
       W_{rightindex},
       W_{pin},
       W_{screensize}
    }
	
	\sigma_{k=1}^{6}{ W_{k} * posture_k }


## Challenge
1. amount of calculation(buffer data)
2. which learning model more suitable for this problem
3. 