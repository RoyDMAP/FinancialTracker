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
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()
                
                if users.isEmpty {
                    emptyStateView
                } else {
                    userListView
                }
            }
            .navigationTitle(NSLocalizedString("financial_tracker", comment: "Financial Tracker"))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    LocalizedImageView(imageName: "background-flag")
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddUser = true }) {
                        Image(systemName: "person.badge.plus")
                            .font(.title2)
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
            .onAppear {
                loadUsers()
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 30) {
            Image(systemName: "person.2.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue.opacity(0.5))
            
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
                    .background(Color.blue)
                    .cornerRadius(15)
            }
            .padding(.horizontal, 50)
        }
    }
    
    private var userListView: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text(NSLocalizedString("select_user", comment: "Select User"))
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 30)
                
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 20) {
                    ForEach(users) { user in
                        UserCard(user: user) {
                            selectedUser = user
                        }
                    }
                }
                .padding()
            }
        }
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
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 15) {
                Text(user.emoji)
                    .font(.system(size: 60))
                
                Text(user.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 150)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(uiColor: .secondarySystemGroupedBackground))
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Add User View
struct AddUserView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var users: [User]
    var onSave: () -> Void
    
    @State private var name: String = ""
    @State private var selectedEmoji: String = "👤"
    
    let emojis = ["👤", "👨", "👩", "👦", "👧", "🧑", "👨‍💼", "👩‍💼", "👨‍🎓", "👩‍🎓", "🧔", "👱"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section(NSLocalizedString("user_details", comment: "User Details")) {
                    TextField(NSLocalizedString("name", comment: "Name"), text: $name)
                        .font(.headline)
                }
                
                Section(NSLocalizedString("choose_icon", comment: "Choose Icon")) {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 15) {
                        ForEach(emojis, id: \.self) { emoji in
                            Text(emoji)
                                .font(.system(size: 40))
                                .frame(width: 50, height: 50)
                                .background(
                                    Circle()
                                        .fill(selectedEmoji == emoji ? Color.blue.opacity(0.2) : Color.clear)
                                )
                                .onTapGesture {
                                    selectedEmoji = emoji
                                }
                        }
                    }
                    .padding(.vertical, 10)
                }
            }
            .navigationTitle(NSLocalizedString("add_user", comment: "Add User"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(NSLocalizedString("cancel", comment: "Cancel")) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(NSLocalizedString("save", comment: "Save")) {
                        saveUser()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    func saveUser() {
        let newUser = User(name: name, emoji: selectedEmoji)
        users.append(newUser)
        onSave()
        dismiss()
    }
}

#Preview {
    UserSelectionView()
}
