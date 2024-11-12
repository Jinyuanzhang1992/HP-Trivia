//
//  Instructions.swift
//  HP Trivia
//
//  Created by Jinyuan Zhang on 11/11/2024.
//

import SwiftUI

struct Instructions: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            InfoBackgroundImage()
            
            VStack {
                Image(Constants.appIconWithRadius)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150)
                    .padding(.top)
                
                ScrollView {
                    Text("How to Play")
                        .font(.largeTitle)
                        .padding()
                    
                    VStack(alignment: .leading) {
                        Text(Constants.insructionReminder)
                            .padding([.horizontal, .bottom])
                        
                        Text(Constants.eachQuestionTitle)
                            .padding([.horizontal, .bottom])
                        
                        Text(Constants.hintReminder)
                            .padding([.horizontal, .bottom])
                        
                        Text(Constants.correctAnswer)
                            .padding([.horizontal])
                    }
                    .font(.title3)
                    
                    Text("Good Luck!")
                        .font(.title)
                }
                .foregroundStyle(.black)
                
                Button("Done"){
                    dismiss()
                }
                .doneButton()
            }
        }
    }
}

#Preview {
    Instructions()
}
