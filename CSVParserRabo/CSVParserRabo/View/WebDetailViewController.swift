//
//  WebDetailViewController.swift
//  CSVParserRabo
//
//  Created by Krishnappa, Harsha on 31/05/2024.
//

import Foundation
import UIKit
import WebKit

class WebDetailViewController: UIViewController {
    @IBOutlet weak var webView: WKWebView!
    var fileURL: URL?
    var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    func updateUI() {
        title = "Detail View"
        webView.navigationDelegate = self
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .large
        self.view.addSubview(activityIndicator)
        if let filePath = fileURL {
            webView.load(URLRequest.init(url: filePath))
        }
    }
}

//MARK: WKNavigationDelegate
extension WebDetailViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        activityIndicator.stopAnimating()
    }
}
