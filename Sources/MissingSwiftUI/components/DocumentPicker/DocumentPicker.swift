//
//  DocumentPickerBridgeView.swift
//  HousePlan
//
//  Created by Nikita Evstigneev on 19/10/2020.
//

import UIKit
import SwiftUI
import UniformTypeIdentifiers

public struct DocumentPicker: UIViewControllerRepresentable {
    
    public enum Mode {
        case export([URL])
        case `import`([UTType])
    }
    
    public typealias DocumentPickedCallback = ([URL]) -> Void
    public typealias UIViewControllerType = UIDocumentPickerViewController
    
    public class Coordinator: NSObject {
        var onDocumentsPicked: DocumentPickedCallback?
    }
    
    let mode: Mode
    let onDocumentsPicked: DocumentPickedCallback?
    
    public init(mode: Mode, onDocumentsPicked: DocumentPickedCallback? = nil) {
        self.mode = mode
        self.onDocumentsPicked = onDocumentsPicked
    }
    
    public func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let vc: UIDocumentPickerViewController
        switch mode {
        case .export(let urls):
            vc = UIDocumentPickerViewController(forExporting: urls)
        case .import(let types):
            vc = UIDocumentPickerViewController(forOpeningContentTypes: types)
        }
        vc.delegate = context.coordinator
        context.coordinator.onDocumentsPicked = onDocumentsPicked
        return vc
    }
    
    public func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
        context.coordinator.onDocumentsPicked = onDocumentsPicked
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
}

extension DocumentPicker.Coordinator: UIDocumentPickerDelegate {
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        onDocumentsPicked?(urls)
    }
}
