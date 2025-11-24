//
// -----------------------------------------
// Original project: Asteroids
// Original package: Asteroids
// Created on: 24/11/2025 by: Steven Barnett
// Web: http://www.sabarnett.co.uk
// GitHub: https://www.github.com/sabarnett
// -----------------------------------------
// Copyright © 2025 Steven Barnett. All rights reserved.
//

import Foundation

extension TimeInterval {
    func stringFormatted() -> String {
        let interval = Int(self)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        let hours = (interval / (60*60)) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
