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
    private var id: String!
    
    public func getName() -> String {
        return name
    }
    
    public func getID() -> String {
        return id
    }
    
    public init(name: String, id:String) {
        self.name = name
        self.id = id
    }
}