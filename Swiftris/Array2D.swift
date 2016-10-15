//
//  Array2D.swift
//  Swiftris
//
//  Created by Nick Flege on 10/12/16.
//  Copyright © 2016 Nick Flege. All rights reserved.
//

class Array2D<T>
{
  let columns: Int
  let rows: Int
  
  var array: Array<T?>
  
  init(columns: Int, rows: Int)
  {
    self.columns = columns
    self.rows = rows
    
    array = Array<T?>(repeating: nil, count: rows * columns)
  }
  
  subscript(column: Int, row: Int) -> T?
  {
    get {
      return array[(row * columns) + column]
    }
    
    set(newValue) {
      array[(row * columns) + column] = newValue
    }
  }
}
