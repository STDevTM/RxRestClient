//
//  ContactTableViewCell.swift
//  RxRestClient_Example
//
//  Created by Tigran Hambardzumyan on 3/27/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit

class ContactTableViewCell: UITableViewCell {

//    let contact: Contact!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var email: UILabel!


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
