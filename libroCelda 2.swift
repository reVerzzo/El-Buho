import SwiftUI

struct BookCell: View {
    var title: String

    var body: some View {
        Text(title)
            .foregroundColor(Colors.primaryText)
            .padding()
            .background(Colors.accent)
            .cornerRadius(8)
    }
}

struct BookCell_Previews: PreviewProvider {
    static var previews: some View {
        BookCell(title: "Sample Book")
            .background(Colors.primaryBackground)
            .previewLayout(.sizeThatFits)
    }
}
