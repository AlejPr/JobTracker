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


//MARK: - Custom Picker View
struct CustomPickerView<T: Hashable>: View {
    
    let options: [T]
    let displayName: (T) -> String
    @Binding var selection: T
    
    var backgroundColor: Color = Color(nsColor: .controlBackgroundColor)
    var borderColor: Color = Color(nsColor: .separatorColor)
    var textColor: Color = .primary
    var cornerRadius: CGFloat = 8
    var padding: EdgeInsets = EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
    var disabled: Bool = false
    
    @State private var isExpanded = false
        
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            
            //Picker Button
            Button {
                withAnimation(.easeInOut(duration: 0.2)) { isExpanded.toggle() }
                
            } label: {
                HStack {
                    Text(displayName(selection))
                        .font(.system(size: 15))
                        .foregroundColor(textColor)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(textColor)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .animation(.easeInOut(duration: 0.2), value: isExpanded)
                }
                .padding(padding)
                .background(backgroundColor)
                .cornerRadius(isExpanded ? cornerRadius : cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(borderColor, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            .disabled(disabled)
            
            //Menu
            .overlay(alignment: .topLeading) {
                if isExpanded {
                    dropDownMenu()
                }
            }
            
            .overlay {
                if disabled {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray)
                        .opacity(0.15)
                }
            }
        }
    }
    
    
    private func dropDownMenu() -> some View {
        VStack(spacing: 0) {
            ForEach(Array(options.enumerated()), id: \.element) { index, option in
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        selection = option
                        isExpanded = false
                    }
                } label: {
                    HStack {
                        Text(displayName(option))
                            .font(.system(size: 15))
                            .foregroundColor(textColor)
                        
                        Spacer()
                        
                        if selection == option {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(selection == option ? Color.blue.opacity(0.1) : backgroundColor)
                }
                .buttonStyle(.plain)
                
                if index < options.count - 1 {
                    Rectangle()
                        .fill(borderColor)
                        .frame(height: 1)
                        .padding(.horizontal, 10)
                }
            }
        }
        .background(backgroundColor)
        .cornerRadius(cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(borderColor, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        .offset(y: padding.top + padding.bottom + 25) // Position below the button
        .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .top)))
    }
    
}


//MARK: - Preview
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
