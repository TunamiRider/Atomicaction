//
//  ScheduledSlot.swift
//  Atomicaction
//
//  Created by Yuki Suzuki on 4/6/26.
//
import SwiftUI
import _SwiftData_SwiftUI

struct TimeSlot: Hashable {
    let hour: Int
    let minute: Int  // always 0, 10, 20, 30, 40, or 50
    var title: String? = nil
    
    static func == (lhs: TimeSlot, rhs: TimeSlot) -> Bool {
        lhs.hour == rhs.hour && lhs.minute == rhs.minute
    }
    func hash(into hasher: inout Hasher){
        hasher.combine(hour)
        hasher.combine(minute)
    }

    // All 10-min slots in a day (144 total)
    static var allSlots: [TimeSlot] {
        (0..<24).flatMap { hour in
            [0, 10, 20, 30, 40, 50].map { minute in
                TimeSlot(hour: hour, minute: minute)
            }
        }
    }

    // Convert a Date to the nearest 10-min slot
    static func from(_ date: Date) -> TimeSlot {
        let cal = Calendar.current
        let hour = cal.component(.hour, from: date)
        let minute = cal.component(.minute, from: date)
        let snapped = (minute / 10) * 10
        return TimeSlot(hour: hour, minute: snapped)
    }

    // Slots occupied by a task (start + duration in 10-min blocks)
    func occupiedSlots(durationMinutes: Int, title: String? = nil) -> [TimeSlot] {
        let count = max(1, durationMinutes / 10)
        return (0..<count).compactMap { i in
            let totalMinutes = hour * 60 + minute + i * 10
            guard totalMinutes < 24 * 60 else { return nil }
            
            var slot = TimeSlot(hour: totalMinutes / 60, minute: totalMinutes % 60)
            if i == 0 { slot.title = title }  // only set on first slot
            return slot
        }
    }

    // Convert back to a Date (today)
    func toDate() -> Date {
        Calendar.current.date(
            bySettingHour: hour, minute: minute, second: 0, of: .now
        ) ?? .now
    }

    // Display string e.g. "9:30 am"
    var displayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: toDate()).lowercased()
    }
    
}


//let proposed = TimeSlot.from(pickedDate)
//if hasConflict(newStart: proposed, newDuration: 30, existingTasks: tasks) {
//    // show conflict warning
//} else {
//    task.scheduledAt = proposed.toDate()
//}

// MARK: - TimeSlotPickerView

struct TimeSlotPickerView: View {
    let existingTasks: [Task]
    @Binding var selectedSlot: TimeSlot?
    @Binding var selectedDuration: Int  // in minutes, multiples of 10

    private let slotHeight: CGFloat = 25
    private let hourLabelWidth: CGFloat = 48
    private let hours = Array(5...21)  // 7am - 9pm

    private var occupiedSlots: Set<TimeSlot> {
        var set = Set<TimeSlot>()
        for task in existingTasks {
            guard let scheduled = task.scheduledAt,
                  let duration = task.durationMinutes else { continue }
            let slots = TimeSlot.from(scheduled).occupiedSlots(durationMinutes: duration, title: task.title)

            slots.forEach { set.insert($0) }
        }
        return set
    }

    private func isOccupied(_ slot: TimeSlot) -> Bool {
        occupiedSlots.contains(slot)
    }

    private func isSelected(_ slot: TimeSlot) -> Bool {
        guard let start = selectedSlot else { return false }
        let selected = Set(start.occupiedSlots(durationMinutes: selectedDuration))
        return selected.contains(slot)
    }

    private func hasConflict(for slot: TimeSlot) -> Bool {
        guard let start = selectedSlot else { return false }
        let proposed = Set(start.occupiedSlots(durationMinutes: selectedDuration))
        return proposed.contains(slot) && isOccupied(slot)
    }

    var body: some View {
        ScrollView {
            HStack(alignment: .top, spacing: 0) {

                // ── Hour labels ──────────────────────────────────────
                VStack(alignment: .trailing, spacing: 0) {
                    ForEach(hours, id: \.self) { hour in
                        Text(hourLabel(hour))
                            .font(AppConsts.appFont16)
                            .foregroundColor(.white.opacity(0.8))
                            .frame(height: slotHeight * 6)  // 6 ten-min slots per hour
                            .frame(width: hourLabelWidth, alignment: .trailing)
                            .padding(.trailing, 8)
                    }
                }

                // ── Slot column ──────────────────────────────────────
                VStack(spacing: 0) {
                    ForEach(hours, id: \.self) { hour in
                        ForEach([0, 10, 20, 30, 40, 50], id: \.self) { minute in
                            let slot = TimeSlot(hour: hour, minute: minute)
                            let occuliedSlot = occupiedSlots.first(where: {$0 == slot})
                            SlotCell(
                                slot: occuliedSlot ?? slot,
                                isOccupied: isOccupied(slot),
                                isSelected: isSelected(slot),
                                hasConflict: hasConflict(for: slot),
                                isHourBoundary: minute == 0,
                                slotHeight: slotHeight
                            )
                            .onTapGesture {
                                if !isOccupied(slot) {
                                    selectedSlot = slot
                                }
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 8)
        }
    }

    private func hourLabel(_ hour: Int) -> String {
        let h = hour > 12 ? hour - 12 : hour
        let ampm = hour >= 12 ? "pm" : "am"
        return "\(h)\(ampm)"
    }
}

// MARK: - SlotCell

struct SlotCell: View {
    let slot: TimeSlot
    let isOccupied: Bool
    let isSelected: Bool
    let hasConflict: Bool
    let isHourBoundary: Bool
    let slotHeight: CGFloat
    

    var body: some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .fill(backgroundColor)
                .frame(height: slotHeight)
                .overlay(alignment: .top) {

                    if isHourBoundary {
                        Rectangle()
                            .fill(Color.white.opacity(0.7))
                            .frame(height: 0.5)
                    } else {
                        Rectangle()
                            .fill(Color.white.opacity(0.4))
                            .frame(height: 0.5)
                    }
                }

            if isOccupied && !isSelected {
                Rectangle()
                    .fill(Color.orange.opacity(0.55))
                    .padding(.horizontal, 4)
                    .frame(height: slotHeight - 2)
                    .cornerRadius(2)
            }

            if isSelected {
                Rectangle()
                    .fill(hasConflict ? Color.red.opacity(0.65) : Color(hex: "#3d8ef0").opacity(0.55))
                    .padding(.horizontal, 4)
                    .frame(height: slotHeight - 2)
                    .cornerRadius(2)
            }
            // ── Title on first slot ──────────────────────────────────
            if let title = slot.title {
                Text(title)
                    .font(AppConsts.appFont16)
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .padding(.horizontal, 8)
            }
        }
    }

//    private var backgroundColor: Color {
//        if hasConflict { return Color.red.opacity(0.08) }
//        if isSelected { return Color.blue.opacity(0.08) }
//        if isOccupied { return Color.orange.opacity(0.08) }
//        return Color.clear
//    }
    // In SlotCell — backgroundColor
    private var backgroundColor: Color {
        if hasConflict { return Color.red.opacity(0.15) }
        if isSelected  { return Color(hex: "#1a2a3a") }   // deep blue tint
        if isOccupied  { return Color(hex: "#2a1f0f") }   // deep amber tint
        return Color.clear
    }
}

// MARK: - Duration Stepper

struct DurationStepperView: View {
    @Binding var duration: Int  // minutes

    var body: some View {
        HStack(spacing: 12) {
            Text("duration")
                .font(AppConsts.appFont16)
                .foregroundColor(.white)

            Button(action: { if duration > 10 { duration -= 10 } }) {
                Image(systemName: "minus.circle")
            }

            Text("\(duration) min")
                .font(AppConsts.appFont16)
                .foregroundColor(.white)
                .frame(minWidth: 64)

            Button(action: { if duration < 180 { duration += 10 } }) {
                Image(systemName: "plus.circle")
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}

// MARK: - Usage example

struct ScheduleTaskSheet: View {
    //let tasks: [Task]
    @Query(filter: #Predicate<Task> {$0.isRoutine}, sort: \Task.scheduledAt, order: .forward) private var tasks2:[Task]
    // @Query(filter: #Predicate<Task> { $0.isCompleted }, sort: \Task.order) private var tasks2: [Task]
    @Environment(\.modelContext) private var modelContext
    @Binding var selectedSlot: TimeSlot?
    @Binding var selectedDuration: Int
    @State var showAddRoutine: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            DurationStepperView(duration: $selectedDuration)

            Divider().overlay(Color.white.opacity(0.12))

            TimeSlotPickerView(
                existingTasks: tasks2,
                selectedSlot: $selectedSlot,
                selectedDuration: $selectedDuration
            )

            if let slot = selectedSlot {
                Divider()
                HStack {
                    Text("\(slot.displayString) · \(selectedDuration) min")
                        .font(AppConsts.appFont14)
                        .foregroundColor(.white)
                    Spacer()
                    Text(occupiedConflict ? "conflict" : "available")
                        .font(AppConsts.appFont12)
                        .foregroundColor(occupiedConflict ? .red : .green)
                    
                    Button(action: {
                        showAddRoutine = true
                    }) {
                        HStack {
                            Text("Add Routine")
                                .font(AppConsts.appFont12)
                        }
                        .foregroundStyle(occupiedConflict ? .red : .green)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(occupiedConflict ? Color.red.opacity(0.1) : Color.green.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                                        .stroke(occupiedConflict ? Color.red.opacity(0.3) : Color.green.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }.disabled(occupiedConflict)
                
                }
                .padding(.horizontal, 28)
                .padding(.vertical, 10)
            }
        }
        .background(Color(hex: "#111214"))
        .sheet(isPresented: $showAddRoutine){
            AddRoutine(scheduledAt: selectedSlot?.toDate() ?? .now, durationMinutes: selectedDuration).presentationDetents([.large])
        }

    }
    private func hasConflict(newStart: TimeSlot, newDuration: Int, existingTasks: [Task]) -> Bool {
        let newSlots = Set(newStart.occupiedSlots(durationMinutes: newDuration))
    
        for task in existingTasks {
            guard let scheduledAt = task.scheduledAt,
                  let duration = task.durationMinutes else { continue }
            let existingSlots = Set(TimeSlot.from(scheduledAt)
                .occupiedSlots(durationMinutes: duration))
            if !newSlots.isDisjoint(with: existingSlots) {
                return true
            }
        }
        return false
    }
    private var occupiedConflict: Bool {
        guard let slot = selectedSlot else { return false }
        return hasConflict(newStart: slot, newDuration: selectedDuration, existingTasks: tasks2)
    }
}

@MainActor
func makePreviewContainer2() -> ModelContainer {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Task.self, configurations: config)
    let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: .now)!
    let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: .now)!
    
    
    let thrtyMinuteFromNow = Date.now.addingTimeInterval(60 * 30)
    let sixtyMinuteFromNow = Date.now.addingTimeInterval(60 * 60)
    
    let fourPM = Calendar.current.date(bySettingHour: 16, minute: 0, second: 0, of: Date())!
    let fourPMandThirdtymin=Calendar.current.date(bySettingHour: 16, minute: 30, second: 0, of: Date())!
    
    let fivePM=Calendar.current.date(bySettingHour: 17, minute: 10, second: 0, of: Date())!
    let sampleTasks = [
        Task(timestamp: .now, title: "Evening Meditation2", task_description: "15 minutes mindfulness session2",isRoutine: false, category: .other, isCompleted: false, dueDate: fivePM, scheduledAt: fivePM, durationMinutes: 20),
        
        Task(timestamp: .now, title: "Morning Run", task_description: "5km around the park", isRoutine: true, category: .personal, isCompleted: true, dueDate: tomorrow, scheduledAt: fourPM, durationMinutes: 30),
        
        Task(timestamp: .now, title: "Buy Groceries", task_description: "Milk, eggs, bread, and fruits", isRoutine: true, category: .home, isCompleted: true, dueDate: tomorrow, scheduledAt: fourPMandThirdtymin, durationMinutes: 30),
        
        Task(timestamp: .now, title: "Team Meeting", task_description: "Weekly sync with the dev team", isRoutine: false, category: .work, dueDate: yesterday),
        
    ]
    
    for (index, task) in sampleTasks.enumerated() {
        task.order = index
        container.mainContext.insert(task)
    }
    
    return container
}
#Preview {
    @Previewable @State var selectedSlot: TimeSlot? = nil
    @Previewable @State var selectedDuration: Int = 30
    ScheduleTaskSheet(
        //tasks: mockTasks,
        selectedSlot: $selectedSlot,
        selectedDuration: $selectedDuration
    ).modelContainer(makePreviewContainer())
    
//    struct PreviewWrapper: View {
//        @State private var selectedSlot: TimeSlot? = nil
//        @State private var selectedDuration: Int = 30
//
//        // Mock tasks
//        let mockTasks: [Task] = {
//            let now = Calendar.current
//            func date(_ h: Int, _ m: Int) -> Date {
//                now.date(bySettingHour: h, minute: m, second: 0, of: .now)!
//            }
//            return [
//                Task(timestamp: .now, title: "standup", task_description: "test1",
//                     isRoutine: true, category: .work,
//                     scheduledAt: date(9, 0), durationMinutes: 30),
//                Task(timestamp: .now, title: "deep work", task_description: "test1",
//                     isRoutine: true, category: .work,
//                     scheduledAt: date(10, 0), durationMinutes: 90),
//                Task(timestamp: .now, title: "lunch", task_description: "test1",
//                     isRoutine: true, category: .other,
//                     scheduledAt: date(12, 0), durationMinutes: 60),
//                Task(timestamp: .now, title: "gym", task_description: "test1",
//                     isRoutine: true, category: .home,
//                     scheduledAt: date(17, 0), durationMinutes: 60),
//            ]
//        }()
//
//        var body: some View {
//            ScheduleTaskSheet(
//                //tasks: mockTasks,
//                selectedSlot: $selectedSlot,
//                selectedDuration: $selectedDuration
//            ).modelContainer(makePreviewContainer2())
//        }
//    }
//    return PreviewWrapper()
}
