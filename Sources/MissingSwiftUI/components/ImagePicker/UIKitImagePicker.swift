//
//  UIKitImagePicker.swift
//  Social
//
//  Created by Nikita Evstigneev on 25/09/2020.
//

import SwiftUI

struct UIKitImagePicker: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = UIImagePickerController
    
    var sourceType: UIImagePickerController.SourceType?
    var mediaTypes: [String]
    var allowsEditing: Bool
    @Binding var isPresented: Bool
    @Binding var pickedMediaWithInfo: [UIImagePickerController.InfoKey: Any]?
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.allowsEditing = allowsEditing
        picker.delegate = context.coordinator
        picker.sourceType = sourceType ?? .photoLibrary
        picker.mediaTypes = mediaTypes
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        uiViewController.delegate = context.coordinator
        uiViewController.sourceType = sourceType ?? .photoLibrary
        uiViewController.mediaTypes = mediaTypes
        uiViewController.allowsEditing = allowsEditing
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(isPresented: $isPresented, pickedMediaWithInfo: $pickedMediaWithInfo)
    }
}

extension UIKitImagePicker {
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        
        @Binding var isPresented: Bool
        @Binding var pickedMediaWithInfo: [UIImagePickerController.InfoKey: Any]?
        
        // pickedImage = (info[.editedImage] as? UIImage)?.withUpOrientation()
        init(isPresented: Binding<Bool>, pickedMediaWithInfo: Binding<[UIImagePickerController.InfoKey: Any]?>) {
            self._isPresented = isPresented
            self._pickedMediaWithInfo = pickedMediaWithInfo
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            pickedMediaWithInfo = info
            isPresented = false
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            isPresented = false
        }
    }
}
