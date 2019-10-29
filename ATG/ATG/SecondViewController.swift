//
//  SecondViewController.swift
//  ATG-Trial#1
//
//  Created by epics on 11/5/18.
//  Copyright © 2018 epics. All rights reserved.
//

import UIKit
import AVFoundation
import Foundation
import MobileCoreServices
import Zip

class SecondViewController: UIViewController, UIDocumentPickerDelegate {
    let manager = FileManager() //Used to work within the local filesystem
    let synth = AVSpeechSynthesizer() //This is used for text to speech
    let rate = UserDefaults.standard.double(forKey: "SpeechRate") //How fast text to speech speaks
    var UnZippedRouteFolder: URL!
    var Routes: [URL]!
    var RouteName = 0
    var SlctedRouteURL: URL?
    var DidTryToRemove = false
    var ConfirmRemove = false
    
    @IBOutlet weak var Label: UILabel!
    @IBOutlet weak var SelectLbl: UILabel!
    @IBOutlet weak var PressLbl: UILabel!
    @IBOutlet weak var RoutesLoadingLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let docDirectory = manager.urls(for: .documentDirectory, in: .userDomainMask)[0] //Gets the documents directory of the app's sandbox
        UnZippedRouteFolder = docDirectory.appendingPathComponent("UnZippedRoutes")
        if !manager.fileExists(atPath: UnZippedRouteFolder.path){
            try? manager.createDirectory(at: UnZippedRouteFolder, withIntermediateDirectories: false, attributes: nil)
        }
        
        do{
            Routes = try manager.contentsOfDirectory(at: UnZippedRouteFolder, includingPropertiesForKeys: nil, options: []) //Collects the existing routes and puts them into an array called "Routes"
        }catch{
            print("Could not receive contents of UnZipped folder")
        }
        
        let utter = AVSpeechUtterance()
        utter.voice = AVSpeechSynthesisVoice(language: "en-US")
        
        let speech = AVSpeechUtterance(string: "You are now at the route selection screen. Swipe from right to left to toggle through the available routes. Long press to select your route.")
        speech.voice = AVSpeechSynthesisVoice(language: "en-US")
        speech.rate = Float(rate)
        synth.speak(speech)
        
        if FileManager.default.ubiquityIdentityToken != nil {
            print("iCloud Available")
        }else {
            print("iCloud Unavailable")
        }
        
    }
    
    @IBAction func LongPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .ended {
            
            let manager = FileManager()
            
            if DidTryToRemove && !ConfirmRemove{
                let utter = AVSpeechUtterance(string: "Are you sure that you want to remove the route? Long press to confirm. Single tap to cancel.")
                utter.rate = Float(rate)
                synth.speak(utter)
                
                ConfirmRemove = true
            }
            else if DidTryToRemove && ConfirmRemove{
                do{
                    try manager.removeItem(at: SlctedRouteURL!)
                    
                    let utter = AVSpeechUtterance(string: "Route Removed")
                    utter.rate = Float(rate)
                    synth.speak(utter)
                    
                    Routes = try manager.contentsOfDirectory(at: UnZippedRouteFolder, includingPropertiesForKeys: nil, options: []) //Collects the existing routes and puts them into an array called "Routes"
                    
                }catch{
                    print("Route could not be removed")
                }
            }
            else if Label.text == "Swipe Left" {
                let utter = AVSpeechUtterance(string: "Please select a route.")
                utter.rate = Float(rate)
                synth.speak(utter)
            }
            
            else {
                performSegue(withIdentifier:"SecondSegue", sender: self)
            }
        }
    }
    
    @IBAction func SwipeRight(_ sender: UISwipeGestureRecognizer) {
        if sender.state == .ended {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func DoubleTap(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            
            if (Routes.count == 0) || (Routes == nil) || (RouteName == 0){
                
                let utter = AVSpeechUtterance(string: "You do not have any routes selected. Please select a route to delete.")
                
                utter.rate = Float(rate)
                synth.speak(utter)
            }
            
            else if !DidTryToRemove {
               
                let utter = AVSpeechUtterance(string: "You are about to remove a route. Long press to continue. Single tap to cancel.")

                utter.rate = Float(rate)
                synth.speak(utter)
                
                DidTryToRemove = true
            }
        }
    }
    
    
    @IBAction func SingleTap(_ sender: UITapGestureRecognizer) {
        
        if sender.state == .ended{
            if DidTryToRemove{
                DidTryToRemove = false
                ConfirmRemove = false
                
                let utter = AVSpeechUtterance(string: "Route removal canceled.")
                utter.rate = Float(rate)
                synth.speak(utter)
            }
        }
    }
    
    @IBAction func SwipeDown(_ sender: UISwipeGestureRecognizer) {
        if sender.state == .ended {
            
            //Opens the document picker and searches only for .zip files. The "com.pkware.zip-archive" is the UTI for .zip files.
            let types: [String] = ["com.pkware.zip-archive"]
            let documentPicker = UIDocumentPickerViewController(documentTypes: types, in: .import)
            documentPicker.delegate = self
            documentPicker.allowsMultipleSelection = true
            documentPicker.modalPresentationStyle = .formSheet
            self.present(documentPicker, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func SwipeLeft(_ sender: UISwipeGestureRecognizer) {
        if sender.state == .ended {
        
            //Toggles through the routes in the UnZippedRouteFolder. It displays the name and saves the URL to pass it to the next view should it be selected.
            if (Routes.count == 0) || (Routes == nil){
                let utter = AVSpeechUtterance(string: "There are currently no routes downloaded")
                utter.rate = Float(rate)
                synth.speak(utter)
                
                Label.text = "No routes downloaded"
            }
            else if RouteName < Routes.count - 1 {
                Label.text = Routes[RouteName].lastPathComponent
                
                let utter = AVSpeechUtterance(string: Routes[RouteName].lastPathComponent)
                utter.rate = Float(rate)
                synth.speak(utter)
                
                SlctedRouteURL = Routes[RouteName]
                
                RouteName += 1
            }
            else{
                
                Label.text = Routes[RouteName].lastPathComponent
                
                let utter = AVSpeechUtterance(string: Routes[RouteName].lastPathComponent)
                utter.rate = Float(rate)
                synth.speak(utter)
                
                SlctedRouteURL = Routes[RouteName]
                
                RouteName = 0
            }
            
        }
    }
    
    //This function sends info to the next view when the segway happens.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is ThirdViewController {
            let vc = segue.destination as? ThirdViewController
            vc?.route = Label.text! //Route name
            vc?.routeURL = SlctedRouteURL //The URL of the Route
        }
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt RouteFolderUrl: [URL]) {
        //The "RouteFolderURL" array contains the URLs chosen by the user, which will be only one
        let RouteName = RouteFolderUrl[0].lastPathComponent.split(separator: ".")[0]

        do{
            //Creates a folder in the the UnZippedRouteFolder and unzips the contents of the chosen route into that new folder:
            let NewRouteURL = UnZippedRouteFolder.appendingPathComponent(String(RouteName))
            try manager.createDirectory(at: NewRouteURL, withIntermediateDirectories: true, attributes: nil)
            try Zip.unzipFile(RouteFolderUrl[0], destination: NewRouteURL, overwrite: true, password: nil)
            
        }catch{
            print("File could not be unzipped.")
        }
        
        do{
            Routes = try manager.contentsOfDirectory(at: UnZippedRouteFolder, includingPropertiesForKeys: nil, options: []) //Collects the existing routes and puts them into an array called "Routes"
        }catch{
            print("Could not receive contents of UnZipped folder")
        }
    }
}

