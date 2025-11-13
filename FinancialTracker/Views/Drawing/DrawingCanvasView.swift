//
//  DrawingCanvasView.swift
//  FinancialTracker
//
//  Created by Roy Dimapilis on 11/1/25.
//

import SwiftUI
import PencilKit

struct DrawingCanvasView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var canvasView = PKCanvasView()
    @State private var toolPicker = PKToolPicker()
    @State private var isDrawing = true
    @State private var brushStyle: PKInkingTool.InkType = .pen
    @State private var currentRotation: Angle = .zero
    @State private var currentZoom: CGFloat = 1.0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                CanvasView(canvasView: $canvasView, toolPicker: $toolPicker)
                    .rotationEffect(currentRotation)
                    .scaleEffect(currentZoom)
                    .gesture(magnificationGesture())
                    .simultaneousGesture(rotationGesture())
                    .simultaneousGesture(twoFingerSwipeGesture())
                    .navigationBarTitle("Drawing Notes", displayMode: .inline)
                    .navigationBarItems(
                        leading: HStack(spacing: 15) {
                            Button(action: { dismiss() }) {
                                Label("Done", systemImage: "xmark.circle.fill")
                            }
                            
                            Button(action: clearCanvas) {
                                Label("Clear", systemImage: "trash")
                            }
                            .keyboardShortcut("k", modifiers: .command)
                            
                            Menu {
                                Button(action: { setBrushStyle(.pen) }) {
                                    Label("Pen", systemImage: "pencil.tip")
                                }
                                .keyboardShortcut("1", modifiers: .command)
                                
                                Button(action: { setBrushStyle(.marker) }) {
                                    Label("Marker", systemImage: "highlighter")
                                }
                                .keyboardShortcut("2", modifiers: .command)
                                
                                Button(action: { setBrushStyle(.pencil) }) {
                                    Label("Pencil", systemImage: "pencil")
                                }
                                .keyboardShortcut("3", modifiers: .command)
                            } label: {
                                Label("Brush", systemImage: brushIconName())
                            }
                            
                            Button(action: toggleDrawingMode) {
                                Label(isDrawing ? "Pen" : "Eraser",
                                      systemImage: isDrawing ? "pencil.tip" : "eraser.fill")
                            }
                            .keyboardShortcut("p", modifiers: .command)
                        },
                        trailing: HStack(spacing: 15) {
                            Button(action: resetView) {
                                Label("Reset", systemImage: "arrow.counterclockwise")
                            }
                            .keyboardShortcut("r", modifiers: .command)
                            
                            Button(action: undo) {
                                Label("Undo", systemImage: "arrow.uturn.backward")
                            }
                            .keyboardShortcut("z", modifiers: .command)
                            
                            Button(action: redo) {
                                Label("Redo", systemImage: "arrow.uturn.forward")
                            }
                            .keyboardShortcut("z", modifiers: [.command, .shift])
                            
                            Button(action: saveDrawing) {
                                Label("Save", systemImage: "square.and.arrow.down")
                            }
                            .keyboardShortcut("s", modifiers: .command)
                        }
                    )
                    .onAppear(perform: setupToolPicker)
            }
            .ignoresSafeArea(.container, edges: .bottom)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // MARK: - Setup
    private func setupToolPicker() {
        if let window = UIApplication.shared.connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.keyWindow })
            .first {
            toolPicker.setVisible(true, forFirstResponder: canvasView)
            toolPicker.addObserver(canvasView)
            canvasView.becomeFirstResponder()
        }
        loadDrawing()
    }
    
    // MARK: - Drawing Actions
    private func clearCanvas() {
        canvasView.drawing = PKDrawing()
    }
    
    private func undo() {
        canvasView.undoManager?.undo()
    }
    
    private func redo() {
        canvasView.undoManager?.redo()
    }
    
    private func toggleDrawingMode() {
        isDrawing.toggle()
        updateTool()
    }
    
    private func setBrushStyle(_ style: PKInkingTool.InkType) {
        brushStyle = style
        isDrawing = true
        updateTool()
    }
    
    private func updateTool() {
        if isDrawing {
            let ink = PKInkingTool(brushStyle, color: .black, width: 5)
            canvasView.tool = ink
        } else {
            canvasView.tool = PKEraserTool(.vector)
        }
    }
    
    private func resetView() {
        withAnimation {
            currentRotation = .zero
            currentZoom = 1.0
        }
    }
    
    private func brushIconName() -> String {
        switch brushStyle {
        case .pen: return "pencil.tip"
        case .marker: return "highlighter"
        case .pencil: return "pencil"
        default: return "paintbrush.fill"
        }
    }
    
    // MARK: - Save & Load
    private func saveDrawing() {
        let data = canvasView.drawing.dataRepresentation()
        UserDefaults.standard.set(data, forKey: "SavedDrawing")
        print("✅ Drawing saved!")
    }
    
    private func loadDrawing() {
        if let data = UserDefaults.standard.data(forKey: "SavedDrawing"),
           let drawing = try? PKDrawing(data: data) {
            canvasView.drawing = drawing
            print("✅ Drawing loaded!")
        }
    }
    
    // MARK: - Gestures
    private func magnificationGesture() -> some Gesture {
        MagnificationGesture()
            .onChanged { scale in
                currentZoom = scale
            }
            .onEnded { scale in
                currentZoom = scale
            }
    }
    
    private func rotationGesture() -> some Gesture {
        RotationGesture()
            .onChanged { angle in
                currentRotation = angle
            }
            .onEnded { angle in
                currentRotation = angle
            }
    }
    
    private func twoFingerSwipeGesture() -> some Gesture {
        DragGesture(minimumDistance: 50)
            .onEnded { value in
                let horizontalSwipe = abs(value.translation.width) > abs(value.translation.height)
                
                if horizontalSwipe {
                    if value.translation.width > 0 {
                        withAnimation {
                            isDrawing = true
                            updateTool()
                        }
                    } else {
                        withAnimation {
                            isDrawing = false
                            updateTool()
                        }
                    }
                }
            }
    }
}

// MARK: - Canvas View
struct CanvasView: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    @Binding var toolPicker: PKToolPicker
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.drawingPolicy = .anyInput
        canvasView.delegate = context.coordinator
        canvasView.alwaysBounceVertical = true
        canvasView.backgroundColor = .systemBackground
        
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        canvasView.becomeFirstResponder()
        
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: CanvasView
        
        init(_ parent: CanvasView) {
            self.parent = parent
        }
        
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            print("Drawing updated – strokes count: \(canvasView.drawing.strokes.count)")
        }
    }
}

// MARK: - Preview
#Preview {
    DrawingCanvasView()
}
