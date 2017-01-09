//
//  GuessingPanel.swift
//  Pictionary
//
//  Created by Richie Gurgul on 12/15/16.
//  Copyright © 2016 Richie Gurgul. All rights reserved.
//

import Foundation
import UIKit

class GuessingPanel: UIViewController, UITextFieldDelegate
{
    override var prefersStatusBarHidden: Bool {return true}
    
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var timeRemaining: UIProgressView!
    
    //The user's drawing from the drawing panel
    var drawing: Drawing!
    var sender: DrawingPanel!
    //The timer for how much time is left
    var timer: Timer!
    
    //The user's correctly guessed letters
    var correctChars: [Character]!
    var guessedChars: [Character]!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        guard drawing != nil else {return}
        guard sender != nil else {return}
        
        //Makes the progress bar taller
        timeRemaining.transform = timeRemaining.transform.scaledBy(x: 1, y: 5)
        
        //Adds the drawing to this view, but at the back so it doesn't appear over the bars
        view.addSubview(drawing.view)
        view.sendSubview(toBack: drawing.view)
        
        correctChars = [Character](drawing.name.characters)
        guessedChars = [Character]()
        
        //Spaces are given for free, everything else is replaced with an underscore
        for correctChar in correctChars
        {
            if correctChar == " " {guessedChars.append(" ")}
            else {guessedChars.append("_")}
        }
        
        updateTitle()
        
        //Delays the start alert because otherwise it wouldn't show up.
        Timer.scheduledTimer(timeInterval: 0.0, target: self, selector: #selector(startAlert), userInfo: nil, repeats: false)
    }
    
    func startAlert()
    {
        let alert = UIAlertController(title: "Now it is time to guess!", message: "Press the button at the bottom of the screen to guess what your friend has drawn. Only matching characters will persist at the top. You have 1:30 to guess it correctly, or your friend wins!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ready", style: .cancel, handler:
        {   (action) in
            //Start the timer when the user is ready
            self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTime), userInfo: nil, repeats: true)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func guessButton(_ sender: AnyObject){
        let guessAlert = UIAlertController(title: "Make a guess:", message: nil, preferredStyle: .alert)
        guessAlert.addTextField
        {   (field) in
            //Only capital letters
            field.autocapitalizationType = .allCharacters
            field.placeholder = String(self.guessedChars)
            field.font = UIFont.boldSystemFont(ofSize: 20)
            field.delegate = self
        }
        guessAlert.addAction(UIAlertAction(title: "Guess", style: .default, handler:
        {   (action) in
            self.guess(string: (guessAlert.textFields?[0].text!)!)
        }))
        guessAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(guessAlert, animated: true, completion: nil)
    }
    
    //Default 90 second countdown
    var timeLeft: Float = 90
    func updateTime(){
        if timeLeft > 0{
            timeLeft -= 1
            timeRemaining.progress = timeLeft/90
            
            //Every fifteen seconds, decide if the user should be randomly given a letter
            //It will never give you the last remaining letter, you have to finish it yourself
            if timeLeft.truncatingRemainder(dividingBy: 15) == 0 && guessedChars.index(of: "_") != -1 {
                freeLetter()
            }
        }
        else{
            //If the user runs out of time, alert them
            endAlert(message: "Time's up!")
        }
    }
    
    func freeLetter(){
        //Picks a random index
        let randomIndex = Int(arc4random_uniform(UInt32(guessedChars.count)))
        //It doesn't care if you've already guessed it, however. So you don't always get one for free
        if guessedChars[randomIndex] == "_"{
            guessedChars[randomIndex] = correctChars[randomIndex]
            updateTitle()
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
        guard let text = textField.text else {return true}
        
        //Only allows capital letters, numbers, and spaces
        let allowed = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890 ".characters
        for c in string.characters {
            if !allowed.contains(c) {
                return false
            }
        }
        
        //Characters also limited to 25
        let newLength = text.characters.count + string.characters.count - range.length
        return newLength <= 25
    }
    
    func guess(string: String){
        var chars = [Character](string.characters)
        
        //Safeguard against an uneven amount of characters
        while chars.count < correctChars.count {
            chars.append(" ")
        }
        
        for i in 0..<correctChars.count{
            //If the user guessed a matching character, give it to them
            if chars[i] == correctChars[i]{
                guessedChars[i] = chars[i]
            }
        }
        updateTitle()
        
        //If all the correct letters have been guessed, end the game
        if guessedChars == correctChars{
            endAlert(message: "You won!")
        }
    }
    
    func endAlert(message: String)
    {
        //Stop the timer
        timer.invalidate()
        
        //Message can be substituted for different endings, while still having the same options
        let alert = UIAlertController(title: message, message: "The phrase was \"\(drawing.name!)\"", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Save this drawing?", style: .default, handler:
        {   (action) in
            self.saveDrawing()
        }))
        alert.addAction(UIAlertAction(title: "Back to main menu.", style: .cancel, handler:
        {   (action) in
            //Dismisses both the popover views
            self.dismiss(animated: true)
            {
                self.sender.gameOver()
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func saveDrawing(){
        //Tells the app to save the drawing
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.save(drawing)
        
        self.dismiss(animated: true)
        {
            self.sender.gameOver()
        }
    }
    
    func updateTitle(){
        //Balancing space on either end
        var title = " "
        for guessedChar in guessedChars
        {
            title += "\(guessedChar) "
        }
        navBar.title = title
    }
}
