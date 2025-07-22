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
    @State private var settingChange = true
    @State private var questions = [String]()
    @State private var answers = [Int]()
    @State private var userAnswers = [String]() // Individual answers for each question
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
                                    }
                                    
                                    // Only show result if user has entered something
                                    if index < userAnswers.count && !userAnswers[index].isEmpty && focusedField != index {
                                        let userAnswer = Int(userAnswers[index]) ?? -1
                                        let correctAnswer = answers[index]
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
                .alert("New Game Unavailable", isPresented: $showingAlert) {
                    Button("OK") { }
                } message: {
                    Text("Finish the round or change a setting to start a new game.")
                }
        }
    }
    
    func generateQuestion(){
        // Reset everything
        questions = []
        answers = []
        userAnswers = []
        
        for _ in 0..<questionCount{
            let firstNumber = Int.random(in: 1...numberOfTimes)
            let secondNumber = numArray.randomElement() ?? 1
            questions.append("\(firstNumber) x \(secondNumber)")
            answers.append(firstNumber * secondNumber)
        }
        
        // Initialize userAnswers array with empty strings
        userAnswers = Array(repeating: "", count: questionCount)
        print("User answer count: \(userAnswers.count)")
    }
    
    func StartGame(){
        if settingChange || allQuestionsAnswered {
            // restart the game with the new setting or if all questions are completed
            generateQuestion()
            settingChange = false
            showingAlert = false
        }
        else {
            showingAlert = true
        }
    }
}

#Preview {
    ContentView()
}
