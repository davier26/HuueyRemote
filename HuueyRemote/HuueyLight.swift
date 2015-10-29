//
//  HuueyLight.swift
//  HuueyRemote
//
//  Created by Nicholas Young on 10/21/15.
//  Copyright © 2015 Nicholas Young. All rights reserved.
//

import Foundation

public class HuueyLight {
    /**
        Holder variables
     */
    private var state = [String:AnyObject!]()
    private var name: String!
    private var id: Int!
    
    
    /**
        Public initializer
     
        - Parameter: Data, JSON array from HuueyInterface
        - Parameter: id, ID of the light
     */
    public init(data: JSON, id: Int) {
        self.name = data.dictionary!["name"]!.stringValue
        self.id = id
        
        for (key, value) in data["state"].dictionary! {
            if ["on", "hue", "bri", "sat"].contains(key) {
                self.state[key] = value.object
            }
        }
    }
    
    /**
        - Returns: Id of the light
     */
    public func getId() -> Int {
        return self.id
    }
    
    /**
        - Returns: Light is on or off
     */
    public func getState() -> Bool {
        return (self.state["on"]?.boolValue)!
    }
    
    /**
        - Returns: Name of the light
     */
    public func getName() -> String {
        return self.name
    }
    
    /**
        - Returns: Raw value of the hue 0 - 65280.0
     */
    public func getColor() -> AnyObject {
        return self.state["hue"]!
    }
    
    /**
        - Returns: Saturation of the light 0 - 255
     */
    public func getSaturation() -> AnyObject {
        return self.state["sat"]!
    }
    
    /**
        - Returns: Brightness of the light 0 - 255
     */
    public func getBrightness() -> AnyObject {
        return self.state["bri"]!
    }
    
    /**
        Updates light state
     
        - Parameter: state: Bool
     */
    public func setState(state: Bool) {
        self.state["on"] = state
    }
    
    /**
        Updates the state of the light
     
        - Parameter: hue, Hue value of the light
        - Parameter: sat, Saturation of the light
        - Parameter: bri, Brightness of the light
        - Parameter: on, Status of the light     
     */
    public func update(hue:Int, sat:Int, bri:Int, on: Bool) {
        self.state["hue"] = hue
        self.state["sat"] = sat
        self.state["bri"] = bri
        self.state["on"] = on
    }

    /**
        Returns UIColor of the light
     
        - Returns: UIColor     
     */
    public func getUIColor() -> UIColor {
        
        var hue = CGFloat(self.getColor().integerValue)
        var sat = CGFloat(self.getSaturation().integerValue)
        var bri = CGFloat(self.getBrightness().integerValue)

        
        hue = round((hue/65280.0)*1000)/1000
        sat = round((sat/255.0)*1000)/1000
        bri = round((bri/255.0)*1000)/1000
        
        let color = UIColor(hue: hue, saturation: sat, brightness: bri, alpha: 1.0)
        
        return color
    }
}