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
   }
	```
	This will verify if you have a connection to the bridge, if you do it sets setup to true

2. If setup == false. Then we need to discover your bridge on your network and generate API keys

	Inside of your viewDidAppear() put the following code:

	```
	override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if !self.setup {
	        huuey.setupWithTimeout(60) { (bridgeState) -> Void in
	            dispatch_async(dispatch_get_main_queue()) {
	                switch bridgeState {
	                case .BridgeNotFound:
	                    print("Not found!")
	                case .Connected:
	                    print("Connected")
	                case .Disconnected:
	                    print("Disconnected")
	                case .Failed:
	                    print("Failed")
	                case .NeedAuth:
	                    print("Need Auth")
	                }
	            }
	        }
        }
    }
	```
	
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
	self.huuey.setup() gets ran whenever you initialize a new Huuey() object, only call manually if you need to update the array of lights/scenes
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
	var light = self.huuey.get(HuueyGet.Light, id: self.huuey.lights[0].getId())
	```
	
## Future improvements
* Add ability to create/edit/delete new groups of lights
* Add ability to create/edit/delete scenes
* Test support for multiple bridges