//
//  AppDelegate.swift
//  UserInteractionWithLayers
//
//  Created by Daniel Farrell on 06/04/2015.
//  Copyright (c) 2015 Daniel Farrell. All rights reserved.
//

import Cocoa
import QuartzCore

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    @IBOutlet weak var canvas: CanvasView!

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        
        canvas.layer = CALayer()
        canvas.wantsLayer = true
        
        let rect = CGRect(x: 0.0,y: 0.0, width: 100.0, height: 100.0)
        
        let square = CAShapeLayer()
        square.path = CGPathCreateWithRect(rect, nil)
        square.bounds = rect
        square.fillColor = NSColor.blueColor().CGColor
        square.strokeColor = NSColor.whiteColor().CGColor
        square.lineWidth = 2.0
        square.anchorPoint = CGPoint(x:0.5, y:0.5)
        square.position = CGPoint(x:400.0, y:200.0)
        
        let diamond = CAShapeLayer()
        diamond.path = CGPathCreateWithRect(rect, nil)
        diamond.bounds = rect;
        diamond.fillColor = NSColor.redColor().CGColor
        diamond.strokeColor = NSColor.whiteColor().CGColor
        diamond.lineWidth = 2.0
        diamond.anchorPoint = CGPoint(x:0.5, y:0.5)
        diamond.transform = CATransform3DRotate(diamond.transform, CGFloat(M_PI_4), 0.0, 0.0, 1.0);
        diamond.position = CGPoint(x:300.0, y:200.0)
        
        canvas.layer?.addSublayer(square)
        canvas.layer?.addSublayer(diamond)
        
        
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

