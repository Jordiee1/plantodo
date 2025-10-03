//
//  ProjectListView.swift
//  plantodo
//
//  Created by จิดาภา สีเพชร on 4/10/2568 BE.
//


import SwiftUI

struct ProjectListView: View {
    @ObservedObject var viewModel: TodoViewModel
    @State private var showAddProject = false
    @State private var selectedProject: ProjectItem?
    @State private var showProjectDetail = false
    @State private var editingProject: ProjectItem?
    @State private var searchText = ""
    @State private var selectedFilter: ProjectFilter = .all
    
    enum ProjectFilter: String, CaseIterable {
        case all = "ทั้งหมด"
        case inProgress = "กำลังดำเนินการ"
        case completed = "เสร็จสิ้น"
    }
    
    var filteredProjects: [ProjectItem] {
        var projects = viewModel.projects
        
        if !searchText.isEmpty {
            projects = projects.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
        
        switch selectedFilter {
        case .all:
            return projects
        case .inProgress:
            return projects.filter { $0.completionPercentage < 100 }
        case .completed:
            return projects.filter { $0.completionPercentage == 100 }
        }
    }
    
    var body: some View {
        NavigationView {
            mainContent
                .navigationTitle("โปรเจกต์")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        addButton
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
    }
    
    private var mainContent: some View {
        ZStack {
            Color(red: 1.0, green: 0.96, blue: 0.97)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                searchAndFilterSection
                
                if filteredProjects.isEmpty {
                    emptyStateView
                } else {
                    projectsListView
                }
            }
        }
    }
    
    private var searchAndFilterSection: some View {
        VStack(spacing: 12) {
            searchBar
            filterScrollView
        }
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("ค้นหาโปรเจกต์...", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                }) {
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
    
    private var filterScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(ProjectFilter.allCases, id: \.self) { filter in
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
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: searchText.isEmpty ? "folder" : "magnifyingglass")
                .font(.system(size: 70))
                .foregroundColor(Color(red: 1.0, green: 0.42, blue: 0.62).opacity(0.3))
            
            Text(searchText.isEmpty ? "ยังไม่มีโปรเจกต์" : "ไม่พบโปรเจกต์ที่ค้นหา")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.gray)
            
            Text(searchText.isEmpty ? "เริ่มต้นสร้างโปรเจกต์ของคุณได้เลย" : "ลองค้นหาด้วยคำอื่น")
                .font(.system(size: 14))
                .foregroundColor(.gray.opacity(0.7))
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    private var projectsListView: some View {
        // แนะนำให้เพิ่ม ScrollView เพื่อให้ลิสต์เลื่อนได้
        ScrollView {
            VStack(spacing: 16) {
                // และวนลูปจาก filteredProjects เพื่อให้การค้นหาทำงานถูกต้อง
                ForEach(filteredProjects) { project in
                    ProjectCardView(project: project, onTap: {
                        selectedProject = project
                        showProjectDetail = true
                    }
                    )
                    .padding(.horizontal, 20)
                }
            }
            .padding(.top, 16)
        }
    }
    
    private var addButton: some View {
        Button(action: {
            editingProject = nil
            showAddProject = true
        }) {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 24))
                .foregroundColor(Color(red: 1.0, green: 0.42, blue: 0.62))
        }
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
