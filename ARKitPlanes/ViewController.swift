//
//  ViewController.swift
//  ARKitPlanes
//
//  Created by Roman Belov on 17.06.2022.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {

    @IBOutlet var sceneView: ARSCNView!
    var planes = [Plane]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        sceneView.autoenablesDefaultLighting = true
        sceneView.debugOptions = [.showFeaturePoints]
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        //обязательно присваиваем делегат после присвоения новой сцены, а не до этого!
        sceneView.scene.physicsWorld.contactDelegate = self
        
        setupGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
}

//MARK: Gestures and objects 
extension ViewController {
    func setupGesture() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(placeBox))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer.numberOfTapsRequired = 1
        
        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(placeVirtualObject))
        sceneView.addGestureRecognizer(doubleTapGestureRecognizer)
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        
        //одинарное нажатия сработает только в случае отсутствия двойного нажатия.
        tapGestureRecognizer.require(toFail: doubleTapGestureRecognizer)
    }
    
    @objc func placeBox(tapGesture: UITapGestureRecognizer) {
        let sceneView = tapGesture.view as! ARSCNView
        let location = tapGesture.location(in: sceneView)
                
        let raycastQuery = sceneView.raycastQuery(from: location, allowing: .estimatedPlane, alignment: .horizontal)
        guard let result = sceneView.session.raycast(raycastQuery!).first else { return }
        createBox(hitResult: result)
    }
        
    func createBox(hitResult: ARRaycastResult) {
        let position = SCNVector3(hitResult.worldTransform.columns.3.x,
                                  hitResult.worldTransform.columns.3.y + 0.5,
                                  hitResult.worldTransform.columns.3.z)
        
        let box = Box(atPosition: position)
        sceneView.scene.rootNode.addChildNode(box)
    }

    
    @objc func placeVirtualObject(tapGesture: UITapGestureRecognizer) {
        let sceneView = tapGesture.view as! ARSCNView
        let location = tapGesture.location(in: sceneView)
        
        let raycastQuery = sceneView.raycastQuery(from: location, allowing: .estimatedPlane, alignment: .horizontal)
        guard let result = sceneView.session.raycast(raycastQuery!).first else { return }
        createVirtualObject(hitResult: result)
    }
    
    func createVirtualObject(hitResult: ARRaycastResult) {
        let position = SCNVector3(hitResult.worldTransform.columns.3.x,
                                  hitResult.worldTransform.columns.3.y + 0.05,
                                  hitResult.worldTransform.columns.3.z)
        
        let virtualObject = VirtualObject.availableObjects[1]
        virtualObject.position = position
        virtualObject.load()
        sceneView.scene.rootNode.addChildNode(virtualObject)
    }

}

//MARK: ARSCNViewDelegate
extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor else { return }
        
        let plane = Plane(anchor: anchor as! ARPlaneAnchor)
        
        planes.append(plane)
        node.addChildNode(plane)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        let plane = planes.filter { plane in
            return plane.anchor.identifier == anchor.identifier
        }.first
        
        guard plane != nil else { return }
        
        plane?.update(anchor: anchor as! ARPlaneAnchor)
    }
}

//MARK: SCNPhysicsContactDelegate
extension ViewController: SCNPhysicsContactDelegate {
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        let nodeA = contact.nodeA
        let nodeB = contact.nodeB
        
        if nodeA.physicsBody?.contactTestBitMask != nodeB.physicsBody?.contactTestBitMask {
            nodeA.geometry?.materials.first?.diffuse.contents = UIColor.systemRed
            nodeB.geometry?.materials.first?.diffuse.contents = UIColor.systemIndigo
        } else {
            nodeB.geometry?.materials.first?.diffuse.contents = UIColor.systemYellow
        }
    }
}
