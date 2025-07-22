//
//  ContentView.swift
//  MultiplicationTables
//
//  Created by Locus Wong on 2025-07-14.
//

import SwiftUI

struct ContentView: View {
    @State private var numberOfTimes = 2
    @State private var questionCount = 5
    @State private var settingChange = false
    @State private var questions = [String]()
    @State private var answers = [Int]()
    @State private var userAnswers = [String]() // Individual answers for each question
    @State private var score = 0
    
    @State private var alertTitle = "New Game Unavailable"
    @State private var alertMessage = "Finish the round or change a setting to start a new game."
    @State private var showingAlert = false
    @FocusState private var focusedField: Int? // Track which field is focused
    
    let questionCounts = [5, 10, 15, 20, 25, 30]
    
    let numArray = [1,2,3,4,5,6,7,8,9,10,11,12]
    
    var tempArray = Array<Int>()
    
    let emptySet: Set<String> = []
    
    // Computed property to check if all questions are answered
    var allQuestionsAnswered: Bool {
        return userAnswers.allSatisfy { !$0.isEmpty }
    }
    
    var body: some View {
        NavigationStack{
            Form {
                VStack(alignment: .leading, spacing: 10){
                    Text("Select one side of the table (up to \(numberOfTimes)):")
                        .font(.headline)
                    Picker("", selection: $numberOfTimes){
                        ForEach(1...12, id: \.self){ index in
                            Text("\(index)")
                        }
                    }.pickerStyle(.segmented)
                    
                    Stepper("", value: $numberOfTimes, in: 1...12)
                }
                .onChange(of: numberOfTimes) {
                    settingChange = true
                }
                
                Picker("How many questions you want?", selection: $questionCount){
                    ForEach(questionCounts, id: \.self){
                        Text("\($0)")
                    }
                }
                .onChange(of: questionCount) {
                    settingChange = true
                }
                
                if !questions.isEmpty {
                    List {
                        Section{
                            ForEach(0..<questions.count, id: \.self){ index in
                                VStack(alignment: .leading, spacing: 8) {
                                    let userAnswer = Int(userAnswers[index].trimmingCharacters(
                                        in: .whitespacesAndNewlines
                                    )) ?? -1
                                    let correctAnswer = answers[index]
                                    HStack{
                                        Text(questions[index])
                                            .font(.headline)
                                        Spacer()
                                        TextField("Answer Here", text: Binding(
                                            get: {
                                                index < userAnswers.count ? userAnswers[index] : ""
                                            },
                                            set: { newValue in
                                                // Ensure userAnswers array is large enough
                                                while userAnswers.count <= index {
                                                    userAnswers.append("")
                                                }
                                                userAnswers[index] = newValue
                                            }
                                        ))
                                        .keyboardType(.numberPad)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .frame(width: 110)
                                        .focused($focusedField, equals: index)
                                        .disabled(!userAnswers[index].isEmpty && focusedField != index)
                                    }
                                    
                                    // Only show result if user has entered something
                                    if index < userAnswers.count && !userAnswers[index].isEmpty && focusedField != index {
                                        HStack {
                                            Image(systemName: userAnswer == correctAnswer ? "checkmark.circle.fill" : "xmark.circle.fill")
                                                .foregroundColor(userAnswer == correctAnswer ? .green : .red)
                                            Text(userAnswer == correctAnswer ? "Correct!" : "Answer is \(correctAnswer)")
                                                .foregroundColor(userAnswer == correctAnswer ? .green : .red)
                                                .font(.caption)
                                        }
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
                
            }.navigationTitle("Multiplication game")
                .toolbar{
                    Button("Start Game", action: StartGame)
                }
                .onAppear(){
                    generateQuestion()
                }
                .alert(alertTitle, isPresented: $showingAlert) {
                    Button("OK") { }
                } message: {
                    Text(alertMessage)
                }
        }
    }
    
    func calculateScore(){
        for index in 0..<questionCount{
            let userAnswer = Int(userAnswers[index].trimmingCharacters(
                in: .whitespacesAndNewlines
            )) ?? -1
            let correctAnswer = answers[index]
            if userAnswer == correctAnswer {
                score += 1
            }
        }
    }
    
    func generateQuestion(){
        // Reset everything
        questions = []
        answers = []
        userAnswers = []
        score = 0
        
        for _ in 0..<questionCount{
            let firstNumber = Int.random(in: 1...numberOfTimes)
            let secondNumber = numArray.randomElement() ?? 1
            questions.append("\(firstNumber) x \(secondNumber)")
            answers.append(firstNumber * secondNumber)
        }
        
        // Initialize userAnswers array with empty strings
        userAnswers = Array(repeating: "", count: questionCount)
    }
    
    func StartGame(){
        if settingChange {
            // restart the game with the new setting or if all questions are completed
            generateQuestion()
            settingChange = false
            showingAlert = false
        }
        else if allQuestionsAnswered {
            calculateScore()
            alertTitle = "Game End"
            alertMessage = "Your final score is: \(score)"
            // restart the game with the new setting or if all questions are completed
            showingAlert = true
            generateQuestion()
        }
        else {
            alertTitle = "New Game Unavailable"
            alertMessage = "Finish the round or change a setting to start a new game."
            showingAlert = true
        }
        
    }
}

#Preview {
    ContentView()
}
