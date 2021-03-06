/*------------------------------------------------------------------------------
 *
 *  ViewController.swift
 *
 *  For full information on usage and licensing, see https://chirp.io/
 *
 *  Copyright © 2011-2019, Asio Ltd.
 *  All rights reserved.
 *
 *----------------------------------------------------------------------------*/

import UIKit
import AVFoundation
import CryptoSwift


class ViewController: UIViewController, UITextViewDelegate {
    
    let key = Array<UInt8>(arrayLiteral: 0x43, 0x68, 0x69, 0x72, 0x70, 0x20, 0x48, 0x61, 0x63, 0x6b, 0x61, 0x74, 0x68, 0x6f, 0x6e, 0x21)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add padding to textViews
        self.inputText.textContainerInset = UIEdgeInsets(top: 15, left: 10, bottom: 15, right: 10)
        self.receivedText.textContainerInset = UIEdgeInsets(top: 15, left: 10, bottom: 15, right: 10)
        
        // Set up some colours for buttons
        self.sendButton.setTitleColor(UIColor.white, for: .disabled)
        let chirpGrey: UIColor = UIColor(red: 84.0 / 255.0, green: 84.0 / 255.0, blue: 84.0 / 255.0, alpha: 1.0)
        let chirpBlue: UIColor = UIColor(red: 43.0 / 255.0, green: 74.0 / 255.0, blue: 201.0 / 255.0, alpha: 1.0)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if let sdk = appDelegate.sdk {
            
            print(sdk.version)
            sdk.sendingBlock = {
                (data : Data?, channel: UInt?) -> () in
                self.sendButton.isEnabled = false
                self.sendButton.setTitle("SENDING", for: .normal)
                self.sendButton.backgroundColor = chirpGrey
                return;
            }
            
            sdk.sentBlock = {
                (data : Data?, channel: UInt?) -> () in
                self.sendButton.isEnabled = true
                self.sendButton.setTitle("SEND", for: .normal)
                self.sendButton.backgroundColor = chirpBlue
                return;
            }
            
            sdk.receivingBlock = {
                (channel: UInt?) -> () in
                self.sendButton.isEnabled = false
                self.sendButton.setTitle("RECEIVING", for: .normal)
                self.sendButton.backgroundColor = chirpGrey
                self.receivedText.text = "...."
                return;
            }
            
            sdk.receivedBlock = {
                (data : Data?, channel: UInt?) -> () in
                self.sendButton.isEnabled = true
                self.sendButton.setTitle("SEND", for: .normal)
                self.sendButton.backgroundColor = chirpBlue
                if let data = data {
                    
                    let iv: Array<UInt8> = self.generateIv()
                    let decrypted = Data(try! AES(key: self.key, blockMode: CTR(iv: iv), padding: .noPadding).decrypt(data.bytes))
                    
                    if let payload = String(data: decrypted, encoding: .ascii) {
                        self.receivedText.text = payload
                        print(String(format: "Received: %@", payload))
                    } else {
                        print("Failed to decode payload!")
                    }
                } else {
                    print("Decode failed!")
                }
                return;
            }
        }
    }
    
    /*
     * Generate a simple initialisation vector by hashing
     * the key and the current timestamp.
     */
    func generateIv() -> Array<UInt8> {
        let date: Date = Date()
        let hour = Calendar.current.component(.hour, from: date)
        let minute = Calendar.current.component(.minute, from: date)
        var preHash = Array<UInt8>()
        preHash += self.key
        preHash.append(UInt8(hour))
        preHash.append(UInt8(minute))
        let hash = preHash.sha256()
        let iv: Array<UInt8> = Array<UInt8>(hash[0...15])
        return iv
    }
    
    /*
     * Convert inputText to NSData and send to the speakers.
     * Check volume is turned up enough before doing so.
     */
    func sendInput() {
        if AVAudioSession.sharedInstance().outputVolume < 0.1 {
            let errmsg = "Please turn the volume up to send messages"
            let alert = UIAlertController(title: "Alert", message: errmsg, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            if let sdk = appDelegate.sdk {
                let data = self.inputText.text.data(using: .utf8)
                if let data = data {
                    let iv: Array<UInt8> = self.generateIv()
                    let encrypted = Data(try! AES(key: self.key, blockMode: CTR(iv: iv), padding: .noPadding).encrypt(data.bytes))
                    if let error = sdk.send(encrypted) {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    /*
     * Clear the inputText on click.
     */
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.inputText.text = ""
    }
    
    @IBAction func send(_ sender: Any) {
        self.sendInput()
    }
    
    /*
     * Check the length of the data does not exceed
     * the max payload length.
     * Catch any return keys in the inputText view
     * and close the keyboard.
     */
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        let data = self.inputText.text.data(using: .utf8)
        if let data = data {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            if let sdk = appDelegate.sdk {
                if data.count >= sdk.maxPayloadLength, text != "" {
                    return false
                }
            }
        }
        return true
    }
    
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var inputText: UITextView!
    @IBOutlet var receivedText: UITextView!
}

