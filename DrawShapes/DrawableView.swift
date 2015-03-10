//
//  DrawableView.swift
//  DrawShapes
//
//  Created by Jordan Focht on 3/9/15.
//  Copyright (c) 2015 Jordan Focht. All rights reserved.
//

import Foundation
import UIKit

struct ColoredRect {
    let color: UIColor
    let origin: CGPoint
    let size: CGSize
    
    var width: CGFloat {
        get {
            return self.size.width
        }
    }
    
    var height: CGFloat {
        get {
            return self.size.height
        }
    }
    
}

class DrawableView: UIControl {
    private let colorPicker = ColorPicker()
    private var currentRect: ResizableRectangleView?
    private var originalLocation: CGPoint?
    private var rectIsPending = false
    
    var contentSize: CGSize?
    var contentBounds: CGRect? {
        get {
            if let contentSize = self.contentSize {
                let scale = min(CGRectGetWidth(self.bounds) / contentSize.width, CGRectGetHeight(self.bounds) / contentSize.height)
                let scaledWidth = contentSize.width * scale
                let scaledHeight = contentSize.height * scale
                let x = round(0.5 * (CGRectGetWidth(self.bounds) - scaledWidth))
                let y = round(0.5 * (CGRectGetHeight(self.bounds) - scaledHeight))
                return CGRectMake(x, y, scaledWidth, scaledHeight)
            } else {
                return nil
            }
        }
    }
    
    var shapes: [ColoredRect] {
        get {
            var shapes = [ColoredRect]()
            for view in self.subviews {
                if let view = view as? ResizableRectangleView {
                    let f = view.convertRect(view.borderedFrame(), toView: self)
                    let relX = min(1.0, max(0.0, f.origin.x / self.bounds.width))
                    let relY = min(1.0, max(0.0, f.origin.y / self.bounds.height))
                    let relWidth = min(1.0, max(0.0, f.width / self.bounds.width))
                    let relHeight = min(1.0, max(0.0, f.height / self.bounds.height))
                    let relOrigin = CGPointMake(relX, relY)
                    let relSize = CGSizeMake(relWidth, relHeight)
                    let rect = ColoredRect(color: view.tintColor, origin: relOrigin, size: relSize)
                    shapes.append(rect)
                }
            }
            return shapes
        }
        set {
            let shapes = newValue
            for view in self.subviews {
                if let view = view as? ResizableRectangleView {
                    view.removeFromSuperview()
                }
            }
            self.colorPicker.alpha = 0
            for shape in shapes {
                let x = shape.origin.x * self.bounds.width
                let y = shape.origin.y * self.bounds.height
                let width = shape.width * self.bounds.width
                let height = shape.height * self.bounds.height
                let rectFrame = CGRect(x: x, y: y, width: width, height: height)
                let view = ResizableRectangleView()
                let inset = view.inset()
                view.tintColor = shape.color
                view.frame = CGRectInset(rectFrame, -inset, -inset)
                view.delegate = self
                self.addSubview(view)
            }
            self.bringSubviewToFront(self.colorPicker)
        }
    }
    
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
        self.bringSubviewToFront(self.colorPicker)
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
            self.shapes = []
        }
    }
    
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) -> Bool {
        let location = touch.locationInView(self)
        if let contentBounds = self.contentBounds {
            if (!contentBounds.contains(location)) {
                return false
            }
        }
        rectIsPending = true
        let newRect = ResizableRectangleView()
        newRect.frame = CGRect(x: location.x, y: location.y, width: 1, height: 1)
        newRect.tintColor = UIColor(CGColor: self.colorPicker.color)
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
                self.bringSubviewToFront(self.colorPicker)
            }
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            if let originalLocation = self.originalLocation {
                let location = touch.locationInView(self)
                currentRect.updateRect(originalLocation, initialTouchLocation: originalLocation, originalCorner: originalLocation)(location: location)
            }
            CATransaction.commit()
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
        self.bringSubviewToFront(self.colorPicker)
        if self.colorPicker.alpha == 0 {
            UIView.animateWithDuration(0.15) {
                self.colorPicker.alpha = 1
            }
        }
    }
    
    func didDeselectResizableRectangleView(view: ResizableRectangleView) {
        self.bringSubviewToFront(self.colorPicker)
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
