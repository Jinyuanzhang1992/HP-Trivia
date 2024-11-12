//
//  Settings.swift
//  HP Trivia
//
//  Created by Jinyuan Zhang on 11/11/2024.
//

import SwiftUI

struct Settings: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: Store

    var body: some View {
        ZStack {
            InfoBackgroundImage()

            VStack {
                Text(Constants.whichBooks)
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .padding(.top)

                ScrollView {
                    LazyVGrid(columns: [GridItem(), GridItem()]) {
                        ForEach(store.books.indices, id: \.self) { i in
                            if store.books[i] == .active || (
                                store.books[i] == .locked && store.purchasedIDs.contains("hp\(i + 1)")
                            ) {
                                ZStack(alignment: .bottomTrailing) {
                                    Image("hp\(i + 1)")
                                        .resizable()
                                        .scaledToFit()
                                        .shadow(radius: 7)

                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.largeTitle)
                                        .imageScale(.large)
                                        .foregroundColor(.green)
                                        .shadow(radius: 1)
                                        .padding(3)
                                }
                                .task {
                                    store.books[i] = .active
                                    store.saveStatus()
                                }
                                .onTapGesture {
                                    store.books[i] = .inactive
                                    store.saveStatus()
                                }
                            }

                            if store.books[i] == .inactive {
                                ZStack(alignment: .bottomTrailing) {
                                    Image("hp\(i + 1)")
                                        .resizable()
                                        .scaledToFit()
                                        .shadow(radius: 7)
                                        .overlay(Rectangle().opacity(0.33))

                                    Image(systemName: "circle")
                                        .font(.largeTitle)
                                        .imageScale(.large)
                                        .foregroundColor(.green.opacity(0.5))
                                        .shadow(radius: 1)
                                        .padding(3)
                                }
                                .onTapGesture {
                                    store.books[i] = .active
                                    store.saveStatus()
                                }
                            }

                            if store.books[i] == .locked {
                                ZStack {
                                    Image("hp\(i + 1)")
                                        .resizable()
                                        .scaledToFit()
                                        .shadow(radius: 7)
                                        .overlay(Rectangle().opacity(0.75))

                                    Image(systemName: "lock.fill")
                                        .font(.largeTitle)
                                        .imageScale(.large)
                                        .shadow(color: .white.opacity(0.75), radius: 1)
                                }
                                .onTapGesture {
                                    // 修复索引计算
                                    let productIndex = i - 3 // 将书本索引转换为产品数组索引
                                    if productIndex >= 0 && productIndex < store.products.count {
                                        let product = store.products[productIndex]
                                        Task {
                                            await store.purchase(product)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }

                Button("Done") {
                    dismiss()
                }
                .doneButton()
            }
            .foregroundStyle(.black)
        }
    }
}

#Preview {
    Settings()
        .environmentObject(Store())
}
