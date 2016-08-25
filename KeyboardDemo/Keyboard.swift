//
//  Keyboard.swift
//  KeyboardDemo
//
//  Created by Jeff Holtzkener on 8/23/16.
//  Copyright © 2016 Jeff Holtzkener. All rights reserved.
//

import UIKit

@IBDesignable class Keyboard: UIView, PianoKeyDelegate{
    let keyPattern:[PianoKey.KeyType] = [.White, .Black, .White, .Black, .White, .White, .Black, .White,.Black, .White, .Black, .White]
    let blackKeyOffset:[CGFloat] = [4.0, 5.5, 0.0, 4.0, 5.0, 6.0, 0.0] // measured from Roland A-500 keyboard
    let numWhiteKeys = 15
    let root:UInt8 = 48
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
    var pressedKeys = Set<UInt8>()

    override func drawRect(rect: CGRect) {
        addPianoKeysWithCurrentFrames()
    }

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
        createKeys()
        multipleTouchEnabled = true
        addPianoKeysWithCurrentFrames()
    }
    
    
    private func getKeyOfTouch(touch: UITouch) -> PianoKey? {
        let loc = touch.locationInView(self)
        var selection: PianoKey?
        var selectedKeys = [PianoKey]()
        for key in pianoKeys {
            if key.frame.contains(loc) {
                selectedKeys.append(key)
            }
        }
        
        // only one key must be white
        if selectedKeys.count == 1 {
            selection = selectedKeys[0]
        } else {
            // if multiple keys, only press black key
            for key in selectedKeys {
                if key.keyType == PianoKey.KeyType.Black && key.keyState != .Pressed {
                    selection = key
                    break
                }
            }
        }
        return selection

    }
    

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        print("touches began")
        for touch in touches {
             checkKeysForTouch(touch)
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        print("touches moved")
        for touch in touches {
            if !self.frame.contains(touch.locationInView(self)) {
                findOldKeyFromTouchAndRelease(touch, newKey: nil)
            } else {
                checkKeysForTouch(touch)
            }
        }
    }
    
    
    private func checkKeysForTouch(touch:UITouch) {
        let loc = touch.locationInView(self)
        var selectedKeys = [PianoKey]()
        for key in pianoKeys {
            if key.frame.contains(loc) {
                selectedKeys.append(key)
            }
        }
        
        // only one key must be white
        if selectedKeys.count == 1 {
            let newKey = selectedKeys[0]
            pressAdded(newKey)
            findOldKeyFromTouchAndRelease(touch, newKey: newKey)
        } else {
            // if multiple keys, only press black key
            for key in selectedKeys {
                if key.keyType == PianoKey.KeyType.Black && key.keyState != .Pressed {
                    pressAdded(key)
                    findOldKeyFromTouchAndRelease(touch, newKey: key)
                    break
                }
            }
        }
    }
    private func findOldKeyFromTouchAndRelease(touch: UITouch, newKey: PianoKey? = nil) {
        let oldLoc = touch.previousLocationInView(self)
        for key in pianoKeys {
            if key.frame.contains(oldLoc) && key != newKey {
                pressRemoved(key)
            }
        }
        
    }
    
        
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        print("ended")
        for touch in touches {
            let formerLoc = touch.previousLocationInView(self)
            for key in pianoKeys {
                if key.frame.contains(formerLoc) {
                   pressRemoved(key)
                }
            }
        }
        if let allTouches = event?.allTouches() {
            verifyTouches(allTouches)
        }
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        print("cancel")
       
        
    }
    
    private func pressAdded(key: PianoKey) {
        
        key.pressed()
        pressedKeys.insert(key.midiNoteNumber)
        print("added \(key.midiNoteNumber), \(pressedKeys)")
    }
    
    private func pressRemoved(key: PianoKey) {
        key.released()
        pressedKeys.remove(key.midiNoteNumber)
        print("released!!! \(key.midiNoteNumber), \(pressedKeys)")
    }
    
    private func debugVerifySet() {
        var actuallyPressed = Set<UInt8>()
        for key in pianoKeys {
            if key.keyState == .Pressed {
                actuallyPressed.insert(key.midiNoteNumber)
            }
        }
        if actuallyPressed == pressedKeys {
            print("all good")
        } else {
            
            print("extra")
            print(pressedKeys)
            print(actuallyPressed)
        }
    }
    
    private func verifyTouches(touches: Set<UITouch>) {
        var touchedKeys = Set<UInt8>()
        for touch in touches {
            if let key = getKeyOfTouch(touch) {
            touchedKeys.insert(key.midiNoteNumber)
            }
        }
        let disjunct = pressedKeys.subtract(touchedKeys)
        if !disjunct.isEmpty {
            print("stuck notes: \(disjunct)")
            // change later to removes keys by index
            for key in pianoKeys {
                if disjunct.contains(key.midiNoteNumber) {
                    pressRemoved(key)
                }
            }
    
        }
    }
    
   
    
    private func createKeys() {
        var whiteKeyNum = 0
        var absoluteNum = 0
        var currentType: PianoKey.KeyType!
        while whiteKeyNum <= numWhiteKeys {
            currentType = keyPattern[absoluteNum % 12]
            if currentType == PianoKey.KeyType.White {
                 whiteKeyNum += 1
            }
            if whiteKeyNum == numWhiteKeys && currentType == .Black { break }
            let key = PianoKey(frame: CGRect.zero, midiNoteNumber: root + UInt8(absoluteNum), type: currentType)

            
            pianoKeys.append(key)
            absoluteNum += 1
        }
    }
    
    private func addPianoKeysWithCurrentFrames() {
        for key in pianoKeys {
            key.removeFromSuperview()
        }
        
        var whiteKeyNum = 0
        for key in pianoKeys {
            let keyFrame: CGRect!
            if key.keyType == PianoKey.KeyType.White {
                keyFrame = CGRect(x: CGFloat(whiteKeyNum) * whiteKeyWidth, y: 0, width: whiteKeyWidth, height: whiteKeyHeight)
                whiteKeyNum += 1
            } else {
                let offset = blackKeyOffset[(whiteKeyNum - 1) % 7]
                keyFrame = CGRect(x: CGFloat(whiteKeyNum - 1) * whiteKeyWidth + whiteKeyWidth * (offset/7.0), y: 0, width: blackKeyWidth, height: blackKeyHeight)
            }
            key.frame = keyFrame
            addSubview(key)
        }
        
        // put black keys on top
        for key in pianoKeys {
            if key.keyType == PianoKey.KeyType.Black {
                bringSubviewToFront(key)
            }
        }
    }
    
    
    func playNoteFromKeyboard(sender: PianoKey) -> Void {
        
    }
    func keyPushReceived(sender: PianoKey) -> Void {
        
    }

    
    
    
    
}
