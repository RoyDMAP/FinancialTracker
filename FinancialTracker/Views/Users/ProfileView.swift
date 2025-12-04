//
//  ProfileView.swift
//  FinancialTracker
//
//  Created by Roy Dimapilis on 12/3/25.
//

import SwiftUI

struct ProfileView: View {
    @State private var name: String = ""
    @State private var occupation: String = ""
    @State private var email: String = ""
    @State private var hobbies: [String] = []
    @State private var newHobby: String = ""
    @State private var showingSummary: Bool = false
    
    var body: some View {
        let theme = AppTheme.current
        
        NavigationStack {
            ZStack {
                ThemedBackground(theme: theme)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Profile Details Section
                        profileDetailsSection(theme: theme)
                        
                        // Hobbies Section
                        hobbiesSection(theme: theme)
                        
                        // View Summary Button
                        Button(action: {
                            showingSummary = true
                        }) {
                            HStack {
                                Image(systemName: "person.text.rectangle")
                                Text("View Profile Summary")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(theme.primaryColor)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("My Profile")
            .sheet(isPresented: $showingSummary) {
                ProfileSummaryView(
                    name: name,
                    occupation: occupation,
                    email: email,
                    hobbies: hobbies
                )
            }
        }
    }
    
    // MARK: - Profile Details Section
    
    private func profileDetailsSection(theme: AppTheme) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Profile Details")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            VStack(spacing: 15) {
                // Name Field
                VStack(alignment: .leading, spacing: 5) {
                    Text("Name")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Enter your name", text: $name)
                        .textFieldStyle(.plain)
                        .padding()
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(8)
                }
                
                // Occupation Field
                VStack(alignment: .leading, spacing: 5) {
                    Text("Occupation")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Enter your occupation", text: $occupation)
                        .textFieldStyle(.plain)
                        .padding()
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(8)
                }
                
                // Email Field
                VStack(alignment: .leading, spacing: 5) {
                    Text("Email")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Enter your email", text: $email)
                        .textFieldStyle(.plain)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            .padding()
            .background(theme.cardBackground)
            .cornerRadius(15)
            .padding(.horizontal)
        }
    }
    
    // MARK: - Hobbies Section
    
    private func hobbiesSection(theme: AppTheme) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Hobbies")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            VStack(spacing: 15) {
                // Add Hobby Field
                HStack {
                    TextField("Add a hobby", text: $newHobby)
                        .textFieldStyle(.plain)
                        .padding()
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(8)
                    
                    Button(action: addHobby) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(theme.primaryColor)
                    }
                    .disabled(newHobby.isEmpty)
                }
                
                // Hobbies List
                if hobbies.isEmpty {
                    Text("No hobbies added yet")
                        .foregroundColor(.secondary)
                        .italic()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                } else {
                    VStack(spacing: 10) {
                        ForEach(hobbies, id: \.self) { hobby in
                            HStack {
                                Image(systemName: "circle.fill")
                                    .font(.system(size: 6))
                                    .foregroundColor(theme.primaryColor)
                                
                                Text(hobby)
                                    .font(.body)
                                
                                Spacer()
                                
                                Button(action: {
                                    deleteHobby(hobby)
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                            .padding()
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                }
            }
            .padding()
            .background(theme.cardBackground)
            .cornerRadius(15)
            .padding(.horizontal)
        }
    }
    
    // MARK: - Actions
    
    private func addHobby() {
        guard !newHobby.isEmpty else { return }
        hobbies.append(newHobby)
        newHobby = ""
    }
    
    private func deleteHobby(_ hobby: String) {
        hobbies.removeAll { $0 == hobby }
    }
}

// MARK: - Profile Summary View

struct ProfileSummaryView: View {
    @Environment(\.dismiss) var dismiss
    let name: String
    let occupation: String
    let email: String
    let hobbies: [String]
    
    var body: some View {
        let theme = AppTheme.current
        
        NavigationStack {
            ZStack {
                ThemedBackground(theme: theme)
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Profile Icon
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(theme.primaryColor)
                            .padding(.top, 20)
                        
                        // Profile Details
                        VStack(spacing: 20) {
                            summaryRow(icon: "person.fill", label: "Name", value: name.isEmpty ? "Not provided" : name, theme: theme)
                            summaryRow(icon: "briefcase.fill", label: "Occupation", value: occupation.isEmpty ? "Not provided" : occupation, theme: theme)
                            summaryRow(icon: "envelope.fill", label: "Email", value: email.isEmpty ? "Not provided" : email, theme: theme)
                        }
                        
                        // Hobbies Section
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundColor(theme.primaryColor)
                                Text("Hobbies")
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }
                            
                            if hobbies.isEmpty {
                                Text("No hobbies added")
                                    .foregroundColor(.secondary)
                                    .italic()
                            } else {
                                VStack(alignment: .leading, spacing: 10) {
                                    ForEach(hobbies, id: \.self) { hobby in
                                        HStack {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(theme.primaryColor)
                                            Text(hobby)
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(theme.cardBackground)
                        .cornerRadius(15)
                        .padding(.horizontal)
                        
                        // Go Back Button
                        Button(action: {
                            dismiss()
                        }) {
                            HStack {
                                Image(systemName: "arrow.left.circle.fill")
                                Text("Go Back")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(theme.secondaryColor)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Profile Summary")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func summaryRow(icon: String, label: String, value: String, theme: AppTheme) -> some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(theme.primaryColor)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 3) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.body)
                    .fontWeight(.medium)
            }
            
            Spacer()
        }
        .padding()
        .background(theme.cardBackground)
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

#Preview {
    ProfileView()
}
