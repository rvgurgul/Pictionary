//
//  ColorPickerDelegate.swift
//  Pictionary
//
//  Created by Richie Gurgul on 12/7/16.
//  Copyright © 2016 Richie Gurgul. All rights reserved.
//

import Foundation
import UIKit

protocol ColorPickerDelegate
{
    var color: CIColor {get}
    func returnFromColorPicker(_ color: UIColor)
}
