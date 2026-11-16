import SwiftUI
import SafariServices

struct SafariReaderView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        let configuration = SFSafariViewController.Configuration()
        configuration.entersReaderIfAvailable = false
        let controller = SFSafariViewController(url: url, configuration: configuration)
        controller.preferredBarTintColor = UIColor(AppColors.background)
        controller.preferredControlTintColor = UIColor(AppColors.accent)
        controller.dismissButtonStyle = .close
        return controller
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}
