//
//  Bridge.swift
//  HuueyRemote
//
//  Created by Nicholas Young on 10/21/15.
//  Copyright © 2015 Nicholas Young. All rights reserved.
//

import Foundation

public enum HuueyGet {
    case Lights
    case ScenesSet
    case ScenesGet
    case Light
    case Discover
    case Api
    case Connected
}

public class HuueyInterface {
    
    private struct HuueyConstants {
        static let HUE_KEY = "API_KEY"
        static let HUE_ADDR = "HUE_ADDR"
        static let HUE_DTYPE = "Huuey#TvOS"
        static let HUE_UPNP_DISCOVERY_URL = "https://www.meethue.com/api/nupnp"
        static let HUE_ENDPOINT_LIGHTS = "lights"
        static let HUE_ENDPOINT_SCENES = "scenes"
        static let HUE_ENDPOINT_GROUPS = "groups"
    }
    private struct HuueyMethods {
        static let GET = "GET"
        static let POST = "POST"
        static let PUT = "PUT"
    }
    
    var HUE_ADDR: String?
    var HUE_KEY: String?
    let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    
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
    
    public init(addr: String, key: String) {
        self.HUE_ADDR = addr
        self.HUE_KEY = key
    }
    
    public func set(on: Bool, light: HuueyLight) {
        self.request(generateUrl(HuueyGet.Light, id: light.id) + "/state", method: HuueyMethods.PUT, data: generateDict(on))
    }
    
    public func set(scene: HuueyScene) {
        let data = generateDict(scene.getID())
        self.request(self.generateUrl(HuueyGet.ScenesSet), method: HuueyMethods.PUT, data:data)
    }
    
    public func set(hue:Int, sat:Int, bri:Int, light:HuueyLight) {
        var data = generateDict(hue, sat: sat, bri: bri)
        data["on"] = true
        
        self.request(generateUrl(HuueyGet.Light, id: light.id) + "/state", method: HuueyMethods.PUT, data: data)
    }
    
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
    
    public func get(get: HuueyGet, id: Int) -> AnyObject {
        let request = self.request(generateUrl(get, id: id), method: HuueyMethods.GET)
        
        if get == HuueyGet.Light {
            return HuueyLight(data: request, id: id)
        }
        
        return false
    }
    
    public func discoverBridge() -> Bool {
        let request = self.request(generateUrl(HuueyGet.Discover), method: HuueyMethods.GET)
        
        if request.count > 0 {
            self.defaults.setValue(request[0]["internalipaddress"].string, forKeyPath: HuueyConstants.HUE_ADDR)
            return true
        }
        return false
    }
    
    public func connectToBridge() -> Bool {
        var connected = false;
        var response: JSON = ""
        
        while(!connected) {
            response = self.request(generateUrl(HuueyGet.Api), method:  HuueyMethods.POST, data: ["devicetype":HuueyConstants.HUE_DTYPE])
            
            if response[0]["error"]["type"] != 101 {
                connected = !connected;
                self.HUE_KEY = response[0]["success"]["username"].rawString()!
            }else {
                sleep(2)
            }
        }
        self.defaults.setValue(self.HUE_KEY, forKey: HuueyConstants.HUE_KEY)
        
        return true;
    }
    
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
    
    private func generateDict(scene: String) -> [String:AnyObject] {
        return [
            "scene": scene,
            "on": true
        ]
    }
    
    private func generateDict(on: Bool) -> [String:Bool] {
        return [
            "on": on
        ]
    }
    
    private func generateDict(hue:Int, sat:Int, bri:Int) -> [String:AnyObject] {
        return [
            "hue":hue,
            "sat":sat,
            "bri":bri,
            "on":true
        ]
    }
}