//
//  DrawingPanel.swift
//  Pictionary
//
//  Created by Richie Gurgul on 12/6/16.
//  Copyright © 2016 Richie Gurgul. All rights reserved.
//

import Foundation
import UIKit

class DrawingPanel: UIViewController, ColorPickerDelegate, UITextFieldDelegate
{
    override var prefersStatusBarHidden: Bool {return true}
    
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var botBar: UIToolbar!
    @IBOutlet weak var panel: UIView!
 
    var colorPickerItem: UIBarButtonItem!
    var brushStrokes: [CAShapeLayer]!
    var undoIndices: [Int]!
    var brushColor: CGColor!
    var brushSize: CGFloat!
    var drawing: Drawing!
    var doubleTap = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        brushStrokes = [CAShapeLayer]()
        undoIndices = [Int]()
        brushColor = UIColor.black.cgColor
        brushSize = 15
        
        navBar.title = "..."
        
        setupBrushes()
        
        Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(wordAlert), userInfo: nil, repeats: false)
    }
    
    func wordAlert()
    {
        let alert = UIAlertController(title: "What are you going to draw?", message: "Make sure your friends don't see this screen!", preferredStyle: .alert)
        alert.addTextField
        {   (field) in
            field.placeholder = "Phrase"
        }
        alert.textFields?[0].delegate = self
        alert.addAction(UIAlertAction(title: "Draw!", style: .default, handler:
        {   (action) in
            self.drawing = Drawing((alert.textFields?[0].text!)!)
            self.navBar.title = self.drawing.name
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        guard let text = textField.text else {return true}
        let newLength = text.characters.count + string.characters.count - range.length
        return newLength <= 17
    }
    
    func returnFromColorPicker(_ color: UIColor)
    {
        colorPickerItem.tintColor = color
        brushColor = color.cgColor
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        touchesMoved(touches, with: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        if let touch = touches.first
        //for touch in touches
        {
            let loc = touch.location(in: panel)
            let dot = UIBezierPath(ovalIn: CGRect(x: loc.x, y: loc.y, width: brushSize, height: brushSize))
            
            let layer = CAShapeLayer()
            layer.path = dot.cgPath
            layer.strokeColor = brushColor
            layer.fillColor = brushColor
            
            brushStrokes.append(layer)
            panel.layer.addSublayer(layer)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        undoIndices.append(brushStrokes.count)
    }
    
    @IBAction func toolsButton(_ sender: AnyObject)
    {
        let tools = UIAlertController(title: "Tools", message: nil, preferredStyle: .actionSheet)
        tools.addAction(UIAlertAction(title: "Clear", style: .destructive, handler:
        {   (action) in
            self.clearPanel()
        }))
        tools.addAction(UIAlertAction(title: "Undo", style: .destructive, handler:
        {   (action) in
            self.undoLast()
        }))
        tools.addAction(UIAlertAction(title: "Brush Size", style: .default, handler:
        {   (action) in
            self.chooseBrushSize()
        }))
        tools.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(tools, animated: true, completion: nil)
    }
    
    func setupBrushes()
    {
        var items = [UIBarButtonItem]()
        let colors: [UIColor] = [.red, .orange, .yellow, .green, .blue, .purple]
        
        for color in colors
        {
            let item = UIBarButtonItem(image: #imageLiteral(resourceName: "paint-brush"), style: .plain, target: self, action: #selector(chooseBrush(sender:)))
            item.tintColor = color
            items.append(item)
            
            let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
            items.append(space)
        }
        
        colorPickerItem = UIBarButtonItem(image: #imageLiteral(resourceName: "paint-brush"), style: .plain, target: self, action: #selector(chooseColor(sender:)))
        colorPickerItem.tintColor = .black
        items.append(colorPickerItem)
        
        botBar.setItems(items, animated: true)
    }
    
    func clearPanel()
    {
        for layer in brushStrokes
        {
            layer.removeFromSuperlayer()
        }
    }
    
    func undoLast()
    {
        if undoIndices.count > 0
        {
            undoIndices.removeLast()
            if let index = undoIndices.last
            {
                while index != brushStrokes.count
                {
                    brushStrokes[index].removeFromSuperlayer()
                    brushStrokes.remove(at: index)
                }
            }
            else
            {
                clearPanel()
            }
        }
    }
    
    func chooseBrushSize()
    {
        /*if let VC = storyboard?.instantiateViewController(withIdentifier: "SizeSlider")
        {
            VC.modalTransitionStyle = .partialCurl
            VC.modalPresentationStyle = .overCurrentContext
        }*/
    }
    
    func chooseColor(sender: UIBarButtonItem)
    {
        if !doubleTap
        {
            brushColor = sender.tintColor?.cgColor
            doubleTap = true
            return
        }
        
        if let VC = storyboard?.instantiateViewController(withIdentifier: "ColorPicker") as? ColorPicker
        {
            VC.modalTransitionStyle = .crossDissolve
            VC.modalPresentationStyle = .overCurrentContext
            VC.sender = self
            
            present(VC, animated: true, completion: nil)
        }
    }
    
    func chooseBrush(sender: UIBarButtonItem)
    {
        doubleTap = false
        brushColor = sender.tintColor?.cgColor
    }
}
