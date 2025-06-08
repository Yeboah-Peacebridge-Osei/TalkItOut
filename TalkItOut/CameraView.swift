import SwiftUI
import AVFoundation

struct CameraView: UIViewRepresentable {
    class CameraCoordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
        var parent: CameraView
        init(parent: CameraView) { self.parent = parent }
    }

    func makeCoordinator() -> CameraCoordinator {
        CameraCoordinator(parent: self)
    }

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        let session = AVCaptureSession()
        session.sessionPreset = .high

        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: camera) else {
            return view
        }
        session.addInput(input)

        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = UIScreen.main.bounds
        view.layer.addSublayer(previewLayer)

        session.startRunning()
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
} 