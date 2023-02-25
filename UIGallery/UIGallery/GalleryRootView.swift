import SwiftUI

struct GalleryRootView: View {
    var body: some View {
        NavigationView {
            List {
                Section {
                    NavigationLink("Tap") {
                        TapGestureView()
                    }
                    NavigationLink("Double tap") {
                        DoubleTapGestureView()
                    }
                    NavigationLink("Long press") {
                        LongPressGestureView()
                    }
                    NavigationLink("Rotation") {
                        RotationGestureView()
                    }
                    NavigationLink("Drag") {
                        DragGestureView()
                    }
                    NavigationLink("Long press and drag") {
                        LongPressAndDragGestureView()
                    }
                } header: {
                    Text("Gesture Samples")
                }
                
                Section {
                    NavigationLink("Text - Adding") {
                        TextAddingView()
                    }
                    NavigationLink("Shape - Circle") {
                        ShapeCircleView()
                    }
                    NavigationLink("Shape - Rectangle") {
                        ShapeRectangleView()
                    }
                    NavigationLink("Shape - Path") {
                        ShapePathView()
                    }
                    NavigationLink("Gradient - Linear") {
                        LinearGradientView()
                    }
                    NavigationLink("Gradient - Angular") {
                        AngularGradientView()
                    }
                    NavigationLink("Gradient - Radial") {
                        RadialGradientView()
                    }
                } header: {
                    Text("View Samples")
                }
                
                /*
                Section {
                    NavigationLink("Sample") {
                        // Preview
                    }
                    NavigationLink("Sample") {
                        // Preview
                    }
                    NavigationLink("Sample") {
                        // Preview
                    }
                } header: {
                    Text("Control Samples")
                }
                
                Section {
                    NavigationLink("Sample") {
                        // Preview
                    }
                    NavigationLink("Sample") {
                        // Preview
                    }
                    NavigationLink("Sample") {
                        // Preview
                    }
                } header: {
                    Text("Layout Samples")
                }
                
                Section {
                    NavigationLink("Sample") {
                        // Preview
                    }
                    NavigationLink("Sample") {
                        // Preview
                    }
                    NavigationLink("Sample") {
                        // Preview
                    }
                } header: {
                    Text("Animation Samples")
                }
                 */
            }
            .navigationTitle("SwiftUI Gallery")
        }
        .navigationViewStyle(.stack)
    }
}

struct GalleryRootView_Previews: PreviewProvider {
    static var previews: some View {
        GalleryRootView()
    }
}
