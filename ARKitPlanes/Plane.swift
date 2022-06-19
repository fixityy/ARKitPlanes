//
//  Plane.swift
//  ARKitPlanes
//
//  Created by Roman Belov on 17.06.2022.
//

import ARKit
import SceneKit

class Plane: SCNNode {
    var anchor: ARPlaneAnchor!
    var planeGeometry: SCNPlane!
    
    init(anchor: ARPlaneAnchor) {
        self.anchor = anchor
        super.init()
        configure()
    }
    
    private func configure() {
        self.planeGeometry = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.x))
        self.planeGeometry.firstMaterial?.diffuse.contents = UIImage(named: "pinkWeb")
        
        self.geometry = planeGeometry
        
        self.position = SCNVector3(anchor.center.x, 0, anchor.center.z)
        
        self.transform = SCNMatrix4MakeRotation(Float(-Double.pi / 2), 1, 0, 0)
        
        let physicsShape = SCNPhysicsShape(geometry: self.geometry!, options: nil)
        
        self.physicsBody = SCNPhysicsBody(type: .static, shape: physicsShape)
        
        self.physicsBody?.categoryBitMask = BitMaskCategory.plane
        self.physicsBody?.collisionBitMask = BitMaskCategory.box
        self.physicsBody?.contactTestBitMask = BitMaskCategory.box
    }
    
    func update(anchor: ARPlaneAnchor) {
        self.planeGeometry.width = CGFloat(anchor.extent.x)
        self.planeGeometry.height = CGFloat(anchor.extent.z)
        self.position = SCNVector3(anchor.center.x, 0, anchor.center.z)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
