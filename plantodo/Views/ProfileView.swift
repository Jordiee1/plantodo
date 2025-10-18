import SwiftUI

struct ProfileView: View {
    @ObservedObject var viewModel: TodoViewModel
    
    private let regularFontName = "IBMPlexSansThai-Regular"
    private let boldFontName = "IBMPlexSansThai-Bold"
    
    @State private var showingScanner = false
    @State private var showingShareSheet = false
    
    // State สำหรับ Inline Editing (ย้ายมาไว้ที่นี่เพื่อความชัดเจน)
    @State private var isEditing: Bool = false
    @State private var tempUserName: String = ""
    @State private var tempInterests: String = ""
    
    // State สำหรับ Goal Setting (ถูกย้ายมาที่นี่ เพื่อให้แก้ไขได้ในหน้าหลัก)
    @State private var tempGoal: String = ""
    @State private var tempThreshold: Int = 2
    
    // คำนวณอัตราความสำเร็จ
    var completionRate: Double {
        let total = viewModel.todos.count
        guard total > 0 else { return 0 }
        let completed = viewModel.todos.filter { $0.isCompleted }.count
        return (Double(completed) / Double(total))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.primaryBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        
                        // MARK: - 1. User Header & Profile Picture & Interests
                        userHeader
                            .padding(.top, 20)
                            .padding(.horizontal, 20)
                        
                        // MARK: - 2. Stats Dashboard
                        statsDashboard
                            .padding(.horizontal, 20)
                        
                        // MARK: - 3. Wishlist Manager (New Primary Feature - Always Editable)
                        wishlistManagerBlock
                            .padding(.horizontal, 20)
                        
                        // MARK: - 4. Action Buttons (Share/Scan)
                        if !isEditing {
                            actionButtons
                                .padding(.horizontal, 20)
                        }
                        
                        // ปุ่ม Save/Cancel เมื่ออยู่ในโหมดแก้ไข
                        if isEditing {
                            saveCancelButtons
                                .padding(.horizontal, 20)
                        }
                        
                        Spacer()
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("โปรไฟล์")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Toolbar ถูกคงไว้
            }
            .sheet(isPresented: $showingScanner) {
                Text("QR Code Scanner (จำลอง)")
            }
            .sheet(isPresented: $showingShareSheet) {
                Text("Share Profile (จำลอง)")
            }
            // ✅ Fix: Overlay Goal Popup ถูกแก้ไขการเรียกใช้
            .overlay(
                Group {
                    if viewModel.showGoalPopup, let achievedGoal = viewModel.latestAchievedGoal {
                        // ✅ FIX: ลบ achievedGoal ออกจาก Argument
                        GoalReachedPopup(viewModel: viewModel, boldFontName: boldFontName)
                            .transition(.opacity.animation(.easeOut(duration: 0.3)))
                    }
                }
            )
            .onAppear(perform: loadTempData) // ✅ ใช้ onAppear เพื่อโหลดข้อมูล
            .font(.custom(regularFontName, size: 16))
        }
    }
    
    // MARK: - Subviews

    private var userHeader: some View {
        HStack(alignment: .top) {
            
            // Profile Image (จำลอง)
            Image(systemName: viewModel.profileImageURL.isEmpty ? "person.circle.fill" : "photo.circle.fill")
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 80)
                .foregroundColor(.accentColor)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    // Username
                    if isEditing {
                        TextField("ชื่อผู้ใช้", text: $tempUserName)
                            .font(.custom(boldFontName, size: 24))
                            .foregroundColor(.black)
                            .padding(5)
                            .background(Color.secondaryBackground)
                            .cornerRadius(5)
                            .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                    } else {
                        Text(viewModel.userName)
                            .font(.custom(boldFontName, size: 28))
                            .foregroundColor(.black)
                    }
                    
                    // ✅ ปุ่ม Edit อยู่ต่อท้าย Username (ใช้ Toggle Editing State)
                    Button(action: {
                        withAnimation {
                            if isEditing {
                                saveChanges(profileOnly: true) // บันทึกเฉพาะ Profile Data
                            } else {
                                loadTempData() // โหลด Goal/Data ล่าสุดก่อนเข้า Edit Mode
                                isEditing = true
                            }
                        }
                    }) {
                        Image(systemName: isEditing ? "checkmark.circle.fill" : "pencil.circle.fill")
                            .foregroundColor(isEditing ? .green : .accentColor)
                            .font(.system(size: 20))
                    }
                }
                
                // Title/Bio ใต้ Username
                Text("Plan Todo User")
                    .font(.custom(regularFontName, size: 16))
                    .foregroundColor(.gray)
                
                // MARK: - Interests Tags (แทน Bio Block)
                if isEditing {
                    TextField("ความสนใจ (คั่นด้วย ,)", text: $tempInterests, axis: .vertical)
                        .font(.custom(regularFontName, size: 14))
                        .padding(5)
                        .background(Color.secondaryBackground)
                        .cornerRadius(5)
                        .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                } else if !viewModel.userInterests.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(viewModel.userInterests, id: \.self) { interest in
                                Text("#\(interest)")
                                    .font(.custom(regularFontName, size: 12))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.accentColor.opacity(0.1))
                                    .foregroundColor(.accentColor)
                                    .cornerRadius(10)
                            }
                        }
                    }
                }
            }
            .padding(.leading, 10)
            
            Spacer()
        }
    }

    private var statsDashboard: some View {
        // Stats Display Mode
        HStack(spacing: 8) {
            FireStreakBlock(
                streakCount: viewModel.currentFireStreak,
                boldFontName: boldFontName,
                regularFontName: regularFontName
            )
            .frame(maxWidth: .infinity, minHeight: 180)
            
            ProgressPieChartBlock(
                percentage: completionRate,
                totalTasks: viewModel.todos.count,
                boldFontName: boldFontName,
                regularFontName: regularFontName
            )
            .frame(maxWidth: .infinity, minHeight: 180)
        }
    }
    
    // MARK: - Wishlist Manager Block
    private var wishlistManagerBlock: some View {
        VStack(alignment: .leading, spacing: 15) {
            
            // MARK: - 3A. Wishlist Input (Always Visible)
            WishlistInlineInput(
                tempGoal: $tempGoal, // ✅ ส่ง Binding ของ @State
                tempThreshold: $tempThreshold, // ✅ ส่ง Binding ของ @State
                regularFontName: regularFontName,
                boldFontName: boldFontName,
                saveGoalAction: { saveGoalChanges() } // บันทึก Goal
            )
            
            // MARK: - 3B. Current Wishlist List
            Text("รายการของรางวัลที่รออยู่")
                .font(.custom(boldFontName, size: 20))
                .foregroundColor(.black)
                .padding(.top, 10)
            
            if viewModel.wishlist.isEmpty {
                Text("คุณยังไม่มีเป้าหมาย/รางวัลที่ตั้งไว้")
                    .font(.custom(regularFontName, size: 14))
                    .foregroundColor(.gray)
                    .padding(.top, 5)
            } else {
                // ✅ แสดงรายการ Wishlist โดยมี Animation เมื่อมีการเปลี่ยนแปลง
                ForEach(viewModel.wishlist) { item in
                    WishlistItemRow(item: item, viewModel: viewModel, boldFontName: boldFontName, regularFontName: regularFontName)
                        .padding(.vertical, 4)
                        .transition(.move(edge: .leading).combined(with: .opacity)) // เพิ่ม Transition
                }
            }
        }
        .padding(15)
        .background(Color.secondaryBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    private var actionButtons: some View {
        HStack(spacing: 15) {
            // Share Profile Button
            Button(action: { showingShareSheet = true }) {
                ActionTile(
                    icon: "square.and.arrow.up",
                    title: "แชร์โปรไฟล์",
                    color: .accentMint,
                    fontName: regularFontName
                )
            }
            
            // Scan QR Code Button
            Button(action: { showingScanner = true }) {
                ActionTile(
                    icon: "qrcode.viewfinder",
                    title: "สแกน QR Code",
                    color: .accentYellow,
                    fontName: regularFontName
                )
            }
        }
    }
    
    // ✅ ปุ่มยกเลิก/บันทึก เมื่ออยู่ในโหมดแก้ไข
    private var saveCancelButtons: some View {
        HStack(spacing: 15) {
            // ปุ่มยกเลิก
            Button(action: {
                withAnimation {
                    isEditing = false
                    loadTempData() // รีเซ็ตข้อมูลชั่วคราว
                }
            }) {
                Text("ยกเลิก")
                    .font(.custom(boldFontName, size: 16))
                    .foregroundColor(.accentRed)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.secondaryBackground)
                    .cornerRadius(12)
            }
            
            // ปุ่มบันทึก (สำหรับ Profile Data เท่านั้น)
            Button(action: { saveChanges(profileOnly: true) }) {
                Text("บันทึกโปรไฟล์")
                    .font(.custom(boldFontName, size: 16))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.accentColor)
                    .cornerRadius(12)
            }
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Helper Functions
    
    // โหลดค่าจาก ViewModel เข้า State ชั่วคราว
    func loadTempData() {
        tempUserName = viewModel.userName
        tempInterests = viewModel.userInterests.joined(separator: ", ")
        // ✅ Fix: โหลดค่า Goal จาก ViewModel
        tempGoal = viewModel.currentGoal
        tempThreshold = viewModel.goalThreshold
    }
    
    func saveChanges(profileOnly: Bool) {
        let interestsArray = tempInterests.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
        
        // บันทึกการเปลี่ยนแปลง Profile
        viewModel.saveUserName(tempUserName)
        viewModel.saveProfileData(imageURL: viewModel.profileImageURL, interests: interestsArray)
        
        // บันทึก Goal Setting ถ้าไม่ได้อยู่ในโหมดแก้ไข Profile Only
        if !profileOnly {
            // ✅ Fix: เรียกใช้ saveGoalData จาก State ชั่วคราว
            viewModel.saveGoalData(goal: tempGoal, threshold: tempThreshold)
        }
        
        isEditing = false
    }

    // ✅ New: Goal Save Logic (แยกออกมา)
    func saveGoalChanges() {
        viewModel.saveGoalData(goal: tempGoal, threshold: tempThreshold)
    }
}

// MARK: - Components for Profile View (แก้ไขให้ใช้ Custom Font)

// 1. Fire Streak Block
struct FireStreakBlock: View {
    let streakCount: Int
    let boldFontName: String
    let regularFontName: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Spacer()
            Text("\(streakCount)")
                .font(.custom(boldFontName, size: 48))
                .foregroundColor(.accentRed)
            
            Text("วันติดกัน")
                .font(.custom(regularFontName, size: 14))
                .foregroundColor(.gray)

            HStack {
                Text("🔥 Streak")
                    .font(.custom(boldFontName, size: 18))
                    .foregroundColor(.accentRed)
            }
        }
        .padding(15)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.secondaryBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// 2. Progress Pie Chart Block
struct ProgressPieChartBlock: View {
    let percentage: Double
    let totalTasks: Int
    let boldFontName: String
    let regularFontName: String
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                // Background Circle
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 10)
                
                // Progress Arc
                Circle()
                    .trim(from: 0, to: CGFloat(percentage))
                    .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                
                Text("\(Int(percentage * 100))%")
                    .font(.custom(boldFontName, size: 24))
                    .foregroundColor(.accentColor)
            }
            .frame(width: 100, height: 100)
            
            Spacer()
            
            Text("Completion Rate")
                .font(.custom(regularFontName, size: 14))
                .foregroundColor(.gray)
            
            Text("\(totalTasks) Tasks Total")
                .font(.custom(boldFontName, size: 16))
                .foregroundColor(.black)
        }
        .padding(15)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.secondaryBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// 3. Action Tile
struct ActionTile: View {
    let icon: String
    let title: String
    let color: Color
    let fontName: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(color)
            
            Text(title)
                .font(.custom(fontName, size: 14))
                .foregroundColor(.black)
        }
        .padding(15)
        .frame(maxWidth: .infinity)
        .background(color.opacity(0.1))
        .cornerRadius(16)
    }
}

// 4. Goal Setting Inline View (Component ใหม่)
struct WishlistInlineInput: View {
    // ✅ Fix: ใช้ Binding สำหรับ Goal State
    @Binding var tempGoal: String
    @Binding var tempThreshold: Int
    let regularFontName: String
    let boldFontName: String
    // ✅ เพิ่ม Action สำหรับบันทึก Goal โดยตรง
    let saveGoalAction: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("ตั้งค่าเป้าหมาย/รางวัล")
                .font(.custom(boldFontName, size: 20))
                .foregroundColor(.black)
            
            VStack(spacing: 10) {
                // Goal Threshold Picker
                HStack {
                    Text("สำเร็จงาน")
                        .font(.custom(regularFontName, size: 16))
                    
                    Picker("จำนวนงาน", selection: $tempThreshold) {
                        ForEach(1...5, id: \.self) { num in
                            Text("\(num) งาน")
                                .tag(num)
                        }
                    }
                    .pickerStyle(.menu)
                    .font(.custom(regularFontName, size: 16))
                    
                    Text("แล้วจะได้:")
                        .font(.custom(regularFontName, size: 16))
                }
                
                // Goal Input
                TextField("เช่น กินไอติม, ดูหนัง", text: $tempGoal, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .font(.custom(regularFontName, size: 16))
                    .padding(.horizontal, 5)
            }
            .padding(15)
            .background(Color.secondaryBackground)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)

            // ✅ ปุ่มบันทึก Goal ทันที
            HStack {
                Spacer()
                Button("บันทึกเป้าหมาย") {
                    saveGoalAction()
                }
                .font(.custom(boldFontName, size: 16))
                .foregroundColor(.white)
                .padding(.vertical, 8)
                .padding(.horizontal, 15)
                .background(Color.accentColor)
                .cornerRadius(10)
            }
        }
    }
}

// ✅ WishlistItemRow (New)
struct WishlistItemRow: View {
    // NOTE: item: WishlistItem ถูกใช้เป็น @ObservedObject ใน ProfileView แล้ว
    @State var item: WishlistItem
    @ObservedObject var viewModel: TodoViewModel
    let boldFontName: String
    let regularFontName: String
    
    var body: some View {
        HStack(spacing: 10) {
            Text(item.emoji)
                .font(.title)
            
            VStack(alignment: .leading) {
                Text(item.goal)
                    .font(.custom(boldFontName, size: 16))
                    .strikethrough(item.isAchieved)
                
                Text("สำเร็จงาน \(item.threshold) ชิ้น")
                    .font(.custom(regularFontName, size: 12))
                    .foregroundColor(.gray)
            }
            // ✅ ทำรายการจางลงเมื่อสำเร็จแล้ว
            .opacity(item.isAchieved ? 0.6 : 1.0)
            
            Spacer()
            
            if item.isAchieved {
                // ปุ่มรับรางวัล (เมื่อสำเร็จ)
                Button("รับรางวัล") {
                    // Logic: ลบ Wishlist ออกจาก List
                    withAnimation(.easeInOut(duration: 0.3)) {
                        viewModel.deleteWishlistItem(item: item)
                    }
                }
                .font(.custom(boldFontName, size: 14))
                .foregroundColor(.accentRed) // เปลี่ยนเป็นสีแดงเพื่อดึงดูด
            } else {
                // แสดง Progress
                Text("\(item.currentProgress)/\(item.threshold)")
                    .font(.custom(boldFontName, size: 14))
                    .foregroundColor(.accentColor)
            }
        }
        .padding(.vertical, 8)
    }
}


// ✅ 5. Goal Reached Popup
struct GoalReachedPopup: View {
    @ObservedObject var viewModel: TodoViewModel
    let boldFontName: String
    // ✅ Note: achievedGoal ถูกลบออกจาก struct เพื่อให้ใช้ viewModel.latestAchievedGoal แทน
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    viewModel.showGoalPopup = false
                }
            
            VStack(spacing: 20) {
                Text("🎉 ยินดีด้วย!")
                    .font(.custom(boldFontName, size: 28))
                    .foregroundColor(.accentColor)
                
                // ✅ Fix: ใช้ viewModel.currentGoal และ viewModel.goalThreshold โดยตรง
                Text("คุณทำภารกิจสำเร็จตามเป้าหมาย \(viewModel.goalThreshold) ชิ้นแล้ว อย่าลืมให้รางวัลตัวเองนะ!")
                    .font(.custom(viewModel.userName.isEmpty ? "IBMPlexSansThai-Regular" : "IBMPlexSansThai-Bold", size: 18))
                    .multilineTextAlignment(.center)
                
                Text("\"\(viewModel.currentGoal)\"")
                    .font(.custom(boldFontName, size: 22))
                    .foregroundColor(.accentRed)
                    .padding(.top, 5)
                
                Button("รับทราบ") {
                    viewModel.showGoalPopup = false
                }
                .font(.custom(boldFontName, size: 18))
                .padding(.horizontal, 30)
                .padding(.vertical, 10)
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .padding(30)
            .frame(maxWidth: 300)
            .background(Color.secondaryBackground)
            .cornerRadius(20)
            .shadow(radius: 20)
        }
    }
}

// 6. Profile Edit Sheet (ถูกยกเลิกใช้งานแล้ว แต่เก็บไว้เผื่อ Debug)
struct ProfileEditSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: TodoViewModel
    
    @State private var tempUserName: String
    @State private var tempInterests: String
    
    @State private var tempGoal: String
    @State private var tempThreshold: Int
    
    private let regularFontName = "IBMPlexSansThai-Regular"
    private let boldFontName = "IBMPlexSansThai-Bold"
    
    init(viewModel: TodoViewModel) {
        self.viewModel = viewModel
        self._tempUserName = State(initialValue: viewModel.userName)
        self._tempInterests = State(initialValue: viewModel.userInterests.joined(separator: ", "))
        self._tempGoal = State(initialValue: viewModel.currentGoal)
        self._tempThreshold = State(initialValue: viewModel.goalThreshold)
    }
    
    func saveChanges() {
        let interestsArray = tempInterests.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
        
        // บันทึกการเปลี่ยนแปลง
        viewModel.saveUserName(tempUserName)
        viewModel.saveProfileData(imageURL: viewModel.profileImageURL, interests: interestsArray)
        
        // ✅ บันทึก Goal Setting
        viewModel.saveGoalData(goal: tempGoal, threshold: tempThreshold)
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Section 1: Name and Picture
                Section(header: Text("ข้อมูลพื้นฐาน").font(.custom(boldFontName, size: 16))) {
                    
                    // Profile Picture (Placeholder)
                    HStack {
                        Text("รูปโปรไฟล์")
                        Spacer()
                        Button("เปลี่ยนรูป") {
                            // จำลองการเปิด Gallery
                        }
                    }
                    .font(.custom(regularFontName, size: 16))
                    
                    // Username Edit
                    TextField("ชื่อผู้ใช้งาน", text: $tempUserName)
                        .font(.custom(regularFontName, size: 16))
                }
                
                // Section 2: Interests
                Section(header: Text("ความสนใจ (คั่นด้วยเครื่องหมาย ,)").font(.custom(boldFontName, size: 16))) {
                    TextEditor(text: $tempInterests)
                        .frame(height: 100)
                        .font(.custom(regularFontName, size: 16))
                }

                // ✅ Section 3: Goal Setting
                Section(header: Text("ตั้งค่าเป้าหมาย/รางวัล").font(.custom(boldFontName, size: 16))) {
                    
                    HStack {
                        Text("สำเร็จงาน")
                            .font(.custom(regularFontName, size: 16))
                        
                        Picker("จำนวนงาน", selection: $tempThreshold) {
                            ForEach(1...5, id: \.self) { num in
                                Text("\(num) งาน")
                                    .tag(num) // ✅ ต้องกำหนด Tag
                            }
                        }
                        .pickerStyle(.menu)
                        .font(.custom(regularFontName, size: 16))
                        
                        Text("แล้วจะได้:")
                            .font(.custom(regularFontName, size: 16))
                    }
                    
                    TextField("เช่น กินไอติม, ดูหนัง", text: $tempGoal)
                        .font(.custom(regularFontName, size: 16))
                }
            }
            .navigationTitle("แก้ไขโปรไฟล์")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("ยกเลิก") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("บันทึก") {
                        saveChanges()
                        dismiss()
                    }
                    .font(.custom(boldFontName, size: 16))
                }
            }
        }
    }
}

