//
//  ViewController.swift
//  BackgroundDetectorUIKit
//
//  Created by David G. Young on 2/24/24.
//

import UIKit
import MessageUI
class ViewController: UIViewController, MFMailComposeViewControllerDelegate {
    var appDelegate: AppDelegate!
    
    @IBOutlet weak var logTextView: UITextView!
    @IBOutlet weak var minor2: UITextField!
    @IBOutlet weak var minor1: UITextField!
    @IBOutlet weak var major1: UITextField!
    @IBOutlet weak var major2: UITextField!
    @IBOutlet weak var uuid: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.appDelegate = UIApplication.shared.delegate as? AppDelegate
        self.appDelegate.vc = self
        self.logTextView.text = appDelegate.getLog()
        self.uuid.text = appDelegate.uuid
        self.major1.text = String(appDelegate.major1)
        self.major2.text = String(appDelegate.major2)
        self.minor1.text = String(appDelegate.minor1)
        self.minor2.text = String(appDelegate.minor2)
    }
    
    @IBAction func updateBeaconIdentifiersTapped(_ sender: Any) {
        if UUID(uuidString: uuid.text ?? "") == nil {
            let alert = UIAlertController(title: "Illegal UUID", message: "Must be of the format 030013ac-4202-55bc-ea11-c75f806bb32", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true, completion: nil)
            return
        }
        if UInt16(major1.text ?? "") == nil {
            let alert = UIAlertController(title: "Illegal major1", message: "Must be of between 0 and 65535", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true, completion: nil)
            return
        }
        if UInt16(major2.text ?? "") == nil {
            let alert = UIAlertController(title: "Illegal major2", message: "Must be of between 0 and 65535", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true, completion: nil)
            return
        }
        if UInt16(minor1.text ?? "") == nil {
            let alert = UIAlertController(title: "Illegal minor1", message: "Must be of between 0 and 65535", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true, completion: nil)
            return
        }
        if UInt16(minor2.text ?? "") == nil {
            let alert = UIAlertController(title: "Illegal minor2", message: "Must be of between 0 and 65535", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true, completion: nil)
            return
        }
        appDelegate.uuid = uuid.text ?? ""
        appDelegate.major1 = UInt16(major1.text ?? "") ?? 0
        appDelegate.major2 = UInt16(major2.text ?? "") ?? 0
        appDelegate.minor1 = UInt16(minor1.text ?? "") ?? 0
        appDelegate.minor2 = UInt16(minor2.text ?? "") ?? 0
        appDelegate.restartMonitoring()
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    
    @IBAction func emailTapped(_ sender: Any) {
        if let data = appDelegate.getLog().data(using: .utf8) {
            if( MFMailComposeViewController.canSendMail() ) {
                let mailComposer = MFMailComposeViewController()
                
                //Set the subject and message of the email
                mailComposer.setSubject("Beacon Detector Logs")
                mailComposer.setMessageBody("", isHTML: false)
                mailComposer.mailComposeDelegate = self
                
                mailComposer.addAttachmentData(data, mimeType: "text/txt", fileName: "data")
                
                self.present(mailComposer, animated: true, completion: {
                    NSLog("Done!")

                })
            }
        }
        
    }
    
        func mailComposeController(_ controller: MFMailComposeViewController,
                                   didFinishWith result: MFMailComposeResult,
                                   error: Error?) {
            switch result {
            case .sent:
                print("Email sent")
            case .saved:
                print("Draft saved")
            case .cancelled:
                print("Email cancelled")
            case  .failed:
                print("Email failed")
            @unknown default:
                print("unknown event")
            }
            controller.dismiss(animated: true, completion: nil)
        }
    
    
    public func updateLog(log: String) {
        self.logTextView.text = log
    }
    @IBAction func clearLog(_ sender: Any) {
        appDelegate.clearLog()
        self.logTextView.text = ""
    }
    
}

