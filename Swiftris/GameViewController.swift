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
  
  var panPointReference: CGPoint?
  
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
  
  // MARK: - Actions
  
  @IBAction func didTap(_ sender: UITapGestureRecognizer)
  {
    swiftris.rotateShape()
  }
  
  @IBAction func didPan(_ sender: UIPanGestureRecognizer)
  {
    let currentPoint = sender.translation(in: view)
    if let originalPoint = panPointReference {
      if abs(currentPoint.x - originalPoint.x) > (BlockSize * 0.9) {
        if sender.velocity(in: view).x > CGFloat(0) {
          swiftris.moveShapeRight()
          panPointReference = currentPoint
        } else {
          swiftris.moveShapeLeft()
          panPointReference = currentPoint
        }
      }
    } else if sender.state == .began {
      panPointReference = currentPoint
    }
  }
  
  @IBAction func didSwipe(_ sender: UISwipeGestureRecognizer)
  {
    swiftris.dropShape()
  }
  
  // MARK: - Helpers
  
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
    scene.stopTicking()
    scene.redrawShape(shape: swiftris.fallingShape!) { 
      swiftris.letShapeFall()
    }
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

extension GameViewController: UIGestureRecognizerDelegate
{
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool
  {
    return true
  }
  
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool
  {
    if gestureRecognizer is UISwipeGestureRecognizer {
      if otherGestureRecognizer is UIPanGestureRecognizer {
        return true
      }
    } else if gestureRecognizer is UIPanGestureRecognizer {
      if otherGestureRecognizer is UITapGestureRecognizer {
        return true
      }
    }
    return false
  }
}
