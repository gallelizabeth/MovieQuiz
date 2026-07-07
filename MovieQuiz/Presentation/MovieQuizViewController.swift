import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    // MARK: - IBOutlets
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    
    
    // MARK: - Properties
    private var correctAnswers = 0
    private var currentQuestionIndex = 0
    
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter = AlertPresenter()
    private var statisticService : StatisticServiceProtocol = StatisticService() // инициализация сервиса по статистике
    
    
    // MARK: - Actions
    @IBAction private func yesButtonClicked(_ sender: Any) {
        showAnswerResult(isCorrect: true)}
    @IBAction private func noButtonClicked(_ sender: Any) {
        showAnswerResult(isCorrect: false)}
    
    
    // MARK: - Quiz Logic
    private func checkAnswer(_ givenAnswer: Bool){
        guard let currentQuestion = currentQuestion else { return }
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        // guard let currentQuestion = currentQuestion else { return }
        
        yesButton.isEnabled = false
        noButton.isEnabled = false
        
        if isCorrect{correctAnswers += 1}
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        imageView.layer.cornerRadius = 20
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return}
            
            self.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            let result = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: "Ваш результат: \(correctAnswers)/10 \nКоличество сыгранных квизов: \(statisticService.gamesCount) \nРекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))\nСредняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%",
                buttonText: "Сыграть ещё раз"
            )
            show(quiz: result)
        } else {
            currentQuestionIndex += 1
            
            questionFactory?.requestNextQuestion()
        }
    }
    
    
    // MARK: - View Models
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(named: model.imageName) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    
    // MARK: - UI
    private func show(quiz step: QuizStepViewModel) {
        yesButton.isEnabled = true
        noButton.isEnabled = true
        
        imageView.layer.borderWidth = 0

        counterLabel.text = step.questionNumber
        imageView.image = step.image
        textLabel.text = step.question
    }
    
    func show(quiz result: QuizResultsViewModel) {
        print("алерт")
        let model = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText)
        { [weak self] in
            guard let self = self else { return }

            restartGame() // self.presenter.restartGame()
            
        }
        
        alertPresenter.show(in: self, model: model)
    }
    
    private func restartGame() {
        imageView.layer.borderWidth = 0

        currentQuestionIndex = 0
        correctAnswers = 0
        
        questionFactory?.requestNextQuestion()
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)

        let questionFactory = QuestionFactory()
        questionFactory.delegate = self
        self.questionFactory = questionFactory

        questionFactory.requestNextQuestion()
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
}
