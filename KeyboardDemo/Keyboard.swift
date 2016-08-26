//
//  Keyboard.swift
//  KeyboardDemo
//
//  Created by Jeff Holtzkener on 8/23/16.
//  Copyright © 2016 Jeff Holtzkener. All rights reserved.
//

import UIKit

@IBDesignable class Keyboard: UIView {
    // set this value for size of keyboard (7 = 1 octave):
    let numWhiteKeys = 8
    let root:UInt8 = 48 // pitch of lowest note
    enum VoiceType {
        case Mono, Poly
    }
    let voiceType: VoiceType = .Mono
    
    var pianoKeys = [PianoKey]()
    var pressedKeys = Set<UInt8>()
    weak var delegate: PianoDelegate?
    
    // MARK: - Geometry
    let keyPattern:[PianoKey.KeyType] = [.White, .Black, .White, .Black, .White, .White, .Black, .White,.Black, .White, .Black, .White]
    let blackKeyOffset:[CGFloat] = [4.0, 5.5, 0.0, 4.0, 5.0, 6.0, 0.0] // measured from Roland A-500 keyboard
    
    var whiteKeyWidth: CGFloat {
        get { return self.bounds.width / CGFloat(numWhiteKeys)}
    }
    var whiteKeyHeight: CGFloat {
        get { return self.bounds.height }
    }
    var blackKeyWidth: CGFloat {
        get { return whiteKeyWidth * (5.0/7.0)} // measured from Roland A-500 keyboard
    }
    var blackKeyHeight: CGFloat {
        get { return whiteKeyHeight * 0.65}
    }
   
    
    
    // MARK: - Init and SetUp
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    func setUp() {
        createKeys()
        multipleTouchEnabled = true
        addPianoKeysWithCurrentFrames()
    }
    
    override func layoutSubviews() {
        addPianoKeysWithCurrentFrames()
    }
    
    override func drawRect(rect: CGRect) {
        addPianoKeysWithCurrentFrames()
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
    
    
    // MARK: - Override Touch Methods
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            if let key = getKeyFromLocation(touch.locationInView(self)) {
                pressAdded(key)
                verifyTouches(event?.allTouches() ?? Set<UITouch>())
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            if !self.frame.contains(touch.locationInView(self)) {
                verifyTouches(event?.allTouches() ?? Set<UITouch>())
            } else {
                if let key = getKeyFromLocation(touch.locationInView(self)) where key != getKeyFromLocation(touch.previousLocationInView(self)) {
                    pressAdded(key)
                    verifyTouches(event?.allTouches() ?? Set<UITouch>())
                }            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            if let key = getKeyFromLocation(touch.locationInView(self)) {
                
                // verify that there isn't another finger pressed to same key
                if var allTouches = event?.allTouches() {
                    allTouches.remove(touch)
                    let noteSet = getNoteSetFromTouches(allTouches)
                    if !noteSet.contains(key.midiNoteNumber) {
                        if voiceType == .Mono {
                            pressRemovedAndPossiblyReplaced(key, allTouches: allTouches)
                        } else {
                            pressRemoved(key)
                        }
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
    
    // MARK: - Identify Keys
    private func getKeyFromLocation(loc: CGPoint) -> PianoKey? {
        var selection: PianoKey?
        var selectedKeys = [PianoKey]()
        for key in pianoKeys {
            if key.frame.contains(loc) {
                selectedKeys.append(key)
            }
        }
        
        // if only one key, must be white
        if selectedKeys.count == 1 {
            selection = selectedKeys[0]
        } else {
            // if multiple keys (b/c keys overlap white), only select black key
            for key in selectedKeys {
                if key.keyType == PianoKey.KeyType.Black {
                    selection = key
                    break
                }
            }
        }
        return selection
    }
    
    private func getKeyFromMidiNote(midiNoteNumber: UInt8) -> PianoKey {
        let index = Int(midiNoteNumber - root)
        return pianoKeys[index]
    }

    // MARK: - Handling Keys
    private func pressAdded(newKey: PianoKey) {
        if voiceType == .Mono {
            for key in pianoKeys where key != newKey {
                pressRemoved(key)
            }
        }
        
        if newKey.pressed() {
            delegate?.noteOn(newKey.midiNoteNumber)
            pressedKeys.insert(newKey.midiNoteNumber)
            print("added \(newKey.midiNoteNumber), \(pressedKeys)")
        }
    }
    
    private func pressRemoved(key: PianoKey) {
        if key.released() {
            delegate?.noteOff(key.midiNoteNumber)
            pressedKeys.remove(key.midiNoteNumber)
            print("released \(key.midiNoteNumber), \(pressedKeys)")
        }
    }
    
    // MONO ONLY
    private func pressRemovedAndPossiblyReplaced(key: PianoKey, allTouches: Set<UITouch>){
        if key.released() {
            delegate?.noteOff(key.midiNoteNumber)
            pressedKeys.remove(key.midiNoteNumber)
            print("released \(key.midiNoteNumber), \(pressedKeys)")
            var remainingNotes = getNoteSetFromTouches(allTouches)
            remainingNotes.remove(key.midiNoteNumber)
            if let highest = remainingNotes.maxElement() {
                pressAdded(getKeyFromMidiNote(highest))
            }
            
        }
    }
    
    // MARK: - Verify Keys
    private func getNoteSetFromTouches(touches: Set<UITouch>) -> Set<UInt8> {
        var touchedKeys = Set<UInt8>()
        for touch in touches {
            if let key = getKeyFromLocation(touch.locationInView(self)) {
                touchedKeys.insert(key.midiNoteNumber)
            }
        }
        return touchedKeys
    }
    
    
    private func verifyTouches(touches: Set<UITouch>) {
        // clean up any stuck notes
        let notesFromTouches = getNoteSetFromTouches(touches)
        let disjunct = pressedKeys.subtract(notesFromTouches)
        if !disjunct.isEmpty {
            print("stuck notes: \(disjunct) touches at\(notesFromTouches)")
            for note in disjunct {
                pressRemoved(getKeyFromMidiNote(note))
            }
        }
    }
    
}

protocol PianoDelegate:class {
    func noteOn(note: UInt8) -> Void
    func noteOff(note: UInt8) -> Void
}
