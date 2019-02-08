//
//  ViewController.swift
//  TreasureHunt
//
//  Created by Simon Elhoej Steinmejer on 08/02/19.
//  Copyright © 2019 Simon Elhoej Steinmejer. All rights reserved.
//

import UIKit

class TreasureViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavbar()
        TreasureMap.shared.initialize()
    }
    
    private func setupNavbar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Explore", style: .plain, target: self, action: #selector(handleExplore))
    }
    
    @objc private func handleExplore() {
        TreasureMap.shared.explore()
    }
}

