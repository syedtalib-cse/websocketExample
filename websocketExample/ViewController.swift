//
//  ViewController.swift
//  websocketExample
//
//  Created by Talib on 02/02/24.
//

import UIKit

class ViewController: UIViewController {
    private var webSocketTask:URLSessionWebSocketTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .blue
        callApiUsingWS()
        
       
    }
    
    //WebSocket Implementation
    
    func callApiUsingWS(){
        
        let session =  URLSession(configuration:.default, delegate:self, delegateQueue:OperationQueue())
        
        guard  let url = URL(string:"wss://winbull.in:3002/socket.io/?EIO=3&transport=websocket") else {return}
        
        webSocketTask  = session.webSocketTask(with:url)
        webSocketTask?.resume()
        
    }
    
    
    func ping(){
        
        
        webSocketTask?.sendPing { error in
            
            if let error = error{
                print("Ping error:\(error)")
                
            }
            
        }
        
    }
    func send(){
        DispatchQueue.global().asyncAfter(deadline:.now()+1) {
            self.send()
            self.webSocketTask?.send(.string("Send new Message : \(Int.random(in:1...1000))"))  { error in
               
                if let  error = error{
                    print("Send error:\(error)")
                    
                }
            }
        }
}
    func receive(){
        
        webSocketTask?.receive {[weak self] result in
            
            switch result{
                
                
            case .success(let message):
                
                switch message {
                case .data(let data):
                    
                    print("Got Data:\(data)")
                    
                case .string(let message):
                    
                    print("Got String:\(message)")
                   
                @unknown default:
                   break
                }
            case .failure(let error):
                print("Receive error:\(error)")
                
            }
            self?.receive()
            
            
        }
        
        
        
        
        
    }
    func close(){
        
        webSocketTask?.cancel(with:.goingAway, reason:"Demo ended".data(using:.utf8))
        
    }
    
    
    
   
}





//MARK WebSocket Implementation
extension ViewController:URLSessionWebSocketDelegate{
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        
        print("Did Connect to Socket")
        ping()
        receive()
        send()
        
        
        
    }
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        
        print("Did Close Connection with reason")
        
    }
    
    
    
}
