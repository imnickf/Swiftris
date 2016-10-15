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
    swiftris.delegate = self
    swiftris.beginGame()
  
    skView.presentScene(scene)
  }

  override var prefersStatusBarHidden: Bool
  {
    return true
  }
  
  func didTick()
  {
    swiftris.letShapeFall()
  }
  
  func nextShape()
  {
    let newShape = swiftris.newShape()
    guard let fallingShape = newShape.fallingShape else {
      return
    }
    scene.addPreviewShapeToScene(shape: newShape.nextShape!) {}
    scene.movePreviewShape(shape: fallingShape) { 
      self.view.isUserInteractionEnabled = true
      self.scene.startTicking()
    }
  }
}

extension GameViewController: SwiftrisDelegate
{
  func gameDidBegin(swiftris: Swiftris)
  {
    if swiftris.nextShape != nil && swiftris.nextShape!.blocks[0].sprite == nil {
      scene.addPreviewShapeToScene(shape: swiftris.nextShape!) {
        self.nextShape()
      }
    } else {
      nextShape()
    }
  }
  
  func gameDidEnd(swiftris: Swiftris)
  {
    view.isUserInteractionEnabled = false
    scene.stopTicking()
  }
  
  func gameDidLevelUp(swiftris: Swiftris)
  {
    
  }
  
  func gameShapeDidDrop(swiftris: Swiftris)
  {
    
  }
  
  func gameShapeDidLand(swiftris: Swiftris)
  {
    scene.stopTicking()
    nextShape()
  }
  
  func gameShapeDidMove(swiftris: Swiftris)
  {
    scene.redrawShape(shape: swiftris.fallingShape!) {}
  }
}
