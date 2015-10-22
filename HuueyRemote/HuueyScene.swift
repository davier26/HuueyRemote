//
//  HuueyScenes.swift
//  HuueyRemote
//
//  Created by Nicholas Young on 10/21/15.
//  Copyright © 2015 Nicholas Young. All rights reserved.
//

import Foundation

public class HuueyScene {
    private var name: String!
    
    public func getName() -> String {
        return name
    }
    
    public init(name: String) {
        self.name = name
    }
}