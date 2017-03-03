//
//  ViewController.swift
//  Attention Test
//
//  Created by Justin Doan on 2/25/17.
//  Copyright © 2017 Justin Doan. All rights reserved.
//
//pod 'ChameleonFramework/Swift'
//https://github.com/ViccAlexander/Chameleon

import UIKit
import ChameleonFramework
import EasyGameCenter
import Localize_Swift
import GuillotineMenu

class ViewController: UIViewController {
    
    
    var maxTime = 5
    
    let timeArray = [5, 10, 15, 20]
    
    var countTimer: Timer?
    var startTime: TimeInterval?
    var firstStartTime: TimeInterval?
    var lastTapTime: TimeInterval?
    
    var taps = 0
    
    @IBOutlet var sgmtTime: UISegmentedControl!
    @IBOutlet var lblTimer: UILabel!
    @IBOutlet var btnStart: UIButton!
    @IBOutlet var lblAlert: UILabel!
    @IBOutlet var lbl2Alert: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        EGC.sharedInstance(self)
        
        EGC.getGKLeaderboard {
            (resultArrayGKLeaderboard) -> Void in
            if let resultArrayGKLeaderboardIsOK = resultArrayGKLeaderboard {
                for oneGKLeaderboard in resultArrayGKLeaderboardIsOK  {
                    print("[Easy Game Center] ID : \(oneGKLeaderboard.identifier)")
                    print("[Easy Game Center] Title :\(oneGKLeaderboard.title)")
                    print("[Easy Game Center] Loading ? : \(oneGKLeaderboard.isLoading)")
                }
            }
        }
        
        Localize.setCurrentLanguage("en")
        print("Available languages: \(Localize.availableLanguages())")
        
        
        
        lblAlert.text = ""
        lbl2Alert.text = ""
        
        setStyle()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.handleTap))
        view.addGestureRecognizer(tap)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
    }
    
    func EGCAuthentified(authentified:Bool) {
        print("Player Authentified = \(authentified)")
    }
    
    func setStyle() {
        
        for x in 0...(sgmtTime.numberOfSegments - 1) {
            
            sgmtTime.setTitle("\(timeArray[x])", forSegmentAt: x)
        }
        
        //Random chameleon color
        let chamColor1 = RandomFlatColor()
        let chamColor2 = ComplementaryFlatColorOf(color: chamColor1)
        let chamColor3 = ContrastColorOf(backgroundColor: chamColor1, returnFlat: true)
        let chamColor4 = ContrastColorOf(backgroundColor: chamColor2, returnFlat: true)
        let chamColor5 = ComplementaryFlatColorOf(color: chamColor3)
        
        view.backgroundColor = chamColor1
        lblTimer.textColor = chamColor3
        lblAlert.textColor = chamColor5
        lbl2Alert.textColor = chamColor5
        
        btnStart.backgroundColor = chamColor2
        btnStart.setTitleColor(chamColor4, for: .normal)
        
        sgmtTime.tintColor = chamColor3
        
        if countTimer != nil {
            if (countTimer?.isValid)! {
                btnStart.setTitle("STOP".localized(using: "ButtonTitles"), for: .normal)
            } else {
                btnStart.setTitle("START".localized(using: "ButtonTitles"), for: .normal)
            }
        } else {
            btnStart.setTitle("START".localized(using: "ButtonTitles"), for: .normal)
        }
        
        //btnStart.backgroundColor = color4
        //btnStart.setTitleColor(color5, for: .normal)
    }
    
    func start() {
        
        maxTime = timeArray[sgmtTime.selectedSegmentIndex]
        
        lblAlert.text = ""
        lbl2Alert.text = ""
        
        taps = 0
        firstStartTime = Date().timeIntervalSinceReferenceDate
        startTime = Date().timeIntervalSinceReferenceDate
        countTimer = Timer.scheduledTimer(timeInterval: 0.01,
                                          target: self,
                                          selector: #selector(self.updateTime),
                                          userInfo: nil,
                                          repeats: true)
        setStyle()
    }
    
    func updateTime() {
        let currentTime = Date().timeIntervalSinceReferenceDate
        var elapsedTime: TimeInterval = currentTime - startTime!
        
        if Int(elapsedTime) < maxTime {
            
            let minutes = UInt8(elapsedTime / 60.0)
            
            elapsedTime -= (TimeInterval(minutes) * 60)
            
            let seconds = UInt8(elapsedTime)
            
            elapsedTime -= TimeInterval(seconds)
            
            let fraction = UInt8(elapsedTime * 100)
            
            let strMinutes = String(format: "%02d", minutes)
            let strSeconds = String(format: "%02d", seconds)
            let strFraction = String(format: "%02d", fraction)
            
            lblTimer.text = "\(strMinutes):\(strSeconds):\(strFraction)"
            
        } else {
            
            stopTimer(reason: .tooLate)
        }
    }
    
    func handleTap() {
        //print("Tapped")
        
        if countTimer == nil {
            print("Timer is nil")
        } else {
            if (countTimer?.isValid)! {
                print("Timer running")
                //let dif = x-y
                //print(dif)
                //y = 0
                let currentTime = Date().timeIntervalSinceReferenceDate
                let elapsedTime = currentTime - startTime!
                if maxTime - Int(elapsedTime) <= 1 {
                    taps += 1
                    lastTapTime = currentTime
                    print(elapsedTime)
                    startTime = Date().timeIntervalSinceReferenceDate
                } else {
                    //TODO: Case: Too Early
                    stopTimer(reason: .tooEarly)
                }
            } else {
                print("Timer not running")
            }
        }
    }
    
    @IBAction func startButton(_ sender: Any) {
        if countTimer == nil {
            start()
        } else {
            if (countTimer?.isValid)! {
                stopTimer(reason: .userEnded)
            } else {
                start()
            }
        }
    }
    
    func stopTimer(reason: stopReason) {
        if (countTimer?.isValid)! {
            switch reason {
            case .tooEarly:
                if taps > 0 {
                    let totalTime = lastTapTime! - firstStartTime!
                    lblAlert.text = "Too early".localized() + " :(".localized()
                    lbl2Alert.text = "Score".localized() + ": \(taps) " + "taps".localized() + " - \(Int(totalTime)) " + "seconds".localized()
                } else {
                    lblAlert.text = "Too early".localized() + " :(".localized()
                    lbl2Alert.text = "You must tap within 1 second of the goal time".localized()
                }
            case .tooLate:
                if taps > 0 {
                    let totalTime = lastTapTime! - firstStartTime!
                    lblAlert.text = "Too late".localized() + " :(".localized()
                    lbl2Alert.text = "Score".localized() + ": \(taps) " + "taps".localized() + " - \(Int(totalTime)) " + "seconds".localized()
                } else {
                    lblAlert.text = "Too late".localized() + " :(".localized()
                    lbl2Alert.text = "You must tap before the goal time".localized()
                }
            case .userEnded:
                if taps > 0 {
                    let totalTime = lastTapTime! - firstStartTime!
                    lblAlert.text = "Game ended".localized()
                    lbl2Alert.text = "Score".localized() + ": \(taps) " + "taps".localized() + " - \(Int(totalTime)) " + "seconds".localized()
                } else {
                    lblAlert.text = "Game ended".localized()
                }
            }
            
            if taps > 0 {
                let totalTime = lastTapTime! - firstStartTime!
                //EGC.reportScoreLeaderboard(leaderboardIdentifier: "LeaderboardIdentifier", score: totalTime)
                EGC.reportScoreLeaderboard(leaderboardIdentifier: "\(maxTime)secondsTime", score: Int(totalTime * 100))
                EGC.reportScoreLeaderboard(leaderboardIdentifier: "\(maxTime)secondsTaps", score: taps)
            }
            countTimer?.invalidate()
        }
        setStyle()
    }
    
    
    enum stopReason {
        case tooEarly
        case tooLate
        case userEnded
    }

}

