
import SwiftUI

struct ReminderView: View {
    @Environment(\.customBodyFont) var bodyFont
    @ObservedObject var viewModel: TodoViewModel
    @State private var selectedTodo: TodoItem?
    @State private var showAddSheet = false
    // NOTE: ลบ State และ Properties ที่ไม่เกี่ยวข้องกับ Reminder Flow ออกไป
    
    // กรองเฉพาะงานที่มีการตั้งเตือนและยังไม่เสร็จ
    var reminderTodos: [TodoItem] {
        return viewModel.todos
            .filter { $0.reminder && !$0.isCompleted }
            .sorted { $0.date < $1.date }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 1.0, green: 0.96, blue: 0.97)
                    .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 15) {
                    
                    Text("รายการแจ้งเตือน")
                        .font(.largeTitle.bold()).font(bodyFont)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    
                    if reminderTodos.isEmpty {
                        Spacer()
                        VStack(spacing: 10) {
                            Text("🔔")
                                .font(.system(size: 60)).font(bodyFont)
                            Text("ไม่มีรายการที่ต้องแจ้งเตือน")
                                .font(.system(size: 18, weight: .semibold)).font(bodyFont)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(reminderTodos) { todo in
                                    // ✅ แก้ไข: เรียกใช้ TodoRowView ด้วย Arguments ครบถ้วน
                                    // เราจะเรียกใช้ TodoRowView/TodoCard ที่รองรับ onToggle, onDelete, onEdit
                                    TodoRowView( // สมมติว่านี่คือชื่อ View ที่ใช้แสดงงานแบบ Row
                                        todo: todo,
                                        onToggle: { viewModel.toggleTodo(todo) },
                                        onDelete: { viewModel.deleteTodo(todo) },
                                        onEdit: {
                                            selectedTodo = todo
                                            showAddSheet = true
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 30)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showAddSheet) {
                // ใช้ AddTodoSheet สำหรับแก้ไข/ดูรายละเอียด
                AddTodoSheet(viewModel: viewModel, editingTodo: selectedTodo)
                    .onDisappear { selectedTodo = nil }
            }
        }
    }
}
