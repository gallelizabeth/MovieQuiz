import UIKit

final class MovieQuizViewController: UIViewController {
    private var correctAnswers = 0
    private var currentQuestionIndex = 0
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        checkAnswer(true)
    }
    @IBAction private func noButtonClicked(_ sender: Any) {
        checkAnswer(false)
    }
    
    
    private func checkAnswer(_ givenAnswer: Bool){
        showAnswerResult(isCorrect: givenAnswer == questions[currentQuestionIndex].correctAnswer)
    }
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image:
                UIImage(named: model.image)!,
            question:
                model.text,
            questionNumber: String("\(currentQuestionIndex + 1)/\(questions.count)"))
    }
    
    private func show(quiz step: QuizStepViewModel) {
        counterLabel.text = step.questionNumber
        imageView.image = step.image
        textLabel.text = step.question
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

    private func show(quiz result: QuizResultsViewModel) {
        imageView.layer.borderWidth = 0
        let alert = UIAlertController(
                title: result.title,
                message: result.text,
                preferredStyle: .alert)
            
            let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
                self.currentQuestionIndex = 0
                self.correctAnswers = 0
                
                let firstQuestion = questions[self.currentQuestionIndex]
                let viewModel = self.convert(model: firstQuestion)
                self.show(quiz: viewModel)
            }
            alert.addAction(action)
            
            self.present(alert, animated: true, completion: nil)
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let currentQuestion = questions[currentQuestionIndex]
        let viewModel = convert(model: currentQuestion)
        show(quiz: viewModel)
    }
}

struct QuizStepViewModel {
  let image: UIImage
  let question: String
  let questionNumber: String
}

struct QuizResultsViewModel {
  let title: String
  let text: String
  let buttonText: String
}

struct QuizQuestion {
    let image: String
    let text: String
    let correctAnswer: Bool
}
// массив вопросов
private let questions: [QuizQuestion] = [
    QuizQuestion(
    image: "The Godfather",
    text: "Рейтинг этого фильма больше чем 6?",
    correctAnswer: true),
    
    QuizQuestion(
    image: "The Dark Knight",
    text: "Рейтинг этого фильма больше чем 6?",
    correctAnswer: true),
    
    QuizQuestion(
    image: "Kill Bill",
    text: "Рейтинг этого фильма больше чем 6?",
    correctAnswer: true),
    
    QuizQuestion(
    image: "The Avengers",
    text: "Рейтинг этого фильма больше чем 6?",
    correctAnswer: true),
    
    QuizQuestion(
    image: "Deadpool",
    text: "Рейтинг этого фильма больше чем 6?",
    correctAnswer: true),
    
    QuizQuestion(
    image: "The Green Knight",
    text: "Рейтинг этого фильма больше чем 6?",
    correctAnswer: true),
    
    QuizQuestion(
    image: "Old",
    text: "Рейтинг этого фильма больше чем 6?",
    correctAnswer: false),
    
    QuizQuestion(
    image: "The Ice Age Adventures of Buck Wild",
    text: "Рейтинг этого фильма больше чем 6?",
    correctAnswer: false),
    
    QuizQuestion(
    image: "Tesla",
    text: "Рейтинг этого фильма больше чем 6?",
    correctAnswer: false),
    
    QuizQuestion(
    image: "Vivarium",
    text: "Рейтинг этого фильма больше чем 6?",
    correctAnswer: false)
]
