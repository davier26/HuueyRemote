//
//  Bridge.swift
//  HuueyRemote
//
//  Created by Nicholas Young on 10/21/15.
//  Copyright © 2015 Nicholas Young. All rights reserved.
//

import Foundation


/**
    HuueyGet: Enum that determines what url to generate
 */
public enum HuueyGet {
    case Lights
    case ScenesGet
    case ScenesSet
    case Light
    case Discover
    case Api
    case Connected
}

public class HuueyInterface {
    private let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    
    /**
        HuueyConstants: Constants that provide URL patterns and keys
     */
    private struct HuueyConstants {
        static let HUE_KEY = "API_KEY"
        static let HUE_ADDR = "HUE_ADDR"
        static let HUE_DTYPE = "Huuey#TvOS"
        static let HUE_UPNP_DISCOVERY_URL = "https://www.meethue.com/api/nupnp"
        static let HUE_ENDPOINT_LIGHTS = "lights"
        static let HUE_ENDPOINT_SCENES = "scenes"
        static let HUE_ENDPOINT_GROUPS = "groups"
    }
    
    /**
        HuueyMethods: Constants that provide Http Methods
     */
    private struct HuueyMethods {
        static let GET = "GET"
        static let POST = "POST"
        static let PUT = "PUT"
    }
    
    /**
        Hue Bridge IP
     */
    var HUE_ADDR: String?
    
    /**
        Hue Bridge Developer Key
     */
    var HUE_KEY: String?
    
    /**
        Public initializer
        
        Trys to use saved data for connection otherwise sets values to nil
     */
    public init() {
        let DEFAULT_ADD = self.defaults.valueForKey(HuueyConstants.HUE_ADDR)
        let DEFAULT_KEY = self.defaults.valueForKey(HuueyConstants.HUE_KEY)
        
        if DEFAULT_ADD != nil {
            self.HUE_ADDR = DEFAULT_ADD as? String
        }else {
            self.HUE_ADDR = nil
        }
        
        if DEFAULT_KEY != nil {
            self.HUE_KEY = DEFAULT_KEY as? String
        }else {
            self.HUE_KEY = nil
        }
    }
    
    /**
        Public initializer
     
        - Parameter: addr, Address of hue bridge
        - Parameter: key, Developer key
     */
    public init(addr: String, key: String) {
        self.HUE_ADDR = addr
        self.HUE_KEY = key
    }
    
    /**
        Sets light on/off
     
        - Parameter: on, Should light be on/off
        - Parameter: light, HuueyLight: Light to be turned on/off
     */
    public func set(on: Bool, light: HuueyLight) {
        self.request(generateUrl(HuueyGet.Light, id: light.getId()) + "/state", method: HuueyMethods.PUT, data: generateDict(on))
    }
    
    /**
        Sets scene to be active
     
        - Parameter: scene, HuueyScene
     */
    public func set(scene: HuueyScene) {
        let data = generateDict(scene.getID())
        self.request(self.generateUrl(HuueyGet.ScenesSet), method: HuueyMethods.PUT, data:data)
    }
    
    /**
        Sets the brightness of a light
     
        - Parameter: bri, Brightness of light 0 - 255
        - Parameter: light, HuueyLight: Light thats brightness should be changed
     */
    public func set(bri: Int, light: HuueyLight) {
        let data = ["bri":bri]
        self.request(generateUrl(HuueyGet.Light, id: light.getId()) + "/state", method: HuueyMethods.PUT, data: data)
    }
    
    /**
        Sets the hue/sat/bri of given light
     
        - Parameter: hue, Hue of light 0 - 65280.0
        - Parameter: sat, Saturation of light 0 - 255
        - Parameter: bri, Brightness of light 0 - 255
        - Parameter: light, HuueyLight: Light thats state should get updated
     */
    public func set(hue:Int, sat:Int, bri:Int, light:HuueyLight) {
        var data = generateDict(hue, sat: sat, bri: bri)
        data["on"] = true
        
        self.request(generateUrl(HuueyGet.Light, id: light.getId()) + "/state", method: HuueyMethods.PUT, data: data)
    }
    
    /**
        Returns groups of data from bridge
     
        - Parameter: get, HuueyGet: What should be grabbed from the bridge
     */
    public func get(get: HuueyGet) -> [AnyObject] {
        let request = self.request(generateUrl(get), method: HuueyMethods.GET)
        
        if get == HuueyGet.Lights {
            var lights: [HuueyLight] = []
            
            for (key, light) in request {
                lights.append(HuueyLight(data: light,id:Int(key)!))
            }
            
            return lights
        }else if get == HuueyGet.ScenesGet {
            var scenes: [HuueyScene] = []
            
            for (key, value) in request {
                if value["name"].stringValue.containsString("on") {
                    scenes.append(HuueyScene(name: value["name"].stringValue, id: key))
                }
            }
            
            return scenes
        }
        
        return [""]
    }
    
    /**
        Returns HuueyLight data from bridge
     
        - Parameter: get, HuueyGet: What should be grabbed from the bridge
        - Parameter: id, Id of needed data
     
        - Returns: Null: If no data is found
        - Returns: HuueyLight: If
     */
    public func get(get: HuueyGet, id: Int) -> AnyObject {
        let request = self.request(generateUrl(get, id: id), method: HuueyMethods.GET)
        
        if get == HuueyGet.Light {
            return HuueyLight(data: request, id: id)
        }
        
        // TODO: Add support for groups
        
        return false
    }
    
    /**
        Searches for bridge on network, if found sets default data for later use
     
        - Returns: Bool, Found/Not found bridge
     */
    public func discoverBridge() -> Bool {
        let request = self.request(generateUrl(HuueyGet.Discover), method: HuueyMethods.GET)
        
        if request.count > 0 {
            self.HUE_ADDR = request[0]["internalipaddress"].string!
            self.defaults.setValue(self.HUE_ADDR, forKeyPath: HuueyConstants.HUE_ADDR)
            return true
        }
        return false
    }
    
    /**
        Trys to connect to bridge, hangs until blue activation button is clicked
     
        - Returns: Bool, Setup/Not setup bridge connection
     */
    public func connectToBridge(timeout: NSTimeInterval!=60) -> Bool {
        var connected = false;
        var response: JSON = ""
        
        let timeoutDate = NSDate(timeIntervalSinceNow: timeout)
        
        while !connected && NSDate().compare(timeoutDate) == .OrderedAscending {
            response = self.request(generateUrl(HuueyGet.Api), method:  HuueyMethods.POST, data: ["devicetype":HuueyConstants.HUE_DTYPE])
            
            if response[0]["error"]["type"] != 101 {
                connected = !connected;
                self.HUE_KEY = response[0]["success"]["username"].rawString()!
            }else {
                sleep(2)
            }
        }
        
        if connected {
            self.defaults.setValue(self.HUE_KEY, forKey: HuueyConstants.HUE_KEY)
        }
        
        return connected
    }
    
    /**
        Checks if its connected to the bridge
     
        - Returns: Bool, Setup/Not setup
     */
    public func bridgeConnected() -> Bool {
        if self.HUE_ADDR == nil || self.HUE_KEY == nil {
            return false
        }else {
            let request = self.request(self.generateUrl(HuueyGet.Connected), method: HuueyMethods.GET)
            
            if(request[0]["error"]["type"]) {
                return false
            }else {
                if(request.count > 0) {
                    return true
                }
            }
            return false
        }
    }
    
    /**
        Handles submitting the actual request.
     
        Calls buildRequest to generate request data
     
        - Parameter: url, Url of request
        - Parameter: method, Http Method of request
        - Parameter: data?, Http request body
     */
    public func request(url: String, method: String, data:[String:AnyObject]?=nil) -> JSON {
        let session = NSURLSession.sharedSession()
        let dst = dispatch_semaphore_create(0)
        
        var requestData: JSON = nil

        let dataTask = session.dataTaskWithRequest(
            self.buildRequest(url, method: method, data: data)
            ){ (data, response, error) in
                requestData = JSON(data: data!)
                dispatch_semaphore_signal(dst)
        }
        
        dataTask.resume();
        dispatch_semaphore_wait(dst, DISPATCH_TIME_FOREVER)
  
        return requestData
    }
    
    /**
        Handles building the request
     
        - Parameter: endpoint, Url of request
        - Parameter: method, Http Method of request
        - Parameter: data?, Http request body
     */
    private func buildRequest(endpoint: String, method: String, data:[String:AnyObject]?=nil) -> NSMutableURLRequest {
        let url = NSURL(string: endpoint)
        let request = NSMutableURLRequest(URL: url!)
        
        request.HTTPMethod = method
        
        if(["POST", "PUT"].contains(method) && data != nil)  {
            let converted = JSON(data!)
            request.HTTPBody = converted.rawString()?.dataUsingEncoding(NSUTF8StringEncoding)
        }
        
        return request;
    }
    
    /**
        Generates required url based on type: HuueyGet
     
        - Parameter: type, HuueyGet
        - Parameter: id?, ID of light/scene/group
     */
    private func generateUrl(type: HuueyGet, id:Int?=nil) -> String {
        var baseUrl: String = ""
        
        if self.HUE_ADDR != nil && self.HUE_KEY != nil {
            baseUrl = "http://\(self.HUE_ADDR!)/api/\(self.HUE_KEY!)/"
        }
        
        switch type {
            case .Lights:
                baseUrl += HuueyConstants.HUE_ENDPOINT_LIGHTS
            break
            case .ScenesSet:
                baseUrl += HuueyConstants.HUE_ENDPOINT_GROUPS + "/0/action"
            break
            case .ScenesGet:
                baseUrl += HuueyConstants.HUE_ENDPOINT_SCENES
            break
            case .Light:
                baseUrl += HuueyConstants.HUE_ENDPOINT_LIGHTS + "/\(id!)"
            break
            case .Discover:
                baseUrl = HuueyConstants.HUE_UPNP_DISCOVERY_URL
            break
            case .Api:
                baseUrl = "http://\(self.HUE_ADDR!)/api/"
            break
            case .Connected:
                baseUrl += HuueyConstants.HUE_ENDPOINT_LIGHTS
            break
        }
        
        return baseUrl
    }
    
    /**
        Generates dictionary for request body
     
        - Parameter: on, On/Off status of light
     */
    private func generateDict(on: Bool) -> [String:Bool] {
        return [
            "on": on
        ]
    }
    
    /**
        Generates dictionary for request body.
     
        Sets light state to ON
     
        - Parameter: scene, String: ID of scene to activate     
     */
    private func generateDict(scene: String) -> [String:AnyObject] {
        return [
            "scene": scene,
            "on": true
        ]
    }
    
    /**
        Generates dictionary for request body
     
        Sets light state to ON
     
        - Parameter: hue, Int: Light Hue 0 - 65280.0
        - Parameter: sat, Int: Light Saturation 0 - 255
        - Parameter: bri, Int: Light Brightness 0 - 255
     */
    private func generateDict(hue:Int, sat:Int, bri:Int) -> [String:AnyObject] {
        return [
            "hue":hue,
            "sat":sat,
            "bri":bri,
            "on":true
        ]
    }
}