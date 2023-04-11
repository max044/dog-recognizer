//
//  CameraView.swift
//  Dog Recognizer
//
//  Created by Maxence Cabiddu on 03/04/2023.
//

import SwiftUI

//struct CameraView: View {
//    @State private var showImagePicker = false
//    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
//    @State private var capturedImage: UIImage?
//
//    var body: some View {
//        VStack {
//            Button(action: {
//                sourceType = .camera
//                showImagePicker = true
//
//            }) {
//                Text("Take a picture")
//            }
//            Button(action: {
//                sourceType = .photoLibrary
//                showImagePicker = true
//            }) {
//                Text("Select a picture")
//            }
//            if let image = capturedImage {
//                Image(uiImage: image)
//                    .resizable()
//                    .scaledToFit()
//            }
//        }
//        .sheet(isPresented: $showImagePicker) {
//            ImagePickerView(sourceType: $sourceType, image: self.$capturedImage)
//        }
//    }
//}

struct CameraView: View {
    @State private var showImagePicker = false
    @State private var capturedImage: UIImage?
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
        var body: some View {
            ZStack {
                VStack {
                    if let image = capturedImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: UIScreen.main.bounds.height * 0.8)
                    } else {
                        
                    }
                    HStack(spacing: 30) {
                        Button(action: {
                            self.showImagePicker = true
                            self.sourceType = .camera
                        }) {
                            Image(systemName: "camera.fill")
                                .font(.title)
                        }
                        Button(action: {
                            self.showImagePicker = true
                            self.sourceType = .photoLibrary
                        }) {
                            Image(systemName: "photo.fill")
                                .font(.title)
                        }
                    }
                    .padding(.vertical, 10)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePickerView(sourceType: self.$sourceType, image: self.$capturedImage)
            }
        }
    }

struct ImagePickerView: UIViewControllerRepresentable {
    @Binding var sourceType: UIImagePickerController.SourceType
    @Binding var image: UIImage?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePickerView>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePickerView>) {
        // No need to update anything here
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePickerView
        
        init(_ parent: ImagePickerView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}
