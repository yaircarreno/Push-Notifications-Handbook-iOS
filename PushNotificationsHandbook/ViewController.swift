//
//  ViewController.swift
//  PushNotificationsHandbook
//
//  Created by Yair Carreno on 29/05/21.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func isForeground() -> Bool {
        return UIApplication.shared.applicationState == .active
    }
}

