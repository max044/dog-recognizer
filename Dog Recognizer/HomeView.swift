//
//  HomeView.swift
//  Dog Recognizer
//
//  Created by Maxence Cabiddu on 03/04/2023.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack {
            Text("Welcome to Dog Recognizer!")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding()
            Text("Take a picture of a dog and we'll tell you its breed.")
                .font(.title3)
                .multilineTextAlignment(.center)
                .padding()
            Image("Logo")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .cornerRadius(10)
                .padding()
        }


    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
