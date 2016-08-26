//
//  ViewController.swift
//  KeyboardDemo
//
//  Created by Jeff Holtzkener on 8/23/16.
//  Copyright © 2016 Jeff Holtzkener. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, PianoDelegate {
    var sampler:AVAudioUnitSampler!
    var engine: AVAudioEngine!
    @IBOutlet weak var myKeyboard: Keyboard!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        myKeyboard.delegate = self
       

        engine = AVAudioEngine()
        sampler = AVAudioUnitSampler()
        engine.attachNode(sampler)
        engine.connect(sampler, to: engine.mainMixerNode, format: nil)
        let audioSession = AVAudioSession.sharedInstance()
        
        // start engine, set up audio session
        do {
            try engine.start()
            try audioSession.setCategory(AVAudioSessionCategoryPlayback, withOptions:
                AVAudioSessionCategoryOptions.MixWithOthers)
            try audioSession.setActive(true)
        } catch {
            print("set up failed")
            return
        }
        
        
    }
    
    
    
    func noteOn(note: UInt8) {
        sampler.startNote(note, withVelocity: 120, onChannel: 0)
    }
    
    func noteOff(note: UInt8) {
        sampler.stopNote(note, onChannel: 0)
    }
   

}

