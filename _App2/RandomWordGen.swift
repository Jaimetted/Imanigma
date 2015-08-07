//
//  File.swift
//  _App
//
//  Created by Intern McIntern on 7/21/15.
//  Copyright (c) 2015 Intern McIntern. All rights reserved.
//

import Foundation

class RandomWordGen{
    
    func generate() -> String{
        let bundle = NSBundle.mainBundle()
        let path = bundle.pathForResource("Words", ofType: "txt")
        let text = String(contentsOfFile: path!, encoding: NSUTF8StringEncoding, error: nil)
        //let text = String(contentsOfFile: "/Users/intern/Desktop/_App2 UI/_App2/Words.txt", encoding: NSUTF8StringEncoding, error: nil)
        
        let lines : [String] = text!.componentsSeparatedByString("\n")
        let lower: UInt32 = 0
        let upper: UInt32 = UInt32(lines.count)
        var temp = Int(arc4random_uniform((upper-lower) - lower))
        return lines[temp]
        
    }
}

