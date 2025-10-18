//
//  TodoListView.swift
//  plantodo
//
// โค้ดฉบับสมบูรณ์ที่ปรับให้แสดงงานค้างทั้งหมดในรูปแบบ Block Grid
// และใช้โทนสีใหม่ (AccentColor, PrimaryBackground)
//

import SwiftUI

struct TodoListView: View {
    @ObservedObject var viewModel: TodoViewModel
    @State private var showAddSheet = false
    @State private var editingTodo: TodoItem?
    
    @State private var searchText = ""
    @State private var selectedFilter: TodoFilter = .active
    @State private var showCalendarSheet = false
    
    private let gridLayout = [GridItem(.flexible()), GridItem(.flexible())]
    
    // ✅ กำหนดชื่อฟอนต์ที่ใช้ (ต้องตรงกับชื่อ PostScript Name ใน Info.plist)
    private let regularFontName = "IBMPlexSansThai-Regular"
    private let boldFontName = "IBMPlexSansThai-Bold"
    
    enum TodoFilter: String, CaseIterable {
        case all = "ทั้งหมด"
        case active = "ยังไม่เสร็จ"
        case completed = "เสร็จแล้ว"
    }

    var displayTodos: [TodoItem] {
        var sourceList: [TodoItem]
        
        switch selectedFilter {
        case .active:
            sourceList = viewModel.todos.filter { !$0.isCompleted }
        case .completed:
            sourceList = viewModel.todos.filter { $0.isCompleted }
        case .all:
            sourceList = viewModel.todos
        }
        
        if !searchText.isEmpty {
            sourceList = sourceList.filter { $0.text.localizedCaseInsensitiveContains(searchText) }
        }
        
        return sourceList.sorted { $0.date < $1.date }
    }
    
    // MARK: - Helper Function สำหรับ Drag and Drop
    func moveItems(from source: IndexSet, to destination: Int) {
        viewModel.todos.move(fromOffsets: source, toOffset: destination)
        viewModel.saveTodos() // ✅ FIX: saveTodos ถูกทำให้เข้าถึงได้แล้ว
    }
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ZStack {
                Color.primaryBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
                    headerView
                    
                    searchAndFilterSection
                        .padding(.bottom, 20)
                    
                    listHeader
                    
                    todoListSection
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showAddSheet, onDismiss: {
                editingTodo = nil
            }) {
                AddTodoSheet(viewModel: viewModel, editingTodo: editingTodo)
            }
            .sheet(isPresented: $showCalendarSheet) {
                CalendarView(viewModel: viewModel)
            }
            // ✅ Overlay Goal Popup ถูกเพิ่มที่นี่
            .overlay(
                Group {
                    if viewModel.showGoalPopup, let achievedGoal = viewModel.latestAchievedGoal {
                        // ✅ FIX: แก้ไข Argument Label
                        GoalReachedPopup(viewModel: viewModel, boldFontName: boldFontName)
                            .transition(.opacity.animation(.easeOut(duration: 0.5)))
                    }
                }
            )
            .font(.custom(regularFontName, size: 16))
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text("สวัสดี \(viewModel.userName)! 🌟")
                    .font(.custom(boldFontName, size: 24)) // ✅ Custom Font
                    .foregroundColor(.black)
                
                Text("คุณมีงานที่รออยู่ \(viewModel.todos.filter { !$0.isCompleted }.count) รายการ ✌️")
                    .font(.custom(regularFontName, size: 16)) // ✅ Custom Font
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            // ปุ่มปฏิทิน (มุมขวาบน)
            Button(action: {
                showCalendarSheet = true
            }) {
                Image(systemName: "calendar")
                    .font(.system(size: 32))
                    .foregroundColor(.accentColor) // ✅ Accent Color
            }
            .buttonStyle(PlainButtonStyle()) // ✅ ป้องกันสีเปลี่ยน
        }
        .padding(.horizontal, 20)
        .padding(.top, 15)
        .padding(.bottom, 10)
    }
    
    // MARK: - Search and Filter Section
    private var searchAndFilterSection: some View {
        VStack(spacing: 12) {
            // Search Bar
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass").foregroundColor(.gray)
                TextField("ค้นหางาน...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.custom(regularFontName, size: 16)) // ✅ Custom Font
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                    .buttonStyle(PlainButtonStyle()) // ✅ ป้องกันสีเปลี่ยน
                }
            }
            .padding(10)
            .background(Color.secondaryBackground) // ✅ สีพื้นหลัง Card/Input
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            .padding(.horizontal, 20)
            
            // Filter Buttons
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(TodoFilter.allCases, id: \.self) { filter in
                        FilterButton(
                            title: filter.rawValue,
                            isSelected: selectedFilter == filter,
                            color: .accentColor,
                            action: {
                                withAnimation {
                                    selectedFilter = filter
                                }
                            },
                            regularFontName: regularFontName
                        )
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    // MARK: - List Header
    private var listHeader: some View {
        HStack {
            Text(listHeaderText)
                .font(.custom(boldFontName, size: 18)) // ✅ Custom Font
            
            Spacer()
            
            Text("\(displayTodos.count) รายการ")
                .font(.custom(regularFontName, size: 14)) // ✅ Custom Font
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
    }

    private var listHeaderText: String {
        if !searchText.isEmpty {
            return "ผลการค้นหา"
        }
        switch selectedFilter {
        case .all:
            return "งานทั้งหมด"
        case .active:
            return "งานที่ยังไม่เสร็จ"
        case .completed:
            return "งานที่เสร็จแล้ว"
        }
    }
    
    // MARK: - Todo List Section
    @ViewBuilder
    private var todoListSection: some View {
        if displayTodos.isEmpty {
            Spacer()
            VStack(spacing: 10) {
                Text("📝")
                    .font(.system(size: 60))
                Text("ยังไม่มีรายการที่ต้องทำ")
                    .font(.custom(boldFontName, size: 18)) // ✅ Custom Font
                    .foregroundColor(.gray)
                Text("แตะปุ่ม + เพื่อเพิ่มรายการใหม่")
                    .font(.custom(regularFontName, size: 14)) // ✅ Custom Font
                    .foregroundColor(.gray)
            }
            Spacer()
        } else {
            ScrollView {
                LazyVGrid(columns: gridLayout, spacing: 15) {
                    ForEach(displayTodos) { todo in
                        TodoBlockCard(
                            todo: todo,
                            onToggle: {
                                withAnimation(.spring()) {
                                    viewModel.toggleTodo(todo)
                                }
                            },
                            onOpenDetail: {
                                editingTodo = todo
                                showAddSheet = true
                            }
                        )
                        .transition(.scale(scale: 0.8).combined(with: .opacity))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
    }
    
    // MARK: - Filter Button Component (รวมในไฟล์)
    struct FilterButton: View {
        let title: String
        let isSelected: Bool
        let color: Color
        let action: () -> Void
        let regularFontName: String
        
        var body: some View {
            Button(action: action) {
                Text(title)
                    .font(.custom(regularFontName, size: 14)) // ✅ Custom Font
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : color)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 8)
                    .background(
                        isSelected ?
                        color :
                        Color.primaryBackground
                    )
                    .cornerRadius(10)
            }
            .buttonStyle(PlainButtonStyle()) // ✅ ป้องกันสีเปลี่ยน
        }
    }
}
