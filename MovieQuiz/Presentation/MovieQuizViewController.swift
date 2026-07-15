import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
    // MARK: - IBOutlets
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    
    // MARK: - Properties
    private var alertPresenter = AlertPresenter()
    private var presenter: MovieQuizPresenter!

    
    // MARK: - Actions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    // MARK: - UI
    func highlightImageBorder(isCorrectAnswer: Bool){
        yesButton.isEnabled = false
        noButton.isEnabled = false
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }

    func show(quiz step: QuizStepViewModel) {
        yesButton.isEnabled = true
        noButton.isEnabled = true
        
        imageView.layer.borderWidth = 0

        imageView.image = UIImage(data: step.image) ?? UIImage()
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    func show(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(
                title: result.title,
                message: result.text,
                preferredStyle: .alert)

        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
                    guard let self = self else { return }

            self.presenter.restartGame()
            }

        alert.addAction(action)

        self.present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - Error Handling
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }
        
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        let model = AlertModel(
            title: "Что-то пошло не так(",
            message: "Невозможно загрузить данные",
            buttonText: "Попробовать ещё раз")
        { [weak self] in
            guard self != nil else { return }
        }
        self.presenter.restartGame()
            alertPresenter.show(in: self, model: model)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = MovieQuizPresenter(viewController: self)

        imageView.layer.cornerRadius = 20
        
        showLoadingIndicator()
    }
}
