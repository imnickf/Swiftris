//
//  JShape.swift
//  Swiftris
//
//  Created by Nick Flege on 10/13/16.
//  Copyright © 2016 Nick Flege. All rights reserved.
//

class JShape: Shape
{
  /*
   
   Orientation 0
   
   • | 0 |
   | 1 |
   | 3 | 2 |
   
   Orientation 90
   
   | 3•|
   | 2 | 1 | 0 |
   
   Orientation 180
   
   | 2•| 3 |
   | 1 |
   | 0 |
   
   Orientation 270
   
   | 0•| 1 | 2 |
   | 3 |
   
   • marks the row/column indicator for the shape
   
   Pivots about `1`
   
   */
  
  override var blockRowColumnPositions: [Orientation: Array<(columnDiff: Int, rowDiff: Int)>]
  {
    return [
      Orientation.zero:       [(1, 0), (1, 1),  (1, 2),  (0, 2)],
      Orientation.ninety:     [(2, 1), (1, 1),  (0, 1),  (0, 0)],
      Orientation.oneEighty:  [(0, 2), (0, 1),  (0, 0),  (1, 0)],
      Orientation.twoSeventy: [(0, 0), (1, 0),  (2, 0),  (2, 1)]
    ]
  }
  
  override var bottomBlocksForOrientations: [Orientation: Array<Block>]
  {
    return [
      Orientation.zero:       [blocks[ThirdBlockIdx], blocks[FourthBlockIdx]],
      Orientation.ninety:     [blocks[FirstBlockIdx], blocks[SecondBlockIdx], blocks[ThirdBlockIdx]],
      Orientation.oneEighty:  [blocks[FirstBlockIdx], blocks[FourthBlockIdx]],
      Orientation.twoSeventy: [blocks[FirstBlockIdx], blocks[SecondBlockIdx], blocks[FourthBlockIdx]]
    ]
  }
}
