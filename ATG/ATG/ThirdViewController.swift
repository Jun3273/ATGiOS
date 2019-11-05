//
//  ThirdViewController.swift
//  ATG-Trial#1
//
//  Created by epics on 11/14/18.
//  Copyright © 2018 epics. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation

class ThirdViewController: UIViewController, CLLocationManagerDelegate {
    
    var route: String = ""
    var routeURL = URL(string: "placeholder")
    let rate = UserDefaults.standard.double(forKey: "SpeechRate")
    var waypointNum = 1
    let defaults = UserDefaults.standard
    var TargetWaypoint = waypoint()
    var Waypoints: [URL]?
    var LastDescription: String?
    var LastWaypoint = false    // sets the last waypoint variable to false
    
    struct waypoint {
        //This struct is used to easily store info for a waypoint
        var latitude: Double = 0 //latitude of the waypoint
        var longitude: Double = 0 //longitude of the waypoint
        var radius: Double = 0 //radius of the waypoint
        var name: String = "" //Name of the waypoint
        var description: String = "" //The description that is read to the user
    }
    
    @IBOutlet weak var NodeLbl: UILabel!
    @IBOutlet weak var CrntRouteLbl: UILabel!
    @IBOutlet weak var LatLbl: UILabel!
    @IBOutlet weak var LongLbl: UILabel!
    
    @IBAction func SwipeRight(_ sender: UISwipeGestureRecognizer) {
    
        if sender.state == .ended {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func DoubleTap(_ sender: UITapGestureRecognizer) {
        if LastDescription != nil {
            let utter = AVSpeechUtterance(string: LastDescription!)
            utter.rate = Float(rate)
            synth.speak(utter)
            //print(waypointNum)
            //print(LastWaypoint) //for the last waypoint if it is a global variable.
        }
    }
    func getNextNode(NextWaypointNum: Int) -> waypoint {
        
        var NextWaypoint = waypoint()
        let DescriptionURL: URL = Waypoints![NextWaypointNum].appendingPathComponent("speech.txt")
        let NextWaypointURL: URL = Waypoints![NextWaypointNum].appendingPathComponent("node.txt")
        print(NextWaypointURL.path)
        let WaypointInfo = try! String(contentsOf: NextWaypointURL)
        let WaypointPieces = WaypointInfo.components(separatedBy: "\n")
        print(WaypointPieces[0])
        let WaypointPiecesFirstLine = WaypointPieces[0]
        
        //Assigns the info to the waypoint:
        NextWaypoint.latitude = Double(WaypointPiecesFirstLine.components(separatedBy: " ")[0])!
        NextWaypoint.longitude = Double(WaypointPiecesFirstLine.components(separatedBy: " ")[1])!
        NextWaypoint.radius = Double(WaypointPiecesFirstLine.components(separatedBy: " ")[2].dropLast())!
        NextWaypoint.name = WaypointPieces[4]
        
        NextWaypoint.description = try! String(contentsOf: DescriptionURL)
        
        
        return NextWaypoint
    }
    
    func getWaypoints(RouteURL: URL){
        //Uses the URL from the last page to get all the waypoint info:
        let manager = FileManager()
        
        Waypoints = try! manager.contentsOfDirectory(at: RouteURL, includingPropertiesForKeys: nil, options: [])
        var WaypointStrings = Array(repeating: "", count: Waypoints!.count)
        
        for Waypoint in 0...(Waypoints!.count - 1){
            WaypointStrings[Waypoint] = Waypoints![Waypoint].path
        }
        
        WaypointStrings.sort(by: <)
        
        for Waypoint in 0...(WaypointStrings.count - 1){
            Waypoints![Waypoint] = URL(fileURLWithPath: WaypointStrings[Waypoint])
        }
    }
    
    let synth = AVSpeechSynthesizer()
    
    let locManager = CLLocationManager()
    
    func startReceivingLocationChanges() {
        
        let authorizationStatus = CLLocationManager.authorizationStatus()
        
        locManager.requestWhenInUseAuthorization()
        
        
        
        if authorizationStatus == .authorizedWhenInUse {
            
            locManager.requestAlwaysAuthorization()
            
        }
        
        if authorizationStatus != .authorizedWhenInUse && authorizationStatus != .authorizedAlways {
            
            // User has not authorized access to location information.
            print("user has not authorized location access")
            return
            
        }
        
        // Do not start services that aren't available.
        
        if !CLLocationManager.locationServicesEnabled() {
            
            // Location services is not available.
            print("location unavailable")
            return
            
        }
        
        // Configure and start the service.
        
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        
        locManager.distanceFilter = 1.0  // In meters.
        
        locManager.delegate = self
        
        locManager.startUpdatingLocation()
        
    }
    
    func locationManager(_ manager: CLLocationManager,  didUpdateLocations locations: [CLLocation]) {
        
        let lastLocation = locations.last!
        
        let latitude = String(format: "%.5f", lastLocation.coordinate.latitude)
        let longitude = String(format: "%.5f", lastLocation.coordinate.longitude)
        LongLbl.text = "\(longitude)"
        
        LatLbl.text = "\(latitude)"
        
        let MtrsToLat = 0.0000090054
        let MtrsToLong = 0.000011797
        
        
        print(TargetWaypoint.longitude)
        print(TargetWaypoint.latitude)
        
        
        if (lastLocation.coordinate.longitude < (TargetWaypoint.longitude + (TargetWaypoint.radius * MtrsToLong))) && (lastLocation.coordinate.longitude > (TargetWaypoint.longitude - (TargetWaypoint.radius * MtrsToLong))) && (lastLocation.coordinate.latitude < (TargetWaypoint.latitude + (TargetWaypoint.radius * MtrsToLat))) && (lastLocation.coordinate.latitude > (TargetWaypoint.latitude - (TargetWaypoint.radius * MtrsToLat))) && !LastWaypoint {
            
            
            NodeLbl.text = TargetWaypoint.name
            
            let utter = AVSpeechUtterance(string: TargetWaypoint.description)
            utter.rate = Float(rate)
            synth.speak(utter)
            
            LastDescription = TargetWaypoint.description
            
            if (waypointNum < Waypoints!.count - 1){
                waypointNum += 1
            }
            else {
                LastWaypoint = true
                print("last waypoint")
            }
            
            TargetWaypoint = getNextNode(NextWaypointNum: waypointNum)
            
        }
        else{
            print("not so good")
            //print("Last waypoint is", LastWaypoint)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startReceivingLocationChanges()
        CrntRouteLbl.text = route
        waypointNum = 1
        
        getWaypoints(RouteURL: routeURL!)
        
        TargetWaypoint = getNextNode(NextWaypointNum: waypointNum)
        
        let speech = AVSpeechUtterance(string: "Your current route is \(route)")
        speech.voice = AVSpeechSynthesisVoice(language: "en-US")
        speech.rate = Float(rate)
        synth.speak(speech)
        
        let utter = AVSpeechUtterance()
        utter.voice = AVSpeechSynthesisVoice(language: "en-US")
        utter.rate = Float(rate)
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
}
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


