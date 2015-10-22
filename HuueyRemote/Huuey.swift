//
//  Huuey.swift
//  HuueyRemote
//
//  Created by Nicholas Young on 10/21/15.
//  Copyright © 2015 Nicholas Young. All rights reserved.
//

import Foundation

public class Huuey {
    let interface: HuueyInterface!
    
    public var lights:[HuueyLight]!
    public var scenes:[HuueyScene]!
    var groups:[HuueyGroup]!
    
    public init() {
        self.interface = HuueyInterface()
        
        if self.isReady() {
            self.setup()
        }
    }
    
    public init(addr: String, key: String) {
        self.interface = HuueyInterface(addr: addr, key: key)
        self.setup()
    }
    
    public init(interface: HuueyInterface) {
        self.interface = interface
        self.setup()
    }
    
    public func setup() {
        // TODO: Implement Groups
//        self.scenes = self.interface.get(HuueyGet.ScenesGet) as! [HuueyScene]
        self.lights = self.interface.get(HuueyGet.Lights) as! [HuueyLight]
    }
    
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
    
    public func isConnected() -> Bool {
        return self.interface.bridgeConnected()
    }
    
    public func discoveredBridge() -> Bool {
        return self.interface.discoverBridge()
    }
    
    public func connectedToBridge() -> Bool {
        return self.interface.connectToBridge()
    }
    
    public func set(on: Bool, lights: AnyObject) -> AnyObject {
        if let light = lights as? HuueyLight {
            self.interface.set(on, light: light)
            return light
            
        }else if let lights = lights as? [HuueyLight] {
            
            for light in lights {
                self.interface.set(on, light: light)
            }
            return lights
            
        }else if let group = lights as? HuueyGroup {
            
            for light in group.lights {
                self.interface.set(on, light: light)
            }
            return group
            
        }else if let groups = lights as? [HuueyGroup] {
            
            for group in groups {
                for light in group.lights {
                    self.interface.set(on, light: light)
                }
            }
            return groups
            
        }else {
            return false
        }
    }
    
    public func set(hue:Int, sat:Int, bri:Int, lights:AnyObject) {
        if let light = lights as? HuueyLight {
            
            light.update(hue, sat: sat, bri: bri)
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
    
    public func set(scene: HuueyScene) {
        self.interface.set(scene)
    }
    
    public func get(type: HuueyGet, id: Int) -> AnyObject{
        return self.interface.get(type, id: id)
    }
}