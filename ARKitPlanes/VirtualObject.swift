//
//  VirtualObject.swift
//  ARKitPlanes
//
//  Created by Roman Belov on 20.06.2022.
//

import SceneKit

class VirtualObject: SCNReferenceNode {
    
    static let availableObjects: [SCNReferenceNode] = {
        
        guard let modelsURL = Bundle.main.url(forResource: "art.scnassets", withExtension: nil) else { return [] }
        
        let fileEnumerator = FileManager().enumerator(at: modelsURL, includingPropertiesForKeys: nil)!
        
        return fileEnumerator.compactMap({ element in
            let url = element as! URL
            
            guard url.pathExtension == "scn" else { return nil }
            
            return VirtualObject(url: url)
        })
    }()
}
