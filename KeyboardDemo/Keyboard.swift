//
//  Keyboard.swift
//  KeyboardDemo
//
//  Created by Jeff Holtzkener on 8/23/16.
//  Copyright © 2016 Jeff Holtzkener. All rights reserved.
//

import UIKit

@IBDesignable class Keyboard: UIView, PianoKeyDelegate{
    let numWhiteKeys = 15
    var whiteKeyWidth: CGFloat {
        get { return self.bounds.width / CGFloat(numWhiteKeys)}
    }
    var whiteKeyHeight: CGFloat {
        get { return self.bounds.height }
    }
    var blackKeyWidth: CGFloat {
        get { return whiteKeyWidth * (5.0/7.0)}
    }
    var blackKeyHeight: CGFloat {
        get { return whiteKeyHeight * 0.65}
    }
    var pianoKeys = [PianoKey]()
    
//    // Only override drawRect: if you perform custom drawing.
//    // An empty implementation adversely affects performance during animation.
//    override func drawRect(rect: CGRect) {
//        // Drawing code
//    }

    var view: UIView!
    override init(frame: CGRect) {
        // 1. setup any properties here
        super.init(frame: frame)
        setUp()

    }
    
    required init?(coder aDecoder: NSCoder) {
        // 1. setup any properties here
        super.init(coder: aDecoder)
        setUp()

    }
    
    func setUp() {
        addWhiteKeys()
        addBlackKeys()
        setKeyIndices()
    }
    
    func drawKeys() {
        // removeKeys if present
        for key in pianoKeys {
            key.removeFromSuperview()
        }
        
        for key in pianoKeys {
            addSubview(key)
        }
    }
    
    private func addWhiteKeys() {
        for key in 0..<numWhiteKeys {
            let wk = PianoKeyFactory.createPianoKey(PianoKeyFactory.PianoKeyType.White, width: whiteKeyWidth, height: whiteKeyHeight)
            wk.frame = CGRect(x: CGFloat(key) * whiteKeyWidth, y: 0, width: whiteKeyWidth, height: whiteKeyHeight)
            wk.addTarget(wk, action: Selector("pressed:"), forControlEvents: UIControlEvents.TouchDown)
            addSubview(wk)
            pianoKeys.append(wk)
        }
        
    }
    private func addBlackKeys() {
        var offset:[Int:CGFloat] = [0: 4.0, 1: 5.5, 3: 4.0,4:5.0,5:6.0] //from Roland A-500 keyboard
        var pos = 0 // index to insert black key
        for key in 0..<numWhiteKeys  {
            pos += 1  // count 1 white key
            // add black key except at 2 (between E and F) and 6 (bt'n B and C)
            let pitchClass = key % 7
            if pitchClass != 2 && pitchClass % 7 != 6 {
                let bk = PianoKeyFactory.createPianoKey(PianoKeyFactory.PianoKeyType.Black, width: blackKeyWidth, height: blackKeyHeight)
                bk.frame = CGRect(x: CGFloat(key) * whiteKeyWidth + whiteKeyWidth * (offset[pitchClass]!/7.0), y: 0, width: blackKeyWidth, height: blackKeyHeight)
         
                bk.addTarget(bk, action: Selector("pressed:"), forControlEvents: UIControlEvents.TouchDown)
                addSubview(bk)
                pianoKeys.insert(bk, atIndex: pos)
                pos += 1 // count 1 black key
            }
            
        }
    }
    
    private func setKeyIndices() {
        for (i,key) in pianoKeys.enumerate() {
            key.delegate = self
            key.keyNumber = i
            let C4 = 48 // it's midinote number
            key.midiNoteNumber = UInt8(i + C4)
        }
    }
    
    func playNoteFromKeyboard(sender: PianoKey) -> Void {
        
    }
    func keyPushReceived(sender: PianoKey) -> Void {
        
    }

    
    
    
    
}
