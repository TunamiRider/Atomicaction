import SwiftUI
import SwiftData
internal import Combine
// MARK: - Animation Phase

enum EclipsePhase {
    case idle        // Default eclipse state
    case shrinking   // Moon shrinks, sun reveals
    case sunRevealed // Sun fully visible, brief pause
    case returning   // Moon grows back to original size
}

// MARK: - EclipseView
struct EclipseView: View {
    
    // ── SwiftData ────────────────────────────────────────────────────
    @Query(filter: #Predicate {$0.isCompleted == false}, sort: \Task.order) private var tasks: [Task]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
 
    // Convenience: first task from the sorted list
    private var firstTask: Task? { prioritizedTasks.first }
    
    private var prioritizedTasks: [Task] {
        let now = Date.now
        
        return tasks.sorted{ a, b in
            let aIsActive = isActiveRoutine(a, at: now)
            let bIsActive = isActiveRoutine(b, at: now)
            
            //Active routine always wins
            if aIsActive != bIsActive { return aIsActive }
            
            if aIsActive && bIsActive {
                let aEnd = endTime(a)
                let bEnd = endTime(b)
                if let aEnd, let bEnd { return aEnd < bEnd }
            }
            
            return a.order < b.order
        }
    }
    private func isActiveRoutine(_ task: Task, at now: Date) -> Bool {
        guard task.isRoutine,
              let scheduled = task.scheduledAt,
              let duration = task.durationMinutes else { return false }
        let end = scheduled.addingTimeInterval(Double(duration) * 60)
        
        return scheduled <= now && now <= end
    }
    private func endTime(_ task: Task) -> Date? {
        guard let scheduled = task.scheduledAt,
              let duration = task.durationMinutes else { return nil }
        
        return scheduled.addingTimeInterval(Double(duration) * 60)
    }

    // Task data
    //var taskTitle: String = ""
    //var taskDescription: String = ""
    //var taskCategory: Category = .other

    // Ambient animations
    @State private var glowPulse: Bool = false
    @State private var coronaRotation: Double = 0
    @State private var outerRingScale: CGFloat = 1.0

    // Sequence state
    @State private var phase: EclipsePhase = .idle
    @State private var moonScale: CGFloat = 1.0
    @State private var sunOpacity: Double = 0.0
    @State private var sunScale: CGFloat = 0.6
    // Sun animation states
    @State private var sunBloom: CGFloat = 1.0
    @State private var buttonOpacity: Double = 1.0
    @State private var isButtonPressed: Bool = false
    
    @State private var timerProgress: Double = 1.0
    @State private var countdownTimer: Timer? = nil
    
    @State private var now:Date = .now

    var body: some View {
        GeometryReader { geo in
            // Use the smaller dimension so it fits on any screen (portrait or landscape)
            let size = min(geo.size.width, geo.size.height)
            // All original values were designed around a ~390pt wide iPhone screen.
            // Scale factor keeps every element proportional to that baseline.
            let s = size / 390

            ZStack {
                // ── Background ──────────────────────────────────────────
                RadialGradient(
                    colors: [
                        Color(red: 0.04, green: 0.02, blue: 0.12),
                        Color(red: 0.01, green: 0.01, blue: 0.06),
                        Color.black
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: 520 * s
                )
                .ignoresSafeArea()

                StarFieldView()

                // ── Outer halo ──────────────────────────────────────────
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 1.0, green: 0.6, blue: 0.1).opacity(glowPulse ? 0.18 : 0.10),
                                Color(red: 1.0, green: 0.4, blue: 0.05).opacity(0.05),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 160 * s,
                            endRadius: 340 * s
                        )
                    )
                    .frame(width: 680 * s, height: 680 * s)
                    .scaleEffect(outerRingScale)

                // ── Corona rays ─────────────────────────────────────────
                CoronaRaysView(rotation: coronaRotation)
                    .frame(width: 520 * s, height: 520 * s)

                // ── Sun (light-based) ────────────────────────────────────
                ZStack {
                    // Layer 1: Wide outer warmth
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(red: 1.0, green: 0.65, blue: 0.1).opacity(0.28),
                                    Color(red: 1.0, green: 0.45, blue: 0.0).opacity(0.12),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 78 * s,
                                endRadius: 286 * s
                            )
                        )
                        .frame(width: 572 * s, height: 572 * s)
                        .scaleEffect(sunBloom)
                        .blur(radius: 30 * s)

                    // Layer 2: Mid warm haze
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(red: 1.0, green: 0.85, blue: 0.35).opacity(0.0),
                                    Color(red: 1.0, green: 0.75, blue: 0.2).opacity(0.55),
                                    Color(red: 1.0, green: 0.55, blue: 0.05).opacity(0.25),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 39 * s,
                                endRadius: 169 * s
                            )
                        )
                        .frame(width: 338 * s, height: 338 * s)
                        .blur(radius: 14 * s)

                    // Layer 3: Inner bright halo
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.clear,
                                    Color(red: 1.0, green: 0.95, blue: 0.6).opacity(glowPulse ? 0.75 : 0.55),
                                    Color(red: 1.0, green: 0.8, blue: 0.3).opacity(0.3),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 36 * s,
                                endRadius: 104 * s
                            )
                        )
                        .frame(width: 208 * s, height: 208 * s)
                        .blur(radius: 6 * s)

                    // Layer 4: White-hot core
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.white,
                                    Color(red: 1.0, green: 0.97, blue: 0.82).opacity(0.95),
                                    Color(red: 1.0, green: 0.88, blue: 0.45).opacity(0.6),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 68 * s
                            )
                        )
                        .frame(width: 136 * s, height: 136 * s)
                        .blur(radius: 8 * s)

                    // Layer 5: Sparkle point
                    Circle()
                        .fill(Color.white)
                        .frame(width: 22 * s, height: 22 * s)
                        .blur(radius: 3 * s)
                }
                .scaleEffect(sunScale)
                .opacity(sunOpacity)

                // ── Inner glow ring ─────────────────────────────────────
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.clear,
                                Color.clear,
                                Color(red: 1.0, green: 0.75, blue: 0.3).opacity(glowPulse ? 0.85 : 0.65),
                                Color(red: 1.0, green: 0.5, blue: 0.1).opacity(0.4),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 110 * s,
                            endRadius: 188 * s
                        )
                    )
                    .frame(width: 376 * s, height: 376 * s)
                    .blur(radius: 6 * s)
                    .opacity(moonScale > 0.1 ? 1.0 : 0.0)

                // ── Timer ring (just outside moon) ──────────────────────────
                let currentTask = firstTask
                TimerRingView(
                    task: currentTask,
                    //scheduledAt: firstTask?.scheduledAt,
                    //durationMinutes: firstTask?.durationMinutes,
                    glowPulse: glowPulse,
                    size: 300 * s,
                    isButtonPressed: $isButtonPressed,
                    onTimerComplete: { completedTask in
                            startSequence(completing: completedTask)
                    }
                )
                .opacity(moonScale > 0.3 ? moonScale : 0)  // fades with moon during animation
                
                // ── Moon disc ────────────────────────────────────────────
                MoonDisc(
                    task: firstTask,
                    modelContext: modelContext,
                    isButtonPressed:$isButtonPressed
                )
                .scaleEffect(moonScale * s)   // bake the screen scale in here
                .opacity(moonScale > 0.05 ? 1.0 : 0.0)

                // ── Crescent limb highlight ──────────────────────────────
                Ellipse()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 1.0, green: 0.85, blue: 0.4).opacity(glowPulse ? 0.9 : 0.7),
                                Color(red: 1.0, green: 0.55, blue: 0.1).opacity(0.3),
                                Color.clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 36 * s, height: 234 * s)
                    .offset(x: 126 * s)
                    .blur(radius: 4 * s)
                    .opacity(moonScale > 0.3 ? moonScale : 0)

                // ── Label ────────────────────────────────────────────────
//                VStack {
//                    Spacer()
//                    Text("TOTAL SOLAR ECLIPSE")
//                        .font(.system(size: 13 * s, weight: .semibold, design: .monospaced))
//                        .tracking(5)
//                        .foregroundStyle(
//                            LinearGradient(
//                                colors: [
//                                    Color(red: 1.0, green: 0.8, blue: 0.4),
//                                    Color(red: 0.9, green: 0.5, blue: 0.15)
//                                ],
//                                startPoint: .leading,
//                                endPoint: .trailing
//                            )
//                        )
//                        .opacity(0.75)
//                        .padding(.bottom, 52 * s)
//                }

                // ── Tap button ───────────────────────────────────────────
                VStack {
                    Button(action:{
                        startSequence(completing: currentTask)
                    }) {
                        Text(isButtonPressed ? "ANIMATING" : "TAP TO ANIMATE")
                            .font(.system(size: 11 * s, weight: .medium, design: .monospaced))
                            .tracking(3)
                            .foregroundColor(Color(red: 1.0, green: 0.8, blue: 0.4).opacity(0.85))
                            .padding(.horizontal, 18 * s)
                            .padding(.vertical, 10 * s)
                            .background(
                                RoundedRectangle(cornerRadius: 20 * s)
                                    .stroke(Color(red: 1.0, green: 0.6, blue: 0.1).opacity(0.5), lineWidth: 1)
                            )
                        
                    }
                    .opacity(buttonOpacity)
                    .padding(.top, 60 * s)
                    Spacer()
                }
                
                // ── Time info ────────────────────────────────────────────────
                VStack {
                    Spacer()
                    // ── Timer Dispaly ────────────────────────────────────────────────
                    if currentTask != nil {
//                        let scheduledAt = firstTask?.scheduledAt,
//                           let duration = firstTask?.durationMinutes
                        HStack(spacing: 16) {
                            // Scheduled time
                            VStack(spacing: 2) {
                                Text("scheduled")
                                    .font(.system(size: 9 * s, weight: .medium, design: .monospaced))
                                    .tracking(2)
                                    .foregroundColor(Color(red: 1.0, green: 0.8, blue: 0.4).opacity(0.5))
                                Text(currentTask?.isRoutine == true
                                     ? (currentTask?.scheduledAt.map { $0.formatted(date: .omitted, time: .shortened).lowercased() } ?? "-")
                                     : "-")
                                    .font(.system(size: 14 * s, weight: .semibold, design: .monospaced))
                                    .foregroundColor(Color(red: 1.0, green: 0.8, blue: 0.4).opacity(0.85))
                            }

                            // Divider dot
                            Circle()
                                .fill(Color(red: 1.0, green: 0.6, blue: 0.1).opacity(0.4))
                                .frame(width: 3 * s, height: 3 * s)

                            // Remaining time
                            VStack(spacing: 2) {
                                Text("remaining")
                                    .font(.system(size: 9 * s, weight: .medium, design: .monospaced))
                                    .tracking(2)
                                    .foregroundColor(Color(red: 1.0, green: 0.8, blue: 0.4).opacity(0.5))
                                Text({
                                    if let task = currentTask,
                                       task.isRoutine,
                                        let scheduledAt = task.scheduledAt,
                                        let duration = task.durationMinutes {
                                        return remainingText(scheduledAt: scheduledAt, duration: duration, now: now)
                                    }
                                    return "-"
                                }())
                                    .font(.system(size: 14 * s, weight: .semibold, design: .monospaced))
                                    .foregroundColor(Color(red: 1.0, green: 0.8, blue: 0.4).opacity(0.85))
                            }
                        }
                        .padding(.horizontal, 20 * s)
                        .padding(.vertical, 10 * s)
                        .background(
                            RoundedRectangle(cornerRadius: 20 * s)
                                .stroke(Color(red: 1.0, green: 0.6, blue: 0.1).opacity(0.25), lineWidth: 1)
                        )
                        .padding(.bottom, 24 * s)
                    }
                    // ── Label ────────────────────────────────────────────────
                    Text("TOTAL SOLAR ECLIPSE")
                        .font(.system(size: 13 * s, weight: .semibold, design: .monospaced))
                        .tracking(5)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color(red: 1.0, green: 0.8, blue: 0.4),
                                    Color(red: 0.9, green: 0.5, blue: 0.15)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .opacity(0.75)
                        .padding(.bottom, 52 * s)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .onAppear {
            resetRoutineTasks()
            
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                glowPulse = true
            }
            withAnimation(.linear(duration: 60).repeatForever(autoreverses: false)) {
                coronaRotation = 360
            }
            withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
                outerRingScale = 1.06
            }
            //startCountdown()
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()){ _ in
            now = .now
        }
        .onChange(of: firstTask?.id){_, _ in
            timerProgress = 1.0
                //startCountdown()
        }
        .onChange(of: scenePhase){_, newPhase in
            if newPhase == .active {
                resetRoutineTasks()
            }
        }
    }

    // MARK: - Animation Sequence

    func startSequence(completing taskToComplete2: Task? = nil) {
        guard phase == .idle else { return }
//        print("🌑 startSequence fired")
//        print("🌑 firstTask at start: \(firstTask?.title ?? "nil")")
//        print("🌑 all tasks count: \(tasks.count)")
//        tasks.forEach { print("   - \($0.title) | completed: \($0.isCompleted) | scheduledAt: \($0.scheduledAt?.description ?? "nil")") }
        
        
        // let taskToComplete = firstTask
//        print("🌑 taskToComplete snapshot: \(taskToComplete?.title ?? "nil")")
        

        
//        print("🌑 firstTask AFTER save: \(firstTask?.title ?? "nil")")
//        print("🌑 tasks AFTER save:")
//        tasks.forEach { print("   - \($0.title) | completed: \($0.isCompleted)") }
        
        withAnimation(.easeOut(duration: 0.3)) {
            buttonOpacity = 0
        }

        // ── Phase 1: Moon shrinks → Sun reveals (0 → 2.2s) ──────────
        phase = .shrinking
        withAnimation(.easeInOut(duration: 2.2)) {
            moonScale  = 0.0
            sunOpacity = 1.0
            sunScale   = 1.0
        }

        // ── Phase 2: Sun blooms briefly (2.2s → 3.4s) ───────────────
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            phase = .sunRevealed
            withAnimation(.easeOut(duration: 0.4)) { sunBloom = 1.18 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                withAnimation(.easeInOut(duration: 0.5)) { sunBloom = 1.0 }
            }
            isButtonPressed = true

        }


        // ── Phase 3: Moon grows back (3.4s → 5.6s) ──────────────────
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.4) {
            phase = .returning
            
            // ← complete the SNAPSHOT, not whatever firstTask is now
            if let task = taskToComplete2 {
//                task.isCompleted = true
//                task.updateCompletionRank()
                task.markCompleted()
                try? modelContext.save()
                print("✅ saved: \(task.title) as completed")
            }
            
            withAnimation(.easeInOut(duration: 2.2)) {
                moonScale  = 1.0
                sunOpacity = 0.0
                sunScale   = 0.6
            }
        }

        // ── Phase 4: Back to idle (6.0s) ────────────────────────────
        DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
            phase    = .idle
            sunBloom = 1.0
            withAnimation(.easeIn(duration: 0.5)) {
                buttonOpacity = 1.0
                isButtonPressed = false
            }
        }
        
    }
    
    // Computed helper (add below state vars)
    private func computeProgress(scheduledAt: Date, durationMinutes: Int) -> Double {
        let end = scheduledAt.addingTimeInterval(Double(durationMinutes) * 60)
        let total = Double(durationMinutes) * 60
        let remaining = end.timeIntervalSinceNow
        return max(0, min(1, remaining / total))
    }

    // Replace / add in .onAppear
    private func startCountdown() {
        countdownTimer?.invalidate()
        timerProgress = 1.0
        //guard let task = firstTask else {return }
//              let scheduled = task.scheduledAt,
//              let duration = task.durationMinutes else { return }
//                let scheduled = firstTask?.scheduledAt ?? .now
//                let duration: Int = firstTask?.durationMinutes ?? 0
        
        
//        timerProgress = computeProgress(scheduledAt: scheduled, durationMinutes: duration)

        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            guard let task = firstTask,
                  let scheduled = task.scheduledAt,
                  let duration = task.durationMinutes else {
                    timerProgress = 1.0
                    return
            }
            
            timerProgress = computeProgress(scheduledAt: scheduled, durationMinutes: duration)
            if timerProgress <= 0 { countdownTimer?.invalidate() }
        }
    }
    
    private func remainingText(scheduledAt: Date, duration: Int, now:Date = .now) -> String {
        let end = scheduledAt.addingTimeInterval(Double(duration) * 60)
        let remaining = end.timeIntervalSinceNow
        //let remaining = end.timeIntervalSince(now)

        if remaining <= 0 { return "done" }

        let totalMinutes = Int(remaining / 60)
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    private func resetRoutineTasks(){
        tasks.forEach{ $0.resetIfNeeded(resetHour: 18) }
        try? modelContext.save()
    }
}

// MARK: - Moon Disc

struct MoonDisc: View {
    let task: Task?
    let modelContext: ModelContext
    @Binding var isButtonPressed: Bool
    

    var title: String {
        task?.title ?? ""
    }
    var taskDescription: String {
        task?.task_description ?? ""
    }
    var category: Category {
        task?.category ?? .other
    }
    var categoryConfig: CategoryConfig {
        CategoryConfig.from(category)
    }

    private var displayTitle: String {
        String(title.prefix(30))
    }
    private var displayDescription: String {
        String(taskDescription.prefix(280))
    }

    var body: some View {
        ZStack {
            // ── Base sphere ──────────────────────────────────────────
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 0.18, green: 0.17, blue: 0.22),
                            Color(red: 0.10, green: 0.09, blue: 0.14),
                            Color(red: 0.04, green: 0.03, blue: 0.07)
                        ],
                        center: UnitPoint(x: 0.38, y: 0.35),
                        startRadius: 0,
                        endRadius: 169
                    )
                )
                .frame(width: 273, height: 273)

            // ── Specular highlight ───────────────────────────────────
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.white.opacity(0.06), Color.clear],
                        center: UnitPoint(x: 0.3, y: 0.28),
                        startRadius: 0,
                        endRadius: 104
                    )
                )
                .frame(width: 273, height: 273)

            // ── Inner shadow ─────────────────────────────────────────
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.clear, Color.black.opacity(0.55)],
                        center: UnitPoint(x: 0.6, y: 0.75),
                        startRadius: 39,
                        endRadius: 156
                    )
                )
                .frame(width: 273, height: 273)

            // ── Content overlay ──────────────────────────────────────
            VStack(spacing: 0) {

                // Category badge
//                if !title.isEmpty || !taskDescription.isEmpty {
//                    HStack(spacing: 5) {
//                        Image(systemName: categoryConfig.icon)
//                            .font(.system(size: 8, weight: .semibold))
//                        Text(category.rawValue.uppercased())
//                            .font(.system(size: 8, weight: .bold, design: .monospaced))
//                            .tracking(1.5)
//                    }
//                    .foregroundColor(categoryConfig.color)
//                    .padding(.horizontal, 10)
//                    .padding(.vertical, 5)
//                    .background(
//                        Capsule()
//                            .fill(categoryConfig.color.opacity(0.15))
//                            .overlay(
//                                Capsule()
//                                    .strokeBorder(categoryConfig.color.opacity(0.35), lineWidth: 0.5)
//                            )
//                    )
//                    .padding(.bottom, 9)
//                }

                // Title
                if !displayTitle.isEmpty {
                    HStack(alignment: .center, spacing: 5) {  // Changed from .firstTextBaseline
                        Image(systemName: categoryConfig.icon)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(categoryConfig.color)
                        
                        Text(displayTitle)
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.white.opacity(0.92))
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .fill(categoryConfig.color.opacity(0.15))
                            .overlay(
                                Capsule()
                                    .strokeBorder(categoryConfig.color.opacity(1), lineWidth: 1)
                            )
                    )
                    .padding(.bottom, 9)

                }

                // Divider
                if !displayTitle.isEmpty && !displayDescription.isEmpty {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.clear,
                                    Color.white.opacity(0.12),
                                    Color.clear
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 0.5)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 8)
                }

                // Description
                if !displayDescription.isEmpty {
                    Text(displayDescription)
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(.white.opacity(0.55))
                        .multilineTextAlignment(.center)
                        .lineLimit(5)
                        .lineSpacing(2.5)
                }
            }
            .padding(.horizontal, 28)
            .padding(.vertical, -80)
            .frame(width: 273, height: 273)
            .clipShape(Circle())

        }
        .shadow(color: Color(red: 1.0, green: 0.55, blue: 0.1).opacity(0.6), radius: 36)
        .shadow(color: Color(red: 1.0, green: 0.3, blue: 0.0).opacity(0.25), radius: 70)
        .onChange(of: isButtonPressed){_, newIsButtonPressed in
            if !newIsButtonPressed { return }
//            
//            if let task2 = task {
//                task2.isCompleted = true
//                task2.updateCompletionRank()
//                try? modelContext.save()
//            }
            
        }
    }
}

// MARK: - Corona Rays

struct CoronaRaysView: View {
    let rotation: Double
    let rayCount = 24

    var body: some View {
        ZStack {
            ForEach(0..<rayCount, id: \.self) { i in
                let angle   = Double(i) / Double(rayCount) * 360.0
                let isLong  = i % 3 == 0
                let length: CGFloat = isLong ? 124 : (i % 2 == 0 ? 85 : 65)
                let opacity: Double = isLong ? 0.35 : 0.18

                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 1.0, green: 0.75, blue: 0.3).opacity(opacity),
                                Color.clear
                            ],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .frame(width: isLong ? 2.5 : 1.5, height: length)
                    .offset(y: -(143 + length / 2))
                    .rotationEffect(.degrees(angle))
            }
        }
        .rotationEffect(.degrees(rotation))
        .blur(radius: 2.5)
    }
}

// MARK: - Star Field

struct StarFieldView: View {
    let stars: [(CGFloat, CGFloat, CGFloat, Double)] = (0..<120).map { _ in
        (
            CGFloat.random(in: -200...200),
            CGFloat.random(in: -420...420),
            CGFloat.random(in: 0.8...2.5),
            Double.random(in: 0.2...0.9)
        )
    }

    var body: some View {
        ZStack {
            ForEach(0..<stars.count, id: \.self) { i in
                Circle()
                    .fill(Color.white.opacity(stars[i].3))
                    .frame(width: stars[i].2, height: stars[i].2)
                    .offset(x: stars[i].0, y: stars[i].1)
            }
        }
    }
}

// MARK: - Preview

#Preview {
//    EclipseView(
//        taskTitle: "Design Review ",
//        taskDescription: "Go through the latest mockups with the team and collect feedback on the new onboarding flow before Thursday's deadline.",
//        taskCategory: .home
//    )
    EclipseView().modelContainer(makePreviewContainer2())
}
