//
//  PianoKey.swift
//  KeyboardDemo
//
//  Created by Jeff Holtzkener on 8/23/16.
//  Copyright © 2016 Jeff Holtzkener. All rights reserved.
//

import UIKit



class PianoKey: UIButton {
    let margin: CGFloat = 0
    var currentColor: UIColor? // set at runtime
    var normalColor: UIColor?  // (white or black) set in factory
    
    
    var inRestrictedMode = false
    enum KeyStates {
        case Default, Disabled, PlayedInternally, Correct, Incorrect
    }
    
    
    var keyNumber: Int!
    var midiNoteNumber: UInt8!
    var isDisabled =  false
    weak var delegate: PianoKeyDelegate?
    
    func getPathAtMargin() -> UIBezierPath {
        let orig = self.bounds
        let marginRect = CGRect(x: margin, y: margin, width: orig.width - (margin * 2.0), height: orig.height - (margin * 2.0))
        let path = UIBezierPath(roundedRect: marginRect, cornerRadius: orig.width/5.0)
        path.lineWidth = 2.0
        return path
    }
    func pressed(sender: UIButton!) {
        print("pressed")
        delegate?.keyPushReceived(self)
   
    }
    
    override func drawRect(rect: CGRect) {
        currentColor = normalColor
        let path = getPathAtMargin()
        currentColor!.setFill()
        UIColor.blackColor().setStroke()
        path.fill()
        path.stroke()
    }
    
}


class PianoKeyFactory {
    enum PianoKeyType {
        case Black, White
    }
    class func createPianoKey(pianoKeyType: PianoKeyType, width: CGFloat, height: CGFloat) -> PianoKey {
        let key = PianoKey()

        switch (pianoKeyType) {
        case .Black:
            key.normalColor = UIColor.blackColor()
        case .White:
            key.normalColor = UIColor.whiteColor()
                  }
        return key
    }
}



protocol PianoKeyDelegate: class{
    func playNoteFromKeyboard(sender: PianoKey) -> Void
    func keyPushReceived(sender: PianoKey) -> Void
}






