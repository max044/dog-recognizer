//
//  ImagePredictor.swift
//  Dog Recognizer
//
//  Created by Maxence Cabiddu on 29/04/2023.
//

import Vision
import UIKit

/// A convenience class that makes image classification predictions.
///
/// The Image Predictor creates and reuses an instance of a Core ML image classifier inside a ``VNCoreMLRequest``.
/// Each time it makes a prediction, the class:
/// - Creates a `VNImageRequestHandler` with an image
/// - Starts an image classification request for that image
/// - Converts the prediction results in a completion handler
/// - Updates the delegate's `predictions` property
/// - Tag: ImagePredictor
class ImagePredictor {
    /// - Tag: name
    static func createImageClassifier() -> VNCoreMLModel {
        // Use a default model configuration.
        let defaultConfig = MLModelConfiguration()

        // Create an instance of the image classifier's wrapper class.
        let imageClassifierWrapper = try? Dog_recognition_img(configuration: defaultConfig)

        guard let imageClassifier = imageClassifierWrapper else {
            fatalError("App failed to create an image classifier model instance.")
        }

        // Get the underlying model instance.
        let imageClassifierModel = imageClassifier.model

        // Create a Vision instance using the image classifier's model instance.
        guard let imageClassifierVisionModel = try? VNCoreMLModel(for: imageClassifierModel) else {
            fatalError("App failed to create a `VNCoreMLModel` instance.")
        }

        return imageClassifierVisionModel
    }

    /// A common image classifier instance that all Image Predictor instances use to generate predictions.
    ///
    /// Share one ``VNCoreMLModel`` instance --- for each Core ML model file --- across the app,
    /// since each can be expensive in time and resources.
    private static let imageClassifier = createImageClassifier()

    /// Stores a classification name and confidence for an image classifier's prediction.
    /// - Tag: Prediction
    struct Prediction {
        /// The name of the object or scene the image classifier recognizes in an image.
        let classification: String

        /// The image classifier's confidence as a percentage string.
        ///
        /// The prediction string doesn't include the % symbol in the string.
        let confidencePercentage: String
    }

    /// The function signature the caller must provide as a completion handler.
    typealias ImagePredictionHandler = (_ predictions: [Prediction]?) -> Void

    /// A dictionary of prediction handler functions, each keyed by its Vision request.
    private var predictionHandlers = [VNRequest: ImagePredictionHandler]()

    /// Generates a new request instance that uses the Image Predictor's image classifier model.
    private func createImageClassificationRequest() -> VNImageBasedRequest {
        // Create an image classification request with an image classifier model.

        let imageClassificationRequest = VNCoreMLRequest(model: ImagePredictor.imageClassifier,
                                                         completionHandler: visionRequestHandler)

        imageClassificationRequest.imageCropAndScaleOption = .centerCrop
        return imageClassificationRequest
    }

    /// Generates an image classification prediction for a photo.
    /// - Parameter photo: An image, typically of an object or a scene.
    /// - Tag: makePredictions
    func makePredictions(for photo: UIImage, completionHandler: @escaping ImagePredictionHandler) throws {

        guard let photoImage = photo.cgImage else {
            fatalError("Photo doesn't have underlying CGImage.")
        }

        let imageClassificationRequest = createImageClassificationRequest()
        predictionHandlers[imageClassificationRequest] = completionHandler

        let handler = VNImageRequestHandler(cgImage: photoImage)
        let requests: [VNRequest] = [imageClassificationRequest]

        // Start the image classification request.
        try handler.perform(requests)
    }

    /// The completion handler method that Vision calls when it completes a request.
    /// - Parameters:
    ///   - request: A Vision request.
    ///   - error: An error if the request produced an error; otherwise `nil`.
    ///
    ///   The method checks for errors and validates the request's results.
    /// - Tag: visionRequestHandler
    private func visionRequestHandler(_ request: VNRequest, error: Error?) {
        // Remove the caller's handler from the dictionary and keep a reference to it.
        guard let predictionHandler = predictionHandlers.removeValue(forKey: request) else {
            fatalError("Every request must have a prediction handler.")
        }

        // Start with a `nil` value in case there's a problem.
        var predictions: [Prediction]? = nil

        // Call the client's completion handler after the method returns.
        defer {
            // Send the predictions back to the client.
            predictionHandler(predictions)
        }

        // Check for an error first.
        if let error = error {
            print("Vision image classification error...\n\n\(error.localizedDescription)")
            return
        }

        // Check that the results aren't `nil`.
        if request.results == nil {
            print("Vision request had no results.")
            return
        }

        // Cast the request's results as an `VNClassificationObservation` array.
        guard let observations = request.results as? [VNClassificationObservation] else {
            print("VNRequest produced the wrong result type: \(type(of: request.results)).")
            return
        }
        
        let pred_logits = observations.map { $0.confidence }
        let pred_softmax = softmax(pred_logits)

        // Get the top 2 predictions
        let top2 = pred_softmax.indices.sorted(by: { pred_softmax[$0] > pred_softmax[$1] })[0..<2]
        let top2_percentage = top2.map { pred_softmax[$0] }
        let classes_pred = top2.map { observations[$0].identifier }
        
        predictions = classes_pred.enumerated().map { i, classLabel in
            let confidencePercentage = String(format: "%.2f", top2_percentage[i] * 100.0)
            return Prediction(classification: classLabel, confidencePercentage: confidencePercentage)
        }
    }
}

func softmax(_ x: [Float]) -> [Float] {
    let max_x = x.max()!
    let exp_x = x.map { exp($0 - max_x) }
    let sum_exp_x = exp_x.reduce(0, +)
    return exp_x.map { $0 / sum_exp_x }
}
