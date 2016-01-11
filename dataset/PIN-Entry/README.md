### File Name Format:

>	[data\_type].[device\_type].csv

	data_type:
		1 == moment
		2 == buffer
	device_type:
		1 == iphone6plus
		2 == iphone5

### JSON Format

	l:
		1==left_thumb, 
		2==right_thumb, 
		3==left_index, 
		4==right_index

	device:
		1==iphone6plus, 
		2==iphone5

	operation:
		0==none, 
		1==never, 
		2==rarely, 
		3==sometimes, 
		4==often, 
		5==always
		
example:

```json
{
	"id" : 16,
	"condition" : [4,3,2,1],
	"device" : [2,1],
	"user": {
		"name" : "user.name",
		"gender" : "female",
		"birthday" : "1996.03.26",
		"age" : 19,
		"join_date" : "2015.12.03",
		"email" : "user.name@email.domain",
		"dominant" : "right",
		"phone" : "Phone Model",
		"use_age" : 3,
		"operation" : {
			"left_thumb" : 3,
			"right_thumb" : 4,
			"left_index" : 1,
			"right_index" : 2,
			"pin" : 5,
			"fingerprint" : 0
		}
	}
}
```

### Data Fields:

```
	id:
		meaningless.
	
	user_id:
		of course it's user id.
	
	test_count:
		means which test is

	test_case:
		only 0, 1
		0 means random
		1 means preinstall

	tap_count:
		means how many touch taps

	moving_flag:
		only 0, 1, 2
		0 means beganTouch,
		1 means moving events,
		2 means endTouch

	hand_posture:
		only 0, 1, 2, 3.
		0 means left thumb,
		1 means right thumb,
		2 means left index finger,
		3 means right index finger

	x,y:
		screen touch position

	offset_x,offset_y:
		button touch offset


	roll,pitch,yaw:
		device attitute

	acc_x,acc_y,acc_z:
		device accelerator

	rotation_x,rotation_y,rotation_z:
		device gyroscope

	touch_time:
		time when touch screen
```


### Test Number Series:

	273849,
	593827,
	950284,
	020485,
	857162,
	495937
	
	
# Buffer Data TimeInterval
NSTimeInterval delta = 0.01

The unit of NSTimeInterval is seconds

Every Buffer recorded 50 records which means every buffer recorded 0.5s buffer length for every touch moment.