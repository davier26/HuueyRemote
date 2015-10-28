# HuueyRemote

## Installation

1. Include HuueyRemote framework into your workspace
2. Import HuueyRemote to any file that needs Huuey()

	```
	import HuueyRemote
	```
3. Create a class variable for Huuey() and a variable to hold connection status

	```
	var huuey: Huuey = Huuey()
	var setup: Bool = false
	```

## Setup bridge instructions

1. Since we need to make sure you have an active connection to the bridge you need to run through the intial setup at least one time before you can use Huuey(). In your viewDidLoad() run the following code:

	```
	if huuey.isReady() {
        self.setup = true
    }else {
    	// Send your user to the dashboard that controls your lights
    }
	```
	This will verify if you have a connection to the bridge, if you do it sets setup to true

2. Next we need to check the setup variable and trigger the bridge discovery method. If setup == false. Inside of your viewDidAppear() put the following code:

	```
	if !self.setup {
        self.setup = true
        
        // Trigger your bridge discovery view here
    }
	```
	Your bridge discovery view should have some sort of indicator to tell the user that you are searching for the bridge
	
3. In your bridge discovery view create another instance class of type Huuey()

	```
	var huuey: Huuey = Huuey()
	```	
4. Inside of your viewDidLoad() put the following code:

	```
	var found = false
    
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
		while !found {
			if self.huuey.discoveredBridge() {
				found = true
				
				// Notifiy the user that the bridge was found and exit the loop
			}else {
				// Update your ui or something to tell the user that you can't find his bridge
			}
		}
		// Send your user to your bridge authentication view here
	}
	```
	This will trigger the while loop to continue to search for the bridge until it is found
	
5. In your bridge authentication view create another instance class of type Huuey()

	```
	var huuey: Huuey = Huuey()
	```	
6. After your user is on the authentication view run the following code inside of viewDidAppear()

	```
	if self.huuey.connectedToBridge() {
	    // Redirect them to whatever view you want
	}
	```
	connectedToBrige() keeps running until the user presses the blue button. After it returns you have an active connection to the bridge!
	
## Modify light instructions

1. After you know you have an active connection to the bridge run:

	```
	self.huuey.setup()
	``` 
	This function will scan your bridge and grab any lights/scenes it finds and populate the public variables:
	
	```
	self.huuey.lights
	self.huuey.scenes
	
	```
2. Huuey() exposes the following functions for controlling your lights:

	```
	public func set(scene: HuueyScene)
	public func set(on: Bool, lights: AnyObject)
	public func set(hue:Int, sat:Int, bri:Int, lights:AnyObject)
	public func setBrightness(bri: Int, light: HuueyLight)
	public func get(type: HuueyGet, id: Int) -> AnyObject
	```
	
	Example of setting a scene active:
	
	```
	self.huuey.set(self.huuey.scenes[0])
	```
	
	Example of setting light(s) on/off:
	
	```
	// Sets all lights on
	self.huuey.set(true, self.huuey.lights)
	
	// Sets all lights off
	self.huuey.set(false, self.huuey.lights)
	
	// Sets specific light on
	self.huuey.set(true, self.huuey.lights[0])
	
	// Sets specific light off
	self.huuey.set(true, self.huuey.lights[0])
	```
	
	Example of light(s) brightness
	
	```
	// Sets all lights brightness
	setBrightness(bri: 255, light: self.huuey.lights)
	
	// Sets specifc lights brightness
	setBrightness(bri: 255, light: self.huuey.lights[0])
	```
	
	Example of setting light(s) on/off:
	
	```
	// Sets all lights color
	self.huuey.set(hue:65000, sat:255, bri:255, lights:self.huuey.lights)
	
	// Sets a specifc lights color
	self.huuey.set(hue:65000, sat:255, bri:255, lights:self.huuey.lights[0])
	```
	
	Example of getting details about a specific light (Only single lights are supported right now)
	
	```
	var light = self.huuey.get(HuueyGet.Light, id: self.huuey.lights[0].getId()
	```
	
## Future improvements
* Add ability to create/edit/delete new groups of lights
* Add ability to create/edit/delete scenes
* Test support for multiple bridges