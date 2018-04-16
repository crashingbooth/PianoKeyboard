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
        // assign delegate
        myKeyboard.delegate = self
       
        // create engine, sampler and session
        engine = AVAudioEngine()
        sampler = AVAudioUnitSampler()
        engine.attach(sampler)
        engine.connect(sampler, to: engine.mainMixerNode, format: nil)
        let audioSession = AVAudioSession.sharedInstance()
        
        // start engine, set up audio session
        do {
            try engine.start()
            try audioSession.setCategory(AVAudioSessionCategoryPlayback, with:
                AVAudioSessionCategoryOptions.mixWithOthers)
            try audioSession.setActive(true)
        } catch {
            print("set up failed")
            return
        }
    }
    
    // MARK: - Keyboard Delegate Methods
    func noteOn(note: UInt8) {
        sampler.startNote(note, withVelocity: 120, onChannel: 0)
    }
    
    func noteOff(note: UInt8) {
        sampler.stopNote(note, onChannel: 0)
    }
   

}

