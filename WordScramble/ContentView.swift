//
//  ContentView.swift
//  WordScramble
//
//  Created by Anu Mittal on 20/02/21.
//

import SwiftUI

struct ContentView: View {
  @State private var rootWord = ""
  @State private var newWord = ""
  @State private var usedWords = [String]()
  
  @State private var errorTitle = ""
  @State private var errorMessage = ""
  @State private var showingError = false
  
  @State private var score = 0
  
  var body: some View {
    NavigationView {
      VStack {
        TextField("Enter your word",
                  text: $newWord,
                  onCommit: addNewWord)
          .textFieldStyle(RoundedBorderTextFieldStyle())
          .autocapitalization(.none)
          .padding()
        
        List(usedWords, id: \.self) {
          Image(systemName: "\($0.count).circle")
          Text($0)
        }
        Text("Score: \(score)")
          .font(.largeTitle)
      }
      .navigationBarTitle("\(rootWord)")
      .navigationBarItems(
        leading: Button("Restart Game") {
          self.setupGame()
        })
    }
    .onAppear(perform: setupGame)
    .alert(isPresented: $showingError) {
      Alert(title: Text(errorTitle),
            message: Text(errorMessage),
            dismissButton: .default(Text("OK")))
    }
  }
  
  func addNewWord() {
    let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

    guard answer.count > 0 else {
      return
    }

    guard isOriginal(word: answer) else {
      wordError(title: "Word used already", message: "Be more original")
      return
    }

    guard isPossible(word: answer) else {
      wordError(title: "Word not recognized",
                message: "Check the charaters - You can't just make them up, you know!")
      return
    }

    guard isReal(word: answer) else {
      let title = "Word not possible"
      var message = "That isn't a real word."
      if answer.count < 3 {
        message = "Please enter more than 2 letter word"
      }
      wordError(title: title, message: message)
      return
    }

    usedWords.insert(answer, at: 0)
    newScore(answer)
    newWord = ""
  }
  
  private func newScore(_ answer: String) {
    score = score + usedWords.count*answer.count
  }
  
  private func setupGame() {
    if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: ".txt") {
      if let startWords = try? String(contentsOf: startWordsURL) {
        let allWords = startWords.components(separatedBy: "\n")
        rootWord = allWords.randomElement() ?? "Unicorns"
        return
      }
    }
    fatalError("Couldn't load start.txt from file")
  }
  
  // check if the word is new
  private func isOriginal(word: String) -> Bool {
    !usedWords.contains(word)
  }
  
  // check if it using the valid charaters
  private func isPossible(word: String) -> Bool {
    var tempWord = rootWord
    for letter in word {
      if let letterIndex = tempWord.firstIndex(of: letter) {
        tempWord.remove(at: letterIndex)
      } else {
        return false
      }
    }
    return true
  }
  
  private func isReal(word: String) -> Bool {
    // check for valid length - > 3
    guard word.count > 3 else {
      return false
    }
    
    // check if starting word matches the root word
    guard word != String(rootWord.prefix(word.count)) else {
      return false
    }
    
    // check if the word is a valid en dictionay word
    let checker = UITextChecker()
    let range = NSRange(location: 0, length: word.utf16.count)
    let misspelledRange = checker.rangeOfMisspelledWord(
      in: word,
      range: range,
      startingAt: 0,
      wrap: false,
      language: "en")
    return misspelledRange.location == NSNotFound
  }
  
  private func wordError(title: String, message: String) {
    errorTitle = title
    errorMessage = message
    showingError = true
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
