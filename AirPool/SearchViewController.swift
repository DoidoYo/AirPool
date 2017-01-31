//
//  SearchViewController.swift
//  AirPool
//
//  Created by Gabriel Fernandes on 1/22/17.
//  Copyright © 2017 Gabriel Fernandes. All rights reserved.
//

import Foundation
import UIKit
import GooglePlaces

protocol SearchViewControllerDelegate {
//    func searchViewDestination(_ predic:GMSAutocompletePrediction?)
//    func searchViewPickup(_ predic:GMSAutocompletePrediction?)
    func searchViewGetPredictions(pickup:GMSAutocompletePrediction?, destination:GMSAutocompletePrediction?)
}

class SearchViewController: UIViewController {
    
    let baseURLGeocode = "https://maps.googleapis.com/maps/api/geocode/json?"
    
    //preloaded vars
    var delegate: SearchViewControllerDelegate?
    var predictionDestination:GMSAutocompletePrediction?
    var predictionPickup:GMSAutocompletePrediction?
    var selectedTextField:Int = 0
    
    //runtime vars
    var searchBound: GMSCoordinateBounds!
    var fetcher: GMSAutocompleteFetcher!
    var fetcherResults:[GMSAutocompletePrediction] = []
    var lastSelectedTextField: UITextField!
    
    @IBOutlet weak var textFieldDestination: UITextField!
    @IBOutlet weak var textFieldPickup: UITextField!
    
    @IBOutlet weak var tableViewResults: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textFieldDestination.delegate = self
        textFieldPickup.delegate = self
        
        tableViewResults.delegate = self
        tableViewResults.dataSource = self
        
        
        fetcher = GMSAutocompleteFetcher(bounds: searchBound, filter: nil)
        fetcher.delegate = self
        
        //set textfield text if already selected
        if let dest = predictionDestination {
            textFieldDestination.text = dest.attributedPrimaryText.string
        }
        if let pick = predictionPickup {
            textFieldPickup.text = pick.attributedPrimaryText.string
        } else {
            textFieldPickup.text = "Current Location"
        }
        //pull up keayboard
        if selectedTextField == 0 {
            textFieldDestination.becomeFirstResponder()
        } else {
            textFieldPickup.becomeFirstResponder()
        }
        
    }
    
    //navigation bar logic
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    @IBAction func buttonBackPress(_ sender: Any) {
        popView()
    }
    
    func popView() {
        //pass data back to main controller
//        delegate?.searchViewDestination(predictionDestination)
//        delegate?.searchViewPickup(predictionPickup)
        delegate?.searchViewGetPredictions(pickup: predictionPickup, destination: predictionDestination)
        //remove this view
        self.navigationController?.popViewController(animated: true)
    }
}

extension SearchViewController: UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, GMSAutocompleteFetcherDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        fetcher.sourceTextHasChanged(textField.text)
        fetcherResults = []
        tableViewResults.reloadData()
        
        lastSelectedTextField = textField
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.selectAll(nil)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //update fetcher when user types
        fetcher.sourceTextHasChanged(textField.text)
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = fetcherResults[indexPath.row].attributedPrimaryText.string
        cell.detailTextLabel?.text = fetcherResults[indexPath.row].attributedSecondaryText?.string
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if lastSelectedTextField == textFieldDestination {
            predictionDestination = fetcherResults[indexPath.row]
        } else {
            predictionPickup = fetcherResults[indexPath.row]
        }
        
        popView()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetcherResults.count
    }
    
    func didAutocomplete(with predictions: [GMSAutocompletePrediction]) {
        //get new data and reload the data showing it
        fetcherResults = predictions
        tableViewResults.reloadData()
    }
    
    func didFailAutocompleteWithError(_ error: Error) {
        print(error)
    }

    
}
