import SwiftUI

struct GalleryRootView: View {
    var body: some View {
        NavigationView {
            List {
                Section {
                    NavigationLink("Navigation") {
                        GalleryNavigationView()
                    }
                } header: {
                    Text("")
                }
                
                Section {
                    NavigationLink("ProgressView") {
                        SampleProgressView()
                    }
                } header: {
                    Text("Custom Controls")
                }
                
                Section {
                    NavigationLink("Simple hero") {
                        SimpleHeroView()
                    }
                    NavigationLink("Card hero") {
                        CardHeroView()
                    }
                    NavigationLink("Parallax Motion") {
                        ParallaxMotionView()
                    }
                } header: {
                    Text("Effect Samples")
                }
                
                Section {
                    NavigationLink("Repeat scale animations") {
                        RepeatAnimationsView()
                    }
                    NavigationLink("Rotate animations") {
                        RotateAnimationsView()
                    }
                    NavigationLink("Rotate 3D animations") {
                        Rotate3DAnimationsView()
                    }
                } header: {
                    Text("Animation Samples")
                }
                
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
                    NavigationLink("Magnification") {
                        MagnificationGestureView()
                    }
                    NavigationLink("Exclusive gesture") {
                        ExclusiveGestureView()
                    }
                    NavigationLink("Sequence gesture") {
                        SequenceGestureView()
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
                
                Section {
                    NavigationLink("Buttons") {
                         ButtonsView()
                    }
                    NavigationLink("TextFields") {
                        TextFieldsView()
                    }
                } header: {
                    Text("Control Samples")
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
                    Text("Layout Samples")
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
