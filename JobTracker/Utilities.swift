//
//  Utilities.swift
//  JobTracker
//

import SwiftUI


public struct TextFieldPlaceholderStyle: ViewModifier {
    var showPlaceHolder: Bool
    var placeholder: String
    var textColor: Color

    public func body(content: Content) -> some View {
        ZStack(alignment: .leading) {
            if showPlaceHolder {
                Text(placeholder)
                    .padding(.horizontal, 15)
                    .foregroundStyle(textColor)
            }
            content
        }
    }
}


#Preview {
    struct PreviewContainer: View {
        @State private var testString: String = ""
        var body: some View {
            ZStack {
                Color.white
                TextField("", text: $testString)
                    .foregroundStyle(.black)
                    .textFieldStyle(.plain)
                    .modifier(TextFieldPlaceholderStyle(showPlaceHolder: true, placeholder: "Testing!", textColor: .blue))
            }
        }
     }
    return PreviewContainer()
}
