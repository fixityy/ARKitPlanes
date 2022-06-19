//
//  Box.swift
//  ARKitPlanes
//
//  Created by Roman Belov on 18.06.2022.
//

import SceneKit
import ARKit

class Box: SCNNode {
    init(atPosition position: SCNVector3) {
        super.init()

        let boxGeometry = SCNBox(width: 0.2, height: 0.2, length: 0.2, chamferRadius: 0)
        boxGeometry.firstMaterial?.diffuse.contents = UIColor.systemMint
        
        self.geometry = boxGeometry
        
        self.position = position
        
        let physicsShape = SCNPhysicsShape(geometry: self.geometry!, options: nil)
        
        self.physicsBody = SCNPhysicsBody(type: .dynamic, shape: physicsShape)
        
        self.physicsBody?.categoryBitMask = BitMaskCategory.box
        self.physicsBody?.collisionBitMask = BitMaskCategory.box | BitMaskCategory.plane
        self.physicsBody?.contactTestBitMask = BitMaskCategory.plane | BitMaskCategory.box
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
