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
  
  @IBOutlet weak var scoreLabel: UILabel!
  @IBOutlet weak var levelLabel: UILabel!
  
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
    levelLabel.text = String(swiftris.level)
    scoreLabel.text = String(swiftris.score)
    scene.tickLengthMillis = TickLengthLevelOne
    
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
    
    scene.play(sound: "Sounds/gameover.mp3")
    scene.animateCollapsing(linesToRemove: swiftris.removeAllBlocks(), fallenBlocks: swiftris.removeAllBlocks()) {
      swiftris.beginGame()
    }
  }
  
  func gameDidLevelUp(swiftris: Swiftris)
  {
    levelLabel.text = String(swiftris.level)
    if scene.tickLengthMillis >= 100 {
      scene.tickLengthMillis -= 100
    } else if scene.tickLengthMillis > 50 {
      scene.tickLengthMillis -= 50
    }
    scene.play(sound: "Sounds/levelup.mp3")
  }
  
  func gameShapeDidDrop(swiftris: Swiftris)
  {
    scene.stopTicking()
    scene.redrawShape(shape: swiftris.fallingShape!) { 
      swiftris.letShapeFall()
    }
    scene.play(sound: "Sounds/drop.mp3")
  }
  
  func gameShapeDidLand(swiftris: Swiftris)
  {
    scene.stopTicking()
    self.view.isUserInteractionEnabled = false
    
    let removedLines = swiftris.removeCompletedLines()
    if removedLines.linesRemoved.count > 0 {
      self.scoreLabel.text = "\(swiftris.score)"
      scene.animateCollapsing(linesToRemove: removedLines.linesRemoved, fallenBlocks:removedLines.fallenBlocks) {
        self.gameShapeDidLand(swiftris: swiftris)
      }
      scene.play(sound: "Sounds/bomb.mp3")
    } else {
      nextShape()
    }
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
