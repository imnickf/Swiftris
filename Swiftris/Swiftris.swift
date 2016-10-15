//
//  Swiftris.swift
//  Swiftris
//
//  Created by Nick Flege on 10/13/16.
//  Copyright © 2016 Nick Flege. All rights reserved.
//

let NumColumns = 10
let NumRows = 20

let StartingColumn = 4
let StartingRow = 0

let PreviewColumn = 12
let PreviewRow = 1

protocol SwiftrisDelegate
{
  // Called when the current round of Swiftris ends
  func gameDidEnd(swiftris: Swiftris)
  
  // Called when a new game has begun
  func gameDidBegin(swiftris: Swiftris)
  
  // Called when the falling shape has become part of the gameboard
  func gameShapeDidLand(swiftris: Swiftris)
  
  // Called when the falling shape has changed its location
  func gameShapeDidMove(swiftris: Swiftris)
  
  // Called when the falling shape has changed its location after being dropped
  func gameShapeDidDrop(swiftris: Swiftris)
  
  // Called when game has reached a new level
  func gameDidLevelUp(swiftris: Swiftris)
}

class Swiftris
{
  var blockArray: Array2D<Block>
  var nextShape: Shape?
  var fallingShape: Shape?
  var delegate: SwiftrisDelegate?
  
  init()
  {
    fallingShape = nil
    nextShape = nil
    blockArray = Array2D<Block>(columns: NumColumns, rows: NumRows)
  }
  
  func beginGame()
  {
    if nextShape == nil {
      nextShape = Shape.random(startingColumn: PreviewColumn, startingRow: PreviewRow)
    }
    delegate?.gameDidBegin(swiftris: self)
  }
  
  func newShape() -> (fallingShape: Shape?, nextShape: Shape?)
  {
    fallingShape = nextShape
    nextShape = Shape.random(startingColumn: PreviewColumn, startingRow: PreviewRow)
    fallingShape?.moveTo(column: StartingColumn, row: StartingRow)
    
    guard !detectIllegalPlacement() else {
      nextShape = fallingShape
      nextShape!.moveTo(column: PreviewColumn, row: PreviewRow)
      endGame()
      return (nil, nil)
    }
    return (fallingShape, nextShape)
  }
  
  func detectIllegalPlacement() -> Bool
  {
    guard let shape = fallingShape else {
      return false
    }
    for block in shape.blocks {
      if block.column < 0 || block.column >= NumColumns || block.row < 0 || block.row >= NumRows {
        return true
      } else if blockArray[block.column, block.row] != nil {
        return true
      }
    }
    return false
  }
  
  func endGame()
  {
    
  }
}
