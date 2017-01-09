//
//  ColorPicker.swift
//  Pictionary
//
//  Created by Richie Gurgul on 12/7/16.
//  Copyright © 2016 Richie Gurgul. All rights reserved.
//

import Foundation
import UIKit

class ColorPicker: UIViewController
{
    @IBOutlet weak var rSlider: UISlider!
    @IBOutlet weak var gSlider: UISlider!
    @IBOutlet weak var bSlider: UISlider!
    @IBOutlet weak var doneButton: UIButton!
    
    override var prefersStatusBarHidden: Bool {return true}
    
    var sender: ColorPickerDelegate!
    var color = UIColor.black
    
    //Using a tuple, the color updates are easier to recognize and update things to reflect changes
    var rgb: (Float, Float, Float) = (0.0, 0.0, 0.0)
    {
        didSet
        {
            color = UIColor(colorLiteralRed: rgb.0, green: rgb.1, blue: rgb.2, alpha: 1)
            rSlider.thumbTintColor = color
            gSlider.thumbTintColor = color
            bSlider.thumbTintColor = color
            doneButton.backgroundColor = color
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        guard sender != nil else
        {
            dismiss(animated: true, completion: nil)
            return
        }
        
        let input: CIColor = sender.color
        let r = Float(input.red)
        let g = Float(input.green)
        let b = Float(input.blue)
        rgb = (r, g, b)
        rSlider.value = r
        gSlider.value = g
        bSlider.value = b
        
        //Makes the button circular
        doneButton.layer.cornerRadius = 25
    }
    
    @IBAction func redUpdate(_ sender: UISlider)
    {
        rgb.0 = sender.value
    }
    
    @IBAction func greenUpdate(_ sender: UISlider)
    {
        rgb.1 = sender.value
    }
    
    @IBAction func blueUpdate(_ sender: UISlider)
    {
        rgb.2 = sender.value
    }
    
    @IBAction func doneButton(_ sender: UIButton)
    {
        self.sender.returnFromColorPicker(color)
        self.dismiss(animated: true, completion: nil)
    }
}
