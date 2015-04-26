/*
 * Copyright (c) 2013-2014 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import Foundation
import CoreGraphics

func tileMapLayerFromFileNamed(fileName: String) -> TileMapLayer? {
  // file must be in bundle
  let path = NSBundle.mainBundle().pathForResource(fileName, ofType: nil)
  if path == nil {
    return nil
  }
  
  var error: NSError?
  let fileContents = String(contentsOfFile:path!, encoding: NSUTF8StringEncoding, error: &error)
    
  // if there was an error, there is nothing to be done.
  // Should never happen in properly configured system.
  if error != nil && fileContents == nil {
    return nil
  }
    
  // get the contents of the file, separated into lines
  let lines = Array<String>(fileContents!.componentsSeparatedByString("\n"))
    
  // first line contains the atlas name for this layer's tiles
  let atlasName = lines[0]
    
  // second line contains tile size, in form width x height
  let tileSizeComps = lines[1].componentsSeparatedByString("x")
    
  var width = tileSizeComps[0].toInt()
    
  var height = tileSizeComps[tileSizeComps.endIndex-1].toInt()
    
  if width != nil && height != nil {
    let tileSize = CGSize(width: width!, height: height!)
      
    //  // remaining lines are the grid. It's assumed that all rows are same length
    let tileCodes = lines[2..<lines.endIndex]
      
    return TileMapLayer(atlasName: atlasName, tileSize: tileSize, tileCodes: Array(tileCodes))
  }
  return nil
}
