//
//  DetailsViewController.swift
//  GBKSoftTechTask1
//
//  Created by Anton Honcharenko on 19.11.2020.
//

import UIKit
import Kingfisher
import MapKit

class DetailsViewController: UIViewController {
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var streetLabel: UILabel!
    @IBOutlet weak var locationMap: MKMapView!
    var model: StoredContactsItem!
    var calback: ((StoredContactsItem) -> Void)?

    static func present(on viewController: UIViewController, model: StoredContactsItem, calback: @escaping ((StoredContactsItem) -> Void)) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: .main)
        let vc = storyboard.instantiateViewController(withIdentifier: "DetailsViewController") as! DetailsViewController
        vc.model = model
        vc.calback = calback
        viewController.navigationController?.pushViewController(vc, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        userAvatar.layer.cornerRadius = userAvatar.frame.height / 2
        setInfo(model: model)
        let rightBarItem = UIBarButtonItem(title: "remove", style: .done, target: self, action: #selector(remove))
        navigationItem.rightBarButtonItem = rightBarItem
    }

    private func setInfo(model: StoredContactsItem) {
        let fullName = [model.firstName ?? "", model.lastName ?? ""].filter({ !$0.isEmpty }).joined(separator: " ")
        title = (model.firstName ?? "") + " " + (model.firstName ?? "")
        nameLabel.text = fullName
        emailLabel.text = model.email
        cityLabel.text = model.city
        streetLabel.text = model.street
        guard let latitude = model.latitude else { return }
        guard let longitude = model.longitude else { return }
        let initialLocation = CLLocation(latitude: latitude, longitude: longitude)
        let artwork = ContactLocationPoint(title: model.city,
                                           locationName: fullName,
                                           coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
        locationMap.centerToLocation(initialLocation)
        locationMap.addAnnotation(artwork)
        userAvatar.kf.setImage(with: URL(string: model.image ?? ""), placeholder: UIImage(named: "avatar"))
    }

    @objc func remove() {
        calback?(model)
        navigationController?.popToRootViewController(animated: true)
    }
    @IBAction func onEditButtonPress(_ sender: Any) {
        EditContactViewController.present(on: self, model: self.model, calback: {
            self.model = $0
            self.setInfo(model: $0)
        })
    }
}

extension MKMapView {
    func centerToLocation(_ location: CLLocation, regionRadius: CLLocationDistance = 90000) {
        let coordinateRegion = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: regionRadius,
            longitudinalMeters: regionRadius)
        setRegion(coordinateRegion, animated: true)
    }
}

class ContactLocationPoint: NSObject, MKAnnotation {
    let title: String?
    let locationName: String?
    let coordinate: CLLocationCoordinate2D

    init(title: String?, locationName: String?, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.locationName = locationName
        self.coordinate = coordinate
        super.init()
    }

    var subtitle: String? {
        return locationName
    }
}
