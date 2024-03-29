//
//  HeroDetailViewController.swift
//  Practica_iOS_avanzado_ref1
//
//  Created by Sergio Amo on 29/10/23.
//

import UIKit
import MapKit
import Kingfisher

// MARK: - View State -
enum HeroDetailViewState {
    case loading(_ isLoading: Bool)
    case update(hero: Hero?, locations: [HeroAnnotation]?)
}

// MARK: - Protocol -
protocol HeroDetailViewControllerDelegate {
    var viewState: ((HeroDetailViewState) -> Void)? { get set }
    func onViewAppear()
}

final class HeroDetailViewController: UIViewController {
    
    //MARK: - IBOutlets -
    @IBOutlet weak var imageOutlet: UIImageView!
    @IBOutlet weak var mapOutlet: MKMapView!
    @IBOutlet weak var tittleOutlet: UILabel!
    @IBOutlet weak var descriptionOutlet: UITextView!
    @IBOutlet weak var loadingView: UIView!
    
    // MARK: - Public Properties -
    var viewModel: HeroDetailViewControllerDelegate?
    
    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
        setObservers()
        viewModel?.onViewAppear()
        makeImageRound()
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
                    case .update(let hero, let locations):
                        self?.updateViews(hero: hero, heroLocations: locations)
                        break
                }
            }
        }
    }
    
    private func updateViews(hero: Hero?, heroLocations: [HeroAnnotation]?) {
        update(title: hero?.name)
        update(description: hero?.description)
        update(photo: hero?.photo)
        update(locations: heroLocations)
    }
    
    private func update(title: String? = nil) {
        tittleOutlet.text = title
    }
    private func update(description: String? = nil) {
        descriptionOutlet.text = description
    }
    private func update(photo: URL? = nil) {
        guard let photo else { return }
        let finalUrl = photo.scheme == "http" ? photo.upgradeUrlScheme(photo) : photo
        imageOutlet.kf.setImage(with: finalUrl)
    }
    
    // Center map to first valid location (they came ordered by date, most recent first)
    private func update(locations: [HeroAnnotation]?) {
        // Validate coordinates
        let lastValidlocations = locations?.compactMap({
            if CLLocationCoordinate2DIsValid($0.coordinate) {
                return $0
            }
            return nil
        })
        // Center map to first valid coordinate
        if let location = lastValidlocations?.first?.coordinate {
            mapOutlet.centerCoordinate = location
        }
        // Add annotations
        lastValidlocations?.forEach { mapOutlet.addAnnotation($0) }
    }
    
    private func makeImageRound() {
        imageOutlet.layer.cornerRadius = imageOutlet.frame.width / 2
        imageOutlet.clipsToBounds = true
        
        imageOutlet.layer.borderWidth = 3
        imageOutlet.layer.borderColor = UIColor.systemBackground.cgColor
    }
}

extension HeroDetailViewController: MKMapViewDelegate {
}
