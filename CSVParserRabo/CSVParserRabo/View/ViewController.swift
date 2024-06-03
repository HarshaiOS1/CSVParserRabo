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
    @IBOutlet weak var localReadButton: UIButton!
    @IBOutlet weak var uploadCSVButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var viewModel = CSVParserViewModel()
    var fileURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Rabo CSV Parser"
        loadCollectionView()
    }
    
    func loadCollectionView() {
        collectionView.register(CSVCell.self, forCellWithReuseIdentifier: "CSVCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        collectionView.collectionViewLayout = layout
        
        collectionView.alwaysBounceVertical = true
        collectionView.alwaysBounceHorizontal = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    @IBAction func localReadButtonAction(_ sender: Any) {
        if let fileURL = Bundle.main.url(forResource: "customers-1000", withExtension: "csv") {
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
                        self.collectionView.reloadData()
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

//MARK: UICollectionViewDataSource & UICollectionViewDelegateFlowLayout
extension ViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.csvData?.rows.count ?? 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.csvData?.rows[section].columns.count ?? 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CSVCell", for: indexPath) as! CSVCell
        if let data = viewModel.csvData?.rows {
            if indexPath.section == 0 {
                
                cell.label.text = data.first?.columns[indexPath.item]
                return cell
            } else {
                cell.label.text = data[indexPath.section].columns[indexPath.item]
                return cell
            }
        } else {
            cell.label.text = "No data"
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfColumns = viewModel.csvData?.rows.first?.columns.count ?? 1
        let width = collectionView.bounds.width / CGFloat(numberOfColumns)
        return CGSize(width: width, height: 50)
    }
}
