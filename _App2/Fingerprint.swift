//
//  Fingerprint.swift
//  _App
//
//  Created by Intern McIntern on 7/20/15.
//  Copyright (c) 2015 Intern McIntern. All rights reserved.
//

import Foundation
import UIKit


class Fingerprint{
    
    let GRID_WIDTH = 32
    let GRID_HEIGHT = 32
    
    var red = Array(count:32, repeatedValue:Array(count: 32, repeatedValue: Int()))
    var green = Array(count:32, repeatedValue:Array(count: 32, repeatedValue: Int()))
    var blue = Array(count:32, repeatedValue:Array(count: 32, repeatedValue: Int()))
    
    var msbRed = Array(count:32, repeatedValue:Array(count:32, repeatedValue:Int()))
    var msbGreen = Array(count:32, repeatedValue:Array(count:32, repeatedValue:Int()))
    var msbBlue = Array(count:32, repeatedValue:Array(count:32, repeatedValue:Int()))
    
    func getHashCode()->String{
        var totalRed = 0
        var totalGreen = 0
        var totalBlue = 0
        for (var i: Int = 0; i < GRID_WIDTH; i++) {
            for (var j: Int = 0; j < GRID_HEIGHT; j++) {
                totalRed += msbRed[i][j]
                totalGreen += msbGreen[i][j]
                totalBlue += msbBlue[i][j]
            }
        }
        return (totalRed.description + "-" + totalGreen.description)
    }
}

 