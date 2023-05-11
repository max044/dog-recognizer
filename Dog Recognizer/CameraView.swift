//
//  CameraView.swift
//  Dog Recognizer
//
//  Created by Maxence Cabiddu on 03/04/2023.
//

import SwiftUI
import CoreML
import UIKit
import Vision
import CoreImage
import CoreData


// Image Transformations

func ImageTransform(inputImage: UIImage) -> UIImage {

    // Create a CIImage from the input image
    guard let ciImage = CIImage(image: inputImage) else {
        fatalError("Unable to create CIImage from input image")
    }

    // Create the filter
    let mean = CIVector(x: 0.485, y: 0.456, z: 0.406)
    let std = CIVector(x: 0.229, y: 0.224, z: 0.225)
    let filter = CIFilter(name: "CIColorMatrix", parameters: [
        kCIInputImageKey: ciImage,
        "inputRVector": std,
        "inputGVector": std,
        "inputBVector": std,
        "inputBiasVector": mean
    ])!

    // Apply the filter
    let context = CIContext()
    guard let outputImage = filter.outputImage else {
        fatalError("Unable to apply filter to input image")
    }
    guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
        fatalError("Unable to create CGImage from output image")
    }
    let outputUIImage = UIImage(cgImage: cgImage)

    // Convert the output image to a UIImage
    return outputUIImage
}

func resize(image: UIImage, size: CGSize) -> UIImage {
    let scale = UIScreen.main.scale
    let resizedSize = CGSize(width: size.width * scale, height: size.height * scale)
    let format = UIGraphicsImageRendererFormat.default()
    format.scale = scale
    let renderer = UIGraphicsImageRenderer(size: resizedSize, format: format)
    let resizedImage = renderer.image { _ in
        image.draw(in: CGRect(origin: .zero, size: resizedSize))
    }
    return resizedImage
}


struct CameraView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showImagePicker = false
    @State private var capturedImage: UIImage?
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var predictionResult: String = ""
    
    private func computePrediction(image: UIImage, completion: @escaping (String) -> Void) {
        let imagePredictor = ImagePredictor()
        
        do {
            try imagePredictor.makePredictions(for: image,
                                               completionHandler: imagePredictionHandler)
        } catch {
            print("Vision was unable to make a prediction...\n\n\(error.localizedDescription)")
        }
    }
    
    private func imagePredictionHandler(_ predictions: [ImagePredictor.Prediction]?) {
        guard let predictions = predictions else {
            print("No predictions. (Check console log.)")
            return
        }

        let formattedPredictions = formatPredictions(predictions)

        let predictionString = formattedPredictions.joined(separator: "\n")
        predictionResult = predictionString

        let new_historic = MyHistoricDB(context: viewContext)
        new_historic.picture = capturedImage?.jpegData(compressionQuality: 1.0)
        new_historic.predictions = predictionString
        new_historic.creationDate = Date()

        do {
            try viewContext.save()
        } catch {
            fatalError("Error saving Core Data context: \(error.localizedDescription)")
        }

        print("predictionString: \(predictionString)")
    }

    private func formatPredictions(_ predictions: [ImagePredictor.Prediction]) -> [String] {
        // Vision sorts the classifications in descending confidence order.
        let predictionsToShow = 2
        let topPredictions: [String] = predictions.prefix(predictionsToShow).map { prediction in
            var name = prediction.classification

            // For classifications with more than one name, keep the one before the first comma.
            if let firstComma = name.firstIndex(of: ",") {
                name = String(name.prefix(upTo: firstComma))
            }

            return "\(name): \(prediction.confidencePercentage)%"
        }

        return topPredictions
    }
    
    var body: some View {
        ZStack {
            VStack {
                if let image = capturedImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: UIScreen.main.bounds.height * 0.8)
                    
                    // text to display the prediction result (breed)
                    Text(predictionResult)
                        .font(.body)
                        .padding(.vertical, 10)
                    

                    HStack() {
                        Button(action: {
                            self.capturedImage = nil
                            self.predictionResult = ""
                        }) {
                            Text("Delete")
                                .foregroundColor(.white)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 20)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }

                        // analyse picture
                        Button(action: {
                            computePrediction(image: image, completion: { result in
                                 self.predictionResult = result
                             })
                        }) {
                            Text("Analyse")
                                .foregroundColor(.white)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 20)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                    }.padding(.vertical, 10)
                    
                } else {
                    Image(systemName: "camera")
                        .font(.system(size: 100))
                        .foregroundColor(.gray)
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: UIScreen.main.bounds.height * 0.8)
                }
                HStack() {
                    Button(action: {
                        self.showImagePicker = true
                        self.sourceType = .camera
                        self.capturedImage = nil
                        self.predictionResult = ""
                    }) {
                        Image(systemName: "camera.fill")
                            .font(.title)
                    }
                    Button(action: {
                        self.showImagePicker = true
                        self.sourceType = .photoLibrary
                        self.capturedImage = nil
                        self.predictionResult = ""
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
