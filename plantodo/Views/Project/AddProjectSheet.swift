import SwiftUI

struct AddProjectSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: TodoViewModel
    
    // ✅ กำหนดชื่อฟอนต์ที่ใช้ (ต้องตรงกับชื่อ PostScript Name ใน Info.plist)
    private let regularFontName = "IBMPlexSansThai-Regular"
    private let boldFontName = "IBMPlexSansThai-Bold"
    
    @State private var projectTitle: String = ""
    @State private var projectDescription: String = ""
    @State private var selectedDate: Date = Date()
    @State private var hasTime: Bool = true
    @State private var startTime: Date = Date()
    @State private var endTime: Date = Date()
    @State private var location: String = ""
    @State private var selectedCategory: Category = .work
    @State private var selectedColor: String = "blue"
    
    @State private var selectedImageURL: String? = nil
    @State private var teamMembers: [String] = []
    @State private var showingContactPicker = false
    @State private var showingImagePicker = false

    var editingProject: ProjectItem?
    
    let availableColors = ["blue", "purple", "pink", "orange", "green", "red"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.primaryBackground // สีพื้นหลังใหม่
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        projectTitleSection
                        projectDescriptionSection
                        
                        projectImageSection
                        
                        projectColorSection
                        projectCategorySection
                        projectDateSection
                        projectTimeSection
                        projectLocationSection
                        
                        projectTeamSection
                        
                        saveButton
                    }
                    .padding(20)
                }
            }
            .navigationTitle(editingProject == nil ? "สร้างโปรเจกต์ใหม่" : "แก้ไขโปรเจกต์")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("ยกเลิก") { dismiss() }
                }
            }
            .onAppear {
                if let project = editingProject {
                    projectTitle = project.title
                    projectDescription = project.description ?? ""
                    selectedDate = project.deadline
                    startTime = project.startTime ?? Date()
                    endTime = project.endTime ?? Date()
                    location = project.location ?? ""
                    selectedCategory = project.category
                    selectedColor = project.color
                    hasTime = project.startTime != nil
                    teamMembers = project.teamMembers
                    selectedImageURL = project.imageURL
                }
            }
            // Mock Components ถูกเรียกใช้จาก Global Scope
            .sheet(isPresented: $showingContactPicker) {
                MockContactPicker(teamMembers: $teamMembers, boldFontName: boldFontName)
            }
            .sheet(isPresented: $showingImagePicker) {
                MockImagePicker(selectedImageURL: $selectedImageURL, boldFontName: boldFontName)
            }
            .font(.custom(regularFontName, size: 16))
        }
    }

    // MARK: - Sub-Sections
    
    private var projectTitleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("ชื่อโปรเจกต์")
                .font(.custom(boldFontName, size: 14))
                .foregroundColor(.gray)
            
            TextField("ใส่ชื่อโปรเจกต์...", text: $projectTitle)
                .font(.custom(regularFontName, size: 16))
                .padding()
                .background(Color.secondaryBackground)
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2), lineWidth: 1))
        }
    }
    
    private var projectDescriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("รายละเอียด")
                .font(.custom(boldFontName, size: 14))
                .foregroundColor(.gray)
            
            TextEditor(text: $projectDescription)
                .font(.custom(regularFontName, size: 16))
                .frame(height: 100)
                .padding(8)
                .background(Color.secondaryBackground)
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2), lineWidth: 1))
        }
    }
    
    // MARK: - Project Image Section
    private var projectImageSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("รูปภาพโปรเจกต์")
                .font(.custom(boldFontName, size: 14))
                .foregroundColor(.gray)

            if let urlString = selectedImageURL, !urlString.isEmpty {
                Image(systemName: "photo.fill")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 150)
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .overlay(alignment: .topTrailing) {
                        Button { selectedImageURL = nil } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.white)
                                .padding(8)
                        }
                    }
            } else {
                Button(action: { showingImagePicker = true }) {
                    HStack {
                        Image(systemName: "photo.badge.plus")
                        Text("เพิ่มรูปภาพประกอบ")
                            .font(.custom(regularFontName, size: 16))
                    }
                    .foregroundColor(.accentColor)
                    .frame(height: 50)
                    .frame(maxWidth: .infinity)
                    .background(Color.secondaryBackground)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2), lineWidth: 1))
                }
            }
        }
    }
    
    private var projectColorSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("สีโปรเจกต์")
                .font(.custom(boldFontName, size: 14))
                .foregroundColor(.gray)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(availableColors, id: \.self) { color in
                        Circle()
                            .fill(getColor(from: color))
                            .frame(width: 50, height: 50)
                            .overlay(Circle().stroke(Color.white, lineWidth: selectedColor == color ? 4 : 0))
                            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                            .onTapGesture { selectedColor = color }
                    }
                }
            }
        }
    }
    
    private var projectCategorySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("หมวดหมู่")
                .font(.custom(boldFontName, size: 14))
                .foregroundColor(.gray)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Category.allCases, id: \.self) { category in
                        // ✅ แก้ไขลำดับ Argument ให้ถูกต้อง
                        CategoryButton(
                            category: category,
                            isSelected: selectedCategory == category,
                            action: { selectedCategory = category },
                            boldFontName: boldFontName
                        )
                    }
                }
            }
        }
    }
    
    private var projectDateSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("วันที่")
                .font(.custom(boldFontName, size: 14))
                .foregroundColor(.gray)
            DatePicker("", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .padding()
                .background(Color.secondaryBackground)
                .cornerRadius(12)
        }
    }
    
    @ViewBuilder
    private var projectTimeSection: some View {
        if hasTime {
            VStack(spacing: 12) {
                HStack {
                    Text("เริ่ม").frame(width: 60, alignment: .leading)
                        .font(.custom(regularFontName, size: 16))
                    DatePicker("", selection: $startTime, displayedComponents: .hourAndMinute).labelsHidden()
                }.padding().background(Color.secondaryBackground).cornerRadius(12)
                
                HStack {
                    Text("สิ้นสุด").frame(width: 60, alignment: .leading)
                        .font(.custom(regularFontName, size: 16))
                    DatePicker("", selection: $endTime, displayedComponents: .hourAndMinute).labelsHidden()
                }.padding().background(Color.secondaryBackground).cornerRadius(12)
            }
        }
    }
    
    private var projectLocationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("สถานที่")
                .font(.custom(boldFontName, size: 14))
                .foregroundColor(.gray)
            HStack {
                Image(systemName: "location.fill").foregroundColor(.accentColor)
                TextField("ใส่สถานที่...", text: $location)
                    .font(.custom(regularFontName, size: 16))
            }.padding().background(Color.secondaryBackground).cornerRadius(12).overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2), lineWidth: 1))
        }
    }
    
    // MARK: - Project Team Section
    private var projectTeamSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("ทีมงาน/ผู้ติดต่อ")
                    .font(.custom(boldFontName, size: 14))
                    .foregroundColor(.gray)
                Spacer()
                Button(action: { showingContactPicker = true }) {
                    Image(systemName: "person.badge.plus")
                        .foregroundColor(.accentColor)
                }
            }
            
            if teamMembers.isEmpty {
                Text("ยังไม่มีทีมงาน").foregroundColor(.gray.opacity(0.6))
                    .font(.custom(regularFontName, size: 16))
            } else {
                LazyVStack(alignment: .leading, spacing: 8) {
                    ForEach(teamMembers, id: \.self) { member in
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .foregroundColor(selectedColor.isEmpty ? .gray : getColor(from: selectedColor))
                            Text(member)
                                .font(.custom(regularFontName, size: 16))
                            Spacer()
                            Button { teamMembers.removeAll { $0 == member } } label: {
                                Image(systemName: "xmark.circle.fill").foregroundColor(.accentRed)
                            }
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color.secondaryBackground)
                        .cornerRadius(10)
                    }
                }
            }
        }
    }
    
    private var saveButton: some View {
        Button(action: saveProject) {
            Text(editingProject == nil ? "สร้างโปรเจกต์" : "บันทึกการแก้ไข")
                .font(.custom(boldFontName, size: 18))
                .foregroundColor(.white).frame(maxWidth: .infinity).padding()
                .background(projectTitle.trimmingCharacters(in: .whitespaces).isEmpty ? Color.gray : Color.accentColor)
                .cornerRadius(15).shadow(color: Color.accentColor.opacity(0.3), radius: 8, x: 0, y: 4)
        }.disabled(projectTitle.trimmingCharacters(in: .whitespaces).isEmpty)
    }
    
    // MARK: - saveProject Function
    private func saveProject() {
        let trimmedTitle = projectTitle.trimmingCharacters(in: .whitespaces)
        guard !trimmedTitle.isEmpty else { return }
        
        let project = ProjectItem(
            id: editingProject?.id ?? UUID(),
            title: trimmedTitle,
            description: projectDescription.trimmingCharacters(in: .whitespaces).isEmpty ? nil : projectDescription.trimmingCharacters(in: .whitespaces),
            deadline: selectedDate,
            startTime: hasTime ? startTime : nil,
            endTime: hasTime ? endTime : nil,
            location: location.trimmingCharacters(in: .whitespaces).isEmpty ? nil : location.trimmingCharacters(in: .whitespaces),
            teamMembers: teamMembers,
            tasks: editingProject?.tasks ?? [],
            category: selectedCategory,
            color: selectedColor,
            imageURL: selectedImageURL
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
        case "blue": return Color.blue
        case "purple": return Color.purple
        case "pink": return Color.pink
        case "orange": return Color.orange
        case "green": return Color.green
        case "red": return Color.red
        default: return Color.blue
        }
    }
}
