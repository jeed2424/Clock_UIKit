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
    
    private var secondsTimer = Timer()
    
    var currentX = 250
    var currentY = 75
    
    var isGoingRight: Bool = true
    var isGoingLeft: Bool = false
    var isGoingDown: Bool = false
    var isGoingUp: Bool = false
    
    var addY: Int = 0
    var addX: Int = 0

    private var currentSecond = 0
    private var deviceDimensions = Dictionary<String, Int>()
    
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
        
        view.layer.borderWidth = 0.5
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
    
    private lazy var fullView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        print("\(deviceDimensions)")
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        setupConstraints()
        configureCornerViews()
        showSeconds()
    }
    
    private func configureCornerViews() {
        self.view.addSubview(fullView)
        
        fullView.backgroundColor = .systemRed
        fullView.alpha = 0.5
        
        print("fullview minx: \(fullView.frame.minX), fullview midx: \(fullView.frame.midX), fullview maxx: \(fullView.frame.maxX)")
        print("fullview miny: \(fullView.frame.minY), fullview midy: \(fullView.frame.midY), fullview maxy: \(fullView.frame.maxY)")
    }
    
    private func bindViewModel() {
        viewModel.$dimensions
            .receiveOnMain()
            .sink { [weak self] dimensions in
                guard let self = self else { return }
                self.deviceDimensions = dimensions ?? ["": 0]
                print("\(self.deviceDimensions)")
                self.reloadFullView()
            }.store(in: &subscriptions)
        
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
        
        viewModel.$currentSecond
            .receiveOnMain()
            .sink{ [weak self] currentSecond in
                guard let self = self, self.view.subviews.contains(self.secondsView) else { return }
                self.currentSecond = currentSecond ?? 0
                if currentSecond == 0 {
                    self.currentX = Int(self.fullView.frame.midX)-35
                    self.currentY = Int(self.fullView.frame.minY)
                    
                    self.isGoingRight = true
                    self.isGoingLeft = false
                    self.isGoingDown = false
                    self.isGoingUp = false
                    
                } else if currentSecond == 15 {
                    self.currentX = Int(self.fullView.frame.maxX)-10
                    self.currentY = Int(self.fullView.frame.midY)-35
                    
                    
                    self.isGoingRight = false
                    self.isGoingLeft = false
                    self.isGoingDown = true
                    self.isGoingUp = false
                    
                } else if currentSecond == 30 {
                    self.currentX = Int(self.fullView.frame.midX)+35
                    self.currentY = Int(self.fullView.frame.maxY)-10
                    
                    
                    self.isGoingRight = false
                    self.isGoingLeft = true
                    self.isGoingDown = false
                    self.isGoingUp = false
                    
                } else if currentSecond == 45 {
                    self.currentX = Int(self.fullView.frame.minX)
                    self.currentY = Int(self.fullView.frame.midY)+35
                    
                    
                    self.isGoingRight = false
                    self.isGoingLeft = false
                    self.isGoingDown = false
                    self.isGoingUp = true
                    
                } else {
                    self.secondsView.backgroundColor = .systemGray
                }
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
            settingsBtn.trailingAnchor.constraint(equalTo: clockTimeView.trailingAnchor, constant: 20),
            settingsBtn.topAnchor.constraint(equalTo: clockTimeView.topAnchor, constant: -20),
            settingsBtn.widthAnchor.constraint(equalToConstant: 24),
            settingsBtn.heightAnchor.constraint(equalToConstant: 24)
        ])
        
    }
    
    private func setupSecondsTimer() {
        secondsTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(getNextSecond), userInfo: nil, repeats: true)
    }
    
    @objc private func getNextSecond() {
        guard self.view.subviews.contains(secondsView) else { return }
        let toast = secondsView
        
        UIView.animate(withDuration: 0.75, animations: {
            
            toast.alpha = 0.75
            
            if (self.currentX - Int(self.fullView.frame.minX)) <= (self.addX+15) && (self.currentY - Int(self.fullView.frame.minY)) <= (self.addY+15) {
                //let addX = Int(self.fullView.frame.maxX-self.fullView.frame.minX)/20
                toast.frame = CGRect(x: self.currentX+self.addX,
                                     y: Int(self.fullView.frame.minY),
                                     width: 10,
                                     height: 10)
                
                self.currentX += self.addX
                self.currentY = Int(self.fullView.frame.minY)
                
                self.isGoingUp = false
                self.isGoingLeft = false
                self.isGoingDown = false
                
                self.isGoingRight = true
                
            } else if (abs(self.currentX - Int(self.fullView.frame.maxX))) <= (self.addX+15) && (abs(self.currentY - Int(self.fullView.frame.minY))) <= (self.addY+15) {
                //let addY = Int(self.fullView.frame.maxY-self.fullView.frame.minY)/10
                
                toast.frame = CGRect(x: Int(self.fullView.frame.maxX)-10,
                                     y: self.currentY+self.addY,
                                     width: 10,
                                     height: 10)
                
                self.currentX = Int(self.fullView.frame.maxX)-10
                self.currentY += self.addY
                
                self.isGoingUp = false
                self.isGoingRight = false
                self.isGoingLeft = false
                
                self.isGoingDown = true
                
            } else if (abs(self.currentX - Int(self.fullView.frame.maxX))) <= (self.addX+15) && (abs(self.currentY - Int(self.fullView.frame.maxY))) <= (self.addY+15) {
               // let addX = Int(self.fullView.frame.maxX-self.fullView.frame.minX)/20
                
                toast.frame = CGRect(x: self.currentX-self.addX,
                                     y: Int(self.fullView.frame.maxY)-10,
                                     width: 10,
                                     height: 10)
                
                self.currentX -= self.addX
                self.currentY = Int(self.fullView.frame.maxY)-10
                
                self.isGoingDown = false
                self.isGoingUp = false
                self.isGoingRight = false
                
                self.isGoingLeft = true
                
            } else if (abs(self.currentX - Int(self.fullView.frame.minX))) <= (self.addX+15) && (abs(self.currentY - Int(self.fullView.frame.maxY))) <= (self.addY+15) {
               // let addY = Int(self.fullView.frame.maxY-self.fullView.frame.minY)/10
                
                toast.frame = CGRect(x: Int(self.fullView.frame.minX),
                                     y: self.currentY-self.addY,
                                     width: 10,
                                     height: 10)
                
                self.currentX = Int(self.fullView.frame.minX)
                self.currentY -= self.addY
                
                self.isGoingDown = false
                self.isGoingLeft = false
                self.isGoingRight = false
                
                self.isGoingUp = true
                
            } else if self.isGoingUp {
             //   let addY = Int(self.fullView.frame.maxY-self.fullView.frame.minY)/10
                
                toast.frame = CGRect(x: self.currentX,
                                     y: self.currentY-self.addY,
                                     width: 10,
                                     height: 10)
               // self.currentX += 35
                self.currentY -= self.addY
                
            } else if self.isGoingDown {
                
               // let addY = Int(self.fullView.frame.maxY-self.fullView.frame.minY)/10

                toast.frame = CGRect(x: self.currentX,
                                     y: self.currentY+self.addY,
                                     width: 10,
                                     height: 10)
               // self.currentX += 35
                self.currentY += self.addY
                
                print("addY: \(self.addY)")
                
            } else if self.isGoingLeft {
               // let addX = Int(self.fullView.frame.maxX-self.fullView.frame.minX)/20
                
                toast.frame = CGRect(x: self.currentX-self.addX,
                                     y: self.currentY,
                                     width: 10,
                                     height: 10)
                self.currentX -= self.addX
                
            } else {
               // let addX = Int(self.fullView.frame.maxX-self.fullView.frame.minX)/20
                
                toast.frame = CGRect(x: self.currentX+self.addX,
                                     y: self.currentY,
                                     width: 10,
                                     height: 10)
                self.currentX += self.addX
            }
            
            toast.alpha = 1
            
            if self.currentSecond == 0 || self.currentSecond == 15 || self.currentSecond == 30 || self.currentSecond == 45 {
                toast.backgroundColor = .systemRed
            }
           // self.currentY += 20
            
        }, completion: { done in
            if done {
             //   toast.alpha = 1
            }
            
        })
        
        
    }
    
    private func setupSeconds() {
        
        secondsView.layer.cornerRadius = 5
        
        self.view.addSubview(secondsView)
        self.view.bringSubviewToFront(secondsView)
        
        secondsView.frame = CGRect(x: currentX,
                             y: currentY,
                             width: 10,
                             height: 10)
        
        setupSecondsTimer()
        
        //        NSLayoutConstraint.activate([
        //            secondsView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
        //            secondsView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 50),
        //            secondsView.widthAnchor.constraint(equalToConstant: 10),
        //            secondsView.heightAnchor.constraint(equalToConstant: 10)
        //        ])
        
    }
    
    private func showSeconds() {
        guard !self.view.subviews.contains(secondsView) else { return }
        
        self.setupSeconds()
    }
}

extension ViewController {
    
    private func reloadFullView() {
        guard self.view.subviews.contains(fullView) else { return }
        
        let deviceX = deviceDimensions["deviceX"]
        let deviceY = deviceDimensions["deviceY"]
        let deviceWidth = deviceDimensions["deviceWidth"]
        let deviceHeight = deviceDimensions["deviceHeight"]
        
        self.fullView.removeFromSuperview()
        self.view.addSubview(fullView)
        self.fullView.frame = CGRect(x: deviceX ?? 0, y: deviceY ?? 0, width: deviceWidth ?? 0, height: deviceHeight ?? 0)
        
        
        addY = (Int(self.fullView.frame.maxY-self.fullView.frame.minY)/10)-3
        addX = (Int(self.fullView.frame.maxX-self.fullView.frame.minX)/20)-2
        
        print("addX: \(addX), addY: \(addY)")
    }
    
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
        if !self.view.subviews.contains(settingsOverlayView) {
            
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
        } else if self.view.subviews.contains(settingsOverlayView) {
            settingsOverlayView.removeFromSuperview()
        }
    }
}

