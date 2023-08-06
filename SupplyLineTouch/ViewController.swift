//
//  ViewController.swift
//  SupplyLineTouch
//
//  Created by Abin Baby on 29/01/20.
//  Copyright © 2020 Abin Baby. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {
    
    //MARK: - UIViewController overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addAnnotations()
        mapView.addGestureRecognizer(mapTap)
    }
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    //MARK: - IBActions
    
    @IBAction func mapViewTapped(tap: UITapGestureRecognizer) {
        let touchPoint: CGPoint = tap.location(in: mapView)
        let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        let mapPoint = MKMapPoint(touchCoordinate)
        
        let meters = self.metersFrom(pixels: 22, at: touchPoint, in: self.mapView)
        for overlay in mapView.overlays {
            if let polyline = (overlay as? MKPolyline) {
                if self.point(mapPoint, isWithin: meters, toLine: polyline) {
                    print("polyline was tapped")
                }
            }
        }
    }
    
    //MARK: - Private API
    
    private let places = Place.getPlaces()
    private lazy var mapTap: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(mapViewTapped(tap:)))
        gesture.numberOfTapsRequired = 1
        return gesture
    }()
    
    private func addAnnotations() {
        mapView?.delegate = self
        mapView?.addAnnotations(places)
        
        let overlays = places.map { MKCircle(center: $0.coordinate, radius: 100) }
        mapView?.addOverlays(overlays)
        
        var locations = places.map { $0.coordinate }
        let polyline = MKPolyline(coordinates: &locations, count: locations.count)
        mapView?.addOverlay(polyline)
    }
    
    /// Returns true when the point is within the specified meter tolerance of the provided polyline.
    /// - Parameters:
    ///   - point: The map point in Mercator projection, to be tested with the polyline.
    ///   - meters: The tolerance in meters.  When the point is within this many meters, this function will return true.  A negative value will be treated as a positive value.
    ///   - polyline: The polyline to be tested with the point.
    /// - Returns: Returns true when the point is within meters of the provided polyline.
    private func point(_ point: MKMapPoint, isWithin meters: Double, toLine polyline: MKPolyline) -> Bool {
        let meters = abs(meters)
        var distance: Double = Double.greatestFiniteMagnitude
        for n in 0..<polyline.pointCount - 1 {
            let ptA = polyline.points()[n]
            let ptB = polyline.points()[n + 1]
            let xDelta: Double = ptB.x - ptA.x
            let yDelta: Double = ptB.y - ptA.y
            
            // Points must not be equal
            if xDelta == 0.0 && yDelta == 0.0 { continue }
            
            let u: Double = ((point.x - ptA.x) * xDelta + (point.y - ptA.y) * yDelta) / (xDelta * xDelta + yDelta * yDelta)
            var ptClosest: MKMapPoint
            if u < 0.0 {
                ptClosest = ptA
            } else if u > 1.0 {
                ptClosest = ptB
            } else {
                ptClosest = MKMapPoint(x: ptA.x + u * xDelta, y: ptA.y + u * yDelta)
            }
            distance = min(distance, ptClosest.distance(to: point))
        }
        return distance < meters
    }
    
    /// Returns a double that represents the number of meters the provided pixel count represents at the current map zoom level.
    /// - Parameters:
    ///   - pixels: The number of pixels to convert to meters for the map views current zoom level.
    ///   - point: A reference point on the map view in the map UIView coordinate space.
    ///   - mapView: A reference to the map view for performing the coordinate space conversions.
    /// - Returns: The number of meters the pixels represents at the current zoom level.
    private func metersFrom(pixels: CGFloat, at point: CGPoint, in mapView: MKMapView) -> Double {
        let endPoint = CGPoint(x: point.x + pixels, y: point.y)
        let coordA: CLLocationCoordinate2D = mapView.convert(point, toCoordinateFrom: mapView)
        let coordB: CLLocationCoordinate2D = mapView.convert(endPoint, toCoordinateFrom: mapView)
        return MKMapPoint(coordA).distance(to: MKMapPoint(coordB))
    }
    
}

//MARK: - MKMapViewDelegate protocol
extension ViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = UIColor.orange
            renderer.lineWidth = 6
            return renderer
        } else if overlay is MKCircle {
            let renderer = MKCircleRenderer(overlay: overlay)
            renderer.strokeColor = .red
            renderer.lineWidth = 2
            renderer.fillColor = .red.withAlphaComponent(0.4)
            return renderer
        } else {
            let renderer = MKOverlayRenderer(overlay: overlay)
            return renderer
        }
    }
}
