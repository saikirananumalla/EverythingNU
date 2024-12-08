//
//  LocationPickerDelegate.swift
//  final
//
//  Created by Sai Kiran Anumalla on 06/12/24.
//


import UIKit
import MapKit

protocol LocationPickerDelegate: AnyObject {
    func didPickLocation(latitude: Double, longitude: Double)
}

class LocationPickerViewController: UIViewController {
    
    var mapView: MKMapView!
    weak var delegate: LocationPickerDelegate?
    var selectedCoordinate: CLLocationCoordinate2D?
    var pinAnnotation: MKPointAnnotation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Select Location"
        setupMap()
        setupConfirmButton()
    }
    
    func setupMap() {
        mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.delegate = self
        self.view.addSubview(mapView)
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
        
        let northeasternCoordinate = CLLocationCoordinate2D(latitude: 42.3398, longitude: -71.0892)
        let regionSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let northeasternRegion = MKCoordinateRegion(center: northeasternCoordinate, span: regionSpan)
        mapView.setRegion(northeasternRegion, animated: true)
        
        pinAnnotation = MKPointAnnotation()
        pinAnnotation.coordinate = northeasternCoordinate
        mapView.addAnnotation(pinAnnotation)
    }
    
    func setupConfirmButton() {
        let confirmButton = UIButton(type: .system)
        confirmButton.setTitle("Confirm Location", for: .normal)
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.addTarget(self, action: #selector(confirmLocation), for: .touchUpInside)
        self.view.addSubview(confirmButton)
        
        NSLayoutConstraint.activate([
            confirmButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            confirmButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
    
    @objc func confirmLocation() {
        guard let coordinate = selectedCoordinate else {
            print("No location selected.")
            return
        }
        delegate?.didPickLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        self.navigationController?.popViewController(animated: true)
    }
}

extension LocationPickerViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let minLatitude = 42.3375
        let maxLatitude = 42.3420
        let minLongitude = -71.0935
        let maxLongitude = -71.0850

        // Current map center
        var center = mapView.centerCoordinate

        // Clamp latitude and longitude to the defined bounds
        center.latitude = min(max(center.latitude, minLatitude), maxLatitude)
        center.longitude = min(max(center.longitude, minLongitude), maxLongitude)

        // Update map center if it goes out of bounds
        if center.latitude != mapView.centerCoordinate.latitude || center.longitude != mapView.centerCoordinate.longitude {
            mapView.setCenter(center, animated: true)
        }

        // Update the selected coordinate
        pinAnnotation.coordinate = center
        selectedCoordinate = center
        print("Selected Coordinate: \(selectedCoordinate?.latitude ?? 0), \(selectedCoordinate?.longitude ?? 0)")
    }

}
