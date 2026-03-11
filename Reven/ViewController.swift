//
//  ViewController.swift
//  Reven
//
//  Created by reveantivirus on 10/11/25.
//

import UIKit
import ReveChatSDK_CPrime

class ViewController: UIViewController, ChatBotEventDelegate {
    
    
    func onChatBotEvent(_ eventType: String) {
        print("ChatBot Event Received: \(eventType)")
        
        if eventType != "" {
            Toast.show("Event : \(eventType)")
        }
    }

    deinit {
        // Unregister to avoid retain cycles
        ReveChatManager.shared().removeChatBotEventDelegate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
       

        let provider = MyCustomerProvider()
        ReveChatManager.shared().setCustomerProvider(provider)
        ReveChatManager.setLogger(FileLogger.shared)

                // Optional App-side log
        FileLogger.shared.log("App started")
       
    }
    
    @IBAction func getRequestTapped(_ sender: UIButton) {
        
        
        
        
        FileLogger.shared.log("========== BUTTON TAP ==========")

            getURL_1 {
                FileLogger.shared.log("URL 1 finished")

                self.getURL_2 {
                    FileLogger.shared.log("URL 2 finished")

                    DispatchQueue.main.async {
                        self.showFinishedAlert()
                    }
                }
            }
    }
    
    func showFinishedAlert() {
        let alert = UIAlertController(
            title: "Done",
            message: "Both requests are finished",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @IBAction func exportLogsTapped(_ sender: UIButton) {
        
        DispatchQueue.main.async {
            self.exportLogs(from: self)
        }
    }
    
    func exportLogs(from vc: UIViewController) {
        let url = FileLogger.shared.logFileURL()

        let activityVC = UIActivityViewController(
            activityItems: [url],
            applicationActivities: nil
        )

        vc.present(activityVC, animated: true)
    }
    
    
    
    func getURL_1(completion: @escaping () -> Void) {

        FileLogger.shared.log("GET REQUEST")
        FileLogger.shared.log("URL ===> https://revesystem-admin.primenow.ai/")

        let url = URL(string: "https://revesystem-admin.primenow.ai/")!

        URLSession.shared.dataTask(with: url) { data, response, error in

            if let error = error {
                FileLogger.shared.log("Error for URL ==> https://revesystem-admin.primenow.ai/: \(error)")
                completion()
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                FileLogger.shared.log("Status code URL ==> https://revesystem-admin.primenow.ai/: \(httpResponse.statusCode)")
            }

            if let data = data {
                FileLogger.shared.log(
                    "DATA URL ==> https://revesystem-admin.primenow.ai/: \(String(data: data, encoding: .utf8) ?? "<non-utf8>")"
                )
            }

            completion()
        }.resume()
    }
    
    
    
    
    func getURL_2(completion: @escaping () -> Void) {

        FileLogger.shared.log("GET REQUEST")
        FileLogger.shared.log("URL ===> https://revesystem-admin.primenow.ai/chat-server")

        let url = URL(string: "https://revesystem-admin.primenow.ai/chat-server")!

        URLSession.shared.dataTask(with: url) { data, response, error in

            if let error = error {
                FileLogger.shared.log("Error for URL ==> https://revesystem-admin.primenow.ai/chat-server: \(error)")
                completion()
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                FileLogger.shared.log("Status code URL ==> https://revesystem-admin.primenow.ai/chat-server: \(httpResponse.statusCode)")
            }

            if let data = data {
                FileLogger.shared.log(
                    "DATA URL ==> https://revesystem-admin.primenow.ai/chat-server: \(String(data: data, encoding: .utf8) ?? "<non-utf8>")"
                )
            }

            completion()
        }.resume()
    }

    
    

    @IBAction func chat(_ sender: UIButton) {
        
        ReveChatManager.shared().setupAccount(with: "4737559")
        
        
        
        ReveChatManager.shared()?.initiateReveChat(with: "abcd", visitorEmail: "abcd@gmail.com", visitorMobile: "123456789", onNavigationViewController: self.navigationController)
        
        ReveChatManager.shared().chatBotEventDelegate = self
    }
    
    
    
    
    
    
    
}


class Toast {
    static func show(_ message: String, duration: Double = 2.0) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }

        let toastLabel = UILabel()
        toastLabel.text = message
        toastLabel.textColor = .white
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        toastLabel.textAlignment = .center
        toastLabel.font = .systemFont(ofSize: 14)
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        toastLabel.numberOfLines = 0

        let padding: CGFloat = 20
        let maxWidth = window.frame.width - 40
        let textSize = toastLabel.sizeThatFits(CGSize(width: maxWidth, height: .greatestFiniteMagnitude))
        toastLabel.frame = CGRect(x: 20, y: window.frame.height - 120, width: maxWidth, height: textSize.height + padding)

        toastLabel.alpha = 0.0
        window.addSubview(toastLabel)

        UIView.animate(withDuration: 0.3, animations: {
            toastLabel.alpha = 1.0
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: duration, options: .curveEaseOut, animations: {
                toastLabel.alpha = 0.0
            }) { _ in
                toastLabel.removeFromSuperview()
            }
        }
    }
}


@objc class FileLogger: NSObject, AppLogger {

    @objc static let shared = FileLogger()
    private let fileURL: URL
    private let queue = DispatchQueue(label: "file.logger.queue")

    private override init() {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.fileURL = dir.appendingPathComponent("app.log")

        if !FileManager.default.fileExists(atPath: fileURL.path) {
            FileManager.default.createFile(atPath: fileURL.path, contents: nil)
        }

        super.init()
    }

    @objc func log(_ message: String) {
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let line = "[\(timestamp)] \(message)\n"

        queue.async {
            if let data = line.data(using: .utf8),
               let handle = try? FileHandle(forWritingTo: self.fileURL) {
                handle.seekToEndOfFile()
                handle.write(data)
                handle.closeFile()
            }
        }
    }

    @objc func logFileURL() -> URL {
        return fileURL
    }
}
