import SwiftUI

struct ProfileView: View {
    @ObservedObject var viewModel: TodoViewModel
    
    var completionRate: Double {
        let total = viewModel.todos.count
        guard total > 0 else { return 0 }
        let completed = viewModel.todos.filter { $0.isCompleted }.count
        return (Double(completed) / Double(total)) * 100
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 1.0, green: 0.96, blue: 0.97)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        VStack(spacing: 16) {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 100))
                                .foregroundColor(Color(red: 1.0, green: 0.42, blue: 0.62))
                            
                            Text("ผู้ใช้งาน")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.black)
                            
                            Text("Plan Todo User")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 40)
                        
                        VStack(spacing: 16) {
                            StatCard(
                                icon: "checkmark.circle.fill",
                                title: "งานทั้งหมด",
                                value: "\(viewModel.todos.count)",
                                color: .blue
                            )
                            
                            StatCard(
                                icon: "checkmark.seal.fill",
                                title: "งานที่เสร็จแล้ว",
                                value: "\(viewModel.todos.filter { $0.isCompleted }.count)",
                                color: .green
                            )
                            
                            StatCard(
                                icon: "clock.fill",
                                title: "งานที่ยังไม่เสร็จ",
                                value: "\(viewModel.todos.filter { !$0.isCompleted }.count)",
                                color: .orange
                            )
                            
                            StatCard(
                                icon: "folder.fill",
                                title: "โปรเจกต์ทั้งหมด",
                                value: "\(viewModel.projects.count)",
                                color: .purple
                            )
                            
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "chart.bar.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(Color(red: 1.0, green: 0.42, blue: 0.62))
                                    
                                    Text("อัตราการทำงานสำเร็จ")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.black)
                                    
                                    Spacer()
                                    
                                    Text("\(Int(completionRate))%")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(Color(red: 1.0, green: 0.42, blue: 0.62))
                                }
                                
                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.2))
                                            .frame(height: 12)
                                            .cornerRadius(6)
                                        
                                        Rectangle()
                                            .fill(Color(red: 1.0, green: 0.42, blue: 0.62))
                                            .frame(width: geometry.size.width * CGFloat(completionRate / 100), height: 12)
                                            .cornerRadius(6)
                                    }
                                }
                                .frame(height: 12)
                            }
                            .padding(20)
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("โปรไฟล์")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
