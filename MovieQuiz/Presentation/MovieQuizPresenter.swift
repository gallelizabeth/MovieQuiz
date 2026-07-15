import Foundation


struct QuizStepViewModel {
  let image: Data
  let question: String
  let questionNumber: String
}


final class MovieQuizPresenter: QuestionFactoryDelegate {
    // MARK: - Properties
    private let statisticService: StatisticServiceProtocol!
    private var questionFactory: QuestionFactoryProtocol?
    private weak var viewController: MovieQuizViewControllerProtocol?

    private var currentQuestion: QuizQuestion?
    private let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0

    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController

        statisticService = StatisticService()

        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    // MARK: - Basic Used
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func restartGame(){
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    func switchToNextQuestion(){
        currentQuestionIndex += 1
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel{
        QuizStepViewModel(
            image: model.image,
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
    
    
    // MARK: - Actions With Buttons
    func didAnswer(isCorrectAnswer: Bool){
        correctAnswers += 1
    }
    
    func yesButtonClicked() {
        didAnswere(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswere(isYes: false)
    }
    
    private func didAnswere(isYes: Bool){
        guard let currentQuestion = currentQuestion else {return}
        
        let givenAnswer = isYes
        
        proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func didFailToLoadData(with error: Error) {
            let message = error.localizedDescription
            viewController?.showNetworkError(message: message)
        }
    
    func didLoadDataFromServer() {
            viewController?.hideLoadingIndicator()
            questionFactory?.requestNextQuestion()
        }
    
    private func proceedToNextQuestionOrResults() {
        if self.isLastQuestion() {
            statisticService.store(correct: correctAnswers, total: self.questionsAmount)
            
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: makeResultsMessage(),
                buttonText: "Сыграть ещё раз")
                viewController?.show(quiz: viewModel)
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    func makeResultsMessage() -> String {
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            
        let bestGame = statisticService.bestGame
        
        let currentGameResultLine = "Ваш результат: \(correctAnswers)\\\(questionsAmount)"
        let totalPlaysCountLine = "Количество сыгранных квизов: \(statisticService.gamesCount)"
        let bestGameInfoLine = "Рекорд: \(bestGame.correct)\\\(bestGame.total)"
        + " (\(bestGame.date.dateTimeString))"
        let averageAccuracyLine = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        
        let resultMessage = [
            currentGameResultLine, totalPlaysCountLine, bestGameInfoLine, averageAccuracyLine
        ].joined(separator: "\n")
        
        return resultMessage
    }
    
    private func proceedWithAnswer(isCorrect: Bool) {
        didAnswer(isCorrectAnswer: isCorrect)
        
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return}
            self.proceedToNextQuestionOrResults()
        }
    }
}
