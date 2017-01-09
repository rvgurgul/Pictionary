//
//  SizeSlider.swift
//  Pictionary
//
//  Created by Richie Gurgul on 12/8/16.
//  Copyright © 2016 Richie Gurgul. All rights reserved.
//

import Foundation
import UIKit

class SizeSlider: UIViewController
{
    @IBOutlet weak var numSlider: UISlider!
    
    var sender: SizeSliderDelegate!
    var preview = UIView()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        guard sender != nil else{
            dismiss(animated: true, completion: nil)
            return
        }
        
        numSlider.value = sender.size
        
        //Tells the slider to return to the last view when the user stops dragging it
        numSlider.addTarget(self, action: #selector(returnToSender), for: .touchUpInside)
        
        //Initializes the preview view
        preview.backgroundColor = UIColor(ciColor: sender.color)
        view.addSubview(preview)
        
        //Then updates it to the selected value
        numSliderValueChanged(self)
    }
    
    @IBAction func numSliderValueChanged(_ sender: AnyObject)
    {
        let val = CGFloat(numSlider.value)
        let size = CGSize(width: val, height: val)
        let point = CGPoint(x: view.center.x - (val/2), y: view.center.y - (val/2))
        preview.frame = CGRect(origin: point, size: size)
        preview.layer.cornerRadius = (val / 2)
    }
    
    func returnToSender()
    {
        sender.returnFromSizeSlider(numSlider.value)
        self.dismiss(animated: true, completion: nil)
    }
}
