//
//  HistoricView.swift
//  Dog Recognizer
//
//  Created by Maxence Cabiddu on 03/04/2023.
//

import SwiftUI
import CoreData

struct HistoricView: View {
     @Environment(\.managedObjectContext) private var viewContext
    
     @FetchRequest(
         sortDescriptors: [NSSortDescriptor(keyPath: \MyHistoricDB.creationDate, ascending: false)],
         animation: .default)
     private var historicPredictions: FetchedResults<MyHistoricDB>
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(historicPredictions) { historicPrediction in
                    
                    HStack {
                        VStack {
                            if let date = historicPrediction.creationDate {
                                Text(date, style: .date)
                                    .font(.body)
                            }
                            if let img = historicPrediction.picture {
                                Image(uiImage: UIImage(data: img)!)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                    .cornerRadius(10)
                            }
                        }
                        Spacer()
                    
                        if let pred = historicPrediction.predictions {
                            Text(pred)
                                .font(.body)
                        }

                         let link = URL(string: "https://github.com/max044/dog-recognizer")!
                         if let img = historicPrediction.picture {
                             let photo = Image(uiImage: UIImage(data: img)!)
                            let message = Text(historicPrediction.predictions! + "\n\n" + link.absoluteString)

                             ShareLink(
                                 item: photo,
                                 message: message,
                                 preview: SharePreview(
                                     "Share this app with your friends! 🐶",
                                     image: photo
                                 ),
                                label: {
                                    Label("", systemImage: "square.and.arrow.up")
                                }
                             )
                         } else {
                             ShareLink(
                                 item: link,
                                 message: Text("Share this app with your friends! 🐶"),
                                 preview: SharePreview(
                                     "Share this app with your friends! 🐶"
                                 ),
                                 label: {
                                     Label("", systemImage: "square.and.arrow.up")
                                 }
                             )
                         }
                        
                        
                    }
                }
            }
            .padding(10)
        }
    }
}

//
//struct HistoricView_Previews: PreviewProvider {
//    static var previews: some View {
//        HistoricView()
//    }
//}
