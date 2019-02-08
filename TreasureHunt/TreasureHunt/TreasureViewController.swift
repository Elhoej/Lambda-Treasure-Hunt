//
//  ViewController.swift
//  TreasureHunt
//
//  Created by Simon Elhoej Steinmejer on 08/02/19.
//  Copyright © 2019 Simon Elhoej Steinmejer. All rights reserved.
//

import UIKit

extension Notification.Name {
    static let didReceiveCooldown = Notification.Name("didReceiveCooldown")
}


class TreasureViewController: UIViewController {

    var cooldownTimer: Timer?
    var cooldown = 0
    
    let cooldownLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.sizeToFit()
        
        return label
    }()
    
    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.init(white: 0.85, alpha: 1)
        view.layer.cornerRadius = 16
        
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.sizeToFit()
        label.numberOfLines = 0
        label.text = "Title: "
        
        return label
    }()
    
    let messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.sizeToFit()
        label.numberOfLines = 0
        label.text = "Message: "
        
        return label
    }()
    
    let coordsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.sizeToFit()
        label.numberOfLines = 0
        label.text = "Coords: "
        
        return label
    }()
    
    let playersLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.sizeToFit()
        label.numberOfLines = 0
        label.text = "Players: "
        
        return label
    }()
    
    let itemsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.sizeToFit()
        label.numberOfLines = 0
        label.text = "Items: "
        
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavbar()
        setupViews()
        TreasureMap.shared.initialize { (room) in
            
            guard let room = room else {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Failed to connect to the server, please try again.", message: nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                return
            }
            
            DispatchQueue.main.async {
                TreasureMap.shared.cooldown = room.cooldown! + 1
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleCooldown), name: .didReceiveCooldown, object: nil)
    }
    
    @objc private func handleCooldown(notification: Notification) {
        if let cooldown = notification.userInfo?["cooldown"] as? Int {
            self.cooldown = cooldown
            cooldownLabel.text = "Cooldown: \(cooldown)"
            cooldownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countdown), userInfo: nil, repeats: true)
        }
    }
    
    @objc private func countdown() {
        cooldown -= 1
        if cooldown < 1 {
            cooldownTimer?.invalidate()
            cooldownTimer = nil
            return
        }
        
        cooldownLabel.text = "Cooldown: \(cooldown)"
    }
    
    private func setupNavbar() {
        navigationItem.title = "Treasure Map Explorer"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Explore", style: .plain, target: self, action: #selector(handleExplore))
    }
    
    @objc private func handleExplore() {
        TreasureMap.shared.explore()
    }
    
    private func setupViews() {
        view.addSubview(cooldownLabel)
        cooldownLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 0))
        
        view.addSubview(containerView)
        containerView.anchor(top: nil, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, size: CGSize(width: 0, height: 300))
        
        let leftStackView = UIStackView(arrangedSubviews: [titleLabel, messageLabel, coordsLabel])
        leftStackView.axis = .vertical
        leftStackView.distribution = .fillEqually
        leftStackView.spacing = 12
        
        let rightStackView = UIStackView(arrangedSubviews: [playersLabel, itemsLabel])
        rightStackView.axis = .vertical
        rightStackView.distribution = .fillEqually
        rightStackView.spacing = 12
        
        let stackView = UIStackView(arrangedSubviews: [leftStackView, rightStackView])
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.distribution = .fillEqually
        
        containerView.addSubview(stackView)
        stackView.anchor(top: containerView.topAnchor, leading: containerView.leadingAnchor, bottom: containerView.bottomAnchor, trailing: containerView.trailingAnchor, padding: .init(top: 12, left: 12, bottom: 12, right: 12))
    }
}

