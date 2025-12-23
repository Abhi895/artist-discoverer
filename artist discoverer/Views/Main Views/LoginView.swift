////
////  LoginView.swift
////  artist discoverer
////
////  Created by Abhi Reddy on 28/11/2025.
////
//
//import SwiftUI
//import FirebaseCore
//import FirebaseAuth
//import Firebase
//import GoogleSignIn
//
//struct LoginView: View {
//    
//    @State private var email: String = ""
//    @State private var password: String = ""
//    @State private var confirmingPassword: String = ""
//    @State private var showPassword: Bool = false
//    @State private var showConfirmPassword: Bool = false
//    @State var isLoginMode: Bool = true
//    @Binding var userValid: Bool
//    @State var userInvalid: Bool = false
//    @State var error: String = ""
//    
//    // Split password into two states
//    enum Field: Hashable { case email, passwordSecure, passwordVisible, confirmPassword }
//    @FocusState private var focusedField: Field?
//    
//    var cobaltBlue = Color(red: 0.047, green: 0.169, blue: 0.306)
//    
//    var body: some View {
//        NavigationStack {
//            ZStack {
//
//
//                //Gradient background
//                LinearGradient(colors: [cobaltBlue , Color.black], startPoint: .topLeading, endPoint: .bottomTrailing)
//                    .ignoresSafeArea(.all)
//                
//                GeometryReader { _ in
//                    //App logo/name
//                    VStack {
//                        Spacer()
//                            .frame(minHeight: 60)
//                        
//                        VStack(spacing: 3) {
//                            
//                            HStack(spacing: 5) {
//                                ZStack {
//                                    //Background glow for the icon
//                                    Circle()
//                                        .fill(
//                                            RadialGradient(
//                                                colors: [cobaltBlue.opacity(0.4), Color.clear],
//                                                center: .center,
//                                                startRadius: 10,
//                                                endRadius: 50
//                                            )
//                                        )
//                                        .frame(width: 50, height: 50)
//                                    
//                                    Image(systemName: "waveform")
//                                        .font(.system(size: 50, weight: .light))
//                                        .foregroundStyle(
//                                            LinearGradient(
//                                                colors: [.white, Color.blue.opacity(0.8)],
//                                                startPoint: .top,
//                                                endPoint: .bottom
//                                            )
//                                        )
//                                }
//                                
//                                Text("Nova")
//                                    .fontWeight(.bold)
//                                    .foregroundStyle(.white)
//                                    .font(.system(size: 45, design: .rounded))
//                            }
//                            
//                            Text("Welcome!")
//                                .foregroundStyle(.gray)
//                                .font(.system(size: 18, design: .rounded))
//                        }
//                        
//                        
//                        //Email and Password TextFields
//                        VStack(spacing: 19) {
//                            //Email TextField
//                            VStack(alignment: .leading, spacing: 5) {
//                                
//                                HStack {
//                                    Image(systemName: "envelope")
//                                        .foregroundColor(.white.opacity(0.7))
//                                        .font(.system(size: 20))
//                                    
//                                    TextField("", text: $email, prompt: Text("Email").foregroundColor(.white.opacity(0.5)))
//                                        .textContentType(.emailAddress)
//                                        .font(.system(size: 18))
//                                        .foregroundStyle(.white)
//                                        .keyboardType(.emailAddress)
//                                        .textInputAutocapitalization(.never)
//                                        .disableAutocorrection(true)
//                                        .focused($focusedField, equals: .email)
//                                    
//                                }
//                                .padding(12)
//                                .glassEffect(.regular, in: .rect(cornerRadius: 10))
//                                .overlay(
//                                    RoundedRectangle(cornerRadius: 10)
//                                        .stroke(.white.opacity(focusedField == .email ? 1.0 : 0.2), lineWidth: focusedField == .email ? 2 : 1)
//                                    
//                                )
//                            }
//                            
//                            //Password TextField
//                            
//                            // Password TextField
//                            ZStack {
//                                // Determine if either password field is focused
//                                let isPasswordFocused = focusedField == .passwordSecure || focusedField == .passwordVisible
//                                
//                                RoundedRectangle(cornerRadius: 10)
//                                    .stroke(.white.opacity(isPasswordFocused ? 1.0 : 0.2), lineWidth: isPasswordFocused ? 2 : 1)
//                                
//                                HStack(alignment: .center) {
//                                    Image(systemName: "lock")
//                                        .foregroundColor(.white.opacity(0.7))
//                                        .font(.system(size: 20))
//                                    
//                                    // ZStack containing BOTH fields overlapping
//                                    ZStack {
//                                        // 1. The Visible Version
//                                        TextField("", text: $password, prompt: Text("Password").foregroundColor(.white.opacity(0.5)))
//                                            .font(.system(size: 18))
//                                            .foregroundStyle(.white)
//                                            .autocorrectionDisabled()
//                                            .textInputAutocapitalization(.never)
//                                            .focused($focusedField, equals: .passwordVisible)
//                                            .opacity(showPassword ? 1 : 0) // Hide with opacity
//                                        
//                                        // 2. The Secure Version
//                                        SecureField("", text: $password, prompt: Text("Password").foregroundColor(.white.opacity(0.5)))
//                                            .font(.system(size: 18))
//                                            .foregroundStyle(.white)
//                                            .autocorrectionDisabled()
//                                            .textInputAutocapitalization(.never)
//                                            .focused($focusedField, equals: .passwordSecure)
//                                            .opacity(showPassword ? 0 : 1) // Hide with opacity
//                                    }
//                                    
//                                    Button {
//                                        showPassword.toggle()
//                                        
//                                        // INSTANTLY switch focus to the other field
//                                        // No DispatchQueue needed because the view already exists
//                                        if showPassword {
//                                            focusedField = .passwordVisible
//                                        } else {
//                                            focusedField = .passwordSecure
//                                        }
//                                        
//                                    } label: {
//                                        Image(systemName: showPassword ? "eye" : "eye.slash")
//                                            .foregroundColor(.white.opacity(0.6))
//                                            .font(.system(size: 17))
//                                    }
//                                }
//                                .padding(12)
//                                .glassEffect(.regular, in: .rect(cornerRadius: 10))
//                            }
//                            
//                            if !isLoginMode {
//                                HStack(alignment: .center) {
//                                    Image(systemName: "lock")
//                                        .foregroundColor(.white.opacity(0.7))
//                                        .font(.system(size: 20))
//                                    
//                                    if showConfirmPassword {
//                                        TextField("", text: $confirmingPassword, prompt: Text("Confirm Password").foregroundColor(.white.opacity(0.5)))
//                                            .textContentType(.password)
//                                            .font(.system(size: 18))
//                                            .foregroundStyle(.white)
//                                            .autocorrectionDisabled()
//                                            .textInputAutocapitalization(.never)
//                                            .focused($focusedField, equals: .confirmPassword)
//                                    } else {
//                                        SecureField("", text: $confirmingPassword, prompt: Text("Confirm Password").foregroundColor(.white.opacity(0.5)))
//                                            .textContentType(.password)
//                                            .font(.system(size: 18))
//                                            .foregroundStyle(.white)
//                                            .autocorrectionDisabled()
//                                            .textInputAutocapitalization(.never)
//                                            .focused($focusedField, equals: .confirmPassword)
//                                    }
//                                    
//                                    Button {
//                                        showConfirmPassword.toggle()
//                                        focusedField = .confirmPassword
//                                    } label: {
//                                        Image(systemName: showConfirmPassword ? "eye" : "eye.slash")
//                                            .foregroundColor(.white.opacity(0.6))
//                                            .font(.system(size: 17))
//                                    }
//                                }
//                                .padding(12)
//                                .glassEffect(.regular, in: .rect(cornerRadius: 10))
//                                .overlay(
//                                    RoundedRectangle(cornerRadius: 10)
//                                        .stroke(.white.opacity(focusedField == .confirmPassword ? 1.0 : 0.2), lineWidth: focusedField == .confirmPassword ? 2 : 1)
//                                        .animation(.easeInOut(duration: 0.2), value: focusedField == .confirmPassword)
//                                )
//                                
//                            }
//                            
//                        }
//                        .padding(.top, isLoginMode ? 40 : 30)
//                        
//                        if isLoginMode {
//                            //Forgot Password button
//                            
//                            HStack {
//                                Spacer()
//                                
//                                Button {
//                                    
//                                } label: {
//                                    Text("Forgot Password")
//                                        .font(.system(size: 11, weight: .medium))
//                                        .foregroundStyle(Color.white.opacity(0.7))
//                                }
//                            }
//                            .padding(.top, 6)
//                        }
//                        
//                        
//                        //Continue Button
//                        Button(action: {
//                            Task {
//                                do {
//                                    if isLoginMode {
//                                        try await AuthManager().tryLoginWith(email: email, password: password)
//                                    } else {
//                                        try await AuthManager().trySignUpWith(email: email, password: password)
//                                    }
//                                    
//                                    userValid = true
//                                } catch {
//                                    userInvalid = true
//                                    self.error = AuthManager().friendlyAuthMessage(for: error, email, password, confirmingPassword, isLoginMode)
//
//                                }
//                            }
//                        }) {
//                            Text("Continue")
//                                .font(.system(size: 20))
//                                .fontWeight(.bold)
//                                .frame(maxWidth: .infinity)
//                                .foregroundStyle(cobaltBlue)
//                                .padding(12)
//                                .background(.white)
//                                .cornerRadius(15)
//                                .padding(.top, 30)
//                                .shadow(color: .white.opacity(0.1), radius: 8, x: 0, y: 2)
//                            
//                        }
//                        
//                        Spacer()
//                            .frame(minHeight: 30)
//                        
//                        
//                        //Or separator
//                        HStack {
//                            Rectangle()
//                                .fill(Color.white.opacity(0.7))
//                                .frame(height: 1)
//                            
//                            Text("or")
//                                .font(.system(size: 17, weight: .semibold, design: .rounded))
//                                .foregroundStyle(Color.white.opacity(0.7))
//                                .padding(.horizontal, 16)
//                            
//                            Rectangle()
//                                .fill(Color.white.opacity(0.7))
//                                .frame(height: 1)
//                        }
//                        
//                        
//                        
//                        //Alternative sign-in options
//                        
//                        VStack(spacing: 27) {
//                            //Continue with apple button
//                            Button {
//                                print("signign in with apple")
//                            } label: {
//                                HStack() {
//                                    Image(systemName: "apple.logo")
//                                        .font(.system(size: 20))
//                                        .padding(.bottom, 2)
//                                    Text("Continue with Apple")
//                                        .font(.system(size: 18, weight: .semibold))
//                                }
//                                .foregroundStyle(.white.opacity(0.7))
//                                .frame(maxWidth: .infinity)
//                                .padding(15)
//                                
//                            }
//                            .glassEffect(.clear)
//                            .shadow(color: .white.opacity(0.1), radius: 8, x: 0, y: 2)
//                            
//                            
//                            //Sign in with google button
//                            
//                            Button {
//                                Task {
//                                    do {
//                                        try await AuthManager().googleOauth()
//                                        userValid = true
//                                    } catch {
//                                        print(error)
//                                    }
//                                }
//                            } label: {
//                                HStack() {
//                                    Image("google_icon")
//                                        .resizable()
//                                        .frame(width: 20, height: 20)
//                                    Text(isLoginMode ? "Sign in with Google":"Sign up with Google")
//                                        .font(.system(size: 18, weight: .semibold))
//                                        .animation(nil, value: isLoginMode)
//                                }
//                                .foregroundStyle(.white.opacity(0.7))
//                                .frame(maxWidth: .infinity)
//                                .padding(15)
//                                
//                            }
//                            .glassEffect(.clear)
//                            .shadow(color: .white.opacity(0.1), radius: 8, x: 0, y: 2)
//                        }.padding(.top, 20)
//                        
//                        
//                        HStack(alignment: .center) {
//                            Text(isLoginMode ? "Don't have an account?" : "Have an account?")
//                                .font(.system(size: 16))
//                                .foregroundStyle(.white.opacity(0.7))
//                                .animation(nil, value: isLoginMode)
//                            
//                            Button {
//                                isLoginMode.toggle()
//                                email = ""
//                                password = ""
//                            } label: {
//                                Text(isLoginMode ? "Sign Up" : "Sign In")
//                                    .foregroundStyle(.white)
//                                    .font(.system(size: 15))
//                                    .fontWeight(.semibold)
//                                    .animation(nil, value: isLoginMode)
//                            }
//                            
//                            .alert("\(error)", isPresented: $userInvalid) {
//                                Button("Ok", role: .cancel) {}
//                            }
//                            
//                            
//                        }
//                        .padding(.top, 25)
//                        .padding(.bottom, 30)
//                        
//                    }
//                    .padding(.bottom, 20)
//                    .padding(.horizontal, 40)
//                    
//                }.ignoresSafeArea(.keyboard)
//
//            }
//            .onTapGesture(count: 4) {
//                userValid = true
//            }
//            .onTapGesture {
//                // Dismiss keyboard when user taps anywhere on the screen
//                focusedField = nil
//                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
//            }
//            .navigationBarBackButtonHidden(true)
//            .toolbarBackgroundVisibility(.hidden, for: .tabBar)
//            .navigationDestination(isPresented: $userValid, destination: {
//                HomeView()
//            })
//        }
//    }
//}
//
//
////#Preview {
////    LoginView()
////}
////
