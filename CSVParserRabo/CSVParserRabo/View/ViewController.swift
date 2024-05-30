//
//  ViewController.swift
//  CSVParserRabo
//
//  Created by Krishnappa, Harsha on 27/05/2024.
//

import UIKit
import UniformTypeIdentifiers

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var localReadButton: UIButton!
    @IBOutlet weak var uploadCSVButton: UIButton!
    
    var viewModel = CSVParserViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
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
        Task {
            do {
                let result = try await viewModel.getCSVTableData(filePath: fileurl)
                viewModel.clearTemporaryDirectory()
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
    
    func showAlert(title: String?, message: String?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func openDocumentPicker() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.commaSeparatedText, UTType.content, UTType.plainText])
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true, completion: nil)
    }
    
    func updateUI() {
        tableView.register(UINib.init(nibName: "CSVDataCell", bundle: nil), forCellReuseIdentifier: "CSVDataCell")
        tableView.delegate = self
        tableView.dataSource = self
    }
}

//MARK: UITableViewDelegate & UITableViewDataSource
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.csvData?.rows.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.width, height: 50.0))
        if viewModel.csvData?.rows.count ?? 0 == 0 {
            cell.textLabel?.text = "No data to display"
            return cell
        }
        guard let cell: CSVDataCell = tableView.dequeueReusableCell(withIdentifier: "CSVDataCell", for: indexPath) as? CSVDataCell else {
            return UITableViewCell.init()
        }
        
        if let row = viewModel.csvData?.rows[indexPath.row] {
            cell.updateRow(row: row)
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
        
        if (selectedFileURL.pathExtension != "numbers" || selectedFileURL.pathExtension != "csv") {
            showAlert(title: "Error", message: "Not .csv file type")
            return
        }
        let result = viewModel.tempSaveFile(selectedFileURL: selectedFileURL)
        if let url = result.0 {
            loadFileData(fileurl: url)
        } else  {
            showAlert(title: "Error", message: result.1 ?? "error reading file")
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("Document picker was cancelled")
    }
}
