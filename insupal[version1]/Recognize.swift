//
//  Recognize.swift
//  SpeechToTextApp
//
//  Created by vander Ouana on 7/14/18.
//  Copyright © 2018 Insupal. All rights reserved.
//
import UIKit
import Foundation
import Speech
import AVFoundation

class Recognize
{
    private var authorized : Bool!
    private var recognitionResult: String!
    private let audioEngine = AVAudioEngine()
    private let request = SFSpeechAudioBufferRecognitionRequest()
    private let speechRecognizer : SFSpeechRecognizer? = SFSpeechRecognizer()
    private var recognitionTask: SFSpeechRecognitionTask?
    private var textField: UITextField!
    
    
    //Add to info list
    //Speech Recognition Usage
    //Microphone Usage Description
    public init(textField: UITextField )
    {
        
        self.textField = textField
        
        requestAuth()
        if(authorized != nil && authorized )
        {
            audioEngine.prepare()
            
        }else
        {
            print("Speech recognition not authorized")
        }
        
    }
    
    
    func requestAuth()
    {
        //let authorized: bool =
        SFSpeechRecognizer.requestAuthorization {authStatus  in
            if(authStatus == SFSpeechRecognizerAuthorizationStatus.authorized){
                self.authorized = true
                print("This request was previously authorized")
                //return true
            }else
            {
                self.authorized = false
                
                //return false
            }
            
        }
        
    }
    
    func stopRecording()
    {
        //stop recording
        
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionTask?.finish()
        if(!audioEngine.isRunning)
        {
            print("audio engine stopped running!")
        }
        
        
    }
    
    
    
    
    
    func recordAndRecognize()
    {
        //else { return }
        
        
        print("starting a new recording...")
        
        let node = audioEngine.inputNode
        
        if(node == nil)
        {
            return
        }
        
        
        
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0 , bufferSize: 1024, format: recordingFormat){ buffer, _ in self.request.append(buffer)}
        
        
        do
        {
            //start recording
            try audioEngine.start()
        }catch
        {
            print(error)
        }
        
        
        guard let myRecognizer = SFSpeechRecognizer()
            else{
                //recognizer not supported for the current localereturn
                return
        }
        
        if !myRecognizer.isAvailable
        {
            //recognizer is not available
            return
        }
        
        
        
        //let request: SFSpeechRecognizer? = SFSpeechRecognizer()
        
        recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { result, error in
            
            if let result = result{
                
                self.recognitionResult = result.bestTranscription.formattedString
                self.textField.text = self.recognitionResult
                print("Recognized: \(self.recognitionResult) ")
                
            } else if let error = error{
                print(error)
            }
            
        } )
        
        
        
        //return self.recognitionResult
    }
    
    
}







/*
 func recognize (path : URL)->String?
 {
 var res : String = ""
 //set up recognizer
 let recognizer : SFSpeechRecognizer? = SFSpeechRecognizer()
 //create recognition request
 let request  = SFSpeechURLRecognitionRequest(url : path)
 //recognize
 recognizer?.recognitionTask(with : request){(result , error) in
 if let error = error {
 print("There was an error \(error)")
 
 }else
 {
 res = (result?.bestTranscription.formattedString)!
 }
 
 }
 
 
 
 return res
 }*/














