import SwiftUI

struct GalleryRootView: View {
    var body: some View {
        NavigationView {
            List {
                Section {
                    NavigationLink("Paged List") {
                        TransactionListView(viewModel: .makeStub())
                    }
                } header: {
                    Text("Features")
                }

                Section {
                    NavigationLink("Navigation") {
                        GalleryNavigationView()
                    }

                    NavigationLink("Nested Navigation Links") {
                        NestedNavigationLink()
                    }

                    NavigationLink("Route Sample") {
                        RouterWithNavigationLink()
                    }

                    if #available(iOS 16.0, *) {
                        NavigationLink("Routing with NavigationPath (iOS 16)") {
                            RoutingExample.PathNavigationView()
                        }

                        NavigationLink("Routing with Destination (iOS 16)") {
                            RoutingExample.DestinationNavigationStackView()
                        }

                        NavigationLink("Routing with filled Destinations (iOS 16)") {
                            RoutingExample.DestinationNavigationStackView([.start, .count(1), .count(2), .count(3), .finish])
                        }
                    }

                    NavigationLink("Routing with destination") {
                        RoutingExample.DestinationView()
                    }

                } header: {
                    Text("Flow")
                }

                Section {
                    NavigationLink("ProgressView") {
                        SampleProgressView()
                    }
                    NavigationLink("Bottom content") {
                        BottomContentSampleView()
                    }
                } header: {
                    Text("Custom Controls")
                }

                Section {
                    NavigationLink("Expandable items") {
                        ExpadableItemsSampleView()
                    }
                    NavigationLink("Simple hero") {
                        SimpleHeroView()
                    }
                    NavigationLink("Scroll hero") {
                        ScrollHeroView()
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
                    NavigationLink("Date Picker") {
                        DatePickerSampleView()
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
