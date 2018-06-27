		//
//  CustomCameraControlsVC.swift
//  CamPlusAudio
//
//  Created by Ashok on 13/12/15.
//  Copyright © 2015 Ashok. All rights reserved.
//

import UIKit
import AVFoundation

protocol CustomCameraControlsVCDelegate: class {
    func didClickStartRecordingButton(_ sender: UIButton)
    func didClickStopRecordingButton(_ sender: UIButton, duration: Int)
    func didClickCancelButtion()
    func didClickSwitchCameraButton()
    func didClickFlashButton()
    func didClickNextButton()
}

extension CustomCameraControlsVCDelegate {
    func didClickStartRecordingButton(_ sender: UIButton) { }
    func didClickStopRecordingButton(_ sender: UIButton, duration: Int) { }
    func didClickCancelButtion() { }
    func didClickSwitchCameraButton() { }
    func didClickFlashButton() { }
    func didClickNextButton() { }
}

class CustomCameraControlsVC: UIViewController {
    
    @IBOutlet weak var audioDurationLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var switchCameraButton: UIButton!
    @IBOutlet var recordProgressView: AMGProgressView!
    @IBOutlet weak var lineView1: UIView!
    @IBOutlet weak var lineView2: UIView!
    @IBOutlet weak var lineView3: UIView!
    @IBOutlet weak var lineView4: UIView!
    @IBOutlet weak var discardButton: UIButton!
    
    weak var delegate: CustomCameraControlsVCDelegate?
    var audioDurationLblTimer = Timer()
    var recordButtonTimer = Timer()
    var counter = 0
    var audioRecorder:AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var playerURL: URL!
    var timer: Timer!
    var initialProgressTimer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        flashButton.isSelected = false
        playButton.isSelected = false
        lineView1.isHidden = true
        lineView2.isHidden = true
        lineView3.isHidden = true
        lineView4.isHidden = true
        nextButton.isHidden = true
        discardButton.isHidden = true
        initializesProgressView()
        // Do any additional setup after loading the view.
        
        //        view.makeToast("Testing")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopTheAudioPlayer()
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: true)
    }
    
    func initializesProgressView() {
        self.recordProgressView.gradientColors = [UIColor.navBarEndColor(), UIColor.navBarStartColor()]
        self.recordProgressView.emptyPartAlpha = 1.0
        self.recordProgressView.clipsToBounds = true
        
        initialProgressTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector:#selector(CustomCameraControlsVC.setInitialProgress), userInfo: nil, repeats: true)
        RunLoop.current.add(initialProgressTimer, forMode: RunLoopMode.commonModes)
    }
    
    func setInitialProgress() {
        DispatchQueue.main.async { () -> Void in
            self.recordProgressView.progress = 0
        }
    }
    
    func setProgress() {
        DispatchQueue.main.async { () -> Void in
            let progress = Float(self.audioRecorder.currentTime + 0.3)/15
            print(progress)
            //            if progress == 0 {
            //                self.timer.invalidate()
            self.recordProgressView.progress = progress
            //                self.performSelector("setInitialProgress", withObject: nil, afterDelay: 0.2)
            //        }
        }
    }
    
    @IBAction func nextButtonAction(_ sender: AnyObject) {
        if let delegate = delegate {
            delegate.didClickNextButton()
            stopTheAudioPlayer()
        }
    }
    
    @IBAction func recordBtnAction(_ sender: UIButton) {
        lineView1.isHidden = false
        lineView2.isHidden = false
        lineView3.isHidden = false
        lineView4.isHidden = false
        switchCameraButton.isUserInteractionEnabled = false
        flashButton.isUserInteractionEnabled = false
        flashButton.alpha = 0.5
        switchCameraButton.alpha = 0.5
        
        self.recordProgressView.gradientColors = [UIColor.navBarEndColor(), UIColor.navBarStartColor()]
        self.recordProgressView.emptyPartAlpha = 1.0
        
        if sender.tag == 1 { // Start recording
            if let delegate = delegate {
                delegate.didClickStartRecordingButton(sender)
            }
            recordButton.isEnabled = false
            recordButton.isUserInteractionEnabled = false
            
            perform(#selector(CustomCameraControlsVC.startRecordingProcess), with: nil, afterDelay: 0.5)
            
        } else { // Stop recording
            print(audioRecorder.currentTime)
            if audioRecorder.currentTime < 2 {
                print("Min duration is 1 second!")
                view.makeToast("Min duration is 1 second!", duration: 2, position: .top, style: ToastStyle())
                return;
            }
            print("stopTheThings")
            sender.isHidden = false
            stopTheThings()
            if let delegate = delegate {
                delegate.didClickStopRecordingButton(sender, duration: counter)
                nextButton.isHidden = false
                discardButton.isHidden = false
                recordButton.setBackgroundImage(gradientBackgroundImage(sender.frame), for: UIControlState())
                recordButton.setImage(UIImage(named: "playBtnWhite"), for: UIControlState())
            }
        }
    }
    
    func startRecordingProcess() {
        // Button Updation
        recordButton.tag = 2
        recordButton.setBackgroundImage(gradientBackgroundImage(recordButton.frame), for: UIControlState())
        recordButton.setImage(UIImage(named: "red_stop_icon"), for: UIControlState())
        recordButton.isEnabled = true
        //
        
        
        record()
        audioDurationLblTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(CustomCameraControlsVC.updateAudioDurationLblWhileReocording), userInfo: nil, repeats: true)
        recordButtonTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector:#selector(CustomCameraControlsVC.userInteractionEnabledAudioButton), userInfo: nil,repeats: false)
        initialProgressTimer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector:#selector(CustomCameraControlsVC.setProgress), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: RunLoopMode.commonModes)
        //        timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector:Selector("setProgress"), userInfo: nil, repeats: true)
    }
    
    @IBAction func playButtonAction(_ sender: AnyObject) {
        if (playButton.isSelected == false) { // Play
            playButton.isSelected = true
            playButton.setBackgroundImage(gradientBackgroundImage(sender.frame), for: UIControlState())
            playButton.setImage(UIImage(named: "pauseBtnWhite"), for: UIControlState())
            playUsingAudioPlayer(playerURL)
        } else { // Pause
            stopTheAudioPlayer()
            playButton.isSelected = false
            playButton.setBackgroundImage(gradientBackgroundImage(sender.frame), for: UIControlState())
            playButton.setImage(UIImage(named: "playBtnWhite"), for: UIControlState())
        }
    }
    
    func playUsingAudioPlayer(_ pathURL: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: pathURL)
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        } catch {
            print("Catch error in playUsingAudioPlayer")
        }
    }
    
    func stopTheAudioPlayer() {
        if audioPlayer != nil {
            if audioPlayer.isPlaying {
                audioPlayer.stop()
            }
        }
    }
    
    @IBAction func flashButtonAction(_ sender: AnyObject) {
        if (flashButton.isSelected == false) {
            flashButton.isSelected = true
            flashButton.setImage(UIImage(named: "flash"), for: UIControlState())
        } else {
            flashButton.isSelected = false
            flashButton.setImage(UIImage(named: "flash"), for: UIControlState())
        }
        if let delegate = delegate {
            delegate.didClickFlashButton()
        }
    }
    
    @IBAction func switchCameraAction(_ sender: AnyObject) {
        if (switchCameraButton.isSelected == true) {
            switchCameraButton.isSelected = false
            flashButton.isUserInteractionEnabled = true
            flashButton.alpha = 1
            //            switchCameraButton.alpha = 1
            switchCameraButton.setImage(UIImage(named: "rotateCamera"), for: UIControlState())
        } else {
            switchCameraButton.isSelected = true
            flashButton.isSelected = false
            flashButton.isUserInteractionEnabled = false
            switchCameraButton.setImage(UIImage(named: "rotateCamera"), for: UIControlState())
            flashButton.setImage(UIImage(named: "flash"), for: UIControlState())
            flashButton.alpha = 0.5
            //            switchCameraButton.alpha = 0.5
        }
        if let delegate = delegate {
            delegate.didClickSwitchCameraButton()
        }
    }
    
    @IBAction func cancelBtnAction(_ sender: AnyObject) {
        stopTheThings()
        stopTheAudioPlayer()
        if let delegate = delegate {
            delegate.didClickCancelButtion()
        }
    }
    
    func userInteractionEnabledAudioButton() {
        recordButton.isUserInteractionEnabled = true
        recordButtonTimer.invalidate()
    }
    
    func updateAudioDurationLblWhileReocording() {
        counter += 1
        print("counter", counter)
        let minutes = floor(audioRecorder.currentTime / 60)
        let seconds = audioRecorder.currentTime - (minutes * 60)
        //        print("minutes--> \(minutes)")
        //         print("seconds--> \(seconds)")
        let time = String(format: "%@%.0f:%@%.0f", arguments: [minutes < 9 ? "0" : "", minutes, seconds < 9 ? "0" : "", seconds])
        audioDurationLabel.text = time
        
        if counter == 15 {
            recordButton.isHidden = true
            recordBtnAction(recordButton)
        }
    }
    
    func record() {
        //init
        let audioSession:AVAudioSession = AVAudioSession.sharedInstance()
        
        //ask for permission
        if (audioSession.responds(to: #selector(AVAudioSession.requestRecordPermission(_:)))) {
            AVAudioSession.sharedInstance().requestRecordPermission({(granted: Bool)-> Void in
                if granted {
                    print("granted")
                    
                    //set category and activate recorder session
                    try! audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
                    try! audioSession.setActive(true)
                    
                    
                    //get documnets directory
                    
                    let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
                    let recordingName = "voiceRecording"+".aac"
                    let filePath = URL(fileURLWithPath: dirPath + "/" + recordingName)
                    
                    //create AnyObject of settings
                    let settings: [String : AnyObject] = [
                        AVFormatIDKey: Int(kAudioFormatMPEG4AAC) as AnyObject, //Int required in Swift2
                        AVSampleRateKey: 48000.0 as AnyObject,
                        AVNumberOfChannelsKey: 2 as AnyObject,
                        AVEncoderBitRateKey: 320000 as AnyObject,
                        AVLinearPCMBitDepthKey: 24 as AnyObject,
                        AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue as AnyObject
                    ]
                    //record
                    try! self.audioRecorder = AVAudioRecorder(url: filePath, settings: settings)
                    self.playerURL = filePath
                    self.audioRecorder.record()
                } else {
                    print("not granted")
                }
            })
        }
    }
    
    func stopTheThings() {
        //    counter = 0
        playButton.isHidden = false
        nextButton.isUserInteractionEnabled = true
        playButton.isSelected = false
        audioDurationLblTimer.invalidate()
        flashButton.isUserInteractionEnabled = false
        if flashButton.isSelected == true {
            flashButton.isSelected = false
            flashButton.setImage(UIImage(named: "flash_Off"), for: UIControlState())
        }
        if timer != nil {
            timer.invalidate()
        }
        if audioRecorder != nil {
            if audioRecorder.isRecording {
                audioRecorder.stop()
                flashButton.isHidden = true
                switchCameraButton.isHidden = true
            }
            do {
                try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
            } catch { }
        }
    }
}

extension CustomCameraControlsVC: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playButtonAction(playButton)
    }
}

