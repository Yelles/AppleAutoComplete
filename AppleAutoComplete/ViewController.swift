//
//  ViewController.swift
//  AppleAutoComplete
//
//  Created by Anthony H on 10/28/18.
//  Copyright © 2018 Anthony H. All rights reserved.
//

import UIKit
import MapKit

// Hide keyboard if view is tapped
extension UIViewController
{
    // to call place self.hideKeyboard() in viewdidload
    func hideKeyboard()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))
        
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
}

// MapKit methods
extension ViewController: MKLocalSearchCompleterDelegate {
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        
        self.tableViewOutlet.reloadData()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // handle error
        
        let title = "Location Update Eroor"
        let message = "Your location could not be determined"
        
        showAlert.showAlert(titleString: title, messageString: message, fromController: self)

    }
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, MKMapViewDelegate, CLLocationManagerDelegate  {

    @IBOutlet weak var textFieldOutlet: UITextField!
    @IBOutlet weak var tableViewOutlet: UITableView!
    
    
    let showAlert = AlertsViewController()
    
    // map variables
    var searchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    var matchingResult:[MKMapItem] = []
    var placeMark:MKPlacemark? = nil

    var matchedItem = MKMapItem()
    var itemName = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboard()
        self.tableViewOutlet.rowHeight = 98
        textFieldOutlet.addTarget(self, action: #selector(textFieldEditingDidChange), for: UIControl.Event.editingChanged)
        
        // Set the delegate for the Completer
        searchCompleter.delegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        self.tableViewOutlet.delegate = self
        self.tableViewOutlet.dataSource = self
        
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return searchResults.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        
        // Configure the cell...
        
        cell.contentView.layer.cornerRadius = 8
        cell.contentView.layer.masksToBounds = false
        
        cell.contentView.layer.shadowOffset = CGSize(width: 0, height: 3)
        cell.contentView.layer.shadowRadius = 3
        cell.contentView.layer.shadowOpacity = 0.3
        cell.contentView.layer.shouldRasterize = true
        cell.contentView.layer.rasterizationScale = UIScreen.main.scale
                
        cell.textLabel?.text = self.searchResults[indexPath.row].title
        cell.detailTextLabel?.text = self.searchResults[indexPath.row].subtitle
        
        return cell
    }// cellfor row
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let completion = searchResults[indexPath.row]

        let searchRequest = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: searchRequest)
        search.start { (response, error) in
            let coordinate = response?.mapItems[0].placemark.coordinate
            self.matchingResult = (response?.mapItems)!
            print(String(describing: coordinate))
            self.placeMark = response?.mapItems[0].placemark
        self.performSegue(withIdentifier: "MapViewSegue", sender: self)
    
        }
    }// didSelectRowAt
    
    
    // MARK: - TextField Delegates
    @IBAction func teaxtFieldAction(_ sender: Any) {
        
    }
    
    @IBAction func textFieldEditingDidChange(_ sender: Any) {
        
        self.searchResults.removeAll()
        
        // send the text to the completer
        searchCompleter.queryFragment = self.textFieldOutlet.text!
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        textField.resignFirstResponder()
        return true
    }
    

    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "MapViewSegue"
        {
            
            //send the location to the MapViewController
            let mapViewViewController = segue.destination as! MapViewController
            mapViewViewController.placeMark = self.placeMark
            
        } // segue.identifier
        
    }


}

