//
//  MainViewModel.swift
//  clock
//
//  Created by Jay Beaudoin on 2022-11-07.
//

import Foundation
import Combine

class MainViewModel: ObservableObject {
    
    let defaults = UserDefaults.standard
    
    var timer = Timer()

    @Published var currentTime: String = ""
    @Published var currentDate: String = ""
    @Published var showDate: Bool = false
    
    // MARK: - Life Cycle
    init() {
        scheduledTimerWithTimeInterval()
        getCurrentDate()
        loadSettings()
    }
    
    func loadSettings() {
        if let savedArray = defaults.object(forKey: "didEnableDate") as? Bool {
            print("\(savedArray)")
            showDate = savedArray
        } else {
            defaults.set(false, forKey: "didEnableDate")
        }
        
    }
    
    func scheduledTimerWithTimeInterval(){
        // Scheduling timer to Call the function "updateCounting" with the interval of 1 seconds
        timer = Timer.scheduledTimer(timeInterval:1 , target: self, selector: #selector(getCurrentTime), userInfo: nil, repeats: true)        
    }
    
    @objc private func getCurrentTime() {
        let mytime = Date()
        let format = DateFormatter()
        format.timeStyle = .medium
        format.timeZone = .autoupdatingCurrent
        format.dateStyle = .none
        currentTime = (format.string(from: mytime))
    }
    
    private func getCurrentDate() {
        let myDate = Date()
        let format = DateFormatter()
        format.timeStyle = .none
        format.dateStyle = .long
        currentDate = (format.string(from: myDate))
    }
}
