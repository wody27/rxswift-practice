//
//  ViewController.swift
//  RxSwiftProject1
//
//  Created by 이재용 on 2020/11/21.
//

import UIKit
import RxSwift

let MOVIE_LIST: String = "https://my.api.mockaroo.com/myapi.json?key=30fca5f0"

class ViewController: UIViewController {
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var editView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.timerLabel.text = "\(Date().timeIntervalSince1970)"
        }
    }
    
    private func setVisibleWithAnimation(_ v: UIView?, _ s: Bool) {
        
        guard let v = v else { return }
        UIView.animate(withDuration: 0.3, animations: { [weak v] in
            v?.isHidden = !s
        }, completion: { [weak self] _ in
            self?.view.layoutIfNeeded()
        })
    }
    
    private func download(_ url: String) -> Observable<String?> {
        
        return Observable.create { (emitter) -> Disposable in
            
            let url = URL(string: url)!
            let task = URLSession.shared.dataTask(with: url) { (data, _, error) in
                guard error == nil else  {
                    emitter.onError(error!)
                    return
                }
                
                if let dat = data, let json = String(data: dat, encoding: .utf8) {
                    emitter.onNext(json)
                    return
                }
                
                emitter.onCompleted()
            }
            
            task.resume()
            
            
            return Disposables.create() {
                task.cancel()
            }
        }
    }
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBAction func onLoad(_ sender: UIButton) {
        editView.text = ""
        setVisibleWithAnimation(activityIndicator, true)
        
        DispatchQueue.global().async {
            let url = URL(string: MOVIE_LIST)!
            let data = try! Data(contentsOf: url)
            let json = String(data: data, encoding: .utf8)
            DispatchQueue.main.async {
                self.editView.text = json
                self.setVisibleWithAnimation(self.activityIndicator, false)
            }
        }
        
    }
}

