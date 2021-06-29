//
//  ContentView.swift
//  Word Scramble
//
//  Created by Soumyattam Dey on 29/06/21.
//

import SwiftUI

struct ContentView: View {
    
    @State private var usedWords=[String]()     //stores players words
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
                    
                //View to show player's words
                List(usedWords,id:\.self){
                    Image(systemName: "\($0.count).circle")
                    Text($0)
                }
            }
            .navigationBarTitle(rootWord)           //Display a random word
            .navigationBarItems(trailing: Button(action: startGame, label: {
                isNewGame ? Text("New word") : Text("Start Game")
            }))             //Start a new game
            .alert(isPresented: $showingError){
                Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("Ok")))
            }
        }
    }
    
    //called to start a new game
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
        
        //if there is any sort of error the app close automatically
        fatalError("Could not load start.txt from bundle")
    }
    
    //called with onCommit()->when a new word is entered
    func addNewWord(){
        let answer=newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        //checks if it is an empty string or not
        guard answer.count>0 else {
            return
        }
        
        //check if it is original that is not entered earlier
        guard isOriginal(word: answer) else {
            wordError(title: "Word already used", message: "Be more original")
            return
        }
        
        //check if it is a two letter word
        guard twoLetterWords(word: answer) else {
            wordError(title: "Not allowed", message: "Words must be more than two letters")
            return
        }
        
        //check if the word is possible to make fromm the root word
        guard isPossible(word: answer) else {
            wordError(title: "Word not recognzed", message: "You can't just make them up, you know !")
            return
        }
        
        //check if the word is correct (calling UITextChecker())
        guard isReal(word: answer) else {
            wordError(title: "Word not possible", message: "That isn't a real world")
            return
        }
        
        usedWords.insert(answer, at: 0)             //insert word in the array
        newWord=""
        score=score+answer.count+usedWords.count    //update user score
    }
    
    func isOriginal(word:String)->Bool{
        
        //if the word is the root word then return false
        if word==rootWord{
            return false
        }
        return !usedWords.contains(word)    //checking if it is already in the array
        
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
