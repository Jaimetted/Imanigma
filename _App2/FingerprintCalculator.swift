//
//  FingerprintCalculator.swift
//  _App
//
//  Created by Intern McIntern on 7/20/15.
//  Copyright (c) 2015 Intern McIntern. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit

extension UIColor {
    
    func rgb() -> Int? {
        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
        var fAlpha: CGFloat = 0
        if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
            
            let iRed = Int(fRed * 255)
            let iGreen = Int(fGreen * 255)
            let iBlue = Int(fBlue * 255)
            let iAlpha = Int(fAlpha * 255)
            let rgb = (iAlpha << 24) + (iRed << 16) + (iGreen << 8) + iBlue
            return rgb
        } else {
            return nil
        }
    }
}

extension UIImage {
    func getPixelColor(pos: CGPoint, forImageData data: UnsafePointer<UInt8>) -> UIColor {
        var pixelInfo: Int = ((Int(self.size.width) * Int(pos.y)) + Int(pos.x)) * 4
        
        var r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
        var g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
        var b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
        var a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)
        
        return UIColor(red: ceil(r), green: ceil(g) ,blue: ceil(b), alpha: ceil(a)  )
    }
}

class FingerprintCalculator{
    
    func getFingerprint(source: UIImage)->Fingerprint{
        var result =  Fingerprint()
        var original = source.CGImage
        
        var blockPixelsY: Int = Int(ceil(source.size.height / CGFloat(result.GRID_HEIGHT)))
        var blockPixelsX: Int = Int(ceil(source.size.width / CGFloat(result.GRID_WIDTH)))
        
        var pixelData = CGDataProviderCopyData(CGImageGetDataProvider(source.CGImage))
        var data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        for (var i: Int = 0; i < ((Int)(source.size.width)); ++i) {
            for (var j: Int = 0; j < ((Int)(source.size.height)); ++j) {
                
                var color:UIColor = source.getPixelColor(CGPoint(x: i, y: j), forImageData: data)
                var RGB: Int? = color.rgb()
                result.red[(i / blockPixelsX)][(j / blockPixelsY)] += ( RGB! >> 16 ) & 0xFF00
               // result.green[(i / blockPixelsX)][(j / blockPixelsY)] += (RGB! >> 8) & 0xFFFF0000
                //result.blue[(i / blockPixelsX)][(j / blockPixelsY)] += ( RGB! & 0xFFFF00 )
            }
        }
        for (var i: Int = 0; i < result.GRID_WIDTH; i++) {
            for (var j: Int = 0; j < result.GRID_HEIGHT; j++) {
                result.red[i][j] /= blockPixelsX * blockPixelsY
                result.green[i][j] /= blockPixelsX * blockPixelsY
                result.blue[i][j] /= blockPixelsX * blockPixelsY
                
                result.msbRed[i][j] = result.red[i][j] >> 6
                
                result.msbGreen[i][j] = result.green[i][j] >> 6
                
                result.msbBlue[i][j] = result.blue[i][j] >> 6
            }
        }
        
        
        return result
    }
}/*//
//  FingerprintCalculator.swift
//  _App
//
//  Created by Intern McIntern on 7/20/15.
//  Copyright (c) 2015 Intern McIntern. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit

extension UIColor {

func rgb() -> Int? {
var fRed : CGFloat = 0
var fGreen : CGFloat = 0
var fBlue : CGFloat = 0
var fAlpha: CGFloat = 0
if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {

let iRed = Int(fRed * 255.0)
let iGreen = Int(fGreen * 255.0)
let iBlue = Int(fBlue * 255.0)
let iAlpha = Int(fAlpha * 255.0)

let rgb = (iAlpha << 24) + (iRed << 16) + (iGreen << 8) + iBlue
return rgb
} else {
return nil
}
}
}

extension UIImage {
func getPixelColor(pos: CGPoint, forImageData data: UnsafePointer<UInt8>) -> UIColor {
var pixelInfo: Int = ((Int(self.size.width) * Int(pos.y)) + Int(pos.x)) * 4

var r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
var g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
var b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
var a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)

return UIColor(red: r, green: g, blue: b, alpha: a)
}
}

class FingerprintCalculator{

func getFingerprint(source: UIImage)->Fingerprint{
var result =  Fingerprint()
var original = source.CGImage

var blockPixelsY: Int = Int(ceil(source.size.height / CGFloat(result.GRID_HEIGHT)))
var blockPixelsX: Int = Int(ceil(source.size.width / CGFloat(result.GRID_WIDTH)))

var pixelData = CGDataProviderCopyData(CGImageGetDataProvider(source.CGImage))
var data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)

for (var i: Int = 0; i < ((Int)(source.size.width)); ++i) {
for (var j: Int = 0; j < ((Int)(source.size.height)); ++j) {

var color:UIColor = source.getPixelColor(CGPoint(x: i, y: j), forImageData: data)
var RGB: Int? = color.rgb()

result.red[(i / blockPixelsX)][(j / blockPixelsY)] += ( RGB! >> 16 ) & 0xFF
result.green[(i / blockPixelsX)][(j / blockPixelsY)] += (RGB! >> 8) & 0xFF
result.blue[(i / blockPixelsX)][(j / blockPixelsY)] += ( RGB! & 0xFF )
}
}
for (var i: Int = 0; i < result.GRID_WIDTH; i++) {
for (var j: Int = 0; j < result.GRID_HEIGHT; j++) {
result.red[i][j] /= (blockPixelsX * blockPixelsY)
result.green[i][j] /= (blockPixelsX * blockPixelsY)
result.blue[i][j] /= (blockPixelsX * blockPixelsY)
}
}
return result
}
}*/