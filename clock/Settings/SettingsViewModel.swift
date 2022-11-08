//
//  SettingsViewModel.swift
//  clock
//
//  Created by Jay Beaudoin on 2022-11-08.
//

import Foundation
import Combine

class SettingsViewModel: ObservableObject {
    
    let defaults = UserDefaults.standard
    
    @Published var didEnableDate: Bool? {
        didSet {
            defaults.set(didEnableDate, forKey: "didEnableDate")
            defaults.synchronize()
        }
    }
    
    init() {
        getUserDefaults()
    }
    
    private func getUserDefaults() {
        didEnableDate = defaults.bool(forKey: "didEnableDate")
    }
}
