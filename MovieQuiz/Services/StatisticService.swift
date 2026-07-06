import Foundation

final class StatisticService: StatisticServiceProtocol{
    private let storage: UserDefaults = .standard
    
    private enum Keys: String {
        case gamesCount          // Счётчик сыгранных игр
        case bestGameCorrect     // Для количества правильных ответов в лучшей игре
        case bestGameTotal       // Для общего количества вопросов в лучшей игре
        case bestGameDate        // Для даты лучшей игры
        case totalCorrectAnswers // Для общего количества правильных ответов за все игры
        case totalQuestionsAsked // Для общего количества вопросов, заданных за все игры
    }
    
    var gamesCount: Int{
        get {
            storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameResult{
        get {
            let correct =  storage.integer(forKey: Keys.bestGameCorrect.rawValue)
            let total =  storage.integer(forKey: Keys.bestGameTotal.rawValue)
            let date = storage.object(forKey: Keys.bestGameDate.rawValue) as? Date ?? Date()
            
            return GameResult(
                correct: correct,
                total: total,
                date: date)
        }
        set {
            storage.set(newValue.correct, forKey: Keys.bestGameCorrect.rawValue)
            storage.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
            storage.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
        }
    }
    
    var totalAccuracy: Double{
        get{
            let totalCorrectAnswers = storage.double(forKey: Keys.totalCorrectAnswers.rawValue)
            let totalQuestionsAsked = storage.double(forKey: Keys.totalQuestionsAsked.rawValue)
            
            guard totalQuestionsAsked > 0 else {return 0.0}
            return (totalCorrectAnswers / totalQuestionsAsked) * 100
            // return (totalCorrectAnswers / Double(gamesCount * 10)) * 100
        }
    }
    
    func store(correct count: Int, total amount: Int) {
        // обновление количества правильных ответов
        var allCorrect =  storage.integer(forKey: Keys.totalCorrectAnswers.rawValue)
        allCorrect += count
        storage.set(allCorrect, forKey: Keys.totalCorrectAnswers.rawValue)
        
        // обновление количества заданных вопросов
        var allAmount =  storage.integer(forKey: Keys.totalQuestionsAsked.rawValue)
        allAmount += amount
        storage.set(allAmount, forKey: Keys.totalQuestionsAsked.rawValue)
        
        // обновление кол-ва сыгранных игр
        gamesCount += 1
        
        // проверка рекорд
        let currentGame = GameResult(correct: count, total: amount, date: Date())
        if bestGame.total == 0{
            bestGame = currentGame
        }else{
            if currentGame.theBestResult(bestGame){
                storage.set(count, forKey: Keys.bestGameCorrect.rawValue)
                storage.set(Date(), forKey: Keys.bestGameDate.rawValue)
            }
        }
    }
}
