import UIKit

class SignInstallButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    private func setupButton() {
        self.setTitle("Sign & Install IPA", for: .normal)
        self.backgroundColor = UIColor.blue
        self.setTitleColor(UIColor.white, for: .white)
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
        
        self.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    @objc private func buttonTapped() {
        // Implement the action to send the IPA file to the web API for signing
        print("Button tapped! Implement API call here.")
    }
}