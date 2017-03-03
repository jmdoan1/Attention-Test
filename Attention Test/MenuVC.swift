//
//  MenuVC.swift
//  Attention Test
//
//  Created by Justin Doan on 3/2/17.
//  Copyright © 2017 Justin Doan. All rights reserved.
//

import UIKit
import ChameleonFramework
import GameKit

class MenuVC: UIViewController, GKGameCenterControllerDelegate {

    @IBOutlet var btnLeaderboard: UIButton!
    
    @IBOutlet var btnBack: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setStyle()
        
        //EGC.sharedInstance(self)
    }
    
    func setStyle() {
        let chamColor1 = RandomFlatColor()
        let chamColor2 = ContrastColorOf(backgroundColor: chamColor1, returnFlat: true)
        
        view.backgroundColor = chamColor1
        btnBack.setTitleColor(chamColor2, for: .normal)
        btnLeaderboard.setTitleColor(chamColor2, for: .normal)
    }
    
    @IBAction func viewLeaderboards(_ sender: Any) {
        //dismiss(animated: true, completion:nil)
        //EGC.showGameCenter()
        //var vc = self.view?.window?.rootViewController
        let gc = GKGameCenterViewController()
        gc.gameCenterDelegate = self
        self.present(gc, animated: true, completion: nil)
    }
    
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController)
    {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
 
    
    


}
