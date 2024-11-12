//
//  ContentView.swift
//  HP Trivia
//
//  Created by Jinyuan Zhang on 11/11/2024.
//

import AVKit
import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: Store
    @EnvironmentObject private var gameViewModel: GameViewModel
    @State private var audioPlayer: AVAudioPlayer!
    @State private var scalePlayButton = false
    @State private var moveBackgroundImage = false
    @State private var animateViewsIn = false
    @State private var showInstructions = false
    @State private var showSettings = false
    @State private var playGame = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Image(Constants.appIcon)
                    .resizable()
                    .frame(width: geo.size.width * 3, height: geo.size.height)
                    .padding(.top, 3)
                    .offset(
                        x: moveBackgroundImage ? geo.size.width/1.1 : -geo
                            .size.width/1.1)
                    .onAppear {
                        withAnimation(
                            .linear(duration: 60).repeatForever()
                        ) {
                            moveBackgroundImage.toggle()
                        }
                    }

                VStack {
                    VStack {
                        if animateViewsIn {
                            VStack {
                                Image(systemName: "bolt.fill")
                                    .font(.largeTitle)
                                    .imageScale(.large)

                                Text("HP")
                                    .font(.custom(Constants.hpFont, size: 70))
                                    .padding(.bottom, -50)

                                Text("Trivia")
                                    .font(.custom(Constants.hpFont, size: 60))
                            }
                            .padding(.top, 70)
                            .transition(.move(edge: .top))
                        }
                    }
                    .animation(
                        .easeInOut(duration: 0.7).delay(2),
                        value: animateViewsIn
                    )

                    Spacer()

                    VStack {
                        if animateViewsIn {
                            VStack {
                                Text("Recent Scores")
                                    .font(.title2)

                                Text("\(gameViewModel.recentScores[0])")
                                Text("\(gameViewModel.recentScores[1])")
                                Text("\(gameViewModel.recentScores[2])")
                            }
                            .font(.title3)
                            .padding()
                            .foregroundStyle(.white)
                            .background(.black.opacity(0.7))
                            .cornerRadius(15)
                            .transition(.opacity)
                        }
                    }
                    .animation(
                        .linear(duration: 1).delay(4),
                        value: animateViewsIn
                    )

                    Spacer()

                    HStack {
                        Spacer()
                        VStack {
                            if animateViewsIn {
                                Button {
                                    showInstructions.toggle()
                                } label: {
                                    Image(systemName: "info.circle.fill")
                                        .font(.largeTitle)
                                        .foregroundStyle(.white)
                                        .shadow(radius: 5)
                                }
                                .transition(
                                    .offset(x: -geo.size.width/4)
                                )
                            }
                        }
                        .animation(
                            .easeInOut(duration: 0.7).delay(2.7),
                            value: animateViewsIn
                        )

                        Spacer()

                        VStack {
                            if animateViewsIn {
                                Button {
                                    filterQuestions()
                                    gameViewModel.startGame()
                                    playGame.toggle()
                                } label: {
                                    Text("Play")
                                        .font(.largeTitle)
                                        .foregroundStyle(.white)
                                        .padding(.vertical, 7)
                                        .padding(.horizontal, 50)
                                        .background(
                                            store.books
                                                .contains(
                                                    .active
                                                ) ? .brown : .gray
                                        )
                                        .cornerRadius(7)
                                        .shadow(radius: 5)
                                }
                                .scaleEffect(scalePlayButton ? 1.2 : 1)
                                .onAppear {
                                    withAnimation(
                                        .easeInOut(duration: 1.3).repeatForever()
                                    ) {
                                        scalePlayButton.toggle()
                                    }
                                }
                                .transition(.offset(y: geo.size.height/3))
                                .fullScreenCover(
                                    isPresented: $playGame)
                                {
                                    GamePlay()
                                        .environmentObject(gameViewModel)
                                        .onAppear {
                                            audioPlayer
                                                .setVolume(0, fadeDuration: 2)
                                        }
                                        .onDisappear {
                                            audioPlayer
                                                .setVolume(1, fadeDuration: 3)
                                        }
                                }
                                .disabled(store.books.contains(.active) ? false : true)
                            }
                        }
                        .animation(
                            .easeInOut(duration: 0.7).delay(2),
                            value: animateViewsIn
                        )

                        Spacer()

                        VStack {
                            if animateViewsIn {
                                Button {
                                    showSettings.toggle()
                                } label: {
                                    Image(systemName: "gearshape.fill")
                                        .font(.largeTitle)
                                        .foregroundStyle(.white)
                                        .shadow(radius: 5)
                                }
                                .transition(
                                    .offset(x: geo.size.width/4)
                                )
                            }
                        }
                        .animation(
                            .easeInOut(duration: 0.7).delay(2.7),
                            value: animateViewsIn
                        )

                        Spacer()
                    }
                    .frame(width: geo.size.width)

                    VStack {
                        if animateViewsIn {
                            if store.books.contains(.active) == false {
                                Text("No questions available. Go to settings. ⬆️")
                                    .multilineTextAlignment(.center)
                                    .transition(.opacity)
                            }
                        }
                    }
                    .animation(.easeInOut.delay(3), value: animateViewsIn)

                    Spacer()
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .ignoresSafeArea()
        .onAppear {
            playAuduo()
            animateViewsIn.toggle()
        }
        .sheet(isPresented: $showInstructions) {
            Instructions()
        }
        .sheet(isPresented: $showSettings) {
            Settings()
                .environmentObject(store)
        }
    }

    private func playAuduo() {
        let sound = Bundle.main.path(forResource: "magic-in-the-air", ofType: "mp3")
        audioPlayer = try! AVAudioPlayer(contentsOf: URL(filePath: sound!))
        audioPlayer.numberOfLoops = -1
        audioPlayer.play()
    }

    private func filterQuestions() {
        var books: [Int] = []

        for (index, status) in store.books.enumerated() {
            if status == .active {
                books.append(index + 1)
            }
        }

        gameViewModel.filterQuestions(to: books)
        gameViewModel.newQuestion()
    }
}

#Preview {
    ContentView()
        .environmentObject(Store())
        .environmentObject(GameViewModel())
}
