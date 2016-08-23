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
    
    var disabledImage : UIImageView!
    var disabledImageAlpha: CGFloat!
    
    var inRestrictedMode = false
    enum KeyStates {
        case Default, Disabled, PlayedInternally, Correct, Incorrect
    }
    var keyState: KeyStates = .Default {
        didSet {
            switch (keyState) {
            case .Disabled:
                addSubview(disabledImage)
            default:
                disabledImage.removeFromSuperview()
            }
            self.setNeedsDisplay()
        }
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
        switch (keyState) {
        case .Disabled:
            fadeInDisabledSymbol()
            
        default:
            delegate?.keyPushReceived(self)
            
        }
        self.setNeedsDisplay()
    }
    
    override func drawRect(rect: CGRect) {
        switch (keyState) {
        case .Default:
            currentColor = normalColor
        case .Disabled:
            currentColor = normalColor
        case .PlayedInternally:
            currentColor = ColorScheme.sharedInstance.internalGuidedColor
        case .Correct:
            currentColor = ColorScheme.sharedInstance.correctColor
        case .Incorrect:
            currentColor = ColorScheme.sharedInstance.incorrectColor        }
        let path = getPathAtMargin()
        currentColor!.setFill()
        
        
        UIColor.blackColor().setStroke()
        path.fill()
        path.stroke()
    }
    
    
    //MARK: - key animations
    
    func flipKey(newState: PianoKey.KeyStates){
        UIView.transitionWithView(self,
                                  duration: 0.2,
                                  options: UIViewAnimationOptions
                                    .TransitionFlipFromLeft,
                                  animations: {self.keyState =  newState},
                                  completion: nil
        )
    }
    
    func animateDefaultEnabledNotes() {
        UIView.transitionWithView(self,
                                  duration: 0.2,
                                  options: UIViewAnimationOptions.TransitionCrossDissolve,
                                  animations: { self.keyState = .Default  },
                                  completion: nil
        )
    }
    
    func animateHighlighting() {
        UIView.transitionWithView(self,
                                  duration: 0.1,
                                  options: UIViewAnimationOptions.TransitionCrossDissolve,
                                  animations: { self.keyState = .PlayedInternally  },
                                  completion: nil
        )
        
    }
    
    func fadeInDisabledSymbol() {
        UIView.animateWithDuration(0.2,
                                   animations: { self.disabledImage.alpha = 1.0 },
                                   completion: ({ _ in self.fadeOutDisabledSymbol() })
        )
        
    }
    
    func fadeOutDisabledSymbol() {
        UIView.animateWithDuration(0.2,
                                   animations: { self.disabledImage.alpha = self.disabledImageAlpha },
                                   completion: nil
        )
    }
}


class PianoKeyFactory {
    enum PianoKeyType {
        case Black, White
    }
    class func createPianoKey(pianoKeyType: PianoKeyType, width: CGFloat, height: CGFloat) -> PianoKey {
        let key = PianoKey()
        let disabledImageFile = UIImage(named: "gray_x.png")
        key.disabledImage = UIImageView(image: disabledImageFile!)
        
        switch (pianoKeyType) {
        case .Black:
            key.normalColor = UIColor.blackColor()
            var imageWidth = width / 4 * (7 / 5 )
            imageWidth = width * 0.8
            key.disabledImageAlpha = 0.4
            key.disabledImage.alpha = key.disabledImageAlpha
            key.disabledImage.frame = CGRect(x: (width / 2) - (imageWidth / 2), y: height - imageWidth - 5, width: imageWidth, height: imageWidth)
            
            
        case .White:
            key.normalColor = UIColor.whiteColor()
            var imageWidth = width  / 4
            
            imageWidth = width * (5 / 7 ) * 0.8
            key.disabledImageAlpha = 0.1
            key.disabledImage.alpha = key.disabledImageAlpha
            key.disabledImage.frame = CGRect(x: (width / 2) - (imageWidth / 2), y: height - imageWidth - 5, width: imageWidth, height: imageWidth)
            
        }
        return key
    }
}



protocol PianoKeyDelegate: class{
    func playNoteFromKeyboard(sender: PianoKey) -> Void
    func keyPushReceived(sender: PianoKey) -> Void
}






