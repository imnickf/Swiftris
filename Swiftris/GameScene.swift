//
//  GameScene.swift
//  Swiftris
//
//  Created by Nick Flege on 10/12/16.
//  Copyright © 2016 Nick Flege. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene
{
  required init(coder aDecoder: NSCoder)
  {
    fatalError("NSCoder not supported")
  }
  
  override init(size: CGSize)
  {
    super.init(size: size)
    
    anchorPoint = CGPoint(x: 0, y: 1.0)
    
    let background = SKSpriteNode(imageNamed: "background")
    background.position = CGPoint(x: 0, y: 0)
    background.anchorPoint = CGPoint(x: 0, y: 1)
    addChild(background)
  }
  
  override func update(_ currentTime: TimeInterval)
  {
    // Called before each frame is rendered
  }
}
