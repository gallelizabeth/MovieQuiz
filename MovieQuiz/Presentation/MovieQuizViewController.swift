import UIKit

final class MovieQuizViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    
    
    // MARK: - Properties
    private let questions = QuizQuestion.mockQuestions
    private var correctAnswers = 0
    private var currentQuestionIndex = 0
    
    
    // MARK: - Actions
    @IBAction private func yesButtonClicked(_ sender: Any) {
        checkAnswer(true)}
    @IBAction private func noButtonClicked(_ sender: Any) {
        checkAnswer(false)}
    
    
    // MARK: - Quiz Logic
    private func checkAnswer(_ givenAnswer: Bool){
        showAnswerResult(isCorrect: givenAnswer == questions[currentQuestionIndex].correctAnswer)
    }
    
    private func showAnswerResult(isCorrect: Bool) {
            if isCorrect{correctAnswers += 1}
            
            imageView.layer.masksToBounds = true
            imageView.layer.borderWidth = 8
            imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
            imageView.layer.cornerRadius = 20
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.showNextQuestionOrResults()
            }
        }
    
    private func showNextQuestionOrResults() {
      if currentQuestionIndex == questions.count - 1 {
          // конец квиза
          let result = QuizResultsViewModel(
              title: "Этот раунд окончен!",
              text: "Ваш результат: \(correctAnswers)/10",
              buttonText: "Сыграть ещё раз"
          )

          show(quiz: result)
      } else {
          currentQuestionIndex += 1
          
          let nextQuestion = questions[currentQuestionIndex]
          let viewModel = convert(model: nextQuestion)
          
          imageView.layer.borderWidth = 0
          show(quiz: viewModel)
      }
    }
    
    
    // MARK: - View Models
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image:
                UIImage(named: model.image)!,
            question:
                model.text,
            questionNumber: String("\(currentQuestionIndex + 1)/\(questions.count)"))
    }
    
    
    // MARK: - UI
    private func show(quiz step: QuizStepViewModel) {
        counterLabel.text = step.questionNumber
        imageView.image = step.image
        textLabel.text = step.question
    }

    private func show(quiz result: QuizResultsViewModel) {
        imageView.layer.borderWidth = 0
        let alert = UIAlertController(
                title: result.title,
                message: result.text,
                preferredStyle: .alert)
            
            let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
                self.currentQuestionIndex = 0
                self.correctAnswers = 0
                
                let firstQuestion = self.questions[self.currentQuestionIndex]
                let viewModel = self.convert(model: firstQuestion)
                self.show(quiz: viewModel)
            }
            alert.addAction(action)
            
            self.present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let currentQuestion = questions[currentQuestionIndex]
        let viewModel = convert(model: currentQuestion)
        show(quiz: viewModel)
    }
}
