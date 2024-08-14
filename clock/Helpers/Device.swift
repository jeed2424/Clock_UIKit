//
//  Device.swift
//  clock
//
//  Created by Jay Beaudoin on 2022-11-09.
//

import Foundation
import UIKit

class Device {
    
    var deviceDimensions = Dictionary<Int, Double>()
    
    func getDimensions() ->  Dictionary<String, Int> {
        switch UIDevice().type {
        case .iPhone6:
            fallthrough
        case .iPhone6Plus:
            fallthrough
        case .iPhone7:
            return ["secondsOutlineX": 30, "secondsOutlineY": 25, "secondsOutlineWidth": 600, "secondsOutlineHeight": 330, "settingsTrailing": 20, "settingsTop": -20]
        case .iPhone7Plus:
            print("Put your thumb on the " +
                  UIDevice().type.rawValue + " TouchID sensor")
        case .iPhone8:
            return ["secondsOutlineX": 30, "secondsOutlineY": 25, "secondsOutlineWidth": 600, "secondsOutlineHeight": 330, "settingsTrailing": 20, "settingsTop": -20]
        case .iPhone8Plus:
            fallthrough
        case .iPhone14:
            return ["secondsOutlineX": 40, "secondsOutlineY": 15, "secondsOutlineWidth": 760, "secondsOutlineHeight": 360, "settingsTrailing": 5, "settingsTop": -5]
        case .iPhone14Pro:
            return ["secondsOutlineX": 50, "secondsOutlineY": 15, "secondsOutlineWidth": 740, "secondsOutlineHeight": 360, "settingsTrailing": 5, "settingsTop": -5]
        case .unrecognized:
            print("Device model unrecognized");
        default:
            print(UIDevice().type.rawValue + " not supported by this app");
            return ["secondsOutlineX": 0, "secondsOutlineY": 0, "secondsOutlineWidth": 150, "secondsOutlineHeight": 150]
        }
        return ["secondsOutlineX": 0, "secondsOutlineY": 0, "secondsOutlineWidth": 150, "secondsOutlineHeight": 150]
    }
}
