//
//  Huuey.swift
//  HuueyRemote
//
//  Created by Nicholas Young on 10/21/15.
//  Copyright © 2015 Nicholas Young. All rights reserved.
//

import Foundation

public enum BridgeState {
    case Disconnected
    case Connected
    case NeedAuth
    case Failed
    case BridgeNotFound
}

public class Huuey {
    /**
        Private HuueyInterface for connections
     */
    private var interface: HuueyInterface!
    
    /**
        Publicly available lights array
     */
    public var lights:[HuueyLight]!
    
    /**
        Publicly available scenes array
     */
    public var scenes:[HuueyScene]!
    
    /**
        Public initializer
     
        Sets self.interface and checks if the interface is setup or not.
     */
    public init() {
        self.interface = HuueyInterface()
        
        if self.isReady() {
            self.getData()
        }
    }
    
    /**
        Public initializer
     
        Assumes you already know the addr/key of bridge
     
        - Parameter: addr, IP of Hue Bridge
        - Parameter: key, Developer key
     */
    public init(addr: String, key: String) {
        self.interface = HuueyInterface(addr: addr, key: key)
        self.getData()
    }
    
    /**
        Public initializer
     
        Assumes you already have an interface setup
     
        - Parameter: interface, HuueyInterface
     */
    public init(interface: HuueyInterface) {
        self.interface = interface
        self.getData()
    }
    
    /**
        Public initializer
     
        Grabs initial light data from the bridge
     */
    public func getData() {
        self.interface = HuueyInterface()
        
        // TODO: Implement Groups
        self.scenes = self.interface.get(HuueyGet.ScenesGet) as! [HuueyScene]
        self.lights = self.interface.get(HuueyGet.Lights) as! [HuueyLight]
    }
    
    public func setup(timeout:NSTimeInterval, onSetup: (bridgeState: BridgeState) -> Void) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            var found = false
            let timeoutDate = NSDate(timeIntervalSinceNow: timeout)
            
            while !found && NSDate().compare(timeoutDate) == .OrderedAscending {
                if self.discoveredBridge() {
                    found = true
                    onSetup(bridgeState: .NeedAuth)
                }
            }
            
            if self.connectedToBridge() {
                onSetup(bridgeState: .Connected)
            } else {
                onSetup(bridgeState: .Failed)
            }
        }
    }
    
    /**
        Returns true if everything is setup and ready to rock
     
        - Returns: Bool
     */
    public func isReady() -> Bool {
        if self.interface == nil || self.interface.HUE_ADDR == nil || self.interface.HUE_KEY == nil {
            return false
        }else {
            if self.isConnected() {
                return true
            }else {
                return false
            }
        }
    }
    
    /**
        Checks if interface is connected to the bridge
     
        - Returns: Bool
     */
    public func isConnected() -> Bool {
        return self.interface.bridgeConnected()
    }
    
    /**
        Trys to discover bridge, returns based on if successful
     
        - Returns: Bool
     */
    public func discoveredBridge() -> Bool {
        return self.interface.discoverBridge()
    }
    
    /**
        Trys to connect to the bridge, returns based on if successful
     
        - Returns: Bool
     */
    public func connectedToBridge() -> Bool {
        return self.interface.connectToBridge()
    }
    
    
    /**
        Sets light(s) on/off
     
        - Parameter: on, Bool on/off
        - Parameter: lights, HuueyLight, [HuueyLight]
     */
    public func set(on: Bool, lights: AnyObject){
        if let light = lights as? HuueyLight {
            
            self.interface.set(on, light: light)
            light.setState(on)
            
        }else if let lights = lights as? [HuueyLight] {
            
            for light in lights {
                self.interface.set(on, light: light)
                light.setState(on)
            }
            
        }else if let group = lights as? HuueyGroup {
            
            for light in group.lights {
                self.interface.set(on, light: light)
                light.setState(on)
            }
            
        }else if let groups = lights as? [HuueyGroup] {
            
            for group in groups {
                for light in group.lights {
                    self.interface.set(on, light: light)
                    light.setState(on)
                }
            }
        }
    }

    /**
        Sets brightness of light
     
        - Parameter: bri, Brightness of light 0 - 255
        - Parameter: light, HuueyLight
     */
    public func setBrightness(bri: Int, light: HuueyLight) {
        self.interface.set(bri, light: light)
    }
    
    /**
        Sets the hue/sat/bri of given light(s)
     
        - Parameter: hue, Hue of light 0 - 65280.0
        - Parameter: sat, Saturation of light 0 - 255
        - Parameter: bri, Brightness of light 0 - 255
        - Parameter: lights, AnyObject: Light(s) thats state should get updated
     */
    public func set(hue:Int, sat:Int, bri:Int, lights:AnyObject) {
        if let light = lights as? HuueyLight {
            
            light.update(hue, sat: sat, bri: bri, on:true)
            self.interface.set(hue, sat: sat, bri: bri, light: light)
            
        }else if let lights = lights as? [HuueyLight] {
            
            for light in lights {
                self.interface.set(hue, sat: sat, bri: bri, light: light)
            }
            
        }else if let group = lights as? HuueyGroup {
            
            for light in group.lights {
                self.interface.set(hue, sat: sat, bri: bri, light: light)
            }
            
        }else if let groups = lights as? [HuueyGroup] {
            
            for group in groups {
                for light in group.lights {
                    self.interface.set(hue, sat: sat, bri: bri, light: light)
                }
            }
            
        }
    }
    
    /**
        Sets a scene active
     
        - Parameter: scene, HuueyScene: Scene that should get activated
     */
    public func set(scene: HuueyScene) {
        self.interface.set(scene)
    }
    
    /**
        Gets specific item from bridge
     
        - Parameter: type, HuueyGet
        - Parameter: id, ID of item
     */
    public func get(type: HuueyGet, id: Int) -> AnyObject{
        return self.interface.get(type, id: id)
    }
}