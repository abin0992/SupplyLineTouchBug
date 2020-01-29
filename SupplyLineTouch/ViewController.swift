//
//  ViewController.swift
//  SupplyLineTouch
//
//  Created by Abin Baby on 29/01/20.
//  Copyright © 2020 Abin Baby. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController,MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    let places = Place.getPlaces()
    var mapTap: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addAnnotations()
        mapTap = UITapGestureRecognizer(target: self, action: #selector(mapViewTapped(tap:)))
        mapTap.numberOfTapsRequired = 1
        mapView.addGestureRecognizer(mapTap)
    }

    func addAnnotations(){
        mapView?.delegate = self
           mapView?.addAnnotations(places)
        
           let overlays = places.map { MKCircle(center: $0.coordinate, radius: 100) }
           mapView?.addOverlays(overlays)
           
           var locations = places.map { $0.coordinate }
           let polyline = MKPolyline(coordinates: &locations, count: locations.count)
        mapView?.addOverlay(polyline)
    }

    @IBAction func mapViewTapped(tap: UITapGestureRecognizer) {
        let touchPoint: CGPoint = tap.location(in: mapView)
	           let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
           let mapPoint = MKMapPoint(touchCoordinate)

           for overlay in mapView.overlays {
               if overlay is MKPolyline {
                   if let polylineRenderer = mapView.renderer(for: overlay) as? MKPolylineRenderer {
                       let polylinePoint = polylineRenderer.point(for: mapPoint)

                       if polylineRenderer.path.contains(polylinePoint) {
                           print("polyline was tapped")
                       }
                   }
               }
           }
    }

    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = UIColor.orange
            renderer.lineWidth = 6
            return renderer
        }
        
        return MKOverlayRenderer()
    }
    
}

