//
//  PianoKey.swift
//  KeyboardDemo
//
//  Created by Jeff Holtzkener on 8/23/16.
//  Copyright © 2016 Jeff Holtzkener. All rights reserved.
//

import UIKit



class PianoKey: UIButton {
    enum KeyType {
        case White, Black
    }
    
    let margin: CGFloat = 0.0
    let normalColor: UIColor!
    let keyType: KeyType!
    let midiNoteNumber: UInt8!
    
    enum KeyStates {
        case Default, Pressed
    }
    
    var keyState: KeyStates = .Default
    
    init(frame: CGRect, midiNoteNumber: UInt8, type: KeyType) {
        self.keyType = type
        self.normalColor = type == .White ? UIColor.whiteColor() : UIColor.blackColor()
        self.midiNoteNumber = midiNoteNumber
        super.init(frame: frame)
        userInteractionEnabled = false
    }
    
  
    required init?(coder aDecoder: NSCoder) {
        // will never call this
        self.normalColor = UIColor.blackColor()
        self.keyType = .White
        self.midiNoteNumber = 60
        super.init(coder: aDecoder)
    }
    
    func getPathAtMargin() -> UIBezierPath {
        // set margin property if wanted
        let cornerRadius =  CGSize(width: self.bounds.width / 5.0, height:  self.bounds.width / 5.0)
        let marginRect = CGRect(x: margin, y: margin, width: self.bounds.width - (margin * 2.0), height: self.bounds.height - (margin * 2.0))
        let path = UIBezierPath(roundedRect: marginRect, byRoundingCorners: [UIRectCorner.BottomLeft, UIRectCorner.BottomRight], cornerRadii:  cornerRadius)
        path.lineWidth = 2.0
        
        return path
    }
    
    override func drawRect(rect: CGRect) {
        
        let path = getPathAtMargin()
        switch keyState {
        case .Default:
            normalColor.setFill()
        case .Pressed:
            UIColor.lightGrayColor().setFill()
        }
        UIColor.blackColor().setStroke()
        path.fill()
        path.stroke()
        
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = path.CGPath
        self.layer.mask = maskLayer
    }

    
    // MARK: - Respond to key presses
    func pressed() -> Bool {
        if keyState != .Pressed {
            keyState = .Pressed
            setNeedsDisplay()
            return true
        } else {
            return false
        }
    }
    
    func released() -> Bool {
        if keyState != .Default {
            keyState = .Default
            setNeedsDisplay()
            return true
        } else {
            return false
        }
        
    }
}









