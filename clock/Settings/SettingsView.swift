//
//  settingsView.swift
//  clock
//
//  Created by Jay Beaudoin on 2022-11-07.
//

import Foundation
import UIKit
import Combine

class SettingsView: UIView {
    
    // "checkmark.diamond"
    // "checkmark.diamond.fill"
    private let viewModel: SettingsViewModel
    
    private var subscriptions = Set<AnyCancellable>()
    public var exitPassthrough = PassthroughSubject<Void, Never>()
    
    private lazy var exitBtn: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let image = UIImage(systemName: "x.circle")
        image?.withRenderingMode(.alwaysTemplate)
        image?.withTintColor(.systemCyan)
        
        button.setImage(image, for: .normal)
        
        button.addTarget(self, action: #selector(exitSettings), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var saveBtn: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.setTitle("Save", for: .normal)
        button.setTitleColor(.black, for: .normal)
        
        button.backgroundColor = .systemCyan
        
        button.layer.cornerRadius = 12
        
        button.addTarget(self, action: #selector(exitSettings), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var showDateBtn: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.setTitle("Enable date?", for: .normal)
        
        button.addTarget(self, action: #selector(setEnableDate), for: .touchUpInside)
        
        return button
    }()
    
    init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        
        self.backgroundColor = .systemGray.withAlphaComponent(0.5)
        
        bindViewModel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupConstraints() {
        addSubview(exitBtn)
        addSubview(showDateBtn)
        addSubview(saveBtn)
        
        NSLayoutConstraint.activate([
            exitBtn.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            exitBtn.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            exitBtn.widthAnchor.constraint(equalToConstant: 18),
            exitBtn.heightAnchor.constraint(equalToConstant: 18)
        ])
        
        NSLayoutConstraint.activate([
            showDateBtn.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 25),
            showDateBtn.topAnchor.constraint(equalTo: topAnchor, constant: 25)
        ])
        
        NSLayoutConstraint.activate([
            saveBtn.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            saveBtn.widthAnchor.constraint(equalToConstant: 50),
            saveBtn.heightAnchor.constraint(equalToConstant: 25),
            saveBtn.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
        
    }
    
    @objc private func exitSettings() {
        exitPassthrough.send()
    }
    
    private func bindViewModel() {
        viewModel.$didEnableDate
            .receiveOnMain()
            .sink{ [weak self] didEnableDate in
                guard let self = self else { return }
                let imageOn = UIImage(systemName: "checkmark.diamond.fill")?.withRenderingMode(.alwaysTemplate).withTintColor(.systemCyan)
                let imageOff = UIImage(systemName: "checkmark.diamond")?.withRenderingMode(.alwaysTemplate).withTintColor(.systemCyan)
                
                self.showDateBtn.setImage(didEnableDate ?? false ? imageOn : imageOff, for: .normal)
            }.store(in: &subscriptions)
    }
    
}

extension SettingsView {
    @objc private func setEnableDate() {
        viewModel.didEnableDate?.toggle()
    }
}
