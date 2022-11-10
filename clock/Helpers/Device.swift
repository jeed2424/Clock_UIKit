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
            fallthrough
        case .iPhone7Plus:
            print("Put your thumb on the " +
                  UIDevice().type.rawValue + " TouchID sensor")
        case .iPhone8:
            return ["deviceX": 30, "deviceY": 25, "deviceWidth": 600, "deviceHeight": 330]
        case .iPhone8Plus:
            fallthrough
        case .iPhone14:
            fallthrough
        case .iPhone14Pro:
            return ["deviceX": 50, "deviceY": 25, "deviceWidth": 740, "deviceHeight": 340]
        case .unrecognized:
            print("Device model unrecognized");
        default:
            print(UIDevice().type.rawValue + " not supported by this app");
            return ["deviceX": 0, "deviceY": 0, "deviceWidth": 150, "deviceHeight": 150]
        }
        return ["deviceX": 0, "deviceY": 0, "deviceWidth": 150, "deviceHeight": 150]
    }
}
