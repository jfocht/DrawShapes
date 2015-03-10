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
    
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) -> Bool {
        let location = touch.locationInView(self)
        let newRect = ResizableRectangleView()
        newRect.frame = CGRect(x: location.x, y: location.y, width: 1, height: 1)
        newRect.tintColor = self.tintColor
        self.addSubview(newRect)
        self.currentRect = newRect
        self.originalLocation = location
        return true
    }
    
    override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) -> Bool {
        if touch.tapCount == 0 {
            return false
        } else if let currentRect = self.currentRect {
            if let originalLocation = self.originalLocation {
                let location = touch.locationInView(self)
                
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                
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
    }
    
}