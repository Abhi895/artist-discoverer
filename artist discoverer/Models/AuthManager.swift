//
//  AuthManager.swift
//  artist discoverer
//
//  Created by Abhi Reddy on 14/12/2025.
//

import SwiftUI
import Firebase
import GoogleSignIn
import FirebaseAuth

struct AuthManager {
    @MainActor
    func googleOauth() async throws {
        // google sign in
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            fatalError("no firebase clientID found")
        }

        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        //get rootView
        let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        guard let rootViewController = scene?.windows.first?.rootViewController
        else {
            fatalError("There is no root view controller!")
        }
        
        //google sign in authentication response
        let result = try await GIDSignIn.sharedInstance.signIn(
            withPresenting: rootViewController
        )
        let user = result.user
        guard let idToken = user.idToken?.tokenString else {
            throw AuthenticationError.runtimeError("Unexpected error occurred, please retry")
        }
        
        //Firebase auth
        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken, accessToken: user.accessToken.tokenString
        )
        try await Auth.auth().signIn(with: credential)
    }
    
    func logout() async throws {
        GIDSignIn.sharedInstance.signOut()
        try Auth.auth().signOut()
    }
    
    
    func tryLoginWith(email: String, password: String) async throws{
        _ = try await Auth.auth().signIn(withEmail: email, password: password)
    }
    
    func trySignUpWith(email: String, password: String) async throws {
        _ = try await Auth.auth().createUser(withEmail: email, password: password)

    }
    
    
    func friendlyAuthMessage(for error: Error, _ email: String, _ password: String, _ confirmingPassword: String, _ isLoginMode: Bool) -> String {
        if email == "" || password == "" {
            return "Email and password fields cannot be left blank."
        }
        
        if !(email.contains("@") && (email.contains(".com") || email.contains(".co.uk"))) {
            return "Please enter a valid email."
        }
        
        if !isLoginMode && confirmingPassword == "" {
            return "Please confirm your password."
        }
        
        if !isLoginMode && password != confirmingPassword {
            return "Passwords do not match."
        }
        
        let errorCode = AuthErrorCode(rawValue: (error as NSError).code)
        switch errorCode {
        case .emailAlreadyInUse:
            return "Seems like you already have an account. Try signing in instead."
        case .invalidEmail:
            return "An account with this email does not exist."
        case .wrongPassword:
            return "The password is incorrect. Please try again."
        case .userNotFound:
            return "Seems like you don't have an account. Try signing up instead."
        case .weakPassword:
            return "Your password is too weak. Please choose a stronger one."
        case .networkError:
            return "A network error occurred. Please check your connection and try again."
        default:
            return error.localizedDescription
        }
    }
}

enum AuthenticationError: Error {
    case runtimeError(String)
}
