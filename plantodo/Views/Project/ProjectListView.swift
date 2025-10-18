//
//  ProjectListView.swift
//  plantodo
//
//  [New Dashboard UI] - พร้อม Animation
//

import SwiftUI

struct ProjectListView: View {
    @ObservedObject var viewModel: TodoViewModel
    @State private var showAddProject = false
    @State private var selectedProject: ProjectItem?
    @State private var showProjectDetail = false
    @State private var editingProject: ProjectItem?
    @State private var searchText = ""
    @State private var showAddTodoSheet = false
    
    // ✅ NEW: State สำหรับควบคุม Entrance Animation
    @State private var isAnimating: Bool = false
    
    private let regularFontName = "IBMPlexSansThai-Regular"
    private let boldFontName = "IBMPlexSansThai-Bold"
    
    // โครงสร้างสำหรับ Dashboard Card (เน้นที่งานที่ยังไม่เสร็จ)
    var activeProjects: [ProjectItem] {
        return viewModel.projects.filter {
            // โชว์เฉพาะโปรเจกต์ที่ยังไม่เสร็จ (ต่ำกว่า 100%)
            viewModel.getProjectProgress(for: $0.id).percentage < 100
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.primaryBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 30) {
                        
                        // MARK: - Header & Search
                        VStack(alignment: .leading, spacing: 20) {
                            headerView
                            searchBar
                        }
                        .padding(.horizontal, 20)
                        
                        // MARK: - Dashboard / Project Overview (Scrollable Cards)
                        if !viewModel.projects.isEmpty {
                            projectOverviewSection
                                // ✅ Entrance Animation
                                .opacity(isAnimating ? 1 : 0)
                                .offset(y: isAnimating ? 0 : 20)
                                .animation(.easeOut(duration: 0.8), value: isAnimating)
                        }
                        
                        // MARK: - Ongoing Tasks (Vertical Rows)
                        if !activeProjects.isEmpty {
                            ongoingTasksSection
                                // ✅ Entrance Animation
                                .opacity(isAnimating ? 1 : 0)
                                .offset(y: isAnimating ? 0 : 20)
                                .animation(.easeOut(duration: 0.8).delay(0.2), value: isAnimating)
                        } else {
                            emptyStateView
                        }
                        
                        Spacer()
                    }
                    .padding(.top, 10)
                }
            }
            // ... (Sheets และ Navigation ยังคงเดิม)
            
            .navigationBarHidden(true)
            .sheet(isPresented: $showProjectDetail) {
                projectDetailSheet
            }
            .sheet(isPresented: $showAddProject) {
                AddProjectSheet(viewModel: viewModel, editingProject: editingProject)
                    .onDisappear { editingProject = nil }
            }
            .sheet(isPresented: $showAddTodoSheet) {
                if let projectID = selectedProject?.id {
                    AddTodoSheet(viewModel: viewModel,
                                 editingTodo: nil, // เพิ่มงานใหม่
                                 initialProjectId: projectID)
                }
            }
            .font(.custom(regularFontName, size: 16)) // ✅ กำหนด Font พื้นฐาน

            // ✅ Trigger Animation เมื่อ View ปรากฏ
            .onAppear {
                isAnimating = true
            }
        }
    }
    
    // MARK: - Sub-Views
    
    private var headerView: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Projects")
                        .font(.custom(boldFontName, size: 34)) // ✅ Custom Font
                        .foregroundColor(.black)
                    
                    Text("ขณะนี้คุณมีงาน \(viewModel.projects.count) โปรเจกต์")
                        .font(.custom(regularFontName, size: 16)) // ✅ Custom Font
                        .foregroundColor(.gray)
                }
                Spacer()
                
                // ปุ่มสร้างโปรเจกต์ใหม่ (Create New Project Button)
                Button("สร้างโปรเจกต์ใหม่") {
                    editingProject = nil
                    showAddProject = true
                }
                .font(.custom(boldFontName, size: 14)) // ✅ Custom Font
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.accentColor) // ✅ Accent Color
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass").foregroundColor(.gray)
            TextField("ค้นหาโปรเจกต์...", text: $searchText)
                .font(.custom(regularFontName, size: 16)) // ✅ Custom Font
        }
        .padding(10)
        .background(Color.secondaryBackground) // ✅ สี Card/Input
        .cornerRadius(10)
    }

    private var projectOverviewSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Dashboard Overview")
                .font(.custom(boldFontName, size: 20)) // ✅ Custom Font
                .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(viewModel.projects) { project in
                        // ProjectCardView: การ์ดใหญ่สำหรับ Dashboard
                        ProjectCardView(project: project, viewModel: viewModel, onTap: {
                            selectedProject = project
                            showProjectDetail = true
                        })
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    private var ongoingTasksSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Ongoing projects")
                    .font(.custom(boldFontName, size: 20)) // ✅ Custom Font
                Spacer()
                Button("See all") {
                    // สามารถใช้ Filter หรือนำทางไป ProjectList View (เก่า)
                }
                .font(.custom(regularFontName, size: 14)) // ✅ Custom Font
                .foregroundColor(.gray)
            }
            .padding(.horizontal, 20)
            
            // Vertical Rows of Projects
            VStack(spacing: 20) {
                ForEach(activeProjects) { project in
                    // ProjectRowCard: การ์ดแถวแนวนอน (Ongoing Tasks)
                    ProjectRowCard(project: project, viewModel: viewModel, onAddSubtask: {
                        selectedProject = project
                        showAddTodoSheet = true // เปิด sheet เพิ่มงานย่อย
                    })
                    .onTapGesture {
                        selectedProject = project
                        showProjectDetail = true
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "folder")
                .font(.system(size: 70)).foregroundColor(.gray.opacity(0.3))
            Text("ไม่พบโปรเจกต์ที่กำลังดำเนินงาน")
                .font(.custom(boldFontName, size: 20)) // ✅ Custom Font
                .foregroundColor(.gray)
            Text("เริ่มต้นสร้างโปรเจกต์ใหม่เพื่อเริ่มใช้งาน")
                .font(.custom(regularFontName, size: 16)) // ✅ Custom Font
                .foregroundColor(.gray.opacity(0.7))
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.top, 50)
    }
    
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
}
