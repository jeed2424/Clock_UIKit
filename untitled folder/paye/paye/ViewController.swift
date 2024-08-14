//
//  ViewController.swift
//  paye
//
//  Created by Jay Beaudoin on 2023-01-11.
//

import UIKit

class ViewController: UIViewController {
    
    private lazy var button: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        
        btn.backgroundColor = .systemCyan
        btn.setTitle("Press here", for: .normal)
        
        btn.addTarget(self, action: #selector(openPopUp), for: .touchUpInside)
        
        return btn
    }()
    
    private lazy var popupView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.backgroundColor = .red
        
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        // Do any additional setup after loading the view.
    }
    
    private func setupConstraints() {
        self.view.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 75),
            button.heightAnchor.constraint(equalToConstant: 50)
        ])
    }


}

extension ViewController {
    @objc private func openPopUp() {
        if self.view.subviews.contains(popupView) {
            popupView.removeFromSuperview()
        } else {
            
            self.view.addSubview(popupView)
            
            NSLayoutConstraint.activate([
                popupView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 25),
                popupView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -25),
                popupView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 50),
                popupView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -50)
            ])
        }
        
    }
}

