//
//  ViewController.swift
//  MapBox
//
//  Created by Grazia Chillè on 03/07/2018.
//  Copyright © 2018 Grazia Chillè. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var lunghezzaLatoOutlet: UITextField!
    @IBOutlet weak var latitudineNordOutlet: UITextField!
    @IBOutlet weak var latitudineSudOutlet: UITextField!
    @IBOutlet weak var longitudineOvestOutlet: UITextField!
    @IBOutlet weak var longitudineEstOutlet: UITextField!
    @IBOutlet weak var searchBlur: UIVisualEffectView!
    
    @IBAction func changeMapView(_ sender: UISegmentedControl) {
        switch (sender.selectedSegmentIndex) {
        case 0:
            myMapView.mapType = .standard
        case 1:
            myMapView.mapType = .satellite
        default:
            myMapView.mapType = .hybrid
        }
    }

    @IBOutlet weak var myMapView: MKMapView!
    @IBOutlet weak var visualizzButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        visualizzButton.layer.cornerRadius = 10
        visualizzButton.layer.masksToBounds = true
        searchBlur.layer.cornerRadius = 20
        searchBlur.layer.masksToBounds = true
        //let initialLocation = CLLocation(latitude: 42.9284783, longitude: -72.2775936)
        //centerMapOnLocation(location: initialLocation)
        
        
      
        
    }
    
    //Disegno il poligono
    func disegnaBox()
    {
        var latitudineNord = (latitudineNordOutlet.text as! NSString).doubleValue
        var longitudineOvest = (longitudineOvestOutlet.text as! NSString).doubleValue
        var latitudineSud = (latitudineSudOutlet.text as! NSString).doubleValue
        var longitudineEst = (longitudineEstOutlet.text as! NSString).doubleValue
        
        //Creo l'annotazione
        var annotation = MKPointAnnotation()
        annotation.title = "P1"
        annotation.coordinate = CLLocationCoordinate2DMake(latitudineNord, longitudineEst)
        var annotation1 = MKPointAnnotation()
        annotation1.title = "P2"
        annotation1.coordinate = CLLocationCoordinate2DMake(latitudineSud, longitudineEst)
        var annotation2 = MKPointAnnotation()
        annotation2.title = "P3"
        annotation2.coordinate = CLLocationCoordinate2DMake(latitudineSud, longitudineOvest)
        var annotation3 = MKPointAnnotation()
        annotation3.title = "P4"
        annotation3.coordinate = CLLocationCoordinate2DMake(latitudineNord, longitudineOvest)
        
        //Zoom
        let coordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitudineNord, longitudineOvest)
        let span = MKCoordinateSpanMake(0.1, 0.1)
        let region = MKCoordinateRegionMake(coordinate, span)
        myMapView.setRegion(region, animated: true)
       
        var points = [CLLocationCoordinate2DMake(latitudineNord, longitudineEst),CLLocationCoordinate2DMake(latitudineSud, longitudineEst ),CLLocationCoordinate2DMake(latitudineSud, longitudineOvest),CLLocationCoordinate2DMake( latitudineNord, longitudineOvest),CLLocationCoordinate2DMake(latitudineNord, longitudineEst)]
        
        let polygon = MKPolygon(coordinates: &points, count: points.count)
        
        myMapView.add(polygon)
        myMapView.addAnnotation(annotation)
        myMapView.addAnnotation(annotation1)
        myMapView.addAnnotation(annotation2)
        myMapView.addAnnotation(annotation3)
        
    }
    
    
    //Personalizzo il poligono
    func mapView(_ mapView: MKMapView!, rendererFor overlay: MKOverlay!) -> MKOverlayRenderer!  {
        if overlay is MKPolygon {
            let polygonView = MKPolygonRenderer(overlay: overlay)
            polygonView.fillColor = UIColor.red
            polygonView.alpha = 0.5
            return polygonView
        }
        return  nil
    }
    
    
    

var flag = false
    
    let regionRadius: CLLocationDistance = 1000
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius * 2.0, regionRadius * 2.0)
        myMapView.setRegion(coordinateRegion, animated: true)
    }

    
    //Implemento la barra di ricerca
    @IBAction func searchButtonAction(_ sender: UIButton) {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        present(searchController, animated: true, completion: nil)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //Ignoriamo le interazioni dell'utente
        UIApplication.shared.beginIgnoringInteractionEvents()
        //indicatore di attività
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.stopAnimating()
        
        self.view.addSubview(activityIndicator)
        
        //Nascondiamo la barra di ricerca
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        
        //Creo la richiesta di ricerca
        let searchRequest = MKLocalSearchRequest()
        searchRequest.naturalLanguageQuery = searchBar.text
        
        let activeSearch = MKLocalSearch(request: searchRequest)
        activeSearch.start{ (response, error) in
            
            activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
            
            if response == nil{
                print("ERROR")
            }else{
                //Rimuovo le annotazioni ogni volta che cerco un nuovo posto
                let allAnnotations = self.myMapView.annotations
                self.myMapView.removeAnnotations(allAnnotations)
             
                
                //Prendo i dati
                let latidudine = response?.boundingRegion.center.latitude
                let longitudine = response?.boundingRegion.center.longitude
                
                //Creo l'annotazione
                let annotation = MKPointAnnotation()
                annotation.title = searchBar.text
                annotation.coordinate = CLLocationCoordinate2DMake(latidudine!, longitudine!)
                self.myMapView.addAnnotation(annotation)
                
                //Zoom sull'annotazione
                let coordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latidudine!, longitudine!)
                let span = MKCoordinateSpanMake(0.1, 0.1)
                let region = MKCoordinateRegionMake(coordinate, span)
                self.myMapView.setRegion(region, animated: true)
            }
        }
    }
    
    
    //Azione del bottone visualizza
    @IBAction func visualizzaAction(_ sender: UIButton) {
        disegnaBox()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

