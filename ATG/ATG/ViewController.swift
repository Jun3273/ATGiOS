//
//  ViewController.swift
//  ATG-Trial#1
//
//  Created by epics on 11/5/18.
//  Copyright © 2018 epics. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    let defaults = UserDefaults.standard
    let synth = AVSpeechSynthesizer()
    var rate = 0.5
    var metadataQuery: NSMetadataQuery!
    //var file: NSMetadataItem
    //var FileName: String
    
    
    @IBAction func LongPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .ended {
            
            performSegue(withIdentifier:"Segue1", sender: self)
        }
    }
    
    
    
    
    @IBAction func SwipeRight(_ sender: UISwipeGestureRecognizer) {
        if sender.state == .ended {
            
            performSegue(withIdentifier:"OptionsSegue", sender: self)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if defaults.bool(forKey: "launchedBefore") {
            rate = defaults.double(forKey: "SpeechRate")
        }
        else{
            defaults.set(0.5, forKey: "SpeechRate")
        }
        
        let utter = AVSpeechUtterance(string: "Welcome to the ATG. Press and hold your finger on the screen to proceed to route selection; or swipe from left to right to change speed of audio.")
        utter.voice = AVSpeechSynthesisVoice(language: "en-US")
        utter.rate = Float(rate)
        synth.speak(utter)
        
        
        // Do any additional setup after loading the view, typically from a nib.
        
    }
}

