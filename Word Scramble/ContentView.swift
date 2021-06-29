//
//  ContentView.swift
//  Word Scramble
//
//  Created by Soumyattam Dey on 29/06/21.
//

import SwiftUI

struct ContentView: View {
    
    @State private var usedWords=[String]()
    @State private var newWord=""
    @State private var rootWord=""
    @State private var isNewGame=false
    @State private var score=0
    
    @State private var errorTitle=""
    @State private var errorMessage=""
    @State private var showingError=false
    
    var body: some View {
        NavigationView{
            Form{
                
                TextField("Enter a new word", text: $newWord,onCommit:addNewWord)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .autocapitalization(.none)
                
                Text("Your score is \(score)")
                    .font(.title3)
                    .fontWeight(.medium)
                    
                    
                
                List(usedWords,id:\.self){
                    Image(systemName: "\($0.count).circle")
                    Text($0)
                }
            }
            .navigationBarTitle(rootWord)
            .navigationBarItems(trailing: Button(action: startGame, label: {
                isNewGame ? Text("New word") : Text("Start Game")
            }))
            .alert(isPresented: $showingError){
                Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("Ok")))
            }
        }
    }
    
    func startGame(){
        usedWords.removeAll()
        score=0
        isNewGame=true
        if let startWordsURL=Bundle.main.url(forResource: "start", withExtension: "txt"){
            if let startWords=try? String(contentsOf: startWordsURL){
                let allWords=startWords.components(separatedBy: "\n")
                rootWord=allWords.randomElement() ?? "silkworm"
                return
            }
        }
        
        fatalError("Could not load start.txt from bundle")
    }
    
    func addNewWord(){
        let answer=newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        
        guard answer.count>0 else {
            return
        }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word already used", message: "Be more original")
            return
        }
        
        guard twoLetterWords(word: answer) else {
            wordError(title: "Not allowed", message: "Words must be more than two letters")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not recognzed", message: "You can't just make them up, you know !")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not possible", message: "That isn't a real world")
            return
        }
        
        usedWords.insert(answer, at: 0)
        newWord=""
        score=score+answer.count+usedWords.count
    }
    
    func isOriginal(word:String)->Bool{
        if word==rootWord{
            return false
        }
        return !usedWords.contains(word)
        
    }
    
    func twoLetterWords(word:String)->Bool{
        !(word.count<=2)
    }
    
    func isPossible(word:String)->Bool{
        var tempWord=rootWord
        
        for letter in word{
            if let pos=tempWord.firstIndex(of: letter){
                tempWord.remove(at: pos)
            }else{
                return false
            }
        }
        return true
    }
    
    func isReal(word:String)->Bool{
        let checker=UITextChecker()
        let range=NSRange(location: 0, length: word.utf16.count)
        let misspelledRange=checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title:String,message:String){
        errorTitle=title
        errorMessage=message
        showingError=true
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
