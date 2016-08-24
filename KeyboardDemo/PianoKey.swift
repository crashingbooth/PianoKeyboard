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
    
    
    var keyNumber: Int!
    var midiNoteNumber: UInt8!
    var isDisabled =  false
    weak var delegate: PianoKeyDelegate?
    
    init(frame: CGRect, midiNoteNumber: UInt8, type: KeyType) {
        self.keyType = type
        self.normalColor = type == .White ? UIColor.whiteColor() : UIColor.blackColor()
        self.midiNoteNumber = midiNoteNumber
        super.init(frame: frame)
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
    func pressed(sender: UIButton!) {
        print("pressed: \(midiNoteNumber)")
        delegate?.keyPushReceived(self)
   
    }
    
    override func drawRect(rect: CGRect) {
      
        let path = getPathAtMargin()
        normalColor.setFill()
        UIColor.blackColor().setStroke()
        path.fill()
        path.stroke()
    }
    
}

//
//class PianoKeyFactory {
//    enum PianoKeyType {
//        case Black, White
//    }
//    class func createPianoKey(pianoKeyType: PianoKeyType, width: CGFloat, height: CGFloat) -> PianoKey {
//        let key = PianoKey()
//
//        switch (pianoKeyType) {
//        case .Black:
//            key.normalColor = UIColor.blackColor()
//        case .White:
//            key.normalColor = UIColor.whiteColor()
//                  }
//        return key
//    }
//}



protocol PianoKeyDelegate: class{
    func playNoteFromKeyboard(sender: PianoKey) -> Void
    func keyPushReceived(sender: PianoKey) -> Void
}






