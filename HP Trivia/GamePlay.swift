//
//  GamePlay.swift
//  HP Trivia
//
//  Created by Jinyuan Zhang on 11/11/2024.
//

import AVKit
import SwiftUI

struct GamePlay: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var gameViewModel: GameViewModel
    @Namespace private var namespace
    @State private var musicPlayer: AVAudioPlayer!
    @State private var sfxPlayer: AVAudioPlayer!
    @State private var animateViewIn = false
    @State private var tappedCorrectAnswer = false
    @State private var hintWiggle = false
    @State private var scaleNextButton = false
    @State private var movePointsToScore = false
    @State private var revealHint = false
    @State private var revealBook = false
    @State private var wrongAnswerTapped: [Int] = []
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Image(Constants.appIcon)
                    .resizable()
                    .frame(width: geo.size.width*3, height: geo.size.height*1.05)
                    .overlay(Rectangle().foregroundStyle(.black.opacity(0.8)))
                
                VStack {
                    // MARK: Controls

                    HStack {
                        Button("End Game") {
                            gameViewModel.endGame()
                            dismiss()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red.opacity(0.5))
                        
                        Spacer()
                        
                        Text("Score: \(gameViewModel.gameScore)")
                    }
                    .padding()
                    .padding(.vertical, 40)
                    
                    // MARK: Question

                    VStack {
                        if animateViewIn {
                            Text(gameViewModel.currentQuestion.question)
                                .font(.custom(Constants.hpFont, size: 50))
                                .multilineTextAlignment(.center)
                                .padding()
                                .transition(.scale)
                                .opacity(tappedCorrectAnswer ? 0.1 : 1)
                        }
                    }
                    .animation(
                        .easeInOut(duration: animateViewIn ? 2 : 0),
                        value: animateViewIn
                    )
                    
                    Spacer()
                    
                    // MARK: Hints

                    HStack {
                        VStack {
                            if animateViewIn {
                                Image(systemName: "questionmark.app.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100)
                                    .foregroundStyle(.cyan)
                                    .rotationEffect(.degrees(hintWiggle ? -13 : -17))
                                    .padding()
                                    .padding(.leading, 20)
                                    .transition(.offset(x: -geo.size.width / 2))
                                    .onAppear {
                                        withAnimation(
                                            .easeInOut(duration: 0.1)
                                                .repeatCount(9)
                                                .delay(5)
                                                .repeatForever())
                                        {
                                            hintWiggle = true
                                        }
                                    }
                                    .onTapGesture {
                                        withAnimation(.easeOut(duration: 1)) {
                                            revealHint = true
                                        }
                                        playFlipSound()
                                        gameViewModel.questionScore -= 1
                                    }
                                    .rotation3DEffect(
                                        .degrees(revealHint ? 1440 : 0),
                                        axis: (x: 0, y: 1, z: 0)
                                    )
                                    .scaleEffect(revealHint ? 5 : 1)
                                    .opacity(revealHint ? 0 : 1)
                                    .offset(x: revealHint ? geo.size.width / 2 : 0)
                                    .overlay(
                                        Text(gameViewModel.currentQuestion.hint)
                                            .padding(.leading, 33)
                                            .minimumScaleFactor(0.5)
                                            .multilineTextAlignment(.center)
                                            .opacity(revealHint ? 1 : 0)
                                            .scaleEffect(revealHint ? 1.33 : 1)
                                    )
                                    .opacity(tappedCorrectAnswer ? 0.1 : 1)
                                    .disabled(tappedCorrectAnswer)
                            }
                        }
                        .animation(
                            .easeOut(duration: animateViewIn ? 1.5 : 0).delay(animateViewIn ? 2 : 0),
                            value: animateViewIn
                        )
                        
                        Spacer()
                        
                        VStack {
                            if animateViewIn {
                                Image(systemName: "book.closed")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 55)
                                    .foregroundStyle(.black)
                                    .frame(width: 100, height: 100)
                                    .background(.cyan)
                                    .cornerRadius(20)
                                    .rotationEffect(.degrees(hintWiggle ? 15 : 17))
                                    .padding()
                                    .padding(.trailing, 20)
                                    .transition(.offset(x: geo.size.width / 2))
                                    .onAppear {
                                        withAnimation(
                                            .easeInOut(duration: 0.1)
                                                .repeatCount(9)
                                                .delay(5)
                                                .repeatForever())
                                        {
                                            hintWiggle = true
                                        }
                                    }
                                    .onTapGesture {
                                        withAnimation(.easeOut(duration: 1)) {
                                            revealBook = true
                                        }
                                        playFlipSound()
                                        gameViewModel.questionScore -= 1
                                    }
                                    .rotation3DEffect(
                                        .degrees(revealBook ? -1440 : 0),
                                        axis: (x: 0, y: 1, z: 0)
                                    )
                                    .scaleEffect(revealBook ? 5 : 1)
                                    .opacity(revealBook ? 0 : 1)
                                    .offset(x: revealBook ? -geo.size.width / 2 : 0)
                                    .overlay(
                                        Image("hp\(gameViewModel.currentQuestion.book)")
                                            .resizable()
                                            .scaledToFit()
                                            .padding(.trailing, 33)
                                            .minimumScaleFactor(0.5)
                                            .multilineTextAlignment(.center)
                                            .opacity(revealBook ? 1 : 0)
                                            .scaleEffect(revealBook ? 1.33 : 1)
                                    )
                                    .opacity(tappedCorrectAnswer ? 0.1 : 1)
                                    .disabled(tappedCorrectAnswer)
                            }
                        }
                        .animation(
                            .easeOut(duration: animateViewIn ? 1.5 : 0).delay(animateViewIn ? 2 : 0),
                            value: animateViewIn
                        )
                    }
                    .padding(.bottom, 30)
                    
                    // MARK: Answers

                    LazyVGrid(columns: [GridItem(), GridItem()]) {
                        ForEach(
                            Array(gameViewModel.answers.enumerated()), id: \.offset
                        ) {
                            i,
                                answer in
                            if gameViewModel.currentQuestion
                                .answers[answer] == true
                            {
                                VStack {
                                    if animateViewIn {
                                        if tappedCorrectAnswer == false {
                                            Text(answer)
                                                .minimumScaleFactor(0.5)
                                                .multilineTextAlignment(.center)
                                                .padding(10)
                                                .frame(width: geo.size.width / 2.15, height: 80)
                                                .background(.green.opacity(0.5))
                                                .cornerRadius(25)
                                                .transition(
                                                    .asymmetric(
                                                        insertion: .scale,
                                                        removal:
                                                        .scale(scale: 5)
                                                            .combined(
                                                                with: .opacity
                                                                    .animation(
                                                                        .easeOut(duration: 0.5)
                                                                    )
                                                            )
                                                    ))
                                                .matchedGeometryEffect(
                                                    id: "answer",
                                                    in: namespace
                                                )
                                                .onTapGesture {
                                                    withAnimation(
                                                        .easeOut(duration: 1))
                                                    {
                                                        tappedCorrectAnswer = true
                                                    }
                                                    playCorrectSound()
                                                    
                                                    DispatchQueue.main
                                                        .asyncAfter(
                                                            deadline: .now() + 3.5
                                                        ) {
                                                            gameViewModel
                                                                .correct()
                                                        }
                                                }
                                        }
                                    }
                                }
                                .animation(
                                    .easeOut(duration: animateViewIn ? 1 : 0).delay(animateViewIn ? 1.5 : 0),
                                    value: animateViewIn
                                )
                            } else {
                                VStack {
                                    if animateViewIn {
                                        Text(answer)
                                            .minimumScaleFactor(0.5)
                                            .multilineTextAlignment(.center)
                                            .padding(10)
                                            .frame(width: geo.size.width / 2.15, height: 80)
                                            .background(
                                                wrongAnswerTapped
                                                    .contains(i) ? .red
                                                    .opacity(0.5) : .green.opacity(0.5)
                                            )
                                            .cornerRadius(25)
                                            .transition(.scale)
                                            .onTapGesture {
                                                withAnimation(
                                                    .easeOut(duration: 1)
                                                ) {
                                                    wrongAnswerTapped
                                                        .append(i)
                                                }
                                                playWrongSound()
                                                giveWrongFeedback()
                                                gameViewModel.questionScore -= 1
                                            }
                                            .scaleEffect(wrongAnswerTapped
                                                .contains(i) ? 0.8 : 1)
                                            .disabled(
                                                tappedCorrectAnswer || wrongAnswerTapped
                                                    .contains(i)
                                            )
                                            .opacity(tappedCorrectAnswer ? 0.1 : 1)
                                    }
                                }
                                .animation(
                                    .easeOut(duration: animateViewIn ? 1 : 0).delay(animateViewIn ? 1.5 : 0),
                                    value: animateViewIn
                                )
                            }
                        }
                    }
                    
                    Spacer()
                }
                .frame(width: geo.size.width, height: geo.size.height)
                .foregroundStyle(.white)
                
                // MARK: Celebration

                VStack {
                    Spacer()
                    VStack {
                        if tappedCorrectAnswer {
                            Text("\(gameViewModel.questionScore)")
                                .font(.largeTitle)
                                .padding(.top, 50)
                                .transition(.offset(y: -geo.size.height / 4))
                                .offset(
                                    x: movePointsToScore ? geo.size.width / 2.3 : 0,
                                    y: movePointsToScore ? -geo.size
                                        .height / 13 : 0
                                )
                                .opacity(movePointsToScore ? 0 : 1)
                                .onAppear {
                                    withAnimation(
                                        .easeInOut(duration: 1).delay(3)
                                    ) {
                                        movePointsToScore = true
                                    }
                                }
                        }
                    }
                    .animation(
                        .easeInOut(duration: 1).delay(2),
                        value: tappedCorrectAnswer
                    )
                    
                    Spacer()
                    
                    VStack {
                        if tappedCorrectAnswer {
                            Text("Brilliant!")
                                .font(.custom(Constants.hpFont, size: 100))
                                .transition(
                                    .scale.combined(with: .offset(y: -geo.size.height / 2))
                                )
                        }
                    }
                    .animation(
                        .easeInOut(duration: tappedCorrectAnswer ? 1 : 0).delay(tappedCorrectAnswer ? 1 : 0),
                        value: tappedCorrectAnswer
                    )
                    
                    Spacer()
                    
                    if tappedCorrectAnswer {
                        Text(gameViewModel.correctAnswer)
                            .minimumScaleFactor(0.5)
                            .multilineTextAlignment(.center)
                            .padding(10)
                            .frame(width: geo.size.width / 2.15, height: 80)
                            .background(.green.opacity(0.5))
                            .cornerRadius(25)
                            .scaleEffect(2)
                            .matchedGeometryEffect(id: "answer", in: namespace)
                    }
                    
                    Group {
                        Spacer()
                        Spacer()
                    }
                    
                    VStack {
                        if tappedCorrectAnswer {
                            Button("Next level>") {
                                animateViewIn = false
                                tappedCorrectAnswer = false
                                revealBook = false
                                revealHint = false
                                movePointsToScore = false
                                wrongAnswerTapped = []
                                gameViewModel.newQuestion()
                                
                                DispatchQueue.main
                                    .asyncAfter(deadline: .now() + 0.5) {
                                        animateViewIn = true
                                    }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.blue.opacity(0.5))
                            .font(.largeTitle)
                            .transition(.offset(y: geo.size.height / 3))
                            .scaleEffect(scaleNextButton ? 1.2 : 1)
                            .onAppear {
                                withAnimation(
                                    .easeInOut(duration: 1.3).repeatForever()
                                ) {
                                    scaleNextButton.toggle()
                                }
                            }
                        }
                    }
                    .animation(
                        .easeInOut(duration: tappedCorrectAnswer ? 2.7 : 0).delay(tappedCorrectAnswer ? 2.7 : 0),
                        value: tappedCorrectAnswer
                    )
                            
                    Group {
                        Spacer()
                        Spacer()
                    }
                }
                .foregroundStyle(.white)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .ignoresSafeArea()
        .onAppear {
            animateViewIn = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                playMusic()
            }
        }
    }
    
    private func playMusic() {
        let sounds = ["let-the-mystery-unfold", "spellcraft", "hiding-place-in-the-forest", "deep-in-the-dell"]
        
        let i = Int.random(in: 0 ... 3)
        
        let sound = Bundle.main.path(forResource: sounds[i], ofType: "mp3")
        musicPlayer = try! AVAudioPlayer(contentsOf: URL(filePath: sound!))
        musicPlayer.volume = 0.1
        musicPlayer.numberOfLoops = -1
        musicPlayer.play()
    }
    
    private func playFlipSound() {
        let sound = Bundle.main.path(forResource: "page-flip", ofType: "mp3")
        sfxPlayer = try! AVAudioPlayer(contentsOf: URL(filePath: sound!))
        sfxPlayer.play()
    }
    
    private func playWrongSound() {
        let sound = Bundle.main.path(forResource: "negative-beeps", ofType: "mp3")
        sfxPlayer = try! AVAudioPlayer(contentsOf: URL(filePath: sound!))
        sfxPlayer.play()
    }
    
    private func playCorrectSound() {
        let sound = Bundle.main.path(forResource: "magic-wand", ofType: "mp3")
        sfxPlayer = try! AVAudioPlayer(contentsOf: URL(filePath: sound!))
        sfxPlayer.play()
    }
    
    private func giveWrongFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
}

#Preview {
    GamePlay()
        .environmentObject(GameViewModel())
}
