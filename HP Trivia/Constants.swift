//
//  Constants.swift
//  HP Trivia
//
//  Created by Jinyuan Zhang on 11/11/2024.
//

import Foundation

enum Constants {
    static let hpFont = "PartyLetPlain"
    static let appIcon = "hogwarts"
    static let bgInstructions = "parchment"
    static let appIconWithRadius = "appiconwithradius"
    static let insructionReminder = "welcome to HP Trivia! In this game, you will be asked random questions from the HP books and you must answer or you will lose points😱"
    static let eachQuestionTitle =  "Each question is worth 5 points, but if ypir guess a wrong answer, you will lose 1 point.👀"
    static let hintReminder = "If you are struggling with a question, there is an option to reveal a hint or reveal the book that answers the question. But beware! Using these also minuses 1 point each.🙈"
    static let correctAnswer = "When you select the correct answer, you will be awarded all the points left for that question and they will be added to your total score.👍"
    static let whichBooks = "Which books would you like to see questions from?❓"
    static let previousQuestion = try! JSONDecoder().decode(
        [Question].self,
        from: Data(contentsOf: Bundle.main.url(forResource: "trivia", withExtension: "json")!))[0]
}

