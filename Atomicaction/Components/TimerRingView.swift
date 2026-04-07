//
//  TimerRingView.swift
//  Atomicaction
//
//  Created by Yuki Suzuki on 4/5/26.
//

// MARK: - Timer Ring
import SwiftUI
internal import Combine
import SwiftData
//private typealias AsyncTask = _Concurrency.Task
//struct TimerRingView: View {
//    let progress: Double      // 1.0 → 0.0
//    let glowPulse: Bool
//    let size: CGFloat         // outer diameter of the ring
//
//    private let tickCount = 60
//    private let strokeWidth: CGFloat = 3.5
//    private let tickLength: CGFloat = 8
//
//    var body: some View {
//        ZStack {
//            // ── Tick marks ───────────────────────────────────────────
//            ForEach(0..<tickCount, id: \.self) { i in
//                let angle = Double(i) / Double(tickCount) * 360.0
//                let isMajor = i % 5 == 0
//                let tickH: CGFloat = isMajor ? tickLength * 1.6 : tickLength
//                let opacity: Double = isMajor ? 0.55 : 0.28
//
//                Rectangle()
//                    .fill(Color(red: 1.0, green: 0.75, blue: 0.3).opacity(opacity))
//                    .frame(width: isMajor ? 2.0 : 1.0, height: tickH)
//                    .offset(y: -(size / 2 + tickH / 2 + 4))
//                    .rotationEffect(.degrees(angle))
//            }
//
//            // ── Background track ─────────────────────────────────────
//            Circle()
//                .stroke(
//                    Color(red: 1.0, green: 0.55, blue: 0.1).opacity(0.12),
//                    lineWidth: strokeWidth
//                )
//                .frame(width: size, height: size)
//
//            // ── Progress arc ─────────────────────────────────────────
//            Circle()
//                .trim(from: 0, to: progress)
//                .stroke(
//                    AngularGradient(
//                        colors: [
//                            Color(red: 1.0, green: 0.85, blue: 0.3),
//                            Color(red: 1.0, green: 0.55, blue: 0.1),
//                            Color(red: 1.0, green: 0.85, blue: 0.3)
//                        ],
//                        center: .center,
//                        startAngle: .degrees(-90),
//                        endAngle: .degrees(270)
//                    ),
//                    style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round)
//                )
//                .frame(width: size, height: size)
//                .rotationEffect(.degrees(-90))
//                .shadow(color: Color(red: 1.0, green: 0.65, blue: 0.1)
//                            .opacity(glowPulse ? 0.9 : 0.6), radius: 6)
//
//            // ── Tip dot at the leading edge ──────────────────────────
//            if progress > 0.01 {
//                let tipAngle = (progress * 360.0) - 90.0
//                let rad = tipAngle * .pi / 180.0
//                let r = size / 2
//                Circle()
//                    .fill(Color.white)
//                    .frame(width: strokeWidth * 2.2, height: strokeWidth * 2.2)
//                    .offset(x: r * cos(rad), y: r * sin(rad))
//                    .shadow(color: Color(red: 1.0, green: 0.8, blue: 0.3)
//                                .opacity(glowPulse ? 1.0 : 0.7), radius: 8)
//            }
//        }
//    }
//}


struct TimerRingView: View {
    //let taskId: PersistentIdentifier?
    let scheduledAt: Date?
    let durationMinutes: Int?
    let glowPulse: Bool
    let size: CGFloat

    @State private var progress: Double = 1.0

    private let tickCount = 60
    private let strokeWidth: CGFloat = 3.5
    private let tickLength: CGFloat = 8
    @Binding  var isButtonPressed: Bool
    let onTimerComplete: ()->Void

    private func computeProgress() -> Double {
        guard let scheduled = scheduledAt,
              let duration = durationMinutes, duration > 0 else { return 1.0 }
        let end = scheduled.addingTimeInterval(Double(duration) * 60)
        let total = Double(duration) * 60
        let remaining = end.timeIntervalSinceNow
        return max(0, min(1, remaining / total))
    }

    var body: some View {
        ZStack {
            // ── Tick marks ───────────────────────────────────────────
            ForEach(0..<tickCount, id: \.self) { i in
                let angle = Double(i) / Double(tickCount) * 360.0
                let isMajor = i % 5 == 0
                let tickH: CGFloat = isMajor ? tickLength * 1.6 : tickLength
                let opacity: Double = isMajor ? 0.55 : 0.28

                Rectangle()
                    .fill(Color(red: 1.0, green: 0.75, blue: 0.3).opacity(opacity))
                    .frame(width: isMajor ? 2.0 : 1.0, height: tickH)
                    .offset(y: -(size / 2 + tickH / 2 + 4))
                    .rotationEffect(.degrees(angle))
            }

            // ── Background track ─────────────────────────────────────
            Circle()
                .stroke(
                    Color(red: 1.0, green: 0.55, blue: 0.1).opacity(0.12),
                    lineWidth: strokeWidth
                )
                .frame(width: size, height: size)

            // ── Progress arc ─────────────────────────────────────────
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        colors: [
                            Color(red: 1.0, green: 0.85, blue: 0.3),
                            Color(red: 1.0, green: 0.55, blue: 0.1),
                            Color(red: 1.0, green: 0.85, blue: 0.3)
                        ],
                        center: .center,
                        startAngle: .degrees(-90),
                        endAngle: .degrees(270)
                    ),
                    style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round)
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))
                .shadow(color: Color(red: 1.0, green: 0.65, blue: 0.1)
                            .opacity(glowPulse ? 0.9 : 0.6), radius: 6)

            // ── Tip dot at the leading edge ──────────────────────────
            if progress > 0.01 {
                let tipAngle = (progress * 360.0) - 90.0
                let rad = tipAngle * .pi / 180.0
                let r = size / 2
                Circle()
                    .fill(Color.white)
                    .frame(width: strokeWidth * 2.2, height: strokeWidth * 2.2)
                    .offset(x: r * cos(rad), y: r * sin(rad))
                    .shadow(color: Color(red: 1.0, green: 0.8, blue: 0.3)
                                .opacity(glowPulse ? 1.0 : 0.7), radius: 8)
            }
        }
        .onAppear {
            progress = computeProgress()
        }
        .onChange(of: scheduledAt) { _, _ in
            progress = 1.0  // snap to full immediately
        }
        .onChange(of: durationMinutes) { _, _ in
            progress = 1.0
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            progress = computeProgress()
            if progress <= 0 {
                onTimerComplete()
            }
        }
        //test
//        .task(id: taskId) {
//            progress = 1.0
//            while true {
//                do {
//                    try await AsyncTask.sleep(nanoseconds: 1_000_000_000)
//                    progress = computeProgress()
//                } catch {
//                    break
//                }
//            }
//        }
    }
}
