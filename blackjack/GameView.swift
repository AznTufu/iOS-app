//
//  GameView.swift
//  blackjack
//
//  Created by ZHANG Tony on 16/10/2024.
//

import SwiftUI

struct Card: Identifiable {
    var id: String { "\(name) \(suit)" }
    var name: String
    var suit: String
}

struct GameView: View {
    let cardSuits = ["Cœur", "Carreau", "Trèfle", "Pique"]
    let cardNames = ["As", "2", "3", "4", "5", "6", "7", "8", "9", "10", "Valet", "Dame", "Roi"]
    
    @State private var deck: [Card] = []
    @State private var playerCards: [Card] = []
    @State private var dealerCards: [Card] = []
    @State private var gameMessage = "Blackjack"
    @State private var playerScore = 0
    @State private var dealerScore = 0
    @State private var playerBalance = 1000
    @State private var playerBet = 0
    @State private var resetGame = true
    
    var betOptions: [Int] {
        if playerBalance == 0 {
            return [25, 50, 100, 250, 500]
        }
        
        let maxBet = playerBalance
        var options: [Int] = []
        
        let increments = [0.05, 0.1, 0.25, 0.5, 1.0]
        for increment in increments {
            let value = Int(Double(maxBet) * increment)
            if value > 0 {
                options.append(value)
            }
        }
        
        if !options.contains(maxBet) {
            options.append(maxBet)
        }
        
        return Array(Set(options)).sorted()
    }
    
    var body: some View {
        VStack {
            Text(gameMessage)
                .font(.largeTitle)
            
            Text("Solde du Joueur : \(playerBalance) €")
                .font(.title2)
            
            Spacer()
            
            if resetGame {
                VStack {
                    let columns = [
                        GridItem(.adaptive(minimum: 110))
                    ]
                    
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(betOptions, id: \.self) { amount in
                            Button(action: {
                                placeBet(amount)
                            }) {
                                Text("\(amount) €")
                                    .padding()
                                    .frame(minWidth: 110)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                    }
                    .padding()
                    
                    Button(action: resetBalance) {
                        Text("Réinitialiser le Solde")
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            } else {
                Text("Cartes restantes : \(deck.count)")
                    .font(.headline)
                Text("Votre Mise : \(playerBet) €")
                    .font(.title2)
                
                VStack {
                    VStack(alignment: .leading) {
                        Text("Cartes du Joueur :")
                        let columns = [
                            GridItem(.adaptive(minimum: 70))
                        ]
                        
                        LazyVGrid(columns: columns, spacing: 10) {
                            ForEach(playerCards) { card in
                                VStack {
                                    Text(card.name)
                                        .font(.headline)
                                    Image(card.suit)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20, height: 20)
                                }
                                .frame(width: 70, height: 100)
                                .background(Color.white)
                                .cornerRadius(5)
                                .shadow(radius: 2)
                                .padding(2)
                            }
                        }
                        Text("Score : \(playerScore)")
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.green.opacity(0.3))
                    .cornerRadius(10)

                    VStack(alignment: .leading) {
                        Text("Cartes du Dealer :")

                        let columns = [
                            GridItem(.adaptive(minimum: 70))
                        ]
                        
                        LazyVGrid(columns: columns, spacing: 10) {
                            ForEach(dealerCards) { card in
                                VStack {
                                    Text(card.name)
                                        .font(.headline)
                                    Image(card.suit)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20, height: 20)
                                }
                                .frame(width: 70, height: 100)
                                .background(Color.white)
                                .cornerRadius(5)
                                .shadow(radius: 2)
                                .padding(2)
                            }
                        }
                        Text("Score : \(dealerScore)")
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.red.opacity(0.3))
                    .cornerRadius(10)
                }
                .padding()

                if gameMessage.contains("gagne") || gameMessage.contains("égalité") {
                    Button(action: resetGameToBetting) {
                        Text("Recommencer")
                            .padding()
                            .background(Color.purple)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                } else {
                    HStack {
                        Button(action: { self.drawCard(for: .player) }) {
                            Text("Tirer")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }

                        Button(action: { self.stopGame() }) {
                            Text("Rester")
                                .padding()
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        Button(action: { self.doubleBet() }) {
                            Text("Doubler")
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                }
            }
            Spacer()
        }
        .onAppear(perform: setupGame)
    }
    
    func placeBet(_ amount: Int) {
        if playerBalance >= amount {
            playerBet = amount
            playerBalance -= amount
            resetGame = false
            setupGame()
        } else {
            gameMessage = "Pas assez de fonds pour parier \(amount) €."
        }
    }
    
    func resetBalance() {
        playerBalance = 1000
    }
    
    func setupGame() {
        deck = createDeck()
        deck.shuffle()
        playerCards = [deck.removeLast(), deck.removeLast()]
        dealerCards = [deck.removeLast()]
        updateScores()
    }

    func createDeck() -> [Card] {
        return cardNames.flatMap { name in
            cardSuits.map { suit in
                Card(name: name, suit: suit)
            }
        }
    }
    
    func cardValue(card: Card) -> Int {
        switch card.name {
        case "Valet", "Dame", "Roi":
            return 10
        case "As":
            return 11
        default:
            return Int(card.name) ?? 0
        }
    }
    
    func calculateScore(cards: [Card]) -> Int {
        var score = 0
        var acesCount = 0
        
        for card in cards {
            score += cardValue(card: card)
            if card.name == "As" {
                acesCount += 1
            }
        }
        
        while score > 21 && acesCount > 0 {
            score -= 10
            acesCount -= 1
        }
        
        return score
    }

    func updateScores() {
        playerScore = calculateScore(cards: playerCards)
        dealerScore = calculateScore(cards: dealerCards)
    }

    func drawCard(for player: Player) {
        if player == .player {
            let newCard = deck.removeLast()
            playerCards.append(newCard)
            updateScores()
            
            if playerScore > 21 {
                gameMessage = "Le joueur dépasse 21 !\nLe dealer gagne."
            }
        } else {
            while dealerScore < 17 {
                let newCard = deck.removeLast()
                dealerCards.append(newCard)
                updateScores()
            }
            determineWinner()
        }
    }
    
    func doubleBet() {
        if playerBalance >= playerBet {
            playerBalance -= playerBet
            playerBet *= 2
            let newCard = deck.removeLast()
            playerCards.append(newCard)
            updateScores()
            
            if playerScore > 21 {
                gameMessage = "Le joueur dépasse 21 !\nLe dealer gagne."
                playerBet = 0
            } else {
                drawCard(for: .dealer)
            }
        } else {
            gameMessage = "Pas assez de fonds pour doubler."
        }
    }

    func stopGame() {
        if dealerCards.count == 1 {
            let newCard = deck.removeLast()
            dealerCards.append(newCard)
            updateScores()
        }

        drawCard(for: .dealer)
    }

    func determineWinner() {
        if dealerScore > 21 {
            gameMessage = "Le dealer dépasse 21 !\nLe joueur gagne !"
            playerBalance += playerBet * 2
        } else if playerScore > dealerScore {
            gameMessage = "Le joueur gagne !"
            playerBalance += playerBet * 2
        } else if dealerScore > playerScore {
            gameMessage = "Le dealer gagne !"
            playerBalance -= playerBet
            if playerBalance < 0 {
                playerBalance = 0
            }
        } else if dealerScore == 21 && playerScore == 21 {
            gameMessage = "C'est une égalité.\nVous gagnez"
            playerBalance += playerBet * 2
        } else {
            gameMessage = "C'est une égalité."
            playerBalance += playerBet
        }
        playerBet = 0
    }
    
    func resetGameToBetting() {
        playerCards.removeAll()
        dealerCards.removeAll()
        playerScore = 0
        dealerScore = 0
        gameMessage = "Blackjack"
        resetGame = true
        deck = createDeck()
        deck.shuffle()
    }
}

enum Player {
    case player, dealer
}

struct BlackjackApp: App {
    var body: some Scene {
        WindowGroup {
            GameView()
        }
    }
}

#Preview {
    GameView()
}
