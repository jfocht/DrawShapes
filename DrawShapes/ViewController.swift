//
//  ViewController.swift
//  DrawShapes
//
//  Created by Jordan Focht on 3/9/15.
//  Copyright (c) 2015 Jordan Focht. All rights reserved.
//

import UIKit



class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        self.view.becomeFirstResponder()

        if let view = self.view as? DrawableView {
            let origins = [(0, 0), (0.5, 0), (0, 0.5), (0.5, 0.5)].map(CGPointMake)
            let color = UIColor.redColor()
            let size = CGSize(width: 0.5, height: 0.5)
            view.shapes = origins.map { ColoredRect(color: color, origin: $0, size: size) }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
