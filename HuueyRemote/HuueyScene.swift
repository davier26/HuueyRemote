//
//  HuueyScenes.swift
//  HuueyRemote
//
//  Created by Nicholas Young on 10/21/15.
//  Copyright © 2015 Nicholas Young. All rights reserved.
//

import Foundation

public class HuueyScene {
    /**
        Private holder variables
     */
    private var name: String!
    private var id: String!
    
    /**
        - Returns: Name of scene
     */
    public func getName() -> String {
        return name
    }
    
    /**
        - Returns: ID of scene
     */
    public func getID() -> String {
        return id
    }
    
    /**
        - Parameter: name, Name of light
        - Parameter: id, ID of light
     */
    public init(name: String, id:String) {
        self.name = name
        self.id = id
    }
}