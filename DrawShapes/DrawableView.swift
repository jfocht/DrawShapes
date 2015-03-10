//
//  DrawableView.swift
//  DrawShapes
//
//  Created by Jordan Focht on 3/9/15.
//  Copyright (c) 2015 Jordan Focht. All rights reserved.
//

import Foundation
import UIKit

class DrawableView: UIControl {
    var currentRect: ResizableRectangleView?
    var originalLocation: CGPoint?
    var rectIsPending = false

    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent) {
        if (motion == UIEventSubtype.MotionShake) {
            for view in self.subviews {
                view.removeFromSuperview()
            }
            
        }
    }
    
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) -> Bool {
        rectIsPending = true
        let location = touch.locationInView(self)
        let newRect = ResizableRectangleView()
        newRect.frame = CGRect(x: location.x, y: location.y, width: 1, height: 1)
        newRect.tintColor = self.tintColor
        self.currentRect = newRect
        self.originalLocation = location
        
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        for view in self.subviews {
            if let view = view as? ResizableRectangleView {
                view.selected = false
                view.updateLayers()
            }
        }
        CATransaction.commit()

        return true
    }
    
    override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) -> Bool {
        if let currentRect = self.currentRect {
            if rectIsPending {
                self.addSubview(currentRect)
            }
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            if let originalLocation = self.originalLocation {
                let location = touch.locationInView(self)
                let newX = min(originalLocation.x, location.x)
                let newY = min(originalLocation.y, location.y)
                let width = max(10, abs(originalLocation.x - location.x))
                let height = max(10, abs(originalLocation.y - location.y))
                let newFrame = CGRectMake(newX, newY, width, height)
                currentRect.frame = newFrame
                CATransaction.commit()
            }
        }
        return super.continueTrackingWithTouch(touch, withEvent: event)
    }
    
    override func endTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) {
        self.currentRect = nil
        self.rectIsPending = false
    }
    
}
