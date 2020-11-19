//
//  ContactCell.swift
//  GBKSoftTechTask1
//
//  Created by Anton Honcharenko on 19.11.2020.
//

import UIKit
import Kingfisher

class ContactCell: UITableViewCell {
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var contentcontainer: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        backgroundColor = .clear
        contentcontainer.layer.cornerRadius = 10
        contentcontainer.layer.shadowOpacity = 0.05
        contentcontainer.layer.shadowOffset = .zero
        userAvatar.layer.cornerRadius = userAvatar.frame.height / 2
    }

    func setInfo(model: StoredContactsItem) {
        let fullName = [model.firstName ?? "", model.lastName ?? ""].filter({ !$0.isEmpty }).joined(separator: " ")
        nameLabel.text = fullName
        emailLabel.text = model.email
        userAvatar.kf.setImage(with: URL(string: model.image ?? ""), placeholder: UIImage(named: "avatar"))
    }
}
