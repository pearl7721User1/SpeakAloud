//
//  DictationViewController.swift
//  SpeakAloud
//
//  Created by SeoGiwon on 17/10/2018.
//  Copyright © 2018 SeoGiwon. All rights reserved.
//

import UIKit
import Speech
import CoreData

protocol TranscriptSaveDelegate {
    func save(transcript: String)
}

class DictationViewController: UIViewController, SFSpeechRecognizerDelegate {

    // MARK: Properties
    private let engSpeechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    private let korSpeechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ko-KR"))!
    private weak var theSpeechRecognizer: SFSpeechRecognizer?
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    private let audioEngine = AVAudioEngine()
    
    @IBOutlet var textView : UITextView!
    @IBOutlet var recorderSignal : UIView!
    @IBOutlet weak var saveButton: UIButton!
    
    var transcripts: [Transcript] = [Transcript]() {
        didSet {
            self.saveButton.isEnabled = transcripts.count > 0 ? true : false
            
        }
    }
    
    
    private var managedContext: NSManagedObjectContext!
    
    var shouldStartAutomatically = false
    private var recorderUIStatus = 0 {
        didSet {
            
            switch recorderUIStatus {
            case -1:
                recorderSignal.backgroundColor = notReadyColor
                textView.text = languageSegmentControl.selectedSegmentIndex == 0 ? "(Not ready yet)" : "아직 준비 안 되었음"
                
            case 0:
                recorderSignal.backgroundColor = readyColor
                textView.text = languageSegmentControl.selectedSegmentIndex == 0 ? "(Tap on the button)" : "버튼을 누르시오"
            case 1:
                recorderSignal.backgroundColor = onAirColor
                textView.text = languageSegmentControl.selectedSegmentIndex == 0 ? "(Go ahead, I'm listening)" : "어서 말하시오"
            default:
                recorderSignal.backgroundColor = notReadyColor
                textView.text = languageSegmentControl.selectedSegmentIndex == 0 ? "(Not ready yet)" : "아직 준비 안 되었음"
            }
        }
    }
    
    private let notReadyColor = UIColor.red
    private let onAirColor = UIColor.blue
    private let readyColor = UIColor.green
    private var shouldSaveTranscript = false
    @IBOutlet var tapGestureRecognizer: UITapGestureRecognizer!
    
    var transcriptSaveDelegate: TranscriptSaveDelegate?
    
    @IBOutlet weak var languageSegmentControl: UISegmentedControl!
    @IBAction func languageSegmentValueChanged(_ sender: UISegmentedControl) {
        
        // switch the selected speech recognizer
        theSpeechRecognizer = sender.selectedSegmentIndex == 0 ? engSpeechRecognizer : korSpeechRecognizer
        
        // end audio
        endAudioEngine()
        
        // reflect ui
        recorderUIStatus = 0
    }
    
    
    @IBAction func tapped(_ sender: UITapGestureRecognizer) {
        
        guard recorderUIStatus != -1 else {
            return
        }
        
        if recorderUIStatus == 1 {
            addTranscript(text: textView.text)
            shouldStartAutomatically = false
        }
        
        recordButtonTapped()
    }
    
    @objc func shakeGestureHandler() {
        
        if audioEngine.isRunning {
            recordButtonTapped()
            
            shouldStartAutomatically = true
        }
        
    }
    
    // MARK: UIViewController
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        managedContext = (UIApplication.shared.delegate as! AppDelegate).coreDataStack.persistentContainer.viewContext
            
            
        NotificationCenter.default.addObserver(self, selector: #selector(shakeGestureHandler), name: NSNotification.Name(rawValue: "shaked"), object: nil)
        
        // Disable the record buttons until authorization has been granted.
        self.recorderUIStatus = 0
        
        saveButton.isEnabled = false
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(setDictationStatusToReady), name: NSNotification.Name(rawValue: "SpeechRecognitionTaskCleared"), object: nil)
        
        theSpeechRecognizer = languageSegmentControl.selectedSegmentIndex == 0 ? engSpeechRecognizer : korSpeechRecognizer
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        engSpeechRecognizer.delegate = self
        korSpeechRecognizer.delegate = self
        
        SFSpeechRecognizer.requestAuthorization { authStatus in
            /*
             The callback may not be called on the main thread. Add an
             operation to the main queue to update the record button's state.
             */
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    self.recordButtonTapped()
                default:
                    self.recorderUIStatus = 0
                    
                }
            }
        }
    }
    
    // MARK: - Recording
    private func startRecording(speechRecognizer: SFSpeechRecognizer) throws {
        
        // Cancel the previous task if it's running.
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(AVAudioSessionCategoryRecord)
        try audioSession.setMode(AVAudioSessionModeMeasurement)
        try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        
        
        
//        guard let inputNode = audioEngine.inputNode else { fatalError("Audio engine has no input node") }
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object") }
        
        // Configure request so that results are returned before audio recording is finished
        recognitionRequest.shouldReportPartialResults = true
        
        // A recognition task represents a speech recognition session.
        // We keep a reference to the task so that it can be cancelled.
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false
            
            if let result = result {
                self.textView.text = result.bestTranscription.formattedString
                isFinal = result.isFinal
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "SpeechRecognitionTaskCleared"), object: nil)
                
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        
        inputNode.installTap(onBus: 0, bufferSize: 1024*5, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        try audioEngine.start()
        
//        textView.text = "(Go ahead, I'm listening)"
    }
    
    private func endAudioEngine() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
    }
    
    @objc func setDictationStatusToReady() {
        self.recorderUIStatus = 0
        if self.shouldStartAutomatically {
            self.recordButtonTapped()
        }
    }
    
    // MARK: SFSpeechRecognizerDelegate
    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        
        print("Delegate called")
        
        if available {
            
            print("Available")
            
            self.recorderUIStatus = 0
        } else {
            self.recorderUIStatus = -1
        }
    }
    
    // MARK: Core Data functions
    private func addTranscript(text: String) {
        
        let transcript = Transcript(context: self.managedContext)
        transcript.timeStamp = Date() as NSDate
        transcript.text = text
        transcript.languageCode = theSpeechRecognizer?.locale.identifier ?? ""
        
        transcripts.append(transcript)
    }
    
    private func createTranscriptsAtTheTime() -> Bool {
        
        let transcriptsAtTheTime = TranscriptsAtTheTime(context: self.managedContext)
        transcriptsAtTheTime.count = Int16(transcripts.count)
        transcriptsAtTheTime.startTime = {
            
            let earliestTranscript: Transcript = transcripts.reduce(transcripts[0], { (transcript1, transcript2) in
                
                if let lValue = transcript1.timeStamp?.timeIntervalSince1970,
                    let rValue = transcript2.timeStamp?.timeIntervalSince1970 {
                    
                    return lValue < rValue ? transcript1 : transcript2
                    
                } else {
                    fatalError("couldn't create timeStamp")
                }
            })
            
            return earliestTranscript.timeStamp
        }()
        
        transcriptsAtTheTime.endTime = {
            
            let mostRecentTranscript: Transcript = transcripts.reduce(transcripts[0], { (transcript1, transcript2) in
                
                if let lValue = transcript1.timeStamp?.timeIntervalSince1970,
                    let rValue = transcript2.timeStamp?.timeIntervalSince1970 {
                    
                    return lValue > rValue ? transcript1 : transcript2
                    
                } else {
                    fatalError("couldn't create timeStamp")
                }
            })
            
            return mostRecentTranscript.timeStamp
        }()
        
        transcriptsAtTheTime.isMadeOf = NSOrderedSet(array: transcripts)
        
        for (_,v) in transcripts.enumerated() {
            v.contributes = transcriptsAtTheTime
        }
        
        do {
            try managedContext.save()
        } catch {
            print("couldn't save transcriptsAtTheTime")
            return false
        }
        
        return true
    }
    
    // MARK: Interface Builder actions    
    private func recordButtonTapped() {
        if audioEngine.isRunning {
            
            print("----------- stop")
            print("recordButtonTapped")
            
            endAudioEngine()
            self.recorderUIStatus = -1
        } else {
            
            print("----------- willStartRecording")
            print("recordButtonTapped")
            
            if let theSpeechRecognizer = theSpeechRecognizer {
                try! startRecording(speechRecognizer: theSpeechRecognizer)
                self.recorderUIStatus = 1
            } else {
                fatalError("theSpeechRecognizer is nil at the moment")
            }
            
        }
    }
    
    
    @IBAction func testCloudKitBtnTapped(_ sender: UIBarButtonItem) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let navigationVC = storyboard.instantiateViewController(withIdentifier: "CloudKitNavigationController") as? UINavigationController {
            
            self.present(navigationVC, animated: true, completion: nil)
            
        }
    }
    
    @IBAction func showTranscriptsBtnTapped(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let navigationVC = storyboard.instantiateViewController(withIdentifier: "TranscriptsArchiveNavigationController") as? TranscriptsArchiveNavigationController {
            
            navigationVC.transcriptsArchiveViewController.managedContext = self.managedContext
            navigationVC.transcriptsArchiveViewController.fetchRequest = TranscriptsAtTheTime.fetchRequest()
            self.present(navigationVC, animated: true, completion: nil)
            
        }
    }
    
    @IBAction func saveBtnTapped(_ sender: UIButton) {
        
        let isCreated = createTranscriptsAtTheTime()
        
        if (isCreated) {
            transcripts.removeAll()
        }
    }
    
}

