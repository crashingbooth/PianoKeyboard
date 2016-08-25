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
    let margin: CGFloat = 0
    let normalColor: UIColor!
    let keyType: KeyType!
    
    enum KeyStates {
        case Default, Pressed
    }
    
    var keyState: KeyStates = .Default
    var keyNumber: Int!
    var midiNoteNumber: UInt8!
    var isDisabled =  false
    weak var delegate: PianoKeyDelegate?
    
    init(frame: CGRect, midiNoteNumber: UInt8, type: KeyType) {
        self.keyType = type
        self.normalColor = type == .White ? UIColor.whiteColor() : UIColor.blackColor()
        self.midiNoteNumber = midiNoteNumber
        super.init(frame: frame)
        userInteractionEnabled = false
    }
    
  
    required init?(coder aDecoder: NSCoder) {
        self.normalColor = UIColor.blackColor()
        self.keyType = .White
        self.midiNoteNumber = 60
        super.init(coder: aDecoder)
    }
    
    func getPathAtMargin() -> UIBezierPath {

        let cornerRadius =  CGSize(width: self.bounds.width / 5.0, height:  self.bounds.width / 5.0)
        let marginRect = CGRect(x: margin, y: margin, width: self.bounds.width - (margin * 2.0), height: self.bounds.height - (margin * 2.0))
        let path = UIBezierPath(roundedRect: marginRect, byRoundingCorners: [UIRectCorner.BottomLeft, UIRectCorner.BottomRight], cornerRadii:  cornerRadius)

        path.lineWidth = 2.0
        return path
    }
    
    func pressed() -> Bool {
        if keyState != .Pressed {
//            print("pressed: \(midiNoteNumber)")
            keyState = .Pressed
            setNeedsDisplay()
            delegate?.keyPushReceived(self)
            return true
        } else {
            return false
        }
    }
    
    func released() -> Bool {
        if keyState != .Default {
            
//            print("released: \(midiNoteNumber)")
            keyState = .Default
            setNeedsDisplay()
            delegate?.keyPushReceived(self)
            return true
        } else {
            return false
        }
        
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
    }
    
}


protocol PianoKeyDelegate: class{
    func playNoteFromKeyboard(sender: PianoKey) -> Void
    func keyPushReceived(sender: PianoKey) -> Void
}






