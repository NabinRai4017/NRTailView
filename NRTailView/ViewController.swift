//
//  ViewController.swift
//  NRTailView
//
//  Created by nabinrai on 12/14/17.
//  Copyright © 2017 nabin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tailView: NRJellyTail!
    
    @IBOutlet weak var lbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tailView.nrJellyTailDelegate = self
        tailView.color = UIColor.red.cgColor
        tailView.resetView()
        self.lbl.text = "Swipe Left"
        
    }
    
    
}

extension ViewController: NRJellyTailDelegate{
    
    
    func swipeLeftAction(jellyView: NRJellyTail) {
        
       print("Left swipe action")
        
    }
    
    
}

