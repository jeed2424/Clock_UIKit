//
//  ViewController.swift
//  clock
//
//  Created by Jay Beaudoin on 2022-11-07.
//

import UIKit
import Combine

class ViewController: UIViewController {
    
    // MARK: - Constants
    private let viewModel = MainViewModel()
    
    // MARK: - Variables
    private var subscriptions = Set<AnyCancellable>()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    private lazy var clockTimeView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.backgroundColor = .systemBackground
        
        return view
    }()
    
    private lazy var clockTimeLbl: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.font = .systemFont(ofSize: 72, weight: .medium)
        
        label.textAlignment = .center
        
        label.textColor = .systemCyan
        
        return label
    }()
    
    private lazy var secondsView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.backgroundColor = .systemGray
        
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.systemRed.cgColor
        
        return view
    }()
    
    private lazy var dateLbl: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.font = .systemFont(ofSize: 24, weight: .medium)
        
        label.textAlignment = .center
        
        label.textColor = .systemCyan
        
        return label
    }()

    
    private lazy var settingsBtn: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let settingsIcon = UIImage(named: "settingsIcon")?.withTintColor(.systemCyan)
        
        button.setImage(settingsIcon, for: .normal)
        
        button.addTarget(self, action: #selector(openSettings), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var settingsOverlayView: SettingsView = {
        let view = SettingsView(viewModel: .init())
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
        setupConstraints()
//        setupSeconds()
    }
    
    private func bindViewModel() {
        viewModel.$currentTime
            .receiveOnMain()
            .sink{ [weak self] currentTime in
                guard let self = self else { return }
                self.clockTimeLbl.text = currentTime
            }.store(in: &subscriptions)
        
        viewModel.$currentDate
            .receiveOnMain()
            .sink{ [weak self] currentDate in
                guard let self = self else { return }
                self.dateLbl.text = currentDate
            }.store(in: &subscriptions)
        
        viewModel.$showDate
            .receiveOnMain()
            .sink{ [weak self] showDate in
                guard let self = self else { return }
                if showDate {
                    self.addDateToView()
                } else {
                    self.removeDateFromView()
                }
            }.store(in: &subscriptions)
    }
    
    private func setupConstraints() {
        view.addSubview(clockTimeView)
        clockTimeView.addSubview(clockTimeLbl)
        view.addSubview(settingsBtn)
        
        NSLayoutConstraint.activate([
            clockTimeView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            clockTimeView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
            clockTimeView.topAnchor.constraint(equalTo: view.topAnchor, constant: 25),
            clockTimeView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -25)
        ])
        
        NSLayoutConstraint.activate([
            clockTimeLbl.leadingAnchor.constraint(equalTo: clockTimeView.leadingAnchor, constant: 25),
            clockTimeLbl.trailingAnchor.constraint(equalTo: clockTimeView.trailingAnchor, constant: -25),
            clockTimeLbl.topAnchor.constraint(equalTo: clockTimeView.topAnchor, constant: 75),
            clockTimeLbl.bottomAnchor.constraint(equalTo: clockTimeView.bottomAnchor, constant: -75)
        ])
        
        NSLayoutConstraint.activate([
            settingsBtn.trailingAnchor.constraint(equalTo: clockTimeView.trailingAnchor),
            settingsBtn.topAnchor.constraint(equalTo: clockTimeView.topAnchor),
            settingsBtn.widthAnchor.constraint(equalToConstant: 24),
            settingsBtn.heightAnchor.constraint(equalToConstant: 24)
        ])
        
    }
    
    private func setupSeconds() {
        var views = [UIView]()
                
        let currentLeading = clockTimeView.leadingAnchor
        var leadingConstant = 5
        
        for _ in 0..<60 {
            views.append(secondsView)
            print("\(views.count)")
        }
        
        views.forEach({ secondView in
            secondView.layer.cornerRadius = 6
                        
            self.clockTimeView.addSubview(secondView)
            self.clockTimeView.bringSubviewToFront(secondView)
            
            NSLayoutConstraint.activate([
                secondView.leadingAnchor.constraint(equalTo: clockTimeView.leadingAnchor, constant: CGFloat(leadingConstant)),
                secondView.topAnchor.constraint(equalTo: clockTimeView.topAnchor, constant: 50),
                secondView.widthAnchor.constraint(equalToConstant: 15),
                secondView.heightAnchor.constraint(equalToConstant: 25)
            ])
            
            leadingConstant += 5
            print("\(leadingConstant)")
        })
    }
    
    
}

extension ViewController {
    
    private func addDateToView() {
        guard !self.clockTimeView.subviews.contains(dateLbl) else { return }
        
        clockTimeView.addSubview(dateLbl)
        
        NSLayoutConstraint.activate([
            dateLbl.leadingAnchor.constraint(equalTo: clockTimeView.leadingAnchor, constant: 150),
            dateLbl.trailingAnchor.constraint(equalTo: clockTimeView.trailingAnchor, constant: -150),
            dateLbl.bottomAnchor.constraint(equalTo: clockTimeLbl.topAnchor, constant: 25)
        ])
    }
    
    private func removeDateFromView() {
        guard self.clockTimeView.subviews.contains(dateLbl) else { return }
        
        dateLbl.removeFromSuperview()
        
    }
    
    private func initSettingsView() {
        let settingsView = settingsOverlayView
        view.addSubview(settingsView)
        self.view.bringSubviewToFront(settingsView)
        settingsView.setupConstraints()
        
        settingsView.alpha = 0
        
        NSLayoutConstraint.activate([
            settingsView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
            settingsView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 25),
            settingsView.widthAnchor.constraint(equalToConstant: view.frame.width/2.5),
            settingsView.heightAnchor.constraint(equalToConstant: view.frame.height/1.25)
        ])
                
        settingsView.exitPassthrough
            .sink{ [weak self] _ in
                DispatchQueue.main.asyncAfter(deadline: .now()+0.25, execute: {
                    UIView.animate(withDuration: 0.5, animations: {
                        settingsView.alpha = 0
                    }, completion: { finished in
                        if finished {
                            settingsView.removeFromSuperview()
                            self?.viewModel.loadSettings()
                            self?.cancellables.removeAll()
                        }
                    })
                })
            }.store(in: &cancellables)
    }
    
    @objc private func openSettings() {
        guard !self.view.subviews.contains(settingsOverlayView) else { return }
                
        initSettingsView()
        
        let settingsView = settingsOverlayView
                
        DispatchQueue.main.asyncAfter(deadline: .now()+0.25, execute: {
            UIView.animate(withDuration: 0.5, animations: {
                
                settingsView.alpha = 1
                
            }, completion: { done in
                if done {

                }
            })
        })
    }
}

