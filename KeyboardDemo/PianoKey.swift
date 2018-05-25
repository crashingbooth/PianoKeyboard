//
//  PianoKey.swift
//  PianoKeyboard
//
//  Created by Jeff Holtzkener on 8/23/16.
//  Copyright © 2016 Jeff Holtzkener. All rights reserved.
//
import UIKit

class PianoKey: UIButton {
    enum KeyType {
        case whiteKey, blackKey
    }
    
    let margin: CGFloat = 0.0
    let normalColor: UIColor!
    let keyType: KeyType!
    let midiNoteNumber: UInt8!
    
    enum KeyStates {
        case notPressed, pressed
    }
    
    var keyState: KeyStates = .notPressed
    
    init(frame: CGRect, midiNoteNumber: UInt8, type: KeyType) {
        self.keyType = type
        self.normalColor = type == .whiteKey ? .white : .black
        self.midiNoteNumber = midiNoteNumber
        super.init(frame: frame)
        isUserInteractionEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        // will never call this
        self.normalColor = .black
        self.keyType = .whiteKey
        self.midiNoteNumber = 60
        super.init(coder: aDecoder)
    }
    
    func getPathAtMargin() -> UIBezierPath {
        // set margin property if wanted
        let cornerRadius =  CGSize(width: self.bounds.width / 5.0, height: self.bounds.width / 5.0)
        let marginRect = CGRect(x: margin,
                                y: margin,
                                width: self.bounds.width - (margin * 2.0),
                                height: self.bounds.height - (margin * 2.0))
        let path = UIBezierPath(roundedRect: marginRect,
                                byRoundingCorners: [.bottomLeft, .bottomRight],
                                cornerRadii: cornerRadius)
        path.lineWidth = 2.0
        
        return path
    }
    
    override func draw(_ rect: CGRect) {
        
        let path = getPathAtMargin()
        switch keyState {
        case .notPressed:
            normalColor.setFill()
        case .pressed:
            UIColor.lightGray.setFill()
        }
        UIColor.black.setStroke()
        path.fill()
        path.stroke()
        
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = path.cgPath
        self.layer.mask = maskLayer
    }
    
    // MARK: - Respond to key presses
    func pressed() -> Bool {
        if keyState != .pressed {
            keyState = .pressed
            DispatchQueue.main.async {
                self.setNeedsDisplay()
            }
            return true
        } else {
            return false
        }
    }
    
    func released() -> Bool {
        if keyState != .notPressed {
            keyState = .notPressed
            DispatchQueue.main.async {
                self.setNeedsDisplay()
            }
            return true
        } else {
            return false
        }
    }
}
