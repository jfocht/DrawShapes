//
//  ViewController.swift
//  DrawShapes
//
//  Created by Jordan Focht on 3/9/15.
//  Copyright (c) 2015 Jordan Focht. All rights reserved.
//

import UIKit



class ViewController: UIViewController {
    @IBOutlet weak var drawable: DrawableView!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        self.drawable.becomeFirstResponder()
        
        if let imageView = self.imageView {
            if let imageSize = imageView.image?.size {
                self.drawable.contentSize = imageSize
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
