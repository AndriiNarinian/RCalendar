//
//  Constants.swift
//  RoliqueCalendar
//
//  Created by Andrii Narinian on 9/25/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import UIKit

public typealias VC = UIViewController

let kEventFetchTimeInterval: TimeInterval = 3600 * 24 * 365 / 12
let kScrollEffectVelocityLimit: CGFloat = 20
let kScrollEffectDeviationMultiplier: CGFloat = 1.4

let defaultMinDate = Date().addingTimeInterval(-kEventFetchTimeInterval).withoutTime
let defaultMaxDate = Date().addingTimeInterval(kEventFetchTimeInterval).withoutTime

let bundle = Bundle(identifier: "io.rolique.RoCalendar")
