//
//  ViewController.swift
//  ICONResizing
//
//  Created by Artem Kandaurov on 19.05.17.
//  Copyright © 2017 Artem Kandaurov. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet var iconImageView: DragDropImageView?
    @IBOutlet var iconSetNameTextField: NSTextField?
    var imageImported: Bool?
    
    // MARK: - Standart Methods

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear() {
        createInterface()
        initVariables()
    }
    
    // MARK: - Image Methods
    
    func resize(image: NSImage, to size: NSSize) -> NSImage {
        let newImage = NSImage(size: size)
        newImage.lockFocus()
        image.draw(in: NSMakeRect(0, 0, size.width, size.height), from: NSMakeRect(0, 0, image.size.width, image.size.height), operation: .sourceOver, fraction: 1)
        newImage.unlockFocus()
        return NSImage(data: newImage.tiffRepresentation!)!
    }
    
    // MARK: - UI
    
    func createInterface() {
        let appDelegate = NSApplication.shared().delegate as! AppDelegate
        iconImageView?.layer?.borderWidth = 5
        iconImageView?.layer?.masksToBounds = true
        iconImageView?.layer?.borderColor = appDelegate.mainColor.cgColor
    }
    
    func initVariables() {
        let _ = self.view.window?.styleMask.remove(.resizable)
        imageImported = false
        iconImageView?.register(forDraggedTypes: [ kUTTypePNG as String ])
        self.view.window?.makeFirstResponder(nil)
    }
    
    func warningDialogue(title: String, text: String) {
        let popup = NSAlert()
        popup.messageText = title
        popup.informativeText = text
        popup.alertStyle = NSAlertStyle.critical
        popup.addButton(withTitle: "OK")
        popup.runModal()
    }
    
    func dialogue(title: String, text: String) {
        let popup = NSAlert()
        popup.messageText = title
        popup.informativeText = text
        popup.alertStyle = NSAlertStyle.informational
        popup.addButton(withTitle: "OK")
        popup.runModal()
    }
    
    // MARK: - Strings
    
    func getAppIconSetName() -> String {
        return (iconSetNameTextField?.stringValue)!
    }
    
    // MARK: - File System
    
    func getIconName() -> String { //Not used
        var iconName = iconImageView?.getImageURL().lastPathComponent
        let nameComponents = iconName?.components(separatedBy: ".")
        if (nameComponents?.count)! > 1 {
            iconName = ""
            for i in 0..<(nameComponents?.count)!-1 {
                iconName?.append((nameComponents?[i])!)
            }
        }
        return iconName!
    }
    
    func createDirectory(named: String) -> URL {
        var url = iconImageView?.getImageURL()
        url?.deleteLastPathComponent()
        url?.appendPathComponent(named)
        do {
            try FileManager.default.createDirectory(at: url!, withIntermediateDirectories: false, attributes: nil)
        } catch {
            var deletingSuccess = true
            do {
                try FileManager.default.removeItem(at: url!)
            } catch {
                deletingSuccess = false
            }
            if deletingSuccess {
                do {
                    try FileManager.default.createDirectory(at: url!, withIntermediateDirectories: false, attributes: nil)
                } catch { }
            }
        }
        return url!
    }
    
    func cropImage(with sidesArray: inout [ Int ], success: inout Bool) -> URL {
        var url = createDirectory(named: "\(getAppIconSetName()).appiconset")
        url.appendPathComponent("icon")
        
        for i in sidesArray {
            url.deleteLastPathComponent()
            url.appendPathComponent("icon_\(i).png")
            do {
                try resize(image: (iconImageView?.image)!, to: NSMakeSize(CGFloat(i)/2.0, CGFloat(i)/2.0)).saveAsPNG(url: url)
            } catch {
                warningDialogue(title: "Something went wrong!", text: "Please, try again")
                success = false
                return url.deletingLastPathComponent()
            }
        }
        let titleString = "Your appiconset is in source icon folder (\((iconImageView?.getImageURL().deletingLastPathComponent())!)) with name:\n\n\(getAppIconSetName()).appiconset"
        dialogue(title: "Export was successful!", text: titleString)
        success = true
        return url.deletingLastPathComponent()
    }
    
    func createiOSContents(at url: URL) -> Bool {
        let sourceURL = Bundle.main.url(forResource: "iContents", withExtension: "json")
        do {
            try FileManager.default.copyItem(at: sourceURL!, to: url)
        }catch{
            return false
        }
        return true
    }
    
    func createmacOSContents(at url: URL) -> Bool {
        let sourceURL = Bundle.main.url(forResource: "macContents", withExtension: "json")
        do {
            try FileManager.default.copyItem(at: sourceURL!, to: url)
        }catch{
            return false
        }
        return true
    }
    
    func createwatchOSContents(at url: URL) -> Bool {
        let sourceURL = Bundle.main.url(forResource: "watchContents", withExtension: "json")
        do {
            try FileManager.default.copyItem(at: sourceURL!, to: url)
        }catch{
            return false
        }
        return true
    }
    
    // MARK: - Actions
    
    @IBAction func exportiOSButtonPressed(sender: NSButton) {
        if (iconImageView?.isImageSeted())! {
            if (iconSetNameTextField?.stringValue.lengthOfBytes(using: .ascii))! <= 0 {
                iconSetNameTextField?.stringValue = "AppIcon"
            }
            let appDelegate = NSApplication.shared().delegate as! AppDelegate
            var success = false
            var url = cropImage(with: &appDelegate.iOSiconSides, success: &success)
            url.appendPathComponent("Contents.json")
            if success {
                if !createiOSContents(at: url) {
                    warningDialogue(title: "Contents file creating went wrong!", text: "Please, try again")
                }
            }
        }else{
            warningDialogue(title: "Image is not seted yet!", text: "Please, drop a png icon image to the field")
        }
    }
    
    @IBAction func exportmacOSButtonPressed(sender: NSButton) {
        if (iconImageView?.isImageSeted())! {
            if (iconSetNameTextField?.stringValue.lengthOfBytes(using: .ascii))! <= 0 {
                iconSetNameTextField?.stringValue = "AppIcon"
            }
            let appDelegate = NSApplication.shared().delegate as! AppDelegate
            var success = false
            var url = cropImage(with: &appDelegate.macOSiconSides, success: &success)
            url.appendPathComponent("Contents.json")
            if success {
                if !createmacOSContents(at: url) {
                    warningDialogue(title: "Contents file creating went wrong!", text: "Please, try again")
                }
            }
        }else{
            warningDialogue(title: "Image is not seted yet!", text: "Please, drop a png icon image to the field")
        }
    }
    
    @IBAction func exportwatchOSButtonPressed(sender: NSButton) {
        if (iconImageView?.isImageSeted())! {
            if (iconSetNameTextField?.stringValue.lengthOfBytes(using: .ascii))! <= 0 {
                iconSetNameTextField?.stringValue = "AppIcon"
            }
            let appDelegate = NSApplication.shared().delegate as! AppDelegate
            var success = false
            var url = cropImage(with: &appDelegate.watchOSiconSides, success: &success)
            url.appendPathComponent("Contents.json")
            if success {
                if !createwatchOSContents(at: url) {
                    warningDialogue(title: "Contents file creating went wrong!", text: "Please, try again")
                }
            }
        }else{
            warningDialogue(title: "Image is not seted yet!", text: "Please, drop a png icon image to the field")
        }
    }

}

extension NSImage {
    @discardableResult
    func saveAsPNG(url: URL) throws -> Bool {
        guard let tiffData = self.tiffRepresentation else {
            throw NSError()
        }
        let imageRep = NSBitmapImageRep(data: tiffData)
        guard let imageData = imageRep?.representation(using: .PNG, properties: [:]) else {
            throw NSError()
        }
        do {
            try imageData.write(to: url)
            return true
        } catch {
            throw NSError()
        }
    }
}
