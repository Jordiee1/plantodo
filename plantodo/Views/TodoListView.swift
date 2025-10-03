//
//  TodoListView.swift
//  plantodo
//
//  Created by จิดาภา สีเพชร on 4/10/2568 BE.
//

import SwiftUI

struct TodoListView: View {
    @ObservedObject var viewModel: TodoViewModel
    @State private var showAddTodo = false
    @State private var selectedTodo: TodoItem?
    @State private var searchText = ""
    @State private var selectedFilter: TodoFilter = .all
    
    enum TodoFilter: String, CaseIterable {
        case all = "ทั้งหมด"
        case active = "ยังไม่เสร็จ"
        case completed = "เสร็จแล้ว"
    }
    
    // MARK: - Filtered Todos
    var filteredTodos: [TodoItem] {
        var todos = viewModel.todos
        
        if !searchText.isEmpty {
            todos = filterBySearch(todos: todos)
        }
        
        return filterByStatus(todos: todos)
    }
    
    private func filterBySearch(todos: [TodoItem]) -> [TodoItem] {
        todos.filter { $0.text.localizedCaseInsensitiveContains(searchText) }
    }
    
    private func filterByStatus(todos: [TodoItem]) -> [TodoItem] {
        switch selectedFilter {
        case .all:
            return todos
        case .active:
            return todos.filter { !$0.isCompleted }
        case .completed:
            return todos.filter { $0.isCompleted }
        }
    }
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            mainContent
                .navigationTitle("งานทั้งหมด")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        addButton
                    }
                }
                .sheet(isPresented: $showAddTodo) {
                    AddTodoSheet(viewModel: viewModel, editingTodo: selectedTodo)
                        .onDisappear { selectedTodo = nil }
                }
        }
    }
    
    // MARK: - Main Content
    private var mainContent: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                searchAndFilterSection
                todoListSection
            }
        }
    }
    
    // MARK: - Search and Filter Section
    private var searchAndFilterSection: some View {
        VStack(spacing: 12) {
            searchBar
            filterButtons
        }
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("ค้นหางาน...", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }
    
    private var filterButtons: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(TodoFilter.allCases, id: \.self) { filter in
                    FilterButton(
                        title: filter.rawValue,
                        isSelected: selectedFilter == filter
                    ) {
                        withAnimation {
                            selectedFilter = filter
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 16)
    }
    
    // MARK: - Todo List Section
    @ViewBuilder
    private var todoListSection: some View {
        if filteredTodos.isEmpty {
            emptyStateView
        } else {
            todoScrollView
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: searchText.isEmpty ? "tray" : "magnifyingglass")
                .font(.system(size: 70))
                .foregroundColor(Color(red: 1.0, green: 0.42, blue: 0.62).opacity(0.3))
            
            Text(searchText.isEmpty ? "ยังไม่มีงาน" : "ไม่พบงานที่ค้นหา")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.gray)
            
            Text(searchText.isEmpty ? "เริ่มต้นเพิ่มงานของคุณได้เลย" : "ลองค้นหาด้วยคำอื่น")
                .font(.system(size: 14))
                .foregroundColor(.gray.opacity(0.7))
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    private var todoScrollView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(filteredTodos) { todo in
                    TodoCard(
                        todo: todo,
                        onToggle: {
                            viewModel.toggleTodo(todo)
                        },
                        onDelete: {
                            viewModel.deleteTodo(todo)
                        }
                    )
                    .onTapGesture {
                        selectedTodo = todo
                        showAddTodo = true
                    }
                }
            }
            .padding(20)
        }
    }
    
    private var addButton: some View {
        Button(action: {
            selectedTodo = nil
            showAddTodo = true
        }) {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 24))
                .foregroundColor(Color(red: 1.0, green: 0.42, blue: 0.62))
        }
    }
}

// MARK: - Filter Button
struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : .gray)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    isSelected ?
                    Color(red: 1.0, green: 0.42, blue: 0.62) :
                    Color.gray.opacity(0.1)
                )
                .cornerRadius(20)
        }
    }
}
