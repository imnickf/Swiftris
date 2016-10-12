//
//  GameViewController.swift
//  Swiftris
//
//  Created by Nick Flege on 10/12/16.
//  Copyright © 2016 Nick Flege. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController
{
  var scene: GameScene!
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
  
    let skView = view as! SKView
    skView.isMultipleTouchEnabled = false
    
    scene = GameScene(size: skView.bounds.size)
    scene.scaleMode = .aspectFill
    
    skView.presentScene(scene)
  }

  override var prefersStatusBarHidden: Bool
  {
    return true
  }
}
