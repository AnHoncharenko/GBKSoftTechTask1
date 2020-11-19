//
//  EditContactViewController.swift
//  GBKSoftTechTask1
//
//  Created by Anton Honcharenko on 19.11.2020.
//

import UIKit
extension Notification.Name {
    static let contactDidEdited = Notification.Name("contactDidEdited")
}

class EditContactViewController: UIViewController {
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var streetTextField: UITextField!
    var model: StoredContactsItem!
    var calback: ((StoredContactsItem) -> Void)?

    static func present(on viewController: UIViewController, model: StoredContactsItem, calback: @escaping ((StoredContactsItem) -> Void)) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: .main)
        let vc = storyboard.instantiateViewController(withIdentifier: "EditContactViewController") as! EditContactViewController
        vc.model = model
        vc.calback = calback
        viewController.navigationController?.pushViewController(vc, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        userAvatar.layer.cornerRadius = userAvatar.frame.height / 2
        setInfo(model: model)
        addTapGesture()
    }

    private func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
    }

    @objc func handleTap() {
        view.endEditing(true)
    }

    private func setInfo(model: StoredContactsItem) {
        title = "Edit"
        firstNameTextField.text = model.firstName
        lastNameTextField.text = model.lastName
        emailTextField.text = model.email
        cityTextField.text = model.city
        streetTextField.text = model.street
        userAvatar.kf.setImage(with: URL(string: model.image ?? ""), placeholder: UIImage(named: "avatar"))
    }

    @IBAction func onConfirmButtonPress(_ sender: Any) {
        model.firstName = firstNameTextField.text!
        model.lastName = lastNameTextField.text!
        model.email = emailTextField.text!
        model.city = cityTextField.text!
        model.street = streetTextField.text!

        StoredContacts.shared.update(model: model, compleation: {
            if $0 {
                self.calback?(self.model)
                self.navigationController?.popViewController(animated: true)
                NotificationCenter.default.post(.init(name: .contactDidEdited))
            }
        })
    }
}
