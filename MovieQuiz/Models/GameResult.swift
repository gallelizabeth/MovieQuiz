import Foundation

struct GameResult {
    let correct: Int
    let total: Int
    let date: Date
    
    func theBestResult(_ anotherTry: GameResult) -> Bool { correct > anotherTry.correct }
}
