//
//  GameScene.swift
//  Swiftris
//
//  Created by Nick Flege on 10/12/16.
//  Copyright © 2016 Nick Flege. All rights reserved.
//

import SpriteKit
import GameplayKit

let TickLengthLevelOne = TimeInterval(600)
let BlockSize: CGFloat = 20.0

class GameScene: SKScene
{
  let gameLayer = SKNode()
  let shapeLayer = SKNode()
  let LayerPosition = CGPoint(x: 6, y: -6)
  
  var tick: (() -> ())?
  var tickLengthMillis = TickLengthLevelOne
  var lastTick: Date?
  
  var textureCache = [String : SKTexture]()
  
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
    
    addChild(gameLayer)
    let gameBoardTexture = SKTexture(imageNamed: "gameboard")
    let gameBoard = SKSpriteNode(texture: gameBoardTexture, size: CGSize(width: BlockSize * CGFloat(NumColumns), height: BlockSize * CGFloat(NumRows)))
    gameBoard.anchorPoint = CGPoint(x: 0, y: 1.0)
    gameBoard.position = LayerPosition
    
    shapeLayer.position = LayerPosition
    shapeLayer.addChild(gameBoard)
    gameLayer.addChild(shapeLayer)
    
    run(SKAction.repeatForever(SKAction.playSoundFileNamed("Sounds/theme.mp3", waitForCompletion: true)))
  }
  
  override func update(_ currentTime: TimeInterval)
  {
    guard let lastTick = lastTick else {
      return
    }
    
    let timePassed = lastTick.timeIntervalSinceNow * -1000.0
    if timePassed > tickLengthMillis {
      self.lastTick = Date()
      tick?()
    }
  }
  
  func play(sound: String)
  {
    run(SKAction.playSoundFileNamed(sound, waitForCompletion: false))
  }
  
  func startTicking()
  {
    lastTick = Date()
  }
  
  func stopTicking()
  {
    lastTick = nil
  }
  
  func pointFor(column: Int, row: Int) -> CGPoint
  {
    let x = LayerPosition.x + (CGFloat(column) * BlockSize) + (BlockSize / 2)
    let y = LayerPosition.y - ((CGFloat(row) * BlockSize) + (BlockSize / 2))
    return CGPoint(x: x, y: y)
  }
  
  func addPreviewShapeToScene(shape: Shape, completion: @escaping () -> ())
  {
    for block in shape.blocks {
      var texture = textureCache[block.spriteName]
      if texture == nil {
        texture = SKTexture(imageNamed: block.spriteName)
        textureCache[block.spriteName] = texture
      }
      
      let sprite = SKSpriteNode(texture: texture)
      sprite.position = pointFor(column: block.column, row: block.row - 2)
      shapeLayer.addChild(sprite)
      block.sprite = sprite
      
      sprite.alpha = 0
      
      let moveAction = SKAction.move(to: pointFor(column: block.column, row: block.row), duration: TimeInterval(0.2))
      moveAction.timingMode = .easeOut
      let fadeInAction = SKAction.fadeAlpha(to: 0.7, duration: 0.4)
      fadeInAction.timingMode = .easeOut
      sprite.run(SKAction.group([moveAction, fadeInAction]))
    }
    run(SKAction.wait(forDuration: 0.4), completion: completion)
  }
  
  func movePreviewShape(shape: Shape, completion: @escaping () -> ())
  {
    for block in shape.blocks {
      let sprite = block.sprite!
      let moveTo = pointFor(column: block.column, row:block.row)
      let moveToAction:SKAction = SKAction.move(to: moveTo, duration: 0.2)
      moveToAction.timingMode = .easeOut
      sprite.run(SKAction.group([moveToAction, SKAction.fadeAlpha(to: 1.0, duration: 0.2)]), completion: {})
    }
    run(SKAction.wait(forDuration: 0.2), completion: completion)
  }
  
  func redrawShape(shape:Shape, completion: @escaping () -> ())
  {
    for block in shape.blocks {
      let sprite = block.sprite!
      let moveTo = pointFor(column: block.column, row:block.row)
      let moveToAction:SKAction = SKAction.move(to: moveTo, duration: 0.05)
      moveToAction.timingMode = .easeOut
      
      if block == shape.blocks.last {
        sprite.run(moveToAction, completion: completion)
      } else {
        sprite.run(moveToAction)
      }
    }
  }
  
  func animateCollapsing(linesToRemove: [[Block]], fallenBlocks: [[Block]], completion: @escaping () -> ())
  {
    var longestDuration: TimeInterval = 0
    for (columnIndex, column) in fallenBlocks.enumerated() {
      for (blockIndex, block) in column.enumerated() {
        let newPosition = pointFor(column: block.column, row: block.row)
        let sprite = block.sprite!
        let delay = (TimeInterval(columnIndex) * 0.05) + (TimeInterval(blockIndex) * 0.05)
        let duration = TimeInterval(((sprite.position.y - newPosition.y) / BlockSize) * 0.1)
        let moveAction = SKAction.move(to: newPosition, duration: duration)
        moveAction.timingMode = .easeOut
        sprite.run(SKAction.sequence([SKAction.wait(forDuration: delay), moveAction]))
        longestDuration = max(longestDuration, duration + delay)
      }
    }
    
    for rowToRemove in linesToRemove {
      for block in rowToRemove {
        let randomRadius = CGFloat(UInt(arc4random_uniform(400) + 100))
        let goLeft = arc4random_uniform(100) % 2 == 0
        
        var point = pointFor(column:block.column, row: block.row)
        point = CGPoint(x: point.x + (goLeft ? -randomRadius : randomRadius), y: point.y)
        
        let randomDuration = TimeInterval(arc4random_uniform(2)) + 0.5
        var startAngle = CGFloat(M_PI)
        var endAngle = startAngle * 2
        if goLeft {
          endAngle = startAngle
          startAngle = 0
        }
        let archPath = UIBezierPath(arcCenter: point, radius: randomRadius, startAngle: startAngle, endAngle: endAngle, clockwise: goLeft)
        let archAction = SKAction.follow(archPath.cgPath, asOffset: false, orientToPath: true, duration: randomDuration)
        archAction.timingMode = .easeIn
        let sprite = block.sprite!
        
        sprite.zPosition = 100
        sprite.run(SKAction.sequence([SKAction.group([archAction, SKAction.fadeOut(withDuration: TimeInterval(randomDuration))]),SKAction.removeFromParent()]))
      }
    }
    run(SKAction.wait(forDuration: longestDuration), completion:completion)
  }
}
