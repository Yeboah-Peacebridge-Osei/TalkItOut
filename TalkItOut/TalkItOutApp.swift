//
//  TalkItOutApp.swift
//  TalkItOut
//
//  Created by Yeboah Peacebridge Osei on 6/1/25.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    private var handle: AuthStateDidChangeListenerHandle?
    
    init() {
        handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.isAuthenticated = (user != nil)
        }
    }
    deinit {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}

@main
struct TalkItOutApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
  @StateObject private var authViewModel = AuthViewModel()
  @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false

  var body: some Scene {
    WindowGroup {
      if !hasCompletedOnboarding {
        OnboardingView()
      } else if authViewModel.isAuthenticated {
        MainTabView()
      } else {
        AuthView()
      }
    }
  }
}


