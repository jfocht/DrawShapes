
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
private let CornerTouchSize: CGFloat = 44

protocol ResizableRectangleViewDelegate : class {
    func didSelectResizableRectangleView(view: ResizableRectangleView)
    func didDeselectResizableRectangleView(view: ResizableRectangleView)
}

class ResizableRectangleView: UIControl {
    private var borderLayer: CALayer = CALayer()
    private var topLeftCircle = CALayer()
    private var topRightCircle = CALayer()
    private var bottomLeftCircle = CALayer()
    private var bottomRightCircle = CALayer()

    weak var delegate: ResizableRectangleViewDelegate?
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

    override var selected: Bool {
        get {
            return super.selected
        }
        set {
            var changed = self.selected != newValue
            super.selected = newValue
            if changed {
                if selected {
                    self.delegate?.didSelectResizableRectangleView(self)
                } else {
                    self.delegate?.didDeselectResizableRectangleView(self)
                }
            }
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

        self.updateBorderLayer()
        let circleFrame = self.borderLayer.frame
        updateCircleLayer(topLeftCircle, center: CGPoint(x: circleFrame.origin.x, y: circleFrame.origin.y))
        updateCircleLayer(topRightCircle, center: CGPoint(x: circleFrame.origin.x, y: CGRectGetMaxY(circleFrame)))
        updateCircleLayer(bottomLeftCircle, center: CGPoint(x: CGRectGetMaxX(circleFrame), y: circleFrame.origin.y))
        updateCircleLayer(bottomRightCircle, center: CGPoint(x: CGRectGetMaxX(circleFrame), y: CGRectGetMaxY(circleFrame)))
    }

    var trackingFrameTransform: (CGPoint -> ())?

    func moveFrame(originalFrame: CGRect, initialTouchLocation: CGPoint)(location: CGPoint) {
        self.frame.origin.x = originalFrame.origin.x + location.x - initialTouchLocation.x
        self.frame.origin.y = originalFrame.origin.y + location.y - initialTouchLocation.y
    }

    func updateRect(anchor: CGPoint, initialTouchLocation: CGPoint, originalCorner: CGPoint)(location: CGPoint) {
        let targetX = originalCorner.x + location.x - initialTouchLocation.x
        let targetY = originalCorner.y + location.y - initialTouchLocation.y
        self.frame.origin.x = min(targetX, anchor.x)
        self.frame.origin.y = min(targetY, anchor.y)

        let minSize = (CornerTouchSize - (self.circleRadius * 2)) / 2 + circleRadius + 2
        self.frame.size.width = max(minSize * 2, abs(anchor.x - targetX))
        self.frame.size.height = max(minSize * 2, abs(anchor.y - targetY))
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
            superview.bringSubviewToFront(self)
        }


        let location = touch.locationInView(self.superview)
        var anchor: CGPoint?
        var corner: CGPoint?

        switch (location.x, location.y) {
        case (let x, let y) where x < self.frame.origin.x + CornerTouchSize && y < self.frame.origin.y + CornerTouchSize:
            anchor = CGPoint(x: CGRectGetMaxX(self.frame), y: CGRectGetMaxY(self.frame))
            corner = CGPoint(x: CGRectGetMinX(self.frame), y: CGRectGetMinY(self.frame))
        case (let x, let y) where x < self.frame.origin.x + CornerTouchSize && y > CGRectGetMaxY(self.frame) - CornerTouchSize:
            anchor = CGPoint(x: CGRectGetMaxX(self.frame), y: CGRectGetMinY(self.frame))
            corner = CGPoint(x: CGRectGetMinX(self.frame), y: CGRectGetMaxY(self.frame))
        case (let x, let y) where x > CGRectGetMaxX(self.frame) - CornerTouchSize && y < self.frame.origin.y + CornerTouchSize:
            anchor = CGPoint(x: CGRectGetMinX(self.frame), y: CGRectGetMaxY(self.frame))
            corner = CGPoint(x: CGRectGetMaxX(self.frame), y: CGRectGetMinY(self.frame))
        case (let x, let y) where x > CGRectGetMaxX(self.frame) - CornerTouchSize && y > CGRectGetMaxY(self.frame) - CornerTouchSize:
            anchor = CGPoint(x: CGRectGetMinX(self.frame), y: CGRectGetMinY(self.frame))
            corner = CGPoint(x: CGRectGetMaxX(self.frame), y: CGRectGetMaxY(self.frame))
        default:
            self.trackingFrameTransform = self.moveFrame(self.frame, initialTouchLocation: location)
        }
        if let anchor = anchor {
            if let corner = corner {
                self.didMove = true
                self.selected = true
                self.trackingFrameTransform = self.updateRect(anchor, initialTouchLocation: location, originalCorner: corner)
                self.updateLayers()
            }
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

    func updateCircleLayer(layer: CALayer, center: CGPoint) {
        layer.hidden = !self.selected
        layer.frame = CGRect(x: center.x - circleRadius, y: center.y - circleRadius, width: 2 * circleRadius, height: 2 * circleRadius)
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
        let circleInset = (CornerTouchSize - (self.circleRadius * 2)) / 2
        self.borderLayer.frame = CGRectInset(self.bounds, self.circleRadius + circleInset, self.circleRadius + circleInset)
        self.borderLayer.setNeedsDisplay()
    }

}
