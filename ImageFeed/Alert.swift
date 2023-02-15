import UIKit

final class Alert {
    private let controller: UIViewController
    
    init(controller: UIViewController) {
        self.controller = controller
    }
    
    func showAlert() {
        let alert = UIAlertController(
            title: "Что-то пошло не так",
            message:"Не удалось войти в систему»",
            preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "ok", style: .cancel, handler: { action in })
        alert.addAction(alertAction)
        DispatchQueue.main.async {
            self.controller.present(alert, animated: true)
        }
    }
}
