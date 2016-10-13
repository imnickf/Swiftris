//
//  Shape.swift
//  Swiftris
//
//  Created by Nick Flege on 10/13/16.
//  Copyright © 2016 Nick Flege. All rights reserved.
//

import SpriteKit

let NumOrientations: UInt32 = 4

enum Orientation: Int, CustomStringConvertible
{
  case zero = 0, ninety, oneEighty, twoSeventy
  
  var description: String
  {
    switch self {
    case .zero:
      return "0"
    case .ninety:
      return "90"
    case .oneEighty:
      return "180"
    case .twoSeventy:
      return "270"
    }
  }
  
  static func random() -> Orientation
  {
    return Orientation(rawValue: Int(arc4random_uniform(NumOrientations)))!
  }
  
  static func rotate(orientation: Orientation, clockwise: Bool) -> Orientation
  {
    var rotated = orientation.rawValue + (clockwise ? 1 : -1)
    if rotated > Orientation.twoSeventy.rawValue {
      rotated = Orientation.zero.rawValue
    } else if rotated < 0 {
      rotated = Orientation.twoSeventy.rawValue
    }
    
    return Orientation(rawValue: rotated)!
  }
}

let NumShapeTypes: UInt32 = 7

let FirstBlockIdx: Int = 0
let SecondBlockIdx: Int = 1
let ThirdBlockIdx: Int = 2
let FourthBlockIdx: Int = 3

class Shape: Hashable, CustomStringConvertible
{
  let color: BlockColor
  var blocks = [Block]()
  var orientation: Orientation
  var column, row: Int
  
  var blockRowColumnPositions: [Orientation: [(columnDiff: Int, rowDiff: Int)]]
  {
    return [:]
  }
  
  var bottomBlocksForOrientations: [Orientation: [Block]]
  {
    return [:]
  }
  
  var bottomBlocks: [Block]
  {
    guard let bottomBlocks = bottomBlocksForOrientations[orientation] else {
      return []
    }
    return bottomBlocks
  }
  
  var hashValue: Int
  {
    return blocks.reduce(0) { $0.hashValue ^ $1.hashValue }
  }
  
  var description: String
  {
    return "\(color) block facing \(orientation): \(blocks[FirstBlockIdx]), \(blocks[SecondBlockIdx]), \(blocks[ThirdBlockIdx]), \(blocks[FourthBlockIdx])"
  }
  
  init(column: Int, row: Int, color: BlockColor, orientation: Orientation)
  {
    self.column = column
    self.row = row
    self.color = color
    self.orientation = orientation
    initalizeBlocks()
  }
  
  convenience init(column: Int, row: Int)
  {
    self.init(column: column, row: row, color: BlockColor.random(), orientation: Orientation.random())
  }
  
  final func initalizeBlocks()
  {
    guard let blockRowColumnTranslations = blockRowColumnPositions[orientation] else {
      return
    }
    blocks = blockRowColumnTranslations.map { (diff) -> Block in
      return Block(column: column + diff.columnDiff, row: row + diff.rowDiff, color: color)
    }
  }
  
  static func ==(lhs: Shape, rhs: Shape) -> Bool
  {
    return lhs.row == rhs.row && lhs.column == rhs.column
  }
}
