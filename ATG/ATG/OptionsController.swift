//
//  OptionsController.swift
//  ATG-Trial#1
//
//  Created by epics on 1/14/19.
//  Copyright © 2019 epics. All rights reserved.
//

import UIKit
import AVFoundation

class OptionsController: UIViewController {

    let synth = AVSpeechSynthesizer()
    var phrase = AVSpeechUtterance()
    var rate = 0.5
    var speed = 3
    let defaults = UserDefaults.standard
    let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
    
    
    @IBOutlet weak var SpeedLbl: UILabel!
    
    @IBAction func SwipeLeft(_ sender: UISwipeGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
    

    
    @IBAction func SwipeUp(_ sender: UISwipeGestureRecognizer) {
    if sender.state == .ended {
            
            if SpeedLbl.text == "5" {
                
                speed = 1
                SpeedLbl.text = "1"
                rate = 0.3
                phrase = AVSpeechUtterance(string: "Speed number one. This is what it sounds like.")
                
                phrase.rate = 0.3
                synth.speak(phrase)
            }
            else {
                
                speed = speed + 1
                rate = rate + 0.1
                SpeedLbl.text = String(speed)
                phrase = AVSpeechUtterance(string: "Speed number" + String(speed) + "This is what it sounds like.")
                
                phrase.rate = Float(rate)
                synth.speak(phrase)
        
            }
            print(rate)
            defaults.set(rate, forKey: "SpeechRate")
            defaults.set(speed, forKey: "TalkSpeed")
            if !launchedBefore  {
                print("First time changing speed")
                UserDefaults.standard.set(true, forKey: "launchedBefore")
            }
        }
    }
    
    @IBAction func SwipeDown(_ sender: UISwipeGestureRecognizer) {
        if sender.state == .ended {
            if SpeedLbl.text == "1" {
                
                speed = 5
                SpeedLbl.text = "5"
                rate = 0.7
                phrase = AVSpeechUtterance(string: "Speed number five. This is what it sounds like.")
                
                phrase.rate = 0.7
                synth.speak(phrase)
            }
            else {
                
                speed = speed - 1
                rate = rate - 0.1
                SpeedLbl.text = String(speed)
                phrase = AVSpeechUtterance(string: "Speed number" + String(speed) + "This is what it sounds like.")
                
                phrase.rate = Float(rate)
                synth.speak(phrase)
                
            }
            print(rate)
            defaults.set(rate, forKey: "SpeechRate")
            defaults.set(speed, forKey: "TalkSpeed")
            
            if !launchedBefore  {
                print("First time changing speed")
                UserDefaults.standard.set(true, forKey: "launchedBefore")
            }
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if launchedBefore {
            rate = defaults.double(forKey: "SpeechRate")
            speed = defaults.integer(forKey: "TalkSpeed")
            
            print("Speed has been changed before")
        }
        print(rate)
        
        SpeedLbl.text = "\(speed)"
        let utter = AVSpeechUtterance(string: "This is the options screen. Here you can change the speed of text to speech. Swipe up to increase the speed. Swipe down to decrease the speed.")
        utter.voice = AVSpeechSynthesisVoice(language: "en-US")
        utter.rate = Float(rate)
        synth.speak(utter)
        
        phrase.voice = AVSpeechSynthesisVoice(language: "en-US")
        // Do any additional setup after loading the view.
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
