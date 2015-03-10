//
//  ColorPickerView.swift
//  DrawShapes
//
//  Created by Jordan Focht on 3/10/15.
//  Copyright (c) 2015 Jordan Focht. All rights reserved.
//

import Foundation
import UIKit

// Color Palette
// Black 0, 0, 0
// http://paletton.com/palette.php?uid=3000X0klwRp4mZHcNVftUOUKwCk
// Red 100, 32.9, 32.9
// Blue 35.7, 52.2, 90.2
// Yellow 100, 100, 32.9
// http://paletton.com/palette.php?uid=32v0y0kqNux9rJVhSxvzmoMHwiT
// Green 54.1, 86.7, 14.1
// Orange 95.3, 36.1, 15.7
// Purple 49, 12.5, 63.5
//
// White 100, 100, 100

let colors = [
    UIColor(red: 0, green: 0, blue: 0, alpha: 1.0),
    UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
    UIColor(red: 1.00, green: 0.329, blue: 0.329, alpha: 1.0),
    UIColor(red: 0.49, green: 0.125, blue: 0.635, alpha: 1.0),
    UIColor(red: 0.357, green: 0.522, blue: 0.902, alpha: 1.0),
    UIColor(red: 0.541, green: 0.867, blue: 0.141, alpha: 1.0),
    UIColor(red: 1.00, green: 1.00, blue: 0.329, alpha: 1.0),
    UIColor(red: 0.953, green: 0.361, blue: 0.157, alpha: 1.0)
].map { $0.CGColor }

private let InterColorSpacing: CGFloat = 5


protocol ColorPickerDelegate : class {
    func colorPicker(picker: ColorPicker, didChangeColor color: CGColor)
}


class ColorPicker: UIControl {
    weak var delegate: ColorPickerDelegate?

    override var frame: CGRect {
        get {
            return super.frame
        }
        set {
            super.frame = newValue
            self.updateLayers()
        }
    }

    private var color: CGColor? {
        didSet {
            if let color = color {
                self.delegate?.colorPicker(self, didChangeColor: color)
            }
        }
    }

    func updateLayers() {
        if self.layer.sublayers == nil {
            for i in 0..<colors.count {
                self.layer.addSublayer(CALayer())
            }
        }
        let height = min((self.bounds.height - (InterColorSpacing * CGFloat(colors.count - 1))) / CGFloat(colors.count), self.bounds.width)
        let width = min(self.bounds.width, height)
        let contentHeight = height * CGFloat(colors.count) + InterColorSpacing * CGFloat(colors.count - 1)
        let startY = (self.bounds.height - contentHeight) / 2
        for (i, color) in enumerate(colors) {
            let layer = self.layer.sublayers[i] as CALayer
            layer.backgroundColor = color
            layer.frame.size.width = width
            layer.frame.size.height = height
            layer.frame.origin.x = 0
            layer.frame.origin.y = startY + (height + InterColorSpacing) * CGFloat(i)
            layer.borderWidth = 1.0 / UIScreen.mainScreen().scale
            layer.borderColor = UIColor.lightGrayColor().CGColor
            layer.cornerRadius = height / 2
            layer.setNeedsDisplay()
        }
    }

    private func updateColorForTouch(touch: UITouch) {
        let location = touch.locationInView(self)
        var minDistance = CGFloat.max
        var newColor = self.color
        for (i, layer) in enumerate(self.layer.sublayers) {
            let midY = CGRectGetMidY(layer.frame)
            let distance = abs(location.y - midY)
            if distance < minDistance {
                minDistance = distance
                newColor = colors[i]
            }
        }
        if minDistance != CGFloat.max {
            self.color = newColor
        }
    }

    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) -> Bool {
        updateColorForTouch(touch)
        return true
    }

    override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) -> Bool {
        updateColorForTouch(touch)
        return true
    }

    override func endTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) {
    }

}
