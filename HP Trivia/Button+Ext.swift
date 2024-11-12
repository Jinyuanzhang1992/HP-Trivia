//
//  Button+Ext.swift
//  HP Trivia
//
//  Created by Jinyuan Zhang on 11/11/2024.
//

import Foundation
import SwiftUI

extension Button {
    func doneButton() -> some View {
        self
            .font(.largeTitle)
            .padding()
            .buttonStyle(.borderedProminent)
            .tint(.brown)
            .foregroundStyle(.white)
    }
}

//
extension FileManager {
    static var documentsDirectory: URL {
        let paht = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )
        return paht.first!
    }
}
