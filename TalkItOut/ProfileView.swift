import SwiftUI
import AVKit

struct ProfileView: View {
    @EnvironmentObject var journalEntriesModel: JournalEntriesModel
    @State private var selectedEntry: JournalEntry? = nil
    @AppStorage("profileDisplayName") private var displayName: String = "Your Name"
    @AppStorage("profileBio") private var bio: String = "A short bio about you."
    @AppStorage("profileImageData") private var profileImageData: Data?
    @State private var showImagePicker = false
    @State private var inputImage: UIImage?
    
    var profileImage: Image {
        if let data = profileImageData, let uiImage = UIImage(data: data) {
            return Image(uiImage: uiImage)
        } else {
            return Image(systemName: "person.crop.circle.fill")
        }
    }
    
    var body: some View {
        ZStack {
            AppColors.deepCream.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Profile info section
                    VStack(spacing: 16) {
                        ZStack(alignment: .bottomTrailing) {
                            profileImage
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white.opacity(0.3), lineWidth: 4))
                                .shadow(color: Color.black.opacity(0.2), radius: 12, x: 0, y: 6)
                            Button(action: { showImagePicker = true }) {
                                Image(systemName: "camera.fill")
                                    .foregroundColor(.white)
                                    .padding(10)
                                    .background(
                                        Circle()
                                            .fill(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                    )
                                    .shadow(radius: 6)
                            }
                            .offset(x: 8, y: 8)
                        }
                        
                        VStack(spacing: 12) {
                            TextField("Display Name", text: $displayName)
                                .font(.title2)
                                .fontWeight(.semibold)
                                .multilineTextAlignment(.center)
                                .foregroundColor(AppColors.deepCharcoal)
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(AppColors.paleLavender)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(AppColors.paleLavender.opacity(0.2), lineWidth: 1)
                                        )
                                )
                                .frame(maxWidth: 250)
                            
                            TextField("Bio", text: $bio)
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .foregroundColor(AppColors.deepCharcoal)
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(AppColors.paleLavender)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(AppColors.paleLavender.opacity(0.15), lineWidth: 1)
                                        )
                                )
                                .frame(maxWidth: 280)
                        }
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 20)
                    
                    // Journal entries section
                    VStack(spacing: 16) {
                        Text("Your Journal Entries")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.deepCharcoal)
                            .padding(.bottom, 8)
                        
                        if journalEntriesModel.entries.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "book.closed.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.white.opacity(0.6))
                                Text("No entries yet")
                                    .font(.headline)
                                    .foregroundColor(.white.opacity(0.8))
                                Text("Start recording to see your entries here")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.6))
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.vertical, 40)
                        } else {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 110), spacing: 16)], spacing: 16) {
                                ForEach(journalEntriesModel.entries) { entry in
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        Color.white.opacity(0.15),
                                                        Color.white.opacity(0.08)
                                                    ]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                            )
                                            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                                        
                                        VStack(spacing: 8) {
                                            Image(systemName: "waveform.circle.fill")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: 32)
                                                .overlay(
                                                    LinearGradient(
                                                        gradient: Gradient(colors: [Color.blue, Color.purple]),
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                    .mask(
                                                        Image(systemName: "waveform.circle.fill")
                                                            .resizable()
                                                            .scaledToFit()
                                                    )
                                                )
                                                .foregroundColor(.clear)
                                            Text(entry.date, style: .date)
                                                .font(.caption)
                                                .fontWeight(.medium)
                                                .foregroundColor(.white.opacity(0.8))
                                        }
                                        .padding(12)
                                    }
                                    .frame(height: 90)
                                    .onTapGesture {
                                        selectedEntry = entry
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.bottom, 32)
            }
        }
        .sheet(item: $selectedEntry) { entry in
            JournalEntryPlaybackView(entry: entry)
                .onAppear {
                    print("[DEBUG] Presenting JournalEntryPlaybackView for entry: \(entry.id)")
                }
        }
        .sheet(isPresented: $showImagePicker, onDismiss: loadImage) {
            ImagePicker(image: $inputImage)
        }
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        profileImageData = inputImage.jpegData(compressionQuality: 0.8)
    }
}

// UIKit image picker bridge for SwiftUI
struct ImagePicker: UIViewControllerRepresentable {
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        init(parent: ImagePicker) { self.parent = parent }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
    @Environment(\.presentationMode) var presentationMode
    @Binding var image: UIImage?
    func makeCoordinator() -> Coordinator { Coordinator(parent: self) }
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = false
        return picker
    }
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView().environmentObject(JournalEntriesModel())
    }
} 