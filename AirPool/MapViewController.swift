//
//  MapViewController.swift
//  AirPool
//
//  Created by Gabriel Fernandes on 1/20/17.
//  Copyright © 2017 Gabriel Fernandes. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps
import GooglePlaces

class MapViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate, GMSMapViewDelegate, SearchViewControllerDelegate {
    
    var locationManager = CLLocationManager()
    
    var myLocation: CLLocation!
    var markerDestination : GMSMarker?
    var markerPickup: GMSMarker?
    
    @IBOutlet weak var textFieldDestination: LeftImageTextField!
    @IBOutlet weak var textFieldPickup: LeftImageTextField!
    @IBOutlet weak var textFieldTime: LeftImageTextField!
    @IBOutlet weak var buttonShareButton: ShareButton!
    @IBOutlet weak var buttonCurrentLocation: RoundButton!
    @IBOutlet weak var viewMap: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        buttonShareButton.setIsEnabled(false)
        
        textFieldDestination.delegate = self
        textFieldPickup.delegate = self
        textFieldTime.delegate = self
        
        let camera: GMSCameraPosition = GMSCameraPosition.camera(withLatitude: 48.857165, longitude: 2.354613, zoom: 8.0)
        viewMap.camera = camera
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        viewMap.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.new, context: nil)
        viewMap.delegate = self
        
        print(UIApplication.shared.keyWindow?.frame.width)
        print(UIApplication.shared.keyWindow?.frame.height)
        
        buttonCurrentLocation.setIsEnabled(false)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField != textFieldTime {
            let story = UIStoryboard(name: "Main", bundle: nil)
            let view = story.instantiateViewController(withIdentifier: "searchViewController") as! SearchViewController
            let radius = 0.009
            let topLeft = CLLocationCoordinate2D(latitude: myLocation.coordinate.latitude - radius, longitude: myLocation.coordinate.longitude - radius)
            let bottomRight = CLLocationCoordinate2D(latitude: myLocation.coordinate.latitude + radius, longitude: myLocation.coordinate.longitude + radius)
            let bounds = GMSCoordinateBounds(coordinate: topLeft, coordinate: bottomRight)
            
            view.delegate = self
            
            view.searchBound = bounds
            
            if textField.restorationIdentifier != "destination" {
                view.selectedTextField = 1
            }
        
            view.hidesBottomBarWhenPushed = true
            
            self.navigationController?.pushViewController(view, animated: true)
            
            return false
        }
        
        return true
    }
    
    //called when users chooses a destination, pickup location or both
    func searchViewGetPredictions(pickup: GMSAutocompletePrediction?, destination: GMSAutocompletePrediction?) {
        //clears all markers
        self.viewMap.clear()
        
        //INEFFICIENT CODE --- MAKE A FUCKING ARRAY BRA
        
        // gets a marker for destination if it exists
        if let dest = destination {
            //set the text field accordingly
            textFieldDestination.text = dest.attributedPrimaryText.string
            //get lat and lng for the place id returned by google
            self.geocoding(id: dest.placeID!, completion: {
                lat, lng in
                //create marker in main thread after the lat ang lng is aquired
                DispatchQueue.main.async {
                    let position = CLLocationCoordinate2D(latitude: lat , longitude: lng)
                    let marker = self.drawMarker(position: position)
                    marker.map = self.viewMap
                    
                    self.markerDestination = marker
                    self.centerCamera()
                }
                
            })
        }
        
        //gets a marker for pickup location
        if let pick = pickup {
            //set text accordingly
            textFieldPickup.text = pick.attributedPrimaryText.string
            //get lat and lng from place if
            self.geocoding(id: pick.placeID!, completion: {
                lat, lng in
                //create marker
                DispatchQueue.main.async {
                    let position = CLLocationCoordinate2D(latitude: lat , longitude: lng)
                    let marker = self.drawMarker(position: position)
                    marker.map = self.viewMap
                    
                    self.markerPickup = marker
                    self.centerCamera()
                }
            })
            
        } else {
            //if no destination is picked make it the user's current locaiton and tell him
            textFieldPickup.text = "Current Location"
            
            let marker = self.drawMarker(position: myLocation.coordinate)
            marker.map = self.viewMap
            self.markerPickup = marker
        }
        
        self.buttonCurrentLocation.setIsEnabled(false)
        
        //enale the share a ride button if both fields are filled
        if !textFieldPickup.text!.isEmpty && !textFieldDestination.text!.isEmpty {
            buttonShareButton.setIsEnabled(true)
        }
    }
    
    
    func centerCamera() {
        func center(pos: CLLocationCoordinate2D, zoom: Float) {
            self.viewMap.camera = GMSCameraPosition.camera(withTarget: pos, zoom: zoom)
            moveToYCenter(pos: pos)
        }
        
        func moveToYCenter(pos: CLLocationCoordinate2D) {
            //get pixel location of coord
            var currentCenterPos = self.viewMap.projection.point(for: self.viewMap.camera.target)
            let currentOffPos = self.viewMap.projection.point(for: pos)
            //move current center up, so that target is position on new center (between the buttons)
            currentCenterPos.y -= currentCenterPos.y - currentOffPos.y
            currentCenterPos.x -= currentCenterPos.x - currentOffPos.x
            
            let newCenterCoord = self.viewMap.projection.coordinate(for: currentCenterPos)
            
            self.viewMap.camera = GMSCameraPosition.camera(withTarget: newCenterCoord, zoom: self.viewMap.camera.zoom)
        }
        
        var zoomPos: CLLocationCoordinate2D!
        
        if let pick = markerPickup {
            zoomPos = pick.position
        } else if let dest = markerDestination {
            zoomPos = dest.position
        } else {
            zoomPos = myLocation.coordinate
        }
        center(pos: zoomPos, zoom: 14.0)
        
        
        if let pick = markerPickup, let dest = markerDestination {
            var bounds = GMSCoordinateBounds()
            bounds = bounds.includingCoordinate(pick.position)
            bounds = bounds.includingCoordinate(dest.position)
            
            //calculate zoom to display all markers
            let zoom = getBoundsZoomLevel(bounds: bounds, mapDim: CGRect(x: 0, y: 0, width: 400, height: 400)) //find more accurate way of getting the map dimesions
            
            //get center location between the two markers
            let imagCenterMarker = CLLocationCoordinate2D(latitude: (pick.position.latitude + dest.position.latitude) / 2.0, longitude: (pick.position.longitude + dest.position.longitude) / 2.0)
            
//            drawMarker(position: imagCenterMarker)
            
            center(pos: imagCenterMarker, zoom: zoom)
        }
    }
    
    func drawMarker(position: CLLocationCoordinate2D) -> GMSMarker {
        let marker = GMSMarker(position: position)
        marker.map = self.viewMap
        return marker
    }
    
    func getBoundsZoomLevel(bounds: GMSCoordinateBounds, mapDim: CGRect) -> Float{
        struct WORLD_DIM {
            static var height = 256
            static var width = 256
        }
        var ZOOM_MAX: Float = 21
        
        func latRad(lat: Float) -> Float {
            let si = sin(lat * Float.pi / 180)
            let radX2 = log((1 + si) / (1 - si)) / 2
            return max(min(radX2, Float.pi), -Float.pi) / 2.0
        }
        
        func zoom(mapPx: Float, worldPx: Float, fraction: Float) -> Float {
            return floor(log(mapPx / worldPx / fraction) / 0.693)
        }
        
        let ne = bounds.northEast
        let sw = bounds.southWest
        
        let latFraction = (latRad(lat: Float(ne.latitude)) - latRad(lat: Float(sw.latitude))) / Float.pi
        
        let lngDiff = ne.longitude - sw.longitude
        let lngFraction = ((lngDiff < 0) ? (lngDiff + 360) : lngDiff) / 360
        
        let latZoom = zoom(mapPx: Float(mapDim.height), worldPx: Float(WORLD_DIM.height), fraction: Float(latFraction))
        let lngZoom = zoom(mapPx: Float(mapDim.width), worldPx: Float(WORLD_DIM.width), fraction: Float(lngFraction))
        
        return min(latZoom, lngZoom, ZOOM_MAX)
    }
    
    @IBAction func buttonCurrentLocationTouch(_ sender: Any) {
        self.centerCamera()
        buttonCurrentLocation.setIsEnabled(false)
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        if gesture {
            buttonCurrentLocation.setIsEnabled(true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            viewMap.isMyLocationEnabled = true
        }
    }
    
    //called every time the user's location is updated
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        //update the user's current location
        myLocation = change![NSKeyValueChangeKey.newKey] as! CLLocation
        //if the pickup location is the user's current location then update the marker to the user's location
        if textFieldPickup.text == "Current Location" {
            markerPickup?.position = myLocation.coordinate
        }
        
        //only move carema to current position if the buttonCurrentLocation was pressed
        if !buttonCurrentLocation.isEnabled {
            self.centerCamera()
            buttonCurrentLocation.setIsEnabled(false)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func geocoding(id: String, completion: @escaping (Double, Double) -> ()) {
        let url = "https://maps.googleapis.com/maps/api/geocode/json?place_id=" + id + "&key=" + AppDelegate.GOOGLE_KEY
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            
            if let data = data, error == nil {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any]
                    let results = json?["results"] as! NSArray
                    let item0 = results[0] as! [String:Any]
                    let geometry = item0["geometry"] as! [String:Any]
                    let location = geometry["location"] as! [String:Any]
                    let lat = (location["lat"] as! Double)
                    let lng = (location["lng"] as! Double)
                    
                    completion(lat, lng)
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
        task.resume()
    }
}
