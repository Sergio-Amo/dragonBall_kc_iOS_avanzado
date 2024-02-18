//
//  HeroesMapViewController.swift
//  Practica_iOS_avanzado_ref1
//
//  Created by Sergio Amo on 18/2/24.
//

import UIKit
import MapKit

// MARK: - View Protocol -
protocol HeroesMapViewControllerDelegate {
    var viewState: ((HeroesMapViewState) -> Void)? { get set }
    func onViewAppear()
}

// MARK: - View State -
enum HeroesMapViewState {
    case loading(_ isLoading: Bool)
    case update(locations: [HeroAnnotation]?)
}

final class HeroesMapViewController: UIViewController {
    //MARK: - IBOutlets -
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var mapOutlet: MKMapView!
    
    // MARK: - Public Properties -
    var viewModel: HeroesMapViewControllerDelegate?
    
    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
        setObservers()
        viewModel?.onViewAppear()
    }
    
    // MARK: - Private functions -
    private func initViews() {
        mapOutlet.delegate = self
    }
    
    private func setObservers() {
        viewModel?.viewState = { [weak self] state in
            DispatchQueue.main.async {
                switch state {
                    case .loading(let isLoading):
                        self?.loadingView.isHidden = !isLoading
                        break
                    case .update(let locations):
                        self?.updateViews(locations: locations)
                        break
                }
            }
        }
    }
    
    private func updateViews(locations: [HeroAnnotation]?) {
        // Validate coordinates
        let lastValidlocations = locations?.compactMap({
            if CLLocationCoordinate2DIsValid($0.coordinate) {
                return $0
            }
            return nil
        })
        // Add annotations
        lastValidlocations?.forEach { mapOutlet.addAnnotation($0) }
    }
    
}

// MARK: - Class extensions -
extension HeroesMapViewController: MKMapViewDelegate {}
