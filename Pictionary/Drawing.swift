//
//  Drawing.swift
//  Pictionary
//
//  Created by Richie Gurgul on 12/7/16.
//  Copyright © 2016 Richie Gurgul. All rights reserved.
//

import Foundation
import UIKit

class Drawing: NSObject, NSCoding
{
    var view: UIView!
    var name: String!
    
    init(_ name: String)
    {
        self.name = name
    }
    
    override init()
    {
        self.name = ""
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        view = aDecoder.decodeObject(forKey: "view") as! UIView
        name = aDecoder.decodeObject(forKey: "name") as! String
    }
    
    func encode(with aCoder: NSCoder)
    {
        aCoder.encode(view, forKey: "view")
        aCoder.encode(name, forKey: "name")
    }
}
