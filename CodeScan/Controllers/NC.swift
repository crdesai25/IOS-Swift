//
//  NC.swift
//  CodeScan
//
//  Created by Stephen Muscarella on 5/27/18.
//  Copyright © 2018 Elite Development LLC. All rights reserved.
//

import UIKit

class NC: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.barTintColor = UIColor.metallicSeaweed
        navigationBar.tintColor = UIColor.metallicSeaweed
        navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.metallicSeaweed]
    }

}
