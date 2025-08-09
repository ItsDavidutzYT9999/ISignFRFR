import UIKit

class ViewController: UIViewController, UIDocumentPickerDelegate {

    let apiBaseUrl = "https://211ee081-96fc-4d64-a08a-4a7ce6ea7ac2-00-jhq8klq3pz83.worf.replit.dev" // <-- Set your API base URL (no /api/upload)
    private var installButton: UIButton?
    private var itmsURL: String?
    private var selectedIPAURL: URL?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        let signInstallButton = SignInstallButton()
        signInstallButton.translatesAutoresizingMaskIntoConstraints = false
        signInstallButton.addTarget(self, action: #selector(selectIPAFile), for: .touchUpInside)

        view.addSubview(signInstallButton)

        NSLayoutConstraint.activate([
            signInstallButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signInstallButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            signInstallButton.widthAnchor.constraint(equalToConstant: 200),
            signInstallButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc private func selectIPAFile() {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.item], asCopy: true)
        picker.delegate = self
        picker.allowsMultipleSelection = false
        present(picker, animated: true, completion: nil)
    }

    // UIDocumentPickerDelegate
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        selectedIPAURL = url
        signAndInstallTapped()
    }

    private func signAndInstallTapped() {
        guard let ipaFileURL = selectedIPAURL,
              let ipaData = try? Data(contentsOf: ipaFileURL) else {
            print("No IPA file selected or failed to load IPA file.")
            return
        }

        let ipaWebSigner = IPAWebSigner(apiBaseUrl: apiBaseUrl)
        ipaWebSigner.signIPA(ipaData: ipaData) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let itmsURL):
                    print("IPA signed! Install URL: \(itmsURL)")
                    self?.itmsURL = itmsURL
                    self?.showInstallButton()
                case .failure(let error):
                    print("Failed to sign IPA: \(error.localizedDescription)")
                }
            }
        }
    }

    private func showInstallButton() {
        installButton?.removeFromSuperview()

        let button = UIButton(type: .system)
        button.setTitle("Install App", for: .normal)
        button.backgroundColor = UIColor.systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(installTapped), for: .touchUpInside)

        view.addSubview(button)
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.topAnchor.constraint(equalTo: view.centerYAnchor, constant: 70),
            button.widthAnchor.constraint(equalToConstant: 200),
            button.heightAnchor.constraint(equalToConstant: 50)
        ])
        installButton = button
    }

    @objc private func installTapped() {
        guard let itmsURL = itmsURL, let url = URL(string: itmsURL) else { return }
        UIApplication.shared.open(url)
    }
}