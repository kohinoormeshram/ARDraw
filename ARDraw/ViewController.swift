//
//  ViewController.swift
//  ARDraw
//
//  Created by Kohinoor on 24/05/19.
//  Copyright © 2019 Kohinoor. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var colorCollectionView: UICollectionView!
    
    let configuration = ARWorldTrackingConfiguration()
    
    let colors = [UIColor.black, UIColor.white, UIColor.red, UIColor.purple, UIColor.blue, UIColor.cyan, UIColor.green, UIColor.yellow, UIColor.orange, UIColor.brown]
    
    var pointerColor = UIColor.blue
    
    @IBOutlet weak var draw: UIButton!
    @IBOutlet weak var reset: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.colorCollectionView.dataSource = self
        self.colorCollectionView.delegate = self
        
        //self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        //self.sceneView.showsStatistics = true
        self.sceneView.session.run(configuration)
        self.sceneView.autoenablesDefaultLighting = true
        self.sceneView.delegate = self
    }

    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        //print("Rendering...")
        
        guard let pointOfView = sceneView.pointOfView else {return}
        let transform = pointOfView.transform
        let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        
        let currentPositionOfCamera = orientation + location
        var drawIsHighlighted = false
        if self.draw.isHighlighted {
            drawIsHighlighted = true
        }
        DispatchQueue.main.async {
            if drawIsHighlighted {
                let sphereNode = SCNNode(geometry: SCNSphere(radius: 0.02))
                sphereNode.position = currentPositionOfCamera
                sphereNode.geometry?.firstMaterial?.diffuse.contents = self.pointerColor
                self.sceneView.scene.rootNode.addChildNode(sphereNode)
            } else {
                let pointer = SCNNode(geometry: SCNSphere(radius: 0.01))
                pointer.name = "pointer"
                pointer.position = currentPositionOfCamera
                
                self.sceneView.scene.rootNode.enumerateChildNodes({ (node, _) in
                    if node.name == "pointer" {
                        node.removeFromParentNode()
                    }
                })
                
                self.sceneView.scene.rootNode.addChildNode(pointer)
                pointer.geometry?.firstMaterial?.diffuse.contents = self.pointerColor
            }
        }
    }
    
    @IBAction func reset(_ sender: Any) {
        self.sceneView.scene.rootNode.enumerateChildNodes({ (node, _) in
            node.removeFromParentNode()
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.colorCollectionView.dequeueReusableCell(withReuseIdentifier: "colorCell", for: indexPath) as! colorCollectionViewCell
        
        let currentColor = self.colors[indexPath.row]
        
        if currentColor == UIColor.black {
            cell.outerView.backgroundColor = UIColor.white
        } else {
            cell.outerView.backgroundColor = UIColor.black
        }
        cell.outerView.layer.cornerRadius = cell.outerView.bounds.size.width/2.0
        
        cell.innerView.backgroundColor = currentColor
        cell.innerView.layer.cornerRadius = cell.innerView.bounds.size.width/2.0
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = self.colorCollectionView.cellForItem(at: indexPath) as! colorCollectionViewCell
        self.pointerColor = cell.innerView.backgroundColor!
    }

}

func +(left : SCNVector3, right : SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}
