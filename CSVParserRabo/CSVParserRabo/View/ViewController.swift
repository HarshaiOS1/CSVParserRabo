//
//  ViewController.swift
//  CSVParserRabo
//
//  Created by Krishnappa, Harsha on 27/05/2024.
//

import UIKit
import UniformTypeIdentifiers
import WebKit

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var localReadButton: UIButton!
    @IBOutlet weak var uploadCSVButton: UIButton!
    
    var viewModel = CSVParserViewModel()
    var fileURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    func updateUI() {
        self.title = "Rabo CSV Parser"
        tableView.register(UINib.init(nibName: "CSVDataCell", bundle: nil), forCellReuseIdentifier: "CSVDataCell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    @IBAction func localReadButtonAction(_ sender: Any) {
        if let fileURL = Bundle.main.url(forResource: "issues", withExtension: "csv") {
            loadFileData(fileurl: fileURL)
        } else {
            showAlert(title: "Error", message: "invalid filepath")
        }
    }
    
    @IBAction func uploadCSVButtonAction(_ sender: Any) {
        openDocumentPicker()
    }
    
    func loadFileData(fileurl: URL) {
        self.fileURL = fileurl
        Task {
            do {
                let result = try await viewModel.getCSVTableData(filePath: fileurl)
                if (viewModel.csvData?.rows.last?.columns.count ?? 0) > 6 {
                    let leftBarButtonItem = UIBarButtonItem(title: "Detail View", style: .plain, target: self, action: #selector(rightBarButtonTapped))
                    navigationItem.rightBarButtonItem = leftBarButtonItem
                } else {
                    viewModel.clearTemporaryDirectory()
                    navigationItem.rightBarButtonItem = nil
                }
                if result {
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                } else {
                    showAlert(title: "Error", message: "Error parsing CSV")
                }
            } catch {
                showAlert(title: "Error", message: "Error parsing : \(error)")
            }
        }
    }
    
    @objc func rightBarButtonTapped() {
        if let filePath = fileURL {
            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
            if let vc = storyboard.instantiateViewController(withIdentifier: "WebDetailViewController") as? WebDetailViewController {
                vc.fileURL = filePath
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func showAlert(title: String?, message: String?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func openDocumentPicker() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes:  [UTType.commaSeparatedText])
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true, completion: nil)
    }
    
    deinit {
        print("deinit - ViewContoller")
        viewModel.clearTemporaryDirectory()
    }
    
}

//MARK: UITableViewDelegate & UITableViewDataSource
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.csvData?.rows.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: CSVDataCell = tableView.dequeueReusableCell(withIdentifier: "CSVDataCell", for: indexPath) as? CSVDataCell else {
            return UITableViewCell.init()
        }
        cell.selectionStyle = .none
        if let row = viewModel.csvData?.rows[indexPath.row] {
            cell.updateRow(row: row)
        } else {
            cell.updateRow(row: CSVRow(columns: ["No data to display, Please select .csv file"]))
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
}

//MARK: UIDocumentPickerDelegate
extension ViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedFileURL = urls.first else { return }
        if !(selectedFileURL.pathExtension == "csv") {
            showAlert(title: "Error", message: "Please select .csv file type")
            return
        }
        viewModel.clearTemporaryDirectory()
        let result = viewModel.tempSaveFile(selectedFileURL: selectedFileURL)
        if let url = result.0 {
            loadFileData(fileurl: url)
        } else  {
            showAlert(title: "Error", message: result.1 ?? "error reading file")
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        showAlert(title: "Alert", message: "Cancelled with out selecting file")
    }
}
