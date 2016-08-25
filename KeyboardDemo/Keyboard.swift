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
        for touch in touches {
             checkKeysForTouch(touch)
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            if !self.frame.contains(touch.locationInView(self)) {
                findOldKeyFromTouchAndRelease(touch, newKey: nil)
            } else {
                checkKeysForTouch(touch)
            }
        }
    }
    
    
    private func checkKeysForTouch(touch:UITouch) {
        if let key = getKeyOfTouch(touch) {
            pressAdded(key)
            findOldKeyFromTouchAndRelease(touch, newKey: key)
        }
    }
    
    // maybe don't care about newkey, b/c checking alltouches
    private func findOldKeyFromTouchAndRelease(touch: UITouch, newKey: PianoKey? = nil) {
        let oldLoc = touch.previousLocationInView(self)
        for key in pianoKeys {
            if key.frame.contains(oldLoc) && key != newKey {
                pressRemoved(key)
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch in touches {
            if let key = getKeyOfTouch(touch) {
                
                // verify that there isn't another finger pressed to same key
                if var allTouches = event?.allTouches() {
                    allTouches.remove(touch)
                    let noteSet = getNoteSetFromTouches(allTouches)
                    if !noteSet.contains(key.midiNoteNumber) {
                        pressRemoved(key)
                    }
                }
            }
        }
        
        let allTouches = event?.allTouches() ?? Set<UITouch>()
        verifyTouches(allTouches)
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        let allTouches = event?.allTouches() ?? Set<UITouch>()
        verifyTouches(allTouches)
        
    }
    
    private func pressAdded(key: PianoKey) {
        if key.pressed() {
            pressedKeys.insert(key.midiNoteNumber)
            print("added \(key.midiNoteNumber), \(pressedKeys)")
        }
    }
    
    private func pressRemoved(key: PianoKey) {
        key.released()
        pressedKeys.remove(key.midiNoteNumber)
        print("released!!! \(key.midiNoteNumber), \(pressedKeys)")
    }
    
    
    private func getNoteSetFromTouches(touches: Set<UITouch>) -> Set<UInt8> {
        var touchedKeys = Set<UInt8>()
        for touch in touches {
            if let key = getKeyOfTouch(touch) {
                touchedKeys.insert(key.midiNoteNumber)
            }
        }
        return touchedKeys
    }
    
    
    private func verifyTouches(touches: Set<UITouch>) {
        // clean up any stuck notes
        let disjunct = pressedKeys.subtract(getNoteSetFromTouches(touches))
        if !disjunct.isEmpty {
            print("stuck notes: \(disjunct)")
            for note in disjunct {
                pressRemoved(getKeyFromMidiNote(note))
            }
        }
    }
    
    private func getKeyFromMidiNote(midiNoteNumber: UInt8) -> PianoKey {
        let index = Int(midiNoteNumber - root)
        return pianoKeys[index]
    }
    
   
    // MARK: - SetUp and Geometry
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
