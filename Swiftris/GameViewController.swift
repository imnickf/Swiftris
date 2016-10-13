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
  var swiftris: Swiftris!
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
  
    let skView = view as! SKView
    skView.isMultipleTouchEnabled = false
    
    scene = GameScene(size: skView.bounds.size)
    scene.scaleMode = .aspectFill
    scene.tick = didTick
    
    swiftris = Swiftris()
    swiftris.beginGame()
  
    skView.presentScene(scene)
    
    scene.addPreviewShapeToScene(shape: swiftris.nextShape!) { 
      self.swiftris.nextShape?.moveTo(column: StartingColumn, row: StartingRow)
      self.scene.movePreviewShape(shape: self.swiftris.nextShape!) {
        let nextShapes = self.swiftris.newShape()
        self.scene.startTicking()
        self.scene.addPreviewShapeToScene(shape: nextShapes.nextShape!) {}
      }
    }
  }

  override var prefersStatusBarHidden: Bool
  {
    return true
  }
  
  func didTick()
  {
    swiftris.fallingShape?.lowerByOneRow()
    scene.redrawShape(shape: swiftris.fallingShape!, completion: {})
  }
}
