//
//  ViewController.swift
//  Pictionary
//
//  Created by Richie Gurgul on 12/6/16.
//  Copyright © 2016 Richie Gurgul. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{
    override var prefersStatusBarHidden: Bool {return true}
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad(){
        super.viewDidLoad()
                delegate.load()
    }
    
    @IBAction func drawingArchives(_ sender: AnyObject){
        let alert = UIAlertController(title: "There are currently \(delegate.drawings.count) drawings saved.", message: "You cannot view them...yet", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

