import SwiftUI

struct ProfileView: View {
	var body: some View {
		NavigationStack {
			ZStack {
				AppColors.background.ignoresSafeArea()

				Text("Perfil")
					.foregroundColor(AppColors.primaryText)
			}
			.navigationTitle("Perfil")
			.navigationBarTitleDisplayMode(.inline)
		}
	}
}
