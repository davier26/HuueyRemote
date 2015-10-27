//
//  HuueyGroupw.swift
//  HuueyRemote
//
//  Created by Nicholas Young on 10/21/15.
//  Copyright © 2015 Nicholas Young. All rights reserved.
//

import Foundation

public class HuueyGroup {
    /**
        Holds all of the lights
     */
    var lights: [HuueyLight]!
    
    
    /**
        - Parameters: lights, [HuueyLight]
     */
    public init(lights: [HuueyLight]) {
        self.lights = lights
    }
}