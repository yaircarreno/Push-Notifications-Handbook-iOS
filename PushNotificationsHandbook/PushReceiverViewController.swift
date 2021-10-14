//
//  PushReceiverViewController.swift
//  PushNotificationsHandbook
//
//  Created by Yair Carreno on 12/10/21.
//

import UIKit

class PushReceiverViewController: UIViewController {

    @IBOutlet weak var scoreText: UILabel!
    @IBOutlet weak var countryText: UILabel!

    var score: String?
    var country: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        scoreText.text = "Score: \(score ?? "")"
        countryText.text = "From: \(country ?? "")"
    }
}
