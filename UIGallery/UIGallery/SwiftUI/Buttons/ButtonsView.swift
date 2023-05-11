//
//  ButtonsView.swift
//  UIGallery
//
//  Created by Joachim Kret on 11/05/2023.
//

import SwiftUI

struct ButtonsView: View {
    @State private var isLoading: Bool = false
    var body: some View {
        List {
            makeStyledButtonsSection()
            makeBorderedButtonsSection()
            makeButtonRolesSection()
            makeListSwipeActionsSection()
            makeButtonBorderShapeSection()
            makeControlSizesButtonsSection()
        }
    }
    
    @ViewBuilder
    private func makeStyledButtonsSection() -> some View {
        Section {
            Button("Filled Style") {}
                .buttonStyle(FilledButtonStyle())
            Button("Outline Style") {}
                .buttonStyle(OutlineButtonStyle())
            Button("Loading style") { isLoading.toggle() }
                .buttonStyle(ProgressButtonStyle(isLoading: isLoading))
            Button("Growing Style") {}
                .buttonStyle(GrowingButtonStyle())
            Button("Gradient Style 1") {}
                .buttonStyle(GradientButtonStyle(colors: [.pink]))
            Button("Gradient Style 2") {}
                .buttonStyle(GradientButtonStyle(colors: [.pink, .purple]))
            Button("Gradient Style 3") {}
                .buttonStyle(GradientButtonStyle(colors: [.pink, .purple, .blue]))
            Button("Big Button Style") {}
                .buttonStyle(BigButtonStyle())
        } header: {
            Text("Custom styled buttons")
        }
    }
    
    @ViewBuilder
    private func makeBorderedButtonsSection() -> some View {
        if #available(iOS 15, *) {
            Section {
                // bordered buttons
                Button("Button 5") {}
                    .buttonStyle(.borderless)
                Button("Button 7") {}
                    .buttonStyle(.bordered)
                Button("Button 8") {}
                    .buttonStyle(.borderedProminent)
            } header: {
                Text("Bordered buttons (iOS 15)")
            }
        }
    }
    
    @ViewBuilder
    private func makeButtonRolesSection() -> some View {
        if #available(iOS 15, *) {
            Section {
                Button(role: .destructive) {
                } label: {
                    Text("Destructive")
                }

                Button(role: .cancel) {
                } label: {
                    Text("Cancel")
                }
            } header: {
                Text("Button roles (iOS 15)")
            }
        }
    }
    
    @ViewBuilder
    private func makeListSwipeActionsSection() -> some View {
        if #available(iOS 15, *) {
            Section {
                Button(role: .destructive) {
                } label: {
                    Text("Swipe Actions")
                }
                .swipeActions {
                    Button(role: .destructive) {
                    } label: {
                        Label("Remove", systemImage: "trash")
                    }
                    // 3
                    Button(role: .cancel) {
                    } label: {
                        Label("Add", systemImage: "plus")
                    }
                    // 4
                    Button {
                    } label: {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                    .tint(.mint)
                }
            } header: {
                Text("Button cell actions (iOS 15)")
            }
        }
    }
    
    @ViewBuilder
    private func makeButtonBorderShapeSection() -> some View {
        if #available(iOS 15, *) {
            Section {
                Button {
                } label: {
                    Text("Capsule")
                }
                .buttonBorderShape(.capsule)
                .buttonStyle(.bordered)
                
                Button {
                } label: {
                    Text("RoundedRectangle(radius: 2)")
                }
                .buttonBorderShape(.roundedRectangle(radius: 2))
                .buttonStyle(.bordered)
            } header: {
                Text("Button border shape (iOS 15)")
            }
        }
    }
    
    @ViewBuilder
    private func makeControlSizesButtonsSection() -> some View {
        if #available(iOS 15, *) {
            Section {
                Button {
                } label: {
                    Text("Mini")
                }
                .controlSize(.mini)
                .buttonStyle(.borderedProminent)

                Button {
                } label: {
                    Text("Small")
                }
                .controlSize(.small)
                .buttonStyle(.borderedProminent)

                Button {
                } label: {
                    Text("Regular")
                }
                .controlSize(.regular)
                .buttonStyle(.borderedProminent)

                Button {
                } label: {
                    Text("Large")
                }
                .controlSize(.large)
                .buttonStyle(.borderedProminent)
            } header: {
                Text("Button control sizes (iOS 15)")
            }
        }
    }
}

struct FilledButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .foregroundColor(configuration.isPressed ? .gray : .white)
            .padding()
            .background(isEnabled ? Color.accentColor : .gray)
            .cornerRadius(8)
    }
}

struct OutlineButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .foregroundColor(configuration.isPressed ? .gray : .accentColor)
            .padding()
            .background(
                RoundedRectangle(
                    cornerRadius: 8.0,
                    style: .continuous)
                .stroke(Color.accentColor)
            )
    }
}

struct ProgressButtonStyle: ButtonStyle {
    let isLoading: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        if #available(iOS 15, *) {
            configuration
                .label
                .foregroundColor(configuration.isPressed ? .gray : .accentColor)
                .opacity(isLoading ? 0 : 1)
                .overlay {
                    if isLoading {
                        Text("...")
                    }
                }
        } else {
            configuration
                .label
                .foregroundColor(configuration.isPressed ? .gray : .accentColor)
                .opacity(isLoading ? 0 : 1)
        }
        
    }
}

struct GradientButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    let colors: [Color]
    
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Image(systemName: "highlighter")
            configuration.label
        }
        .font(.body.bold())
        .foregroundColor(isEnabled ? .white : .black)
        .padding()
        .frame(height: 44.0)
        .background(makeBackgroudView(configuration: configuration))
        .cornerRadius(10.0)
    }
    
    @ViewBuilder
    private func makeBackgroudView(configuration: Configuration) -> some View {
        if !isEnabled {
            disabledBackground
        } else if configuration.isPressed {
            pressedBackground
        } else {
            enabledBackground
        }
    }
    
    private var enabledBackground: some View {
        LinearGradient(
            colors: colors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing)
    }
    
    private var disabledBackground: some View {
        LinearGradient(
            colors: [.gray],
            startPoint: .topLeading,
            endPoint: .bottomTrailing)
    }
    
    private var pressedBackground: some View {
        LinearGradient(
            colors: colors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing)
        .opacity(0.4)
    }
}

struct GrowingButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .foregroundColor(configuration.isPressed ? .gray : .white)
            .background(isEnabled ? Color.accentColor : .gray)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct BigButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @State var color: Color = .accentColor

    func makeBody(configuration: Configuration) -> some View {
        if #available(iOS 15, *) {
            configuration.label
            .font(.title.bold())
            .padding()
            .frame(maxWidth: .infinity)
            .foregroundColor(isEnabled ? .white : Color(UIColor.systemGray3))
            .background(isEnabled ? color : Color(UIColor.systemGray5))
            .cornerRadius(12)
            .overlay {
                if configuration.isPressed {
                    Color(white: 1.0, opacity: 0.2)
                        .cornerRadius(12)
                }
            }
        }
    }
}

struct ButtonsView_Previews: PreviewProvider {
    static var previews: some View {
        ButtonsView()
    }
}
