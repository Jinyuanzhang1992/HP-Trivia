//
//  SharedViews.swift
//  HP Trivia
//
//  Created by Jinyuan Zhang on 11/11/2024.
//

import SwiftUI

struct InfoBackgroundImage: View {
    var body: some View {
        Image(Constants.bgInstructions)
            .resizable()
            .ignoresSafeArea()
            .background(.brown)    }
}

#Preview {
    InfoBackgroundImage()
}
