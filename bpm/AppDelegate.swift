//
//  AppDelegate.swift
//  bpm
//
//  Created by Ben Brook on 2015-12-21.
//  Copyright © 2015 Ben Brook. All rights reserved.
//

import Cocoa

extension String {
    func leftPadding(toLength: Int, withPad character: Character) -> String {
        let newLength = count
        if newLength < toLength {
            return String(repeatElement(character, count: toLength - newLength)) + self
        } else {
            return self.substring(from: index(self.startIndex, offsetBy: newLength - toLength))
        }
    }
}

@NSApplicationMain
final class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    
    // load NSUserDefaults
    let defaults = UserDefaults.standard

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem.button?.title = "bpm"
        
        if let button = statusItem.button {
            button.action = #selector(clicked(sender:))
            button.keyEquivalent = ""
        }
        
        if !defaults.bool(forKey: "noShowDialogOnStart") {
            dialogOKCancelNoshow(question: "Instructions", text: ("Control-Click to quit the app.\nAlt-Click to show this window again.\n\nTap to calculate BPM.\n\n\nBuilt by Ben Brook:   www.builtbybenbrook.com"))
        }
    }
    
    var lastPress = Date()
    var avg = 0.0
    var i = 1.0
    var timer = Timer()

    func dialogOKCancelNoshow(question: String, text: String) {
        let myPopup: NSAlert = NSAlert()
        myPopup.messageText = question
        myPopup.informativeText = text
        myPopup.alertStyle = .warning
        myPopup.addButton(withTitle: "OK")
        
        myPopup.showsSuppressionButton = true
        myPopup.suppressionButton?.title = "Do not show this message on launch"
        
        let res = myPopup.runModal()
        
        if myPopup.suppressionButton?.state == NSControl.StateValue(1) {
            defaults.set(true, forKey: "noShowDialogOnStart")
        } else {
            defaults.set(false, forKey: "noShowDialogOnStart")
        }
    }

    @objc
    func clicked(sender: AnyObject?) {
        let clickEvent = NSApp.currentEvent!  // see what caused calling of the menu action
            // modifierFlags contains a number with bits set for various modifier keys
            // ControlKeyMask is the enum for the Ctrl key
            // AlternateKeyMask is the enum for the Alt key
            // use logical and with the raw values to find if the bit is set in modifierFlags
        if (Int(clickEvent.modifierFlags.rawValue) & Int(NSEvent.ModifierFlags.control.rawValue)) != 0 {      // ctrl click to quit
            NSApplication.shared.terminate(self)
        } else if (Int(clickEvent.modifierFlags.rawValue) & Int(NSEvent.ModifierFlags.option.rawValue)) != 0 {     // alt click to show info
            dialogOKCancelNoshow(question: "Instructions", text: ("Control-Click to quit the app.\nAlt-Click to show this window again.\n\nTap to calculate BPM.\n\nBuilt by Ben Brook:   www.builtbybenbrook.com\n"))
        } else { // regular click
            timer.invalidate()
            let elapsedTime = Date().timeIntervalSince(lastPress)
            print(elapsedTime)
            if elapsedTime > 2.5 {
                print("1")
                avg = 0.0
                i = 1.0
                lastPress = Date()
            } else {
                print("2")
                avg = (avg*(i-1) + elapsedTime) / i
                lastPress = Date()
                i = i + 1
                let x = Int(60/avg)
                statusItem.button?.title = String(x).leftPadding(toLength: 3, withPad: " ")
            }
            timer = Timer.scheduledTimer(timeInterval: 2.5, target:self, selector: #selector(updateCounter), userInfo: nil, repeats: false)
        }
    }
    
    @objc
    func updateCounter() {
        statusItem.button?.title = "bpm"
    }
    
}
