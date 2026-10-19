import SwiftUI

struct BookDetailView: View {
    var title: String
    var author: String = "Autor Desconocido"
    var description: String = "Este es un libro fascinante que explora los misterios del bosque nocturno..."

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Colors.primaryText)

            Text(author)
                .font(.title2)
                .foregroundColor(Colors.secondaryText)

            Text("Descripción")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(Colors.accent)

            Text(description)
                .foregroundColor(Colors.contrast)
        }
        .padding()
        .background(Colors.primaryBackground)
    }
}

struct BookDetailView_Previews: PreviewProvider {
    static var previews: some View {
        BookDetailView(title: "El Secreto del Búho")
    }
}

// Assuming Colors is defined somewhere else in the project as:
// struct Colors {
//     static let primaryBackground = Color.white
//     static let luxuryAccent = Color.orange
//     static let contrast = Color.gray
//     static let secondaryText = Color.gray.opacity(0.7)
//     static let primaryText = Color.black
// }

