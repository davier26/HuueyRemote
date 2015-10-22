//
//  HuueyLight.swift
//  HuueyRemote
//
//  Created by Nicholas Young on 10/21/15.
//  Copyright © 2015 Nicholas Young. All rights reserved.
//

import Foundation

public class HuueyLight {
    public var state = [String:AnyObject!]()
    public var name: String!
    public var id: Int!
    
    public init(data: JSON, id: Int) {
        self.name = data.dictionary!["name"]!.stringValue
        self.id = id
        
        for (key, value) in data["state"].dictionary! {
            if ["on", "hue", "bri", "sat"].contains(key) {
                self.state[key] = value.object
            }
        }
    }
    
    public func getState() -> Bool {
        return (self.state["on"]?.boolValue)!
    }
    
    public func getName() -> String {
        return self.name
    }
    
    public func getColor() -> AnyObject {
        return self.state["hue"]!
    }
    
    public func getSaturation() -> AnyObject {
        return self.state["sat"]!
    }
    
    public func getBrightness() -> AnyObject {
        return self.state["bri"]!
    }
    
    public func update(hue:Int, sat:Int, bri:Int) {
        self.state["hue"] = hue
        self.state["sat"] = sat
        self.state["bri"] = bri
    }

    public func getUIColor() -> UIColor {
        let hue:Float = Float(self.getColor().integerValue)
        let sat:Double = Double(self.getSaturation().integerValue)
        let bri:Double = Double(self.getBrightness().integerValue)
        
        return UIColor(hue: CGFloat(round((hue/65280.0)*1000)/1000), saturation: CGFloat(sat), brightness: CGFloat(bri), alpha: 1.0)
    }
}