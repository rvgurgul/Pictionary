//
//  SizeSliderDelegate.swift
//  Pictionary
//
//  Created by Richie Gurgul on 12/8/16.
//  Copyright © 2016 Richie Gurgul. All rights reserved.
//

import Foundation
import UIKit

protocol SizeSliderDelegate
{
    var size: Float {get}
    var color: CIColor {get}
    func returnFromSizeSlider(_ value: Float)
}
