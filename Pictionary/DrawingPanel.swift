//
//  DrawingPanel.swift
//  Pictionary
//
//  Created by Richie Gurgul on 12/6/16.
//  Copyright © 2016 Richie Gurgul. All rights reserved.
//

import Foundation
import UIKit

class DrawingPanel: UIViewController, ColorPickerDelegate, SizeSliderDelegate, UITextFieldDelegate
{
    //Hides the status bar
    override var prefersStatusBarHidden: Bool {return true}
    //Tells the color picker what the current custom color is (default is black)
    var color: CIColor {return CIColor(cgColor: brushColor)}
    //Tells the size slider what the current size is (default is 50)
    var size: Float {return Float(brushSize)}
    
    //The top bar
    @IBOutlet weak var navBar: UINavigationItem!
    //The bottom bar
    @IBOutlet weak var botBar: UIToolbar!
    //The view the user draws in
    @IBOutlet weak var panel: UIView!
    //This progress view represents the amount of time remaining to draw
    @IBOutlet weak var timeRemaining: UIProgressView!
 
    //This timer counts down from 60 to limit the player's time
    var timTheTimer: Timer!
    //The bottom right paint brush is used to select a custom color
    var colorPickerItem: UIBarButtonItem!
    //This array stores all the dots of paint that make up a brush stroke
    var brushStrokes: [CAShapeLayer]!
    //This array stores the beginning indices of each brush stroke
    var undoIndices: [Int]!
    //This is the selected color
    var brushColor: CGColor!
    //This is the current size of the brush
    var brushSize: CGFloat!
    //This is the storage class that collects the phrase and the user's drawing
    var drawing: Drawing!
    //This keeps track of if the user taps the custom color button twice
    var doubleTap = false
    //This keeps track of if the user is in a modal view
    var selecting = false
    
    //What happens when the view loads initially
    override func viewDidLoad(){
        super.viewDidLoad()
        
        //Initializes most variables
        brushStrokes = [CAShapeLayer]()
        undoIndices = [Int]()
        brushColor = UIColor.black.cgColor
        brushSize = 40
        drawing = Drawing()
        
        //Sets the top bar to a condescending ellipse while the user enters their phrase.
        navBar.title = "..."
        
        //Changes the height of the progress bar because frankly, 2 pixels is not nearly enough
        timeRemaining.transform = timeRemaining.transform.scaledBy(x: 1, y: 5)
        
        //Programmatically adds all of the brushes to the bottom bar
        setupBrushes()
        
        //Delays the alert that prompts the user for their word
        Timer.scheduledTimer(timeInterval: 0.0, target: self, selector: #selector(wordAlert), userInfo: nil, repeats: false)
    }
    
    //When the user is done, we transition to the next view
    @IBAction func doneButton(_ sender: AnyObject){
        drawing.view = panel
        if let VC = storyboard?.instantiateViewController(withIdentifier: "GuessingPanel") as? GuessingPanel
        {
            self.selecting = true
            VC.drawing = drawing
            VC.sender = self
            present(VC, animated: true, completion: nil)
        }
    }
    
    //Called by the guessing screen when the game is over.
    func gameOver(){
        dismiss(animated: true, completion: nil)
    }
    
    //Prompts the user for the phrase they plan on drawing
    func wordAlert(){
        let alert = UIAlertController(title: "What are you going to draw?", message: "Make sure your friends don't see this screen!", preferredStyle: .alert)
        alert.addTextField
        {   (field) in
            field.autocapitalizationType = .allCharacters
            field.placeholder = "Phrase"
            field.text = self.drawing.name
        }
        //Sets up the delegate to limit the character count
        alert.textFields?[0].delegate = self
        alert.addAction(UIAlertAction(title: "Draw!", style: .default, handler:
        {   (action) in
            //Ensures the user enters something
            if let text = alert.textFields?[0].text, text != ""{
                if self.drawing.name == ""{
                    self.timTheTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTime), userInfo: nil, repeats: true)
                }
                self.drawing.name = text
                self.navBar.title = text
            }
            else
            {
                self.wordAlert()
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    //This variable represents the number of seconds the user has left to draw
    var timeLeft: Float = 60
    func updateTime(){
        if timeLeft > 0{
            //Don't count down while the player is choosing a brush size or color
            if selecting {return}
            
            timeLeft -= 1
            timeRemaining.progress = timeLeft/60
        }
        else{
            timTheTimer.invalidate()
            timesUpAlert()
        }
    }
    
    //Alert the player when their time is up 
    func timesUpAlert(){
        let alert = UIAlertController(title: "Time's up!", message: "Now, hand your phone to your friend and have them guess what you drew!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler:
        {   (action) in
            self.doneButton(self)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    //Limits the character count of the text field
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
        guard let text = textField.text else {return true}
        
        let allowed = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890 ".characters
        for c in string.characters {
            if !allowed.contains(c) {
                return false
            }
        }
        
        let newLength = text.characters.count + string.characters.count - range.length
        return newLength <= 25
    }
    
    //Protocol Function - Recieves data from a color picker view
    func returnFromColorPicker(_ color: UIColor){
        colorPickerItem.tintColor = color
        brushColor = color.cgColor
        selecting = false
    }
    
    //Protocol Function - Recieves data from a size slider view
    func returnFromSizeSlider(_ value: Float){
        brushSize = CGFloat(value)
        selecting = false
    }
    
    //Same functionality as below
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        touchesMoved(touches, with: event)
    }
    
    //Whenever the user moves their tap/drags, a dot is drawn.
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?){
        //Make sure the user is focused on this view
        if selecting {return}
        for touch in touches{
            //Create a path centered around the user's tap and of the correct size
            let loc = touch.location(in: panel)
            let size = CGSize(width: brushSize, height: brushSize)
            let point = CGPoint(x: loc.x - (brushSize/2), y: loc.y - (brushSize/2))
            let frame = CGRect(origin: point, size: size)
            let path = UIBezierPath(ovalIn: frame)
            
            //Create the paint drop (circular layer) using the path and set its color
            let layer = CAShapeLayer()
            layer.path = path.cgPath
            layer.strokeColor = brushColor
            layer.fillColor = brushColor
            
            //Add the layer to the brush stroke array
            brushStrokes.append(layer)
            //Add the layer to the draw panel so the user can see it
            panel.layer.addSublayer(layer)
        }
    }
    
    //When the user stops dragging, save the index of where they stopped. This will come in handy later
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?){
        undoIndices.append(brushStrokes.count)
    }
    
    //Present the user with options to help them.
    @IBAction func toolsButton(_ sender: AnyObject){
        let tools = UIAlertController(title: "Tools", message: nil, preferredStyle: .actionSheet)
        //Clears the entire drawing
        tools.addAction(UIAlertAction(title: "Clear", style: .destructive, handler:
        {   (action) in
            self.clearPanel()
        }))
        //Undo the last brush stroke made
        tools.addAction(UIAlertAction(title: "Undo", style: .destructive, handler:
        {   (action) in
            self.undoLast()
        }))
        //Change the size of the brush
        tools.addAction(UIAlertAction(title: "Brush Size", style: .default, handler:
        {   (action) in
            self.chooseBrushSize()
        }))
        //Change the color of the brush
        tools.addAction(UIAlertAction(title: "Brush Color", style: .default, handler:
        {   (action) in
            self.chooseColor(sender: self.colorPickerItem)
        }))
        //Change the phrase
        tools.addAction(UIAlertAction(title: "Change Phrase", style: .default, handler:
        {   (action) in
            self.wordAlert()
        }))
        //A cancel of course
        tools.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(tools, animated: true, completion: nil)
    }
    
    func setupBrushes(){
        var items = [UIBarButtonItem]()
        let colors: [UIColor] = [.red, .orange, .yellow, .green, .blue, .purple]
        
        //RED _ ORANGE _ YELLOW _ GREEN _ BLUE _ PURPLE _
        for color in colors{
            let item = UIBarButtonItem(image: #imageLiteral(resourceName: "paint-brush"), style: .plain, target: self, action: #selector(chooseBrush(sender:)))
            item.tintColor = color
            items.append(item)
            
            let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
            items.append(space)
        }
        
        //CUSTOM BRUSH
        colorPickerItem = UIBarButtonItem(image: #imageLiteral(resourceName: "paint-brush"), style: .plain, target: self, action: #selector(chooseColor(sender:)))
        colorPickerItem.tintColor = .black
        items.append(colorPickerItem)
        
        //Sets the items on the bottom bar to the custom ones we've made
        botBar.setItems(items, animated: true)
    }
    
    func clearPanel(){
        //Removes each layer from the draw panel
        for layer in brushStrokes{
            layer.removeFromSuperlayer()
        }
    }
    
    func undoLast(){
        //If you have even drawn 1 brush stroke
        if undoIndices.count > 0{
            //Remove the last, as it is the beginning of the next stroke
            undoIndices.removeLast()
            
            //Get the start of the current last stroke
            if let index = undoIndices.last{
                //And remove all of the paint drops
                while index != brushStrokes.count{
                    brushStrokes[index].removeFromSuperlayer()
                    brushStrokes.remove(at: index)
                }
                return
            }
            //If it fails, it will just clear the board.
            clearPanel()
        }
    }
    
    func chooseBrushSize(){
        //Programmatically creates and segues to a Size Slider view controller
        if let VC = storyboard?.instantiateViewController(withIdentifier: "SizeSlider") as? SizeSlider{
            selecting = true
            
            VC.modalTransitionStyle = .crossDissolve
            VC.modalPresentationStyle = .overCurrentContext
            VC.sender = self
            
            present(VC, animated: true, completion: nil)
        }
    }
    
    func chooseColor(sender: UIBarButtonItem){
        //Special check to see if the user taps for the first time
        if !doubleTap{
            //Selects the previous custom color
            brushColor = sender.tintColor?.cgColor
            doubleTap = true
            return
        }
        
        //Programmatically creates and segues to a Color Picker view controller
        if let VC = storyboard?.instantiateViewController(withIdentifier: "ColorPicker") as? ColorPicker{
            selecting = true
            
            VC.modalTransitionStyle = .crossDissolve
            VC.modalPresentationStyle = .overCurrentContext
            VC.sender = self
            
            present(VC, animated: true, completion: nil)
        }
    }
    
    //Selects the color of the selected default brush.
    func chooseBrush(sender: UIBarButtonItem){
        doubleTap = false
        brushColor = sender.tintColor?.cgColor
    }
}
