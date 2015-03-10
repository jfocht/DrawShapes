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
    private let colorPicker = ColorPicker()
    private var currentRect: ResizableRectangleView?
    private var originalLocation: CGPoint?
    private var rectIsPending = false
    
    override init() {
        super.init()
        self.addColorPicker()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addColorPicker()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addColorPicker()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.addColorPicker()
    }
    
    private func addColorPicker() {
        colorPicker.delegate = self
        colorPicker.alpha = 0
        self.addSubview(colorPicker)
        colorPicker.frame = CGRect(x: self.bounds.width - 44, y: 0, width: 44, height: self.bounds.height)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        colorPicker.frame = CGRect(x: self.bounds.width - 44, y: 0, width: 44, height: self.bounds.height)
    }

    override func canBecomeFirstResponder() -> Bool {
        return true
    }

    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent) {
        if (motion == UIEventSubtype.MotionShake) {
            for view in self.subviews {
                if view as? ColorPicker != self.colorPicker {
                    view.removeFromSuperview()
                }
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
                currentRect.delegate = self
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


extension DrawableView: ColorPickerDelegate {

    func colorPicker(picker: ColorPicker, didChangeColor color: CGColor) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        for view in self.subviews {
            if let view = view as? ResizableRectangleView {
                if view.selected {
                    view.tintColor = UIColor(CGColor: color)
                    view.updateLayers()
                }
            }
        }
        CATransaction.commit()
    }

}

extension DrawableView: ResizableRectangleViewDelegate {

    func didSelectResizableRectangleView(view: ResizableRectangleView) {
        if self.colorPicker.alpha == 0 {
            UIView.animateWithDuration(0.15) {
                self.colorPicker.alpha = 1
            }
        }
    }

    func didDeselectResizableRectangleView(view: ResizableRectangleView) {
        if colorPicker.alpha == 1 {
            let selectionCount = self.subviews.reduce(0) {
                acc, view in

                if let view = view as? ResizableRectangleView {
                    return acc + (view.selected ? 1 : 0)
                }
                return acc
            }
            if selectionCount == 0 {
                UIView.animateWithDuration(0.15) {
                    self.colorPicker.alpha = 0
                }
            }
        }
    }
}
