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
    
    private lazy var secondsOutline: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        print("\(deviceDimensions)")
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        configure()
    }
    
    private func configureSecondsOutline() {
        self.view.addSubview(secondsOutline)
        
        secondsOutline.backgroundColor = .systemRed
        secondsOutline.alpha = 0.5
    }
    
    private func configure() {
        addSettingsGesture()
        setupConstraints()
        configureSecondsOutline()
        showSeconds()
    }
    
    private func bindViewModel() {
        
        viewModel.$currentSecond
            .receiveOnHigh()
            .sink{ [weak self] currentSecond in
                guard let self = self else { return }
                self.currentSecond = currentSecond ?? 0

                DispatchQueue.main.async {
                guard self.view.subviews.contains(self.secondsView) else { return }
                    if currentSecond == 0 {
                        self.currentX = Int(self.secondsOutline.frame.midX)-35
                        self.currentY = Int(self.secondsOutline.frame.minY)
                        
                        self.isGoingRight = true
                        self.isGoingLeft = false
                        self.isGoingDown = false
                        self.isGoingUp = false
                        
                    } else if currentSecond == 15 {
                        self.currentX = Int(self.secondsOutline.frame.maxX)-10
                        self.currentY = Int(self.secondsOutline.frame.midY)-35
                        print("currentX  at 30 secs: \(self.currentY)")
                        
                        self.isGoingRight = false
                        self.isGoingLeft = false
                        self.isGoingDown = true
                        self.isGoingUp = false
                        
                    } else if currentSecond == 30 {
                        self.currentX = Int(self.secondsOutline.frame.midX)+35
                        self.currentY = Int(self.secondsOutline.frame.maxY)-10
                        
                        self.isGoingRight = false
                        self.isGoingLeft = true
                        self.isGoingDown = false
                        self.isGoingUp = false
                        
                    } else if currentSecond == 45 {
                        self.currentX = Int(self.secondsOutline.frame.minX)
                        self.currentY = Int(self.secondsOutline.frame.midY)+35
                        
                        
                        self.isGoingRight = false
                        self.isGoingLeft = false
                        self.isGoingDown = false
                        self.isGoingUp = true
                        
                    } else {
                        self.secondsView.backgroundColor = .systemGray
                    }
                }

            }.store(in: &subscriptions)
        
        viewModel.$dimensions
            .receiveOnMain()
            .sink { [weak self] dimensions in
                guard let self = self else { return }
                self.deviceDimensions = dimensions ?? ["": 0]
                print("\(self.deviceDimensions)")
                self.loadSettingsBtn()
                self.reloadSecondsOutline()
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
        
    }
    
    private func setupSecondsTimer() {
        secondsTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(getNextSecond), userInfo: nil, repeats: true)
    }
    
    @objc private func getNextSecond() {
        guard self.view.subviews.contains(secondsView) else { return }
        let toast = secondsView
        
        UIView.animate(withDuration: 0.75, animations: {
            
            toast.alpha = 0.75
            
            if (self.currentX - Int(self.secondsOutline.frame.minX)) <= (self.addX+15) && (self.currentY - Int(self.secondsOutline.frame.minY)) <= (self.addY+15) {
                //let addX = Int(self.secondsOutline.frame.maxX-self.secondsOutline.frame.minX)/20
                toast.frame = CGRect(x: self.currentX+self.addX,
                                     y: Int(self.secondsOutline.frame.minY),
                                     width: 10,
                                     height: 10)
                
                self.currentX += self.addX
                self.currentY = Int(self.secondsOutline.frame.minY)
                
                self.isGoingUp = false
                self.isGoingLeft = false
                self.isGoingDown = false
                
                self.isGoingRight = true
                
            } else if (abs(self.currentX - Int(self.secondsOutline.frame.maxX))) <= (self.addX+15) && (abs(self.currentY - Int(self.secondsOutline.frame.minY))) <= (self.addY+15) {
                //let addY = Int(self.secondsOutline.frame.maxY-self.secondsOutline.frame.minY)/10
                
                toast.frame = CGRect(x: Int(self.secondsOutline.frame.maxX)-10,
                                     y: self.currentY+self.addY,
                                     width: 10,
                                     height: 10)
                
                self.currentX = Int(self.secondsOutline.frame.maxX)-10
                self.currentY += self.addY
                
                self.isGoingUp = false
                self.isGoingRight = false
                self.isGoingLeft = false
                
                self.isGoingDown = true
                
            } else if (abs(self.currentX - Int(self.secondsOutline.frame.maxX))) <= (self.addX+15) && (abs(self.currentY - Int(self.secondsOutline.frame.maxY))) <= (self.addY+15) {
               // let addX = Int(self.secondsOutline.frame.maxX-self.secondsOutline.frame.minX)/20
                
                toast.frame = CGRect(x: self.currentX-self.addX,
                                     y: Int(self.secondsOutline.frame.maxY)-10,
                                     width: 10,
                                     height: 10)
                
                self.currentX -= self.addX
                self.currentY = Int(self.secondsOutline.frame.maxY)-10
                
                self.isGoingDown = false
                self.isGoingUp = false
                self.isGoingRight = false
                
                self.isGoingLeft = true
                
            } else if (abs(self.currentX - Int(self.secondsOutline.frame.minX))) <= (self.addX+15) && (abs(self.currentY - Int(self.secondsOutline.frame.maxY))) <= (self.addY+15) {
               // let addY = Int(self.secondsOutline.frame.maxY-self.secondsOutline.frame.minY)/10
                
                toast.frame = CGRect(x: Int(self.secondsOutline.frame.minX),
                                     y: self.currentY-self.addY,
                                     width: 10,
                                     height: 10)
                
                self.currentX = Int(self.secondsOutline.frame.minX)
                self.currentY -= self.addY
                
                self.isGoingDown = false
                self.isGoingLeft = false
                self.isGoingRight = false
                
                self.isGoingUp = true
                
            } else if self.isGoingUp {
             //   let addY = Int(self.secondsOutline.frame.maxY-self.secondsOutline.frame.minY)/10
                
                toast.frame = CGRect(x: self.currentX,
                                     y: self.currentY-self.addY,
                                     width: 10,
                                     height: 10)
               // self.currentX += 35
                self.currentY -= self.addY
                
            } else if self.isGoingDown {
                
               // let addY = Int(self.secondsOutline.frame.maxY-self.secondsOutline.frame.minY)/10

                toast.frame = CGRect(x: self.currentX,
                                     y: self.currentY+self.addY,
                                     width: 10,
                                     height: 10)
               // self.currentX += 35
                self.currentY += self.addY
                                
            } else if self.isGoingLeft {
               // let addX = Int(self.secondsOutline.frame.maxX-self.secondsOutline.frame.minX)/20
                
                toast.frame = CGRect(x: self.currentX-self.addX,
                                     y: self.currentY,
                                     width: 10,
                                     height: 10)
                self.currentX -= self.addX
                
            } else {
               // let addX = Int(self.secondsOutline.frame.maxX-self.secondsOutline.frame.minX)/20
                
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
                print("currentSecond: \(self.currentSecond), CurrentY: \(self.currentY)")
             //   toast.alpha = 1
            }
            
        })
        
        
    }
    
    private func setupSeconds() {
        DispatchQueue.main.asyncAfter(1, action: {
            self.secondsView.layer.cornerRadius = 5
            
            self.view.addSubview(self.secondsView)
            self.view.bringSubviewToFront(self.secondsView)
            
            let second = 15
            print("Seconds: \(second)")
            
            if (second >= 51 && second <= 59) || (second >= 0 && second <= 10) {

                if second >= 0 && second <= 10 {
                    self.currentX = Int(self.secondsOutline.frame.midX)-35+(self.addX*second)
                    print("\(self.currentX)")
                    
                } else {
                    self.currentX = ((Int(self.secondsOutline.frame.midX)-35)-(self.addX*second))
                }
                
                self.isGoingRight = true
                self.isGoingLeft = false
                self.isGoingDown = false
                self.isGoingUp = false

            } else if second >= 11 && second <= 20 {
                let secondValue = self.viewModel.getSecondsValue(direction: .down,
                                                                 startOfLine: 11,
                                                                 currentSeconds: second)
                let value = Int(self.secondsOutline.frame.minY)-20
                print("Value: \(value)")
                let value2 = self.addY*secondValue
                
                self.currentY = (value+value2)+self.addY// (Int(self.secondsOutline.frame.minY)+35)+(self.addY*secondValue) // secondValue
                self.currentX = Int(self.secondsOutline.frame.maxX)-10
                
                print("currentY at start: \(self.currentY)")
                print("addY: \(self.addY)")
                
                self.secondsView.frame = CGRect(x: self.currentX,
                                                y: self.currentY,
                                                width: 10,
                                                height: 10)
                
                self.isGoingRight = false
                self.isGoingLeft = false
                self.isGoingDown = true
                self.isGoingUp = false
                
            } else if second >= 21 && second <= 40 {
                let secondValue = self.viewModel.getSecondsValue(direction: .left,
                                                                 startOfLine: 21,
                                                                 currentSeconds: second)

                // currentX = ((Int(secondsOutline.frame.midX)-35)-(addX*second))
                
                self.currentX = (Int(self.secondsOutline.frame.maxX)+35)-(self.addX*second)
                //(Int(self.secondsOutline.frame.minY)+35)+(self.addX*secondValue)
                self.currentY = Int(self.secondsOutline.frame.maxY)-10
                
                self.secondsView.frame = CGRect(x: self.currentX,
                                                y: self.currentY,
                                                width: 10,
                                                height: 10)
                
                
                self.isGoingRight = false
                self.isGoingLeft = true
                self.isGoingDown = false
                self.isGoingUp = false

            } else if second >= 41 && second <= 50 {
                
                let secondValue = self.viewModel.getSecondsValue(direction: .up,
                                                                 startOfLine: 41,
                                                                 currentSeconds: second)
                let value = Int(self.secondsOutline.frame.maxY)+20
                print("Value: \(value)")
                let value2 = self.addY*secondValue
                
                self.currentY = abs(value-value2)// (Int(self.secondsOutline.frame.minY)+35)+(self.addY*secondValue) // secondValue
                self.currentX = Int(self.secondsOutline.frame.maxX)-10
                
                print("currentY at start: \(self.currentY)")
                print("addY: \(self.addY)")
                
                self.secondsView.frame = CGRect(x: self.currentX,
                                                y: self.currentY,
                                                width: 10,
                                                height: 10)
                
                self.isGoingRight = false
                self.isGoingLeft = false
                self.isGoingDown = false
                self.isGoingUp = true

            }
            
            self.setupSecondsTimer()
        })
    }
    
    private func showSeconds() {
        guard !self.view.subviews.contains(secondsView) else { return }
        
        self.setupSeconds()
    }
}

extension ViewController {
    
    private func addSettingsGesture() {
        // Initialize Swipe Gesture Recognizer
          let openSettingsGesture = UITapGestureRecognizer(target: self, action: #selector(openSettings))

          // Configure Swipe Gesture Recognizer
        openSettingsGesture.numberOfTapsRequired = 1

          // Add Swipe Gesture Recognizer
        self.secondsOutline.addGestureRecognizer(openSettingsGesture)
    }
    
    private func loadSettingsBtn() {
        let settingsTrailing = deviceDimensions["settingsTrailing"]
        let settingsTop = deviceDimensions["settingsTop"]
        
        NSLayoutConstraint.activate([
            settingsBtn.trailingAnchor.constraint(equalTo: clockTimeView.trailingAnchor, constant: CGFloat(settingsTrailing ?? 0)),
            settingsBtn.topAnchor.constraint(equalTo: clockTimeView.topAnchor, constant: CGFloat(settingsTop ?? 0)),
            settingsBtn.widthAnchor.constraint(equalToConstant: 24),
            settingsBtn.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        print("trailing: \(settingsTrailing), top: \(settingsTop)")
    }
    
    private func reloadSecondsOutline() {
        guard self.view.subviews.contains(secondsOutline) else { return }
        
        let secondsOutlineX = deviceDimensions["secondsOutlineX"]
        let secondsOutlineY = deviceDimensions["secondsOutlineY"]
        let secondsOutlineWidth = deviceDimensions["secondsOutlineWidth"]
        let secondsOutlineHeight = deviceDimensions["secondsOutlineHeight"]
        
        self.secondsOutline.removeFromSuperview()
        self.view.addSubview(secondsOutline)
        self.secondsOutline.frame = CGRect(x: secondsOutlineX ?? 0, y: secondsOutlineY ?? 0, width: secondsOutlineWidth ?? 0, height: secondsOutlineHeight ?? 0)
        
        
        addY = (Int(self.secondsOutline.frame.maxY-self.secondsOutline.frame.minY)/10)-3
        addX = (Int(self.secondsOutline.frame.maxX-self.secondsOutline.frame.minX)/20)-2
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

