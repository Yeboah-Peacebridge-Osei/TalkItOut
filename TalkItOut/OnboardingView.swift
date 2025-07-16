import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @State private var animateGradient = false
    
    private let pages: [OnboardingPage] = [
        OnboardingPage(title: "Welcome to TalkItOut!", description: "Your private space to talk, reflect, and grow. Record your thoughts and feelings with ease.", image: "wave.3.forward.circle.fill"),
        OnboardingPage(title: "Core Features", description: "• Record your voice\n• Playback and review entries\n• Secure and private journaling", image: "mic.fill"),
        OnboardingPage(title: "How to Use", description: "Tap the record button to start. Swipe to review your entries. Your privacy is our priority.", image: "hand.tap.fill"),
        OnboardingPage(title: "Ready to Begin?", description: "Start your journey now! You can always revisit this guide from your profile.", image: "checkmark.seal.fill")
    ]
    
    var body: some View {
        ZStack {
            AnimatedCalmBackground(animate: $animateGradient)
                .ignoresSafeArea()
            VStack(spacing: 32) {
                Spacer()
                Image(systemName: pages[currentPage].image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 100)
                    .foregroundColor(.white)
                    .shadow(radius: 10)
                    .padding(.bottom, 16)
                Text(pages[currentPage].title)
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                Text(pages[currentPage].description)
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                Spacer()
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \ .self) { idx in
                        Circle()
                            .fill(idx == currentPage ? Color.white : Color.white.opacity(0.3))
                            .frame(width: 10, height: 10)
                    }
                }
                .padding(.bottom, 16)
                HStack {
                    if currentPage < pages.count - 1 {
                        Button("Skip") {
                            hasCompletedOnboarding = true
                        }
                        .foregroundColor(.white.opacity(0.7))
                        Spacer()
                        Button("Next") {
                            withAnimation { currentPage += 1 }
                        }
                        .bold()
                        .foregroundColor(.white)
                    } else {
                        Button("Get Started") {
                            hasCompletedOnboarding = true
                        }
                        .bold()
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                        .background(Color.blue.opacity(0.7))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
        }
        .onAppear {
            withAnimation(Animation.linear(duration: 8).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
        }
    }
}

struct AnimatedCalmBackground: View {
    @Binding var animate: Bool
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.2, green: 0.4, blue: 0.6),
                Color(red: 0.4, green: 0.7, blue: 0.8),
                Color(red: 0.7, green: 0.9, blue: 0.9),
                Color(red: 0.3, green: 0.6, blue: 0.7)
            ]),
            startPoint: animate ? .topLeading : .bottomTrailing,
            endPoint: animate ? .bottomTrailing : .topLeading
        )
        .animation(.linear(duration: 8).repeatForever(autoreverses: true), value: animate)
        .overlay(
            WaterRippleEffect()
                .opacity(0.18)
        )
    }
}

struct WaterRippleEffect: View {
    @State private var ripple = false
    var body: some View {
        ZStack {
            ForEach(0..<3) { i in
                Circle()
                    .stroke(Color.white.opacity(0.25), lineWidth: 2)
                    .scaleEffect(ripple ? CGFloat(1.2 + Double(i) * 0.5) : 0.8)
                    .opacity(ripple ? 0.1 : 0.3)
                    .animation(Animation.easeInOut(duration: 4).repeatForever().delay(Double(i)), value: ripple)
            }
        }
        .onAppear {
            ripple = true
        }
    }
}

struct OnboardingPage {
    let title: String
    let description: String
    let image: String
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
} 