//
//  UserSelectionView.swift
//  FinancialTracker
//
//  Created by Roy Dimapilis on 11/8/25.
//

import SwiftUI

struct UserSelectionView: View {
    @State private var users: [User] = []
    @State private var showingAddUser = false
    @State private var selectedUser: User?
    @State private var showingMainApp = false
    @State private var showingDeleteAlert = false
    @State private var userToDelete: User?
    
    var body: some View {
        let theme = AppTheme.current
        
        return NavigationStack {
            ZStack {
                ThemedBackground(theme: theme)
                
                if users.isEmpty {
                    emptyStateView(theme: theme)
                } else {
                    userListView(theme: theme)
                }
            }
            .navigationTitle(NSLocalizedString("financial tracker", comment: "Financial Tracker"))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    LocalizedImageView(imageName: "background-flag")
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddUser = true }) {
                        Image(systemName: "person.badge.plus")
                            .font(.title2)
                            .foregroundColor(theme.primaryColor)
                    }
                }
            }
            .sheet(isPresented: $showingAddUser) {
                AddUserView(users: $users, onSave: saveUsers)
            }
            .fullScreenCover(item: $selectedUser) { user in
                ContentView(
                    currentUser: user,
                    onLogout: {
                        selectedUser = nil
                    }
                )
            }
            .alert("Delete User", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    if let user = userToDelete {
                        deleteUser(user)
                    }
                }
            } message: {
                if let user = userToDelete {
                    Text("Are you sure you want to delete \(user.name)? All their transactions will be permanently deleted.")
                }
            }
            .onAppear {
                loadUsers()
            }
        }
    }
    
    private func emptyStateView(theme: AppTheme) -> some View {
        VStack(spacing: 30) {
            Image(systemName: "person.2.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(theme.primaryColor.opacity(0.5))
            
            Text(NSLocalizedString("no_users_yet", comment: "No Users Yet"))
                .font(.title)
                .fontWeight(.bold)
            
            Text(NSLocalizedString("create_profile_prompt", comment: "Create a profile to get started"))
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Button(action: { showingAddUser = true }) {
                Label(NSLocalizedString("add_user", comment: "Add User"), systemImage: "person.badge.plus")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(theme.primaryColor)
                    .cornerRadius(15)
            }
            .padding(.horizontal, 50)
        }
    }
    
    private func userListView(theme: AppTheme) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                Text(NSLocalizedString("select_user", comment: "Select User"))
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(theme.primaryColor)
                    .padding(.top, 30)
                
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 20) {
                    ForEach(users) { user in
                        UserCard(user: user, theme: theme) {
                            selectedUser = user
                        } onDelete: {
                            userToDelete = user
                            showingDeleteAlert = true
                        }
                    }
                }
                .padding()
            }
        }
    }
    
    func deleteUser(_ user: User) {
        // Remove user from list
        users.removeAll { $0.id == user.id }
        
        // Delete user's transactions from UserDefaults
        let transactionKey = "SavedTransactions_\(user.id.uuidString)"
        UserDefaults.standard.removeObject(forKey: transactionKey)
        
        // Save updated user list
        saveUsers()
        
        print("✅ Deleted user: \(user.name) and their transactions")
    }
    
    func saveUsers() {
        if let encoded = try? JSONEncoder().encode(users) {
            UserDefaults.standard.set(encoded, forKey: "SavedUsers")
            print("✅ Saved \(users.count) users")
        }
    }
    
    func loadUsers() {
        if let savedData = UserDefaults.standard.data(forKey: "SavedUsers"),
           let decoded = try? JSONDecoder().decode([User].self, from: savedData) {
            users = decoded
            print("✅ Loaded \(users.count) users")
        }
    }
}

// MARK: - User Card
struct UserCard: View {
    let user: User
    let theme: AppTheme
    let action: () -> Void
    let onDelete: () -> Void
    
    @State private var showingOptions = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 15) {
                ZStack(alignment: .topTrailing) {
                    ProfileImageView(user: user, size: 80)
                    
                    // Options button (three dots)
                    Button(action: {
                        showingOptions = true
                    }) {
                        Image(systemName: "ellipsis.circle.fill")
                            .font(.title3)
                            .foregroundColor(theme.primaryColor)
                            .background(
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 24, height: 24)
                            )
                    }
                    .offset(x: 10, y: -10)
                    .buttonStyle(PlainButtonStyle())
                }
                
                Text(user.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 150)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(theme.cardBackground)
                    .shadow(color: theme.primaryColor.opacity(0.2), radius: 8, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(theme.primaryColor.opacity(0.3), lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityIdentifier("userCard_\(user.name)")
        .confirmationDialog("User Options", isPresented: $showingOptions) {
            Button("\(user.emoji) \(user.name)") { }
                .disabled(true)
            
            Button("Delete User", role: .destructive) {
                onDelete()
            }
            
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Choose an option for \(user.name)")
        }
    }
}

// MARK: - Add User View
struct AddUserView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var users: [User]
    var onSave: () -> Void
    
    @State private var name: String = ""
    @State private var selectedEmoji: String = "👤"
    @State private var selectedImage: UIImage?
    @State private var showPhotoOption = true
    
    let emojis = ["👤", "👨", "👩", "👦", "👧", "🧑", "👨‍💼", "👩‍💼", "👨‍🎓", "👩‍🎓", "🧔", "👱"]
    
    var body: some View {
        let theme = AppTheme.current
        
        return NavigationStack {
            ZStack {
                ThemedBackground(theme: theme)
                
                Form {
                    Section(NSLocalizedString("user_details", comment: "User Details")) {
                        TextField(NSLocalizedString("name", comment: "Name"), text: $name)
                            .font(.headline)
                            .accessibilityIdentifier("userNameTextField")
                    }
                    .listRowBackground(theme.cardBackground)
                    
                    // Photo/Emoji Toggle
                    Section {
                        Picker("Profile Type", selection: $showPhotoOption) {
                            Text("Photo").tag(true)
                            Text("Emoji").tag(false)
                        }
                        .pickerStyle(.segmented)
                    }
                    .listRowBackground(theme.cardBackground)
                    
                    if showPhotoOption {
                        // Photo Picker Section
                        Section(NSLocalizedString("choose_photo", comment: "Choose Photo")) {
                            HStack {
                                Spacer()
                                PhotoPickerView(selectedImage: $selectedImage)
                                Spacer()
                            }
                            .padding(.vertical, 20)
                        }
                        .listRowBackground(theme.cardBackground)
                    } else {
                        // Emoji Picker Section
                        Section(NSLocalizedString("choose_icon", comment: "Choose Icon")) {
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 15) {
                                ForEach(emojis, id: \.self) { emoji in
                                    Text(emoji)
                                        .font(.system(size: 40))
                                        .frame(width: 50, height: 50)
                                        .background(
                                            Circle()
                                                .fill(selectedEmoji == emoji ? theme.primaryColor.opacity(0.2) : Color.clear)
                                        )
                                        .overlay(
                                            Circle()
                                                .stroke(selectedEmoji == emoji ? theme.primaryColor : Color.clear, lineWidth: 2)
                                        )
                                        .onTapGesture {
                                            selectedEmoji = emoji
                                        }
                                }
                            }
                            .padding(.vertical, 10)
                        }
                        .listRowBackground(theme.cardBackground)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(NSLocalizedString("add_user", comment: "Add User"))
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom) {
                CulturalButtonRow(
                    primaryTitle: NSLocalizedString("save", comment: "Save"),
                    primaryAction: {
                        saveUser()
                    },
                    secondaryTitle: NSLocalizedString("cancel", comment: "Cancel"),
                    secondaryAction: {
                        dismiss()
                    },
                    primaryRole: nil
                )
                .padding()
                .background(theme.cardBackground)
                .disabled(name.isEmpty)
            }
        }
    }
    
    func saveUser() {
        // Convert UIImage to Data
        let photoData = selectedImage?.jpegData(compressionQuality: 0.8)
        
        let newUser = User(
            name: name,
            emoji: selectedEmoji,
            photoData: photoData
        )
        users.append(newUser)
        onSave()
        dismiss()
    }
}

#Preview {
    UserSelectionView()
}
