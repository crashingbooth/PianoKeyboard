//
//  Keyboard.swift
//  KeyboardDemo
//
//  Created by Jeff Holtzkener on 8/23/16.
//  Copyright © 2016 Jeff Holtzkener. All rights reserved.
//

import UIKit

@IBDesignable class Keyboard: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    // Our custom view from the XIB file
    var view: UIView!
    override init(frame: CGRect) {
        // 1. setup any properties here
        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        // 1. setup any properties here
        super.init(coder: aDecoder)
        xibSetup()
    }
    func xibSetup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "Keyboard", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        
        return view
    }
    
    
}
