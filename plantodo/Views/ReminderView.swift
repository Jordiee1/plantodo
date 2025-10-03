import SwiftUI

struct ReminderView: View {
    @ObservedObject var viewModel: TodoViewModel
    @State private var showAddTodo: Bool = false
    @State private var selectedTodo: TodoItem?
    @State private var selectedProject: ProjectItem?
    @State private var showProjectDetail: Bool = false
    @State private var showAddProject: Bool = false
    @State private var editingProject: ProjectItem?
    @State private var currentWeekDates: [Date] = []
    
    var body: some View {
        NavigationView {
            mainContent
                .navigationTitle(formatNavigationTitle())
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        addMenu
                    }
                }
                .sheet(isPresented: $showAddTodo) {
                    AddTodoSheet(viewModel: viewModel, editingTodo: selectedTodo)
                        .onDisappear {
                            selectedTodo = nil
                        }
                }
                .sheet(isPresented: $showProjectDetail) {
                    projectDetailSheet
                }
                .sheet(isPresented: $showAddProject) {
                    AddProjectSheet(viewModel: viewModel, editingProject: editingProject)
                        .onDisappear {
                            editingProject = nil
                        }
                }
        }
        .onAppear {
            updateCurrentWeek()
        }
        .onChange(of: viewModel.selectedDate) { oldValue, newValue in
            updateCurrentWeek()
        }
    }
    
    // MARK: - Main Content
    private var mainContent: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                weekScrollView
                contentScrollView
            }
        }
    }
    
    // MARK: - Week Scroll View
    private var weekScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(currentWeekDates, id: \.self) { date in
                    DateButton(
                        date: date,
                        isSelected: Calendar.current.isDate(date, inSameDayAs: viewModel.selectedDate),
                        hasTask: viewModel.hasTasksOnDate(date),
                        fireCount: viewModel.getFireCount(for: date)
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            viewModel.selectedDate = date
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    // MARK: - Content Scroll View
    private var contentScrollView: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 12) {
                    if viewModel.todosForSelectedDate.isEmpty && viewModel.projectsForSelectedDate.isEmpty {
                        emptyStateView
                    } else {
                        tasksAndProjectsView
                    }
                }
                .padding(.bottom, 20)
            }
        }
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
                .frame(height: 60)
            
            Image(systemName: "calendar.badge.checkmark")
                .font(.system(size: 70))
                .foregroundColor(Color(red: 1.0, green: 0.42, blue: 0.62).opacity(0.3))
            
            Text("ไม่มีงานในวันนี้")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.gray)
            
            Text("เริ่มต้นเพิ่มงานหรือโปรเจกต์ของคุณได้เลย")
                .font(.system(size: 14))
                .foregroundColor(.gray.opacity(0.7))
                .multilineTextAlignment(.center)
            
            Spacer()
                .frame(height: 40)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
    }
    
    // MARK: - Tasks and Projects View
    @ViewBuilder
    private var tasksAndProjectsView: some View {
        if !viewModel.todosForSelectedDate.isEmpty {
            todosSection
        }
        
        if !viewModel.projectsForSelectedDate.isEmpty {
            projectsSection
        }
    }
    
    // MARK: - Todos Section
    private var todosSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            todosSectionHeader
            todosListView
        }
    }
    
    private var todosSectionHeader: some View {
        HStack {
            Text("งาน")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)
            
            Text("(\(completedTodosCount)/\(viewModel.todosForSelectedDate.count))")
                .font(.system(size: 16))
                .foregroundColor(.gray)
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    private var completedTodosCount: Int {
        viewModel.todosForSelectedDate.filter { $0.isCompleted }.count
    }
    
    private var todosListView: some View {
        ForEach(viewModel.todosForSelectedDate) { todo in
            TodoCard(
                todo: todo,
                onToggle: {
                    viewModel.toggleTodo(todo)
                },
                onDelete: {
                    viewModel.deleteTodo(todo)
                }
            )
            .padding(.horizontal, 20)
            .onTapGesture {
                selectedTodo = todo
                showAddTodo = true
            }
        }
    }
    
    // MARK: - Projects Section
    private var projectsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            projectsSectionHeader
            projectsListView
        }
    }
    
    private var projectsSectionHeader: some View {
        HStack {
            Text("โปรเจกต์")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)
            
            Text("(\(viewModel.projectsForSelectedDate.count))")
                .font(.system(size: 16))
                .foregroundColor(.gray)
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    private var projectsListView: some View {
        ForEach(viewModel.projectsForSelectedDate) { project in
            // แก้ไขที่บรรทัดนี้
            ProjectCardView(project: project, onTap: {
                selectedProject = project
                showProjectDetail = true
            })

    
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Add Menu
    private var addMenu: some View {
        Menu {
            Button(action: {
                selectedTodo = nil
                showAddTodo = true
            }) {
                Label("เพิ่ม Task", systemImage: "plus.circle")
            }
            
            Button(action: {
                editingProject = nil
                showAddProject = true
            }) {
                Label("เพิ่มโปรเจกต์", systemImage: "folder.badge.plus")
            }
        } label: {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 24))
                .foregroundColor(Color(red: 1.0, green: 0.42, blue: 0.62))
        }
    }
    
    // MARK: - Project Detail Sheet
    @ViewBuilder
    private var projectDetailSheet: some View {
        if let project = selectedProject {
            ProjectDetailView(project: project, viewModel: viewModel) {
                editingProject = project
                showProjectDetail = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showAddProject = true
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    private func updateCurrentWeek() {
        let calendar = Calendar.current
        let today = viewModel.selectedDate
        
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: today) else {
            return
        }
        
        var dates: [Date] = []
        var currentDate = weekInterval.start
        
        while currentDate < weekInterval.end {
            dates.append(currentDate)
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else {
                break
            }
            currentDate = nextDate
        }
        
        currentWeekDates = dates
    }
    
    private func formatNavigationTitle() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "th_TH")
        
        if Calendar.current.isDateInToday(viewModel.selectedDate) {
            return "วันนี้"
        } else if Calendar.current.isDateInTomorrow(viewModel.selectedDate) {
            return "พรุ่งนี้"
        } else {
            formatter.dateFormat = "d MMMM yyyy"
            return formatter.string(from: viewModel.selectedDate)
        }
    }
}

struct DateButton: View {
    let date: Date
    let isSelected: Bool
    let hasTask: Bool
    let fireCount: Int
    let action: () -> Void
    
    private var dayName: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "th_TH")
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                dayNameText
                dayNumberCircle
                taskIndicator
                fireIndicator
            }
            .frame(width: 60)
            .padding(.vertical, 8)
            .background(buttonBackground)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var dayNameText: some View {
        Text(dayName)
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(dayNameColor)
    }
    
    private var dayNameColor: Color {
        if isSelected {
            return .white
        } else if isToday {
            return Color(red: 1.0, green: 0.42, blue: 0.62)
        } else {
            return .gray
        }
    }
    
    private var dayNumberCircle: some View {
        ZStack {
            Circle()
                .fill(circleBackgroundColor)
                .frame(width: 44, height: 44)
            
            Text(dayNumber)
                .font(.system(size: 16, weight: isSelected ? .bold : .medium))
                .foregroundColor(dayNumberColor)
        }
    }
    
    private var circleBackgroundColor: Color {
        if isSelected {
            return Color(red: 1.0, green: 0.42, blue: 0.62)
        } else if isToday {
            return Color(red: 1.0, green: 0.42, blue: 0.62).opacity(0.1)
        } else {
            return Color.clear
        }
    }
    
    private var dayNumberColor: Color {
        if isSelected {
            return .white
        } else if isToday {
            return Color(red: 1.0, green: 0.42, blue: 0.62)
        } else {
            return .black
        }
    }
    
    private var taskIndicator: some View {
        Circle()
            .fill(hasTask ? Color(red: 1.0, green: 0.42, blue: 0.62) : Color.clear)
            .frame(width: 6, height: 6)
    }
    
    @ViewBuilder
    private var fireIndicator: some View {
        if fireCount > 0 {
            HStack(spacing: 2) {
                ForEach(0..<min(fireCount, 3), id: \.self) { _ in
                    Text("🔥")
                        .font(.system(size: 12))
                }
            }
        } else {
            Text("")
                .font(.system(size: 12))
                .frame(height: 12)
        }
    }
    
    private var buttonBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(isSelected ? Color(red: 1.0, green: 0.42, blue: 0.62).opacity(0.1) : Color.clear)
    }
}
