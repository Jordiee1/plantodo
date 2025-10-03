import SwiftUI

struct AddProjectSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: TodoViewModel
    
    @State private var projectTitle: String = ""
    @State private var projectDescription: String = ""
    @State private var selectedDate: Date = Date()
    @State private var hasTime: Bool = true
    @State private var startTime: Date = Date()
    @State private var endTime: Date = Date()
    @State private var location: String = ""
    @State private var teamMembers: [String] = []
    @State private var newMemberName: String = ""
    @State private var tasks: [ProjectTask] = []
    @State private var newTaskTitle: String = ""
    @State private var selectedAssignee: String = ""
    @State private var selectedCategory: Category = .work
    @State private var selectedColor: String = "blue"
    @State private var showAddMemberAlert: Bool = false
    @State private var showAddTaskAlert: Bool = false
    
    var editingProject: ProjectItem?
    
    let availableColors = ["blue", "purple", "pink", "orange", "green", "red"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("ชื่อโปรเจกต์")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.gray)
                            
                            TextField("ใส่ชื่อโปรเจกต์...", text: $projectTitle)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("รายละเอียด")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.gray)
                            
                            TextEditor(text: $projectDescription)
                                .frame(height: 100)
                                .padding(8)
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("สีโปรเจกต์")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.gray)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(availableColors, id: \.self) { color in
                                        Circle()
                                            .fill(getColor(from: color))
                                            .frame(width: 50, height: 50)
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.white, lineWidth: selectedColor == color ? 4 : 0)
                                            )
                                            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                                            .onTapGesture {
                                                selectedColor = color
                                            }
                                    }
                                }
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("หมวดหมู่")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.gray)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(Category.allCases, id: \.self) { category in
                                        CategoryButton(category: category, isSelected: selectedCategory == category) {
                                            selectedCategory = category
                                        }
                                    }
                                }
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("วันที่")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.gray)
                            
                            DatePicker("", selection: $selectedDate, displayedComponents: .date)
                                .datePickerStyle(.graphical)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                        }
                        
                        if hasTime {
                            VStack(spacing: 12) {
                                HStack {
                                    Text("เริ่ม")
                                        .font(.system(size: 14, weight: .semibold))
                                        .frame(width: 60, alignment: .leading)
                                    DatePicker("", selection: $startTime, displayedComponents: .hourAndMinute)
                                        .labelsHidden()
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                
                                HStack {
                                    Text("สิ้นสุด")
                                        .font(.system(size: 14, weight: .semibold))
                                        .frame(width: 60, alignment: .leading)
                                    DatePicker("", selection: $endTime, displayedComponents: .hourAndMinute)
                                        .labelsHidden()
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("สถานที่")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.gray)
                            
                            HStack {
                                Image(systemName: "location.fill")
                                    .foregroundColor(Color.appPrimary)

                                TextField("ใส่สถานที่...", text: $location)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("ทีมงาน")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.gray)
                                
                                Spacer()
                                
                                Button(action: { showAddMemberAlert = true }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "plus.circle.fill")
                                        Text("เพิ่มสมาชิก")
                                    }
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Color.appPrimary)
                                }
                            }
                            
                            if teamMembers.isEmpty {
                                HStack {
                                    Spacer()
                                    VStack(spacing: 8) {
                                        Image(systemName: "person.2.slash")
                                            .font(.system(size: 40))
                                            .foregroundColor(.gray.opacity(0.5))
                                        Text("ยังไม่มีสมาชิกในทีม")
                                            .font(.system(size: 14))
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 30)
                                .background(Color.white)
                                .cornerRadius(12)
                            } else {
                                VStack(spacing: 8) {
                                    ForEach(Array(teamMembers.enumerated()), id: \.offset) { index, member in
                                        HStack {
                                            Image(systemName: "person.circle.fill")
                                                .font(.system(size: 24))
                                                .foregroundColor(Color.appPrimary)

                                            Text(member)
                                                .font(.system(size: 16))
                                            
                                            Spacer()
                                            
                                            Button(action: {
                                                withAnimation {
                                                    teamMembers.remove(at: index)
                                                }
                                            }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .font(.system(size: 20))
                                                    .foregroundColor(.red.opacity(0.7))
                                            }
                                        }
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(12)
                                        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
                                    }
                                }
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("รายการงาน")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.gray)
                                
                                if !tasks.isEmpty {
                                    Text("(\(tasks.filter { $0.isCompleted }.count)/\(tasks.count))")
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                Button(action: { showAddTaskAlert = true }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "plus.circle.fill")
                                        Text("เพิ่มงาน")
                                    }
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Color.appPrimary)
                                }
                            }
                            
                            if tasks.isEmpty {
                                HStack {
                                    Spacer()
                                    VStack(spacing: 8) {
                                        Image(systemName: "list.bullet.clipboard")
                                            .font(.system(size: 40))
                                            .foregroundColor(.gray.opacity(0.5))
                                        Text("ยังไม่มีรายการงาน")
                                            .font(.system(size: 14))
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 30)
                                .background(Color.white)
                                .cornerRadius(12)
                            } else {
                                VStack(spacing: 8) {
                                    ForEach(Array(tasks.enumerated()), id: \.element.id) { index, task in
                                        HStack(spacing: 12) {
                                            Button(action: {
                                                withAnimation {
                                                    tasks[index].isCompleted.toggle()
                                                }
                                            }) {
                                                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                                    .font(.system(size: 24))
                                                    .foregroundColor(task.isCompleted ? .green : .gray)
                                            }
                                            
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(task.title)
                                                    .font(.system(size: 16))
                                                    .foregroundColor(.black)
                                                    .strikethrough(task.isCompleted)
                                                
                                                if let assignedTo = task.assignedTo, !assignedTo.isEmpty {
                                                    HStack(spacing: 4) {
                                                        Image(systemName: "person.fill")
                                                            .font(.system(size: 10))
                                                        Text(assignedTo)
                                                            .font(.system(size: 12))
                                                    }
                                                    .foregroundColor(.gray)
                                                }
                                            }
                                            
                                            Spacer()
                                            
                                            Button(action: {
                                                withAnimation {
                                                    tasks.remove(at: index)
                                                }
                                            }) {
                                                Image(systemName: "trash")
                                                    .font(.system(size: 16))
                                                    .foregroundColor(.red.opacity(0.7))
                                            }
                                        }
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(12)
                                        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
                                    }
                                }
                            }
                        }
                        
                        Button(action: saveProject) {
                            Text(editingProject == nil ? "สร้างโปรเจกต์" : "บันทึกการแก้ไข")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    projectTitle.trimmingCharacters(in: .whitespaces).isEmpty ?
                                    Color.gray : Color(red: 1.0, green: 0.42, blue: 0.62)
                                )
                                .cornerRadius(15)
                                .shadow(color: Color(red: 1.0, green: 0.42, blue: 0.62).opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .disabled(projectTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                    .padding(20)
                }
            }
            .navigationTitle(editingProject == nil ? "สร้างโปรเจกต์ใหม่" : "แก้ไขโปรเจกต์")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("ยกเลิก") {
                        dismiss()
                    }
                }
            }
            .alert("เพิ่มสมาชิกทีม", isPresented: $showAddMemberAlert) {
                TextField("ชื่อสมาชิก", text: $newMemberName)
                Button("เพิ่ม") {
                    if !newMemberName.trimmingCharacters(in: .whitespaces).isEmpty {
                        withAnimation {
                            teamMembers.append(newMemberName.trimmingCharacters(in: .whitespaces))
                        }
                        newMemberName = ""
                    }
                }
                Button("ยกเลิก", role: .cancel) {
                    newMemberName = ""
                }
            } message: {
                Text("ใส่ชื่อสมาชิกในทีม")
            }
            .alert("เพิ่มงาน", isPresented: $showAddTaskAlert) {
                TextField("ชื่องาน", text: $newTaskTitle)
                TextField("มอบหมายให้", text: $selectedAssignee)
                Button("เพิ่ม") {
                    if !newTaskTitle.trimmingCharacters(in: .whitespaces).isEmpty {
                        let assignee = selectedAssignee.trimmingCharacters(in: .whitespaces).isEmpty ? nil : selectedAssignee.trimmingCharacters(in: .whitespaces)
                        let newTask = ProjectTask(
                            title: newTaskTitle.trimmingCharacters(in: .whitespaces),
                            isCompleted: false,
                            assignedTo: assignee
                        )
                        withAnimation {
                            tasks.append(newTask)
                        }
                        newTaskTitle = ""
                        selectedAssignee = ""
                    }
                }
                Button("ยกเลิก", role: .cancel) {
                    newTaskTitle = ""
                    selectedAssignee = ""
                }
            } message: {
                Text("ใส่รายละเอียดงาน")
            }
        }
        .onAppear {
            if let project = editingProject {
                projectTitle = project.title
                projectDescription = project.description ?? ""
                selectedDate = project.date
                startTime = project.startTime ?? Date()
                endTime = project.endTime ?? Date()
                location = project.location ?? ""
                teamMembers = project.teamMembers
                tasks = project.tasks
                selectedCategory = project.category
                selectedColor = project.color
                hasTime = project.startTime != nil
            }
        }
    }
    
    private func saveProject() {
        let trimmedTitle = projectTitle.trimmingCharacters(in: .whitespaces)
        guard !trimmedTitle.isEmpty else { return }
        
        let project = ProjectItem(
            id: editingProject?.id ?? UUID(),
            title: trimmedTitle,
            description: projectDescription.trimmingCharacters(in: .whitespaces).isEmpty ? nil : projectDescription.trimmingCharacters(in: .whitespaces),
            date: selectedDate,
            startTime: hasTime ? startTime : nil,
            endTime: hasTime ? endTime : nil,
            location: location.trimmingCharacters(in: .whitespaces).isEmpty ? nil : location.trimmingCharacters(in: .whitespaces),
            teamMembers: teamMembers,
            tasks: tasks,
            category: selectedCategory,
            color: selectedColor
        )
        
        if editingProject != nil {
            viewModel.updateProject(project)
        } else {
            viewModel.addProject(project)
        }
        
        dismiss()
    }
    
    private func getColor(from colorName: String) -> Color {
        switch colorName {
        case "blue":
            return Color.blue
        case "purple":
            return Color.purple
        case "pink":
            return Color.pink
        case "orange":
            return Color.orange
        case "green":
            return Color.green
        case "red":
            return Color.red
        default:
            return Color.blue
        }
    }
}
