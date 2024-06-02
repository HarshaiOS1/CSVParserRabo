//
//  WebDetailViewControllerTests.swift
//  CSVParserRaboTests
//
//  Created by Krishnappa, Harsha on 02/06/2024.
//

import XCTest
import UIKit
import WebKit
@testable import CSVParserRabo

class WebDetailViewControllerTests: XCTestCase {
    var webDetailViewController : WebDetailViewController!
    var expectation: XCTestExpectation!
    
    override func setUpWithError() throws {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(identifier: "WebDetailViewController") as? WebDetailViewController {
            webDetailViewController = vc
            webDetailViewController.loadViewIfNeeded()
        }
    }
    
    func testWebViewLoadsCSV() {
        expectation = self.expectation(description: "Web view loads CSV file")
        guard let webView = webDetailViewController.webView else {
            XCTFail("WebView is not initialized")
            return
        }
        webView.navigationDelegate = self
        if let url = Bundle.main.url(forResource: "issues", withExtension: "csv") {
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        } else {
            XCTFail("File not found")
        }
        wait(for: [expectation], timeout: 5.0)
    }
}

//MARK: WKNavigationDelegate
extension WebDetailViewControllerTests: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        expectation.fulfill()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: any Error) {
        XCTFail("WebView \(error.localizedDescription)")
    }
}
