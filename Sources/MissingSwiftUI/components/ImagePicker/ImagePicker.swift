//
//  ImagePicker.swift
//  Social
//
//  Created by Nikita Evstigneev on 25/09/2020.
//

import SwiftUI
import MobileCoreServices

public struct ImagePickerViewModifier: ViewModifier {
    @Binding var isPresented: Bool
    @Binding var pickedImage: UIImage?
    
    @State private var sourceType: UIImagePickerController.SourceType?
    @State private var isPickingSourceType = false
    @State private var isPickingImage = false
    @State private var pickedInfo: [UIImagePickerController.InfoKey: Any]?
    
    public func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPickingImage) {
                let info = Binding<[UIImagePickerController.InfoKey: Any]?>(
                    get: { pickedInfo }) { (info) in
                    pickedInfo = info
                    pickedImage = (info?[.editedImage] as? UIImage)?.withUpOrientation()
                }
                UIKitImagePicker(sourceType: sourceType, mediaTypes: [kUTTypeImage as String], isPresented: $isPickingImage, pickedMediaWithInfo: info)
                    .ignoresSafeArea()
            }
            .actionSheet(isPresented: $isPickingSourceType, content: {
                ActionSheet(
                    title: Text("Select photo"),
                    message: nil,
                    buttons: [
                        .default(Text("Camera"), action: {
                            sourceType = .camera
                        }),
                        .default(Text("Photo library"), action: {
                            sourceType = .photoLibrary
                        }),
                        .cancel({
                            isPresented = false
                        })
                    ]
                )
            })
            .onChange(of: isPresented) { isPresented in
                if isPresented {
                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                        sourceType = nil
                        isPickingSourceType = true
                    } else {
                        sourceType = .photoLibrary
                        pickedImage = nil
                        isPickingImage = true
                    }
                }
            }
            .onChange(of: sourceType) { sourceType in
                if sourceType != nil {
                    pickedImage = nil
                    isPickingImage = true
                }
            }
            .onChange(of: isPickingImage) { isPickingImage in
                if !isPickingImage {
                    isPresented = false
                }
            }
    }
}

public extension View {
    func imagePicker(_ isPresented: Binding<Bool>, pickedImage: Binding<UIImage?>) -> some View {
        modifier(ImagePickerViewModifier(
            isPresented: isPresented,
            pickedImage: pickedImage
        ))
    }
}
