//
//  HuueyGroupw.swift
//  HuueyRemote
//
//  Created by Nicholas Young on 10/21/15.
//  Copyright © 2015 Nicholas Young. All rights reserved.
//

import Foundation

public class HuueyGroup {
    var lights: [HuueyLight]!
    
    public init(lights: [HuueyLight]) {
        self.lights = lights
    }
}