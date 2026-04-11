//
//  Utilities.swift
//  JobTracker
//

import SwiftUI


public struct TextFieldPlaceholderStyle: ViewModifier {
    var showPlaceHolder: Bool
    var placeholder: String
    var textColor: Color
    var leadingOffset: CGFloat = 0
    var font: Font = .body

    public func body(content: Content) -> some View {
        ZStack(alignment: .leading) {
            if showPlaceHolder {
                Text(placeholder)
                    .padding(.horizontal, 15)
                    .foregroundStyle(textColor)
                    .padding(.leading, leadingOffset)
                    .font(font)
                    .lineLimit(1)
            }
            content
        }
    }
}


public struct PressedOpacityButtonStyle: ButtonStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.6 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
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
    
    @Binding var expandedPickerId: String?
    let pickerId: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            
            //Picker Button
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    if expandedPickerId == pickerId { expandedPickerId = nil }
                    else { expandedPickerId = pickerId }
                }
                
            } label: {
                HStack {
                    Text(displayName(selection))
                        .font(.system(size: 15))
                        .foregroundColor(textColor)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(textColor)
                        .rotationEffect(.degrees(expandedPickerId == pickerId ? 180 : 0))
                        .animation(.easeInOut(duration: 0.2), value: expandedPickerId == pickerId)
                }
                .padding(padding)
                .background(backgroundColor)
                .cornerRadius(expandedPickerId == pickerId ? cornerRadius : cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(borderColor, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            .disabled(disabled)
            
            //Menu
            .overlay(alignment: .topLeading) {
                if expandedPickerId == pickerId { dropDownMenu() }
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
                        expandedPickerId = nil
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


//MARK: - Button
struct LargeStylizedButton: View {
    
    let action: () -> Void
    let buttonSidePadding: CGFloat = 15
    let containerHeight: CGFloat = 90
    let imageName: String 
    let title: String
    var isVisible: Bool = true
    var disabled: Bool = false
    
    var body: some View {
        if isVisible {
            
            Button(action: action) {
                HStack(spacing: 8) {
                    
                    Image(systemName: imageName)
                        .font(.system(size: 16, weight: .medium))
                        .padding(.leading, 10)
                    
                    Text("\(title)")
                        .font(.system(size: 16, weight: .medium))
                        .padding(.trailing, 20)
                }
                .foregroundColor(.white)
                .frame(height: 48)
                .frame(maxWidth: .infinity)
                .background(disabled ? Color.gray : Color.blue)
                .cornerRadius(8)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, buttonSidePadding)
            .frame(height: containerHeight)
            .allowsHitTesting(!disabled)
        }
    }
    
}


//MARK: - Functions
public func isValidUrl(url: String) -> Bool {
    let urlRegEx = "^(https?://)?([a-z0-9-]+\\.)+[a-z]{2,63}(/[-\\w@\\+\\.~#\\?&/=%]*)?$"
    let urlTest = NSPredicate(format:"SELF MATCHES %@", urlRegEx)
    let result = urlTest.evaluate(with: url)
    return result
}


//MARK: - Preview
#Preview {
    /*
    struct PreviewContainer: View {
        @State private var testString: String = ""
        var body: some View {

        }
     }
    return PreviewContainer()
     */
}
