
//
//  ResizableRectangleView.swift
//  DrawShapes
//
//  Created by Jordan Focht on 3/9/15.
//  Copyright (c) 2015 Jordan Focht. All rights reserved.
//

import Foundation
import UIKit

private let DefaultTint = UIColor(red: 0, green: 164 / 255.0, blue: 1.0, alpha: 1.0).CGColor
private let DefaultStrokeTint = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).CGColor
private let ClearColor = UIColor.clearColor().CGColor
private let DefaultCircleRadius: CGFloat = 8

class ResizableRectangleView: UIControl {
    private var borderLayer: CALayer = CALayer()
    private var topLeftCircle = CALayer()
    private var topRightCircle = CALayer()
    private var bottomLeftCircle = CALayer()
    private var bottomRightCircle = CALayer()

    var strokeTintColor: CGColor = DefaultStrokeTint
    var circleRadius: CGFloat = DefaultCircleRadius


    override var frame: CGRect {
        get {
            return super.frame
        }
        set {
            super.frame = newValue
            self.updateLayers()
        }
    }

    func updateLayers() {
        
        if self.layer.sublayers == nil {
            self.layer.addSublayer(self.borderLayer)
            self.layer.addSublayer(self.topLeftCircle)
            self.layer.addSublayer(self.topRightCircle)
            self.layer.addSublayer(self.bottomLeftCircle)
            self.layer.addSublayer(self.bottomRightCircle)
            let layers = (self.layer.sublayers ?? []) as [CALayer]
            for layer in layers {
                layer.contentsScale = UIScreen.mainScreen().scale
            }
        }

        updateCircleLayer(topLeftCircle, point: CGPoint(x: bounds.origin.x - circleRadius, y: bounds.origin.y - circleRadius))
        updateCircleLayer(topRightCircle, point: CGPoint(x: bounds.origin.x - circleRadius, y: CGRectGetMaxY(bounds) - circleRadius))
        updateCircleLayer(bottomLeftCircle, point: CGPoint(x: CGRectGetMaxX(bounds) - circleRadius, y: bounds.origin.y - circleRadius))
        updateCircleLayer(bottomRightCircle, point: CGPoint(x: CGRectGetMaxX(bounds) - circleRadius, y: CGRectGetMaxY(bounds) - circleRadius))

        self.updateBorderLayer()
    }

    var trackingFrameTransform: (CGPoint -> ())?

    func moveFrame(originalFrame: CGRect, initialTouchLocation: CGPoint)(location: CGPoint) {
        let dx = initialTouchLocation.x - location.x
        let dy = initialTouchLocation.y - location.y
        self.frame.origin.x = originalFrame.origin.x - dx
        self.frame.origin.y = originalFrame.origin.y - dy
    }

    func updateRect(anchor: CGPoint)(location: CGPoint) {
        let newX = min(anchor.x, location.x)
        let newY = min(anchor.y, location.y)
        let width = max(10, abs(anchor.x - location.x))
        let height = max(10, abs(anchor.y - location.y))
        self.frame.origin.x = newX
        self.frame.origin.y = newY
        self.frame.size.width = width
        self.frame.size.height = height
    }

    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) -> Bool {
        CATransaction.begin()
        CATransaction.setDisableActions(true)

        if let superview = self.superview as? DrawableView {
            for view in superview.subviews {
                if let view = view as? ResizableRectangleView {
                    if view != self {
                        view.selected = false
                        view.updateLayers()
                    }
                }
            }
        }
        let location = touch.locationInView(self.superview)
        var anchor: CGPoint?
        let touchWidth: CGFloat = 44
        switch (location.x, location.y) {
        case (let x, let y) where x < self.frame.origin.x + touchWidth && y < self.frame.origin.y + touchWidth:
            anchor = CGPoint(x: CGRectGetMaxX(self.frame), y: CGRectGetMaxY(self.frame))
            self.selected = true
        case (let x, let y) where x < self.frame.origin.x + touchWidth && y > CGRectGetMaxY(self.frame) - touchWidth:
            anchor = CGPoint(x: CGRectGetMaxX(self.frame), y: CGRectGetMinY(self.frame))
            self.selected = true
        case (let x, let y) where x > CGRectGetMaxX(self.frame) - touchWidth && y < self.frame.origin.y + touchWidth:
            anchor = CGPoint(x: CGRectGetMinX(self.frame), y: CGRectGetMaxY(self.frame))
            self.selected = true
        case (let x, let y) where x > CGRectGetMaxX(self.frame) - touchWidth && y > CGRectGetMaxY(self.frame) - touchWidth:
            anchor = CGPoint(x: CGRectGetMinX(self.frame), y: CGRectGetMinY(self.frame))
            self.selected = true
        default:
            self.trackingFrameTransform = self.moveFrame(self.frame, initialTouchLocation: location)
        }
        if let anchor = anchor {
            self.trackingFrameTransform = self.updateRect(anchor)
        }
        
        CATransaction.commit()
        return true
    }
    
    var didMove = false

    override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) -> Bool {
        CATransaction.begin()
        CATransaction.setDisableActions(true)

        didMove = true
        let location = touch.locationInView(self.superview)
        self.trackingFrameTransform?(location)
        self.updateLayers()
        
        CATransaction.commit()
        return true
    }

    override func endTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)

        if !didMove {
            self.selected = !self.selected
        }
        didMove = false
        self.updateLayers()
        self.trackingFrameTransform = nil
        
        CATransaction.commit()
    }

    func updateCircleLayer(layer: CALayer, point: CGPoint) {
        layer.hidden = !self.selected
        layer.frame = CGRect(x: point.x, y: point.y, width: 2 * circleRadius, height: 2 * circleRadius)
        layer.backgroundColor = self.tintColor.CGColor
        layer.borderColor = strokeTintColor
        layer.cornerRadius = self.circleRadius
        layer.borderWidth = 1
        layer.setNeedsDisplay()
    }

    func updateBorderLayer() {
        self.borderLayer.masksToBounds = false
        self.borderLayer.borderWidth = 1
        self.borderLayer.borderColor = self.tintColor.CGColor
        self.borderLayer.frame = self.bounds
        self.borderLayer.setNeedsDisplay()
    }

}
