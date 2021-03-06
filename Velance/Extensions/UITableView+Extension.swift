import UIKit

extension UITableView {

    func setEmptyMessage(_ message: String) {
        
        let messageLabel = UILabel(frame: CGRect(x: 100, y: 100, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .black
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = .systemFont(ofSize: 17, weight: .bold)
        messageLabel.sizeToFit()

        self.backgroundView = messageLabel
        self.separatorStyle = .none
    
    }

    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .none
    }
}
