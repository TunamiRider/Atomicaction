////
////
////import SwiftUI
////
////// MARK: - Animation Phase
////
////enum EclipsePhase {
////    case idle        // Default eclipse state
////    case shrinking   // Moon shrinks, sun reveals
////    case sunRevealed // Sun fully visible, brief pause
////    case returning   // Moon grows back to original size
////}
////
////// MARK: - EclipseView
////
////struct EclipseView: View {
////
////    // Ambient animations
////    @State private var glowPulse: Bool = false
////    @State private var coronaRotation: Double = 0
////    @State private var outerRingScale: CGFloat = 1.0
////
////    // Sequence state
////    @State private var phase: EclipsePhase = .idle
////    @State private var moonScale: CGFloat = 1.0
////    @State private var sunOpacity: Double = 0.0
////    @State private var sunScale: CGFloat = 0.6
////    // Sun animation states
////    @State private var sunBloom: CGFloat = 1.0
////    @State private var buttonOpacity: Double = 1.0
////
////    var body: some View {
////        ZStack {
////            // ── Background ──────────────────────────────────────────
////            RadialGradient(
////                colors: [
////                    Color(red: 0.04, green: 0.02, blue: 0.12),
////                    Color(red: 0.01, green: 0.01, blue: 0.06),
////                    Color.black
////                ],
////                center: .center,
////                startRadius: 0,
////                endRadius: 420
////            )
////            .ignoresSafeArea()
////
////            StarFieldView()
////
////            // ── Outer halo ──────────────────────────────────────────
////            Circle()
////                .fill(
////                    RadialGradient(
////                        colors: [
////                            Color(red: 1.0, green: 0.6, blue: 0.1).opacity(glowPulse ? 0.18 : 0.10),
////                            Color(red: 1.0, green: 0.4, blue: 0.05).opacity(0.05),
////                            Color.clear
////                        ],
////                        center: .center,
////                        startRadius: 120,
////                        endRadius: 260
////                    )
////                )
////                .frame(width: 520, height: 520)
////                .scaleEffect(outerRingScale)
////
////            // ── Corona rays ─────────────────────────────────────────
////            CoronaRaysView(rotation: coronaRotation)
////                .frame(width: 400, height: 400)
////
////            // ── Sun (light-based) ────────────────────────────────────
////            ZStack {
////                // Layer 1: Wide outer warmth — ties into existing corona halo
////                Circle()
////                    .fill(
////                        RadialGradient(
////                            colors: [
////                                Color(red: 1.0, green: 0.65, blue: 0.1).opacity(0.28),
////                                Color(red: 1.0, green: 0.45, blue: 0.0).opacity(0.12),
////                                Color.clear
////                            ],
////                            center: .center,
////                            startRadius: 60,
////                            endRadius: 220
////                        )
////                    )
////                    .frame(width: 440, height: 440)
////                    .scaleEffect(sunBloom)
////                    .blur(radius: 30)
////
////                // Layer 2: Mid warm haze — amber-gold band
////                Circle()
////                    .fill(
////                        RadialGradient(
////                            colors: [
////                                Color(red: 1.0, green: 0.85, blue: 0.35).opacity(0.0),
////                                Color(red: 1.0, green: 0.75, blue: 0.2).opacity(0.55),
////                                Color(red: 1.0, green: 0.55, blue: 0.05).opacity(0.25),
////                                Color.clear
////                            ],
////                            center: .center,
////                            startRadius: 30,
////                            endRadius: 130
////                        )
////                    )
////                    .frame(width: 260, height: 260)
////                    .blur(radius: 14)
////
////                // Layer 3: Inner bright halo — white-gold ring
////                Circle()
////                    .fill(
////                        RadialGradient(
////                            colors: [
////                                Color.clear,
////                                Color(red: 1.0, green: 0.95, blue: 0.6).opacity(glowPulse ? 0.75 : 0.55),
////                                Color(red: 1.0, green: 0.8, blue: 0.3).opacity(0.3),
////                                Color.clear
////                            ],
////                            center: .center,
////                            startRadius: 28,
////                            endRadius: 80
////                        )
////                    )
////                    .frame(width: 160, height: 160)
////                    .blur(radius: 6)
////
////                // Layer 4: Pure white-hot core — just light, no disc edge
////                Circle()
////                    .fill(
////                        RadialGradient(
////                            colors: [
////                                Color.white,
////                                Color(red: 1.0, green: 0.97, blue: 0.82).opacity(0.95),
////                                Color(red: 1.0, green: 0.88, blue: 0.45).opacity(0.6),
////                                Color.clear
////                            ],
////                            center: .center,
////                            startRadius: 0,
////                            endRadius: 52
////                        )
////                    )
////                    .frame(width: 104, height: 104)
////                    .blur(radius: 8)
////
////                // Layer 5: Sparkle point — tiny needle-bright center
////                Circle()
////                    .fill(Color.white)
////                    .frame(width: 18, height: 18)
////                    .blur(radius: 3)
////            }
////            .scaleEffect(sunScale)
////            .opacity(sunOpacity)
////
////            // ── Inner glow ring ─────────────────────────────────────
////            Circle()
////                .fill(
////                    RadialGradient(
////                        colors: [
////                            Color.clear,
////                            Color.clear,
////                            Color(red: 1.0, green: 0.75, blue: 0.3).opacity(glowPulse ? 0.85 : 0.65),
////                            Color(red: 1.0, green: 0.5, blue: 0.1).opacity(0.4),
////                            Color.clear
////                        ],
////                        center: .center,
////                        startRadius: 85,
////                        endRadius: 145
////                    )
////                )
////                .frame(width: 290, height: 290)
////                .blur(radius: 6)
////                .opacity(moonScale > 0.1 ? 1.0 : 0.0)
////
////            // ── Moon disc ────────────────────────────────────────────
////            MoonDisc()
////                .scaleEffect(moonScale)
////                .opacity(moonScale > 0.05 ? 1.0 : 0.0)
////
////            // ── Crescent limb highlight ──────────────────────────────
////            Ellipse()
////                .fill(
////                    LinearGradient(
////                        colors: [
////                            Color(red: 1.0, green: 0.85, blue: 0.4).opacity(glowPulse ? 0.9 : 0.7),
////                            Color(red: 1.0, green: 0.55, blue: 0.1).opacity(0.3),
////                            Color.clear
////                        ],
////                        startPoint: .leading,
////                        endPoint: .trailing
////                    )
////                )
////                .frame(width: 28, height: 180)
////                .offset(x: 97)
////                .blur(radius: 4)
////                .opacity(moonScale > 0.3 ? moonScale : 0)
////
////            // ── Label ────────────────────────────────────────────────
////            VStack {
////                Spacer()
////                Text("TOTAL SOLAR ECLIPSE")
////                    .font(.system(size: 13, weight: .semibold, design: .monospaced))
////                    .tracking(5)
////                    .foregroundStyle(
////                        LinearGradient(
////                            colors: [
////                                Color(red: 1.0, green: 0.8, blue: 0.4),
////                                Color(red: 0.9, green: 0.5, blue: 0.15)
////                            ],
////                            startPoint: .leading,
////                            endPoint: .trailing
////                        )
////                    )
////                    .opacity(0.75)
////                    .padding(.bottom, 52)
////            }
////
////            // ── Tap button ───────────────────────────────────────────
////            VStack {
////                Button(action: startSequence) {
////                    Text("TAP TO ANIMATE")
////                        .font(.system(size: 11, weight: .medium, design: .monospaced))
////                        .tracking(3)
////                        .foregroundColor(Color(red: 1.0, green: 0.8, blue: 0.4).opacity(0.85))
////                        .padding(.horizontal, 18)
////                        .padding(.vertical, 10)
////                        .background(
////                            RoundedRectangle(cornerRadius: 20)
////                                .stroke(Color(red: 1.0, green: 0.6, blue: 0.1).opacity(0.5), lineWidth: 1)
////                        )
////                }
////                .opacity(buttonOpacity)
////                .padding(.top, 60)
////                Spacer()
////            }
////        }
////        .onAppear {
////            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
////                glowPulse = true
////            }
////            withAnimation(.linear(duration: 60).repeatForever(autoreverses: false)) {
////                coronaRotation = 360
////            }
////            withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
////                outerRingScale = 1.06
////            }
////        }
////    }
////
////    // MARK: - Animation Sequence
////
////    func startSequence() {
////        guard phase == .idle else { return }
////
////        withAnimation(.easeOut(duration: 0.3)) {
////            buttonOpacity = 0
////        }
////
////        // ── Phase 1: Moon shrinks → Sun reveals (0 → 2.2s) ──────────
////        phase = .shrinking
////        withAnimation(.easeInOut(duration: 2.2)) {
////            moonScale  = 0.0
////            sunOpacity = 1.0
////            sunScale   = 1.0
////        }
////
////        // ── Phase 2: Sun blooms briefly (2.2s → 3.4s) ───────────────
////        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
////            phase = .sunRevealed
////            withAnimation(.easeOut(duration: 0.4)) { sunBloom = 1.18 }
////            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
////                withAnimation(.easeInOut(duration: 0.5)) { sunBloom = 1.0 }
////            }
////        }
////
////        // ── Phase 3: Moon grows back (3.4s → 5.6s) ──────────────────
////        DispatchQueue.main.asyncAfter(deadline: .now() + 3.4) {
////            phase = .returning
////            withAnimation(.easeInOut(duration: 2.2)) {
////                moonScale  = 1.0
////                sunOpacity = 0.0
////                sunScale   = 0.6
////            }
////        }
////
////        // ── Phase 4: Back to idle (6.0s) ────────────────────────────
////        DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
////            phase    = .idle
////            sunBloom = 1.0
////            withAnimation(.easeIn(duration: 0.5)) {
////                buttonOpacity = 1.0
////            }
////        }
////    }
////
////}
////
////// MARK: - Moon Disc
////
////struct MoonDisc: View {
////    var body: some View {
////        Circle()
////            .fill(
////                RadialGradient(
////                    colors: [
////                        Color(red: 0.18, green: 0.17, blue: 0.22),
////                        Color(red: 0.10, green: 0.09, blue: 0.14),
////                        Color(red: 0.04, green: 0.03, blue: 0.07)
////                    ],
////                    center: UnitPoint(x: 0.38, y: 0.35),
////                    startRadius: 0,
////                    endRadius: 130
////                )
////            )
////            .frame(width: 210, height: 210)
////            .overlay(
////                Circle().fill(
////                    RadialGradient(
////                        colors: [Color.white.opacity(0.06), Color.clear],
////                        center: UnitPoint(x: 0.3, y: 0.28),
////                        startRadius: 0,
////                        endRadius: 80
////                    )
////                )
////            )
////            .overlay(
////                Circle().fill(
////                    RadialGradient(
////                        colors: [Color.clear, Color.black.opacity(0.55)],
////                        center: UnitPoint(x: 0.6, y: 0.75),
////                        startRadius: 30,
////                        endRadius: 120
////                    )
////                )
////            )
////            .shadow(color: Color(red: 1.0, green: 0.55, blue: 0.1).opacity(0.6), radius: 28)
////            .shadow(color: Color(red: 1.0, green: 0.3, blue: 0.0).opacity(0.25), radius: 55)
////    }
////}
////
////// MARK: - Corona Rays
////
////struct CoronaRaysView: View {
////    let rotation: Double
////    let rayCount = 24
////
////    var body: some View {
////        ZStack {
////            ForEach(0..<rayCount, id: \.self) { i in
////                let angle   = Double(i) / Double(rayCount) * 360.0
////                let isLong  = i % 3 == 0
////                let length: CGFloat = isLong ? 95 : (i % 2 == 0 ? 65 : 50)
////                let opacity: Double = isLong ? 0.35 : 0.18
////
////                Rectangle()
////                    .fill(
////                        LinearGradient(
////                            colors: [
////                                Color(red: 1.0, green: 0.75, blue: 0.3).opacity(opacity),
////                                Color.clear
////                            ],
////                            startPoint: .bottom,
////                            endPoint: .top
////                        )
////                    )
////                    .frame(width: isLong ? 2 : 1.2, height: length)
////                    .offset(y: -(110 + length / 2))
////                    .rotationEffect(.degrees(angle))
////            }
////        }
////        .rotationEffect(.degrees(rotation))
////        .blur(radius: 2.5)
////    }
////}
////
////// MARK: - Star Field
////
////struct StarFieldView: View {
////    let stars: [(CGFloat, CGFloat, CGFloat, Double)] = (0..<120).map { _ in
////        (
////            CGFloat.random(in: -200...200),
////            CGFloat.random(in: -420...420),
////            CGFloat.random(in: 0.8...2.5),
////            Double.random(in: 0.2...0.9)
////        )
////    }
////
////    var body: some View {
////        ZStack {
////            ForEach(0..<stars.count, id: \.self) { i in
////                Circle()
////                    .fill(Color.white.opacity(stars[i].3))
////                    .frame(width: stars[i].2, height: stars[i].2)
////                    .offset(x: stars[i].0, y: stars[i].1)
////            }
////        }
////    }
////}
////
////// MARK: - Preview
////
////#Preview {
////    EclipseView()
////}
//
//import SwiftUI
//
//// MARK: - Animation Phase
//
//enum EclipsePhase {
//    case idle        // Default eclipse state
//    case shrinking   // Moon shrinks, sun reveals
//    case sunRevealed // Sun fully visible, brief pause
//    case returning   // Moon grows back to original size
//}
//
//// MARK: - EclipseView
//
//struct EclipseView: View {
//
//    // Task data
//    var taskTitle: String = ""
//    var taskDescription: String = ""
//    var taskCategory: Category = .other
//
//    // Ambient animations
//    @State private var glowPulse: Bool = false
//    @State private var coronaRotation: Double = 0
//    @State private var outerRingScale: CGFloat = 1.0
//
//    // Sequence state
//    @State private var phase: EclipsePhase = .idle
//    @State private var moonScale: CGFloat = 1.0
//    @State private var sunOpacity: Double = 0.0
//    @State private var sunScale: CGFloat = 0.6
//    // Sun animation states
//    @State private var sunBloom: CGFloat = 1.0
//    @State private var buttonOpacity: Double = 1.0
//
//    var body: some View {
//        ZStack {
//            // ── Background ──────────────────────────────────────────
//            RadialGradient(
//                colors: [
//                    Color(red: 0.04, green: 0.02, blue: 0.12),
//                    Color(red: 0.01, green: 0.01, blue: 0.06),
//                    Color.black
//                ],
//                center: .center,
//                startRadius: 0,
//                endRadius: 420
//            )
//            .ignoresSafeArea()
//
//            StarFieldView()
//
//            // ── Outer halo ──────────────────────────────────────────
//            Circle()
//                .fill(
//                    RadialGradient(
//                        colors: [
//                            Color(red: 1.0, green: 0.6, blue: 0.1).opacity(glowPulse ? 0.18 : 0.10),
//                            Color(red: 1.0, green: 0.4, blue: 0.05).opacity(0.05),
//                            Color.clear
//                        ],
//                        center: .center,
//                        startRadius: 120,
//                        endRadius: 260
//                    )
//                )
//                .frame(width: 520, height: 520)
//                .scaleEffect(outerRingScale)
//
//            // ── Corona rays ─────────────────────────────────────────
//            CoronaRaysView(rotation: coronaRotation)
//                .frame(width: 400, height: 400)
//
//            // ── Sun (light-based) ────────────────────────────────────
//            ZStack {
//                // Layer 1: Wide outer warmth — ties into existing corona halo
//                Circle()
//                    .fill(
//                        RadialGradient(
//                            colors: [
//                                Color(red: 1.0, green: 0.65, blue: 0.1).opacity(0.28),
//                                Color(red: 1.0, green: 0.45, blue: 0.0).opacity(0.12),
//                                Color.clear
//                            ],
//                            center: .center,
//                            startRadius: 60,
//                            endRadius: 220
//                        )
//                    )
//                    .frame(width: 440, height: 440)
//                    .scaleEffect(sunBloom)
//                    .blur(radius: 30)
//
//                // Layer 2: Mid warm haze — amber-gold band
//                Circle()
//                    .fill(
//                        RadialGradient(
//                            colors: [
//                                Color(red: 1.0, green: 0.85, blue: 0.35).opacity(0.0),
//                                Color(red: 1.0, green: 0.75, blue: 0.2).opacity(0.55),
//                                Color(red: 1.0, green: 0.55, blue: 0.05).opacity(0.25),
//                                Color.clear
//                            ],
//                            center: .center,
//                            startRadius: 30,
//                            endRadius: 130
//                        )
//                    )
//                    .frame(width: 260, height: 260)
//                    .blur(radius: 14)
//
//                // Layer 3: Inner bright halo — white-gold ring
//                Circle()
//                    .fill(
//                        RadialGradient(
//                            colors: [
//                                Color.clear,
//                                Color(red: 1.0, green: 0.95, blue: 0.6).opacity(glowPulse ? 0.75 : 0.55),
//                                Color(red: 1.0, green: 0.8, blue: 0.3).opacity(0.3),
//                                Color.clear
//                            ],
//                            center: .center,
//                            startRadius: 28,
//                            endRadius: 80
//                        )
//                    )
//                    .frame(width: 160, height: 160)
//                    .blur(radius: 6)
//
//                // Layer 4: Pure white-hot core — just light, no disc edge
//                Circle()
//                    .fill(
//                        RadialGradient(
//                            colors: [
//                                Color.white,
//                                Color(red: 1.0, green: 0.97, blue: 0.82).opacity(0.95),
//                                Color(red: 1.0, green: 0.88, blue: 0.45).opacity(0.6),
//                                Color.clear
//                            ],
//                            center: .center,
//                            startRadius: 0,
//                            endRadius: 52
//                        )
//                    )
//                    .frame(width: 104, height: 104)
//                    .blur(radius: 8)
//
//                // Layer 5: Sparkle point — tiny needle-bright center
//                Circle()
//                    .fill(Color.white)
//                    .frame(width: 18, height: 18)
//                    .blur(radius: 3)
//            }
//            .scaleEffect(sunScale)
//            .opacity(sunOpacity)
//
//            // ── Inner glow ring ─────────────────────────────────────
//            Circle()
//                .fill(
//                    RadialGradient(
//                        colors: [
//                            Color.clear,
//                            Color.clear,
//                            Color(red: 1.0, green: 0.75, blue: 0.3).opacity(glowPulse ? 0.85 : 0.65),
//                            Color(red: 1.0, green: 0.5, blue: 0.1).opacity(0.4),
//                            Color.clear
//                        ],
//                        center: .center,
//                        startRadius: 85,
//                        endRadius: 145
//                    )
//                )
//                .frame(width: 290, height: 290)
//                .blur(radius: 6)
//                .opacity(moonScale > 0.1 ? 1.0 : 0.0)
//
//            // ── Moon disc ────────────────────────────────────────────
//            MoonDisc(
//                title: taskTitle,
//                taskDescription: taskDescription,
//                category: taskCategory
//            )
//                .scaleEffect(moonScale)
//                .opacity(moonScale > 0.05 ? 1.0 : 0.0)
//
//            // ── Crescent limb highlight ──────────────────────────────
//            Ellipse()
//                .fill(
//                    LinearGradient(
//                        colors: [
//                            Color(red: 1.0, green: 0.85, blue: 0.4).opacity(glowPulse ? 0.9 : 0.7),
//                            Color(red: 1.0, green: 0.55, blue: 0.1).opacity(0.3),
//                            Color.clear
//                        ],
//                        startPoint: .leading,
//                        endPoint: .trailing
//                    )
//                )
//                .frame(width: 28, height: 180)
//                .offset(x: 97)
//                .blur(radius: 4)
//                .opacity(moonScale > 0.3 ? moonScale : 0)
//
//            // ── Label ────────────────────────────────────────────────
//            VStack {
//                Spacer()
//                Text("TOTAL SOLAR ECLIPSE")
//                    .font(.system(size: 13, weight: .semibold, design: .monospaced))
//                    .tracking(5)
//                    .foregroundStyle(
//                        LinearGradient(
//                            colors: [
//                                Color(red: 1.0, green: 0.8, blue: 0.4),
//                                Color(red: 0.9, green: 0.5, blue: 0.15)
//                            ],
//                            startPoint: .leading,
//                            endPoint: .trailing
//                        )
//                    )
//                    .opacity(0.75)
//                    .padding(.bottom, 52)
//            }
//
//            // ── Tap button ───────────────────────────────────────────
//            VStack {
//                Button(action: startSequence) {
//                    Text("TAP TO ANIMATE")
//                        .font(.system(size: 11, weight: .medium, design: .monospaced))
//                        .tracking(3)
//                        .foregroundColor(Color(red: 1.0, green: 0.8, blue: 0.4).opacity(0.85))
//                        .padding(.horizontal, 18)
//                        .padding(.vertical, 10)
//                        .background(
//                            RoundedRectangle(cornerRadius: 20)
//                                .stroke(Color(red: 1.0, green: 0.6, blue: 0.1).opacity(0.5), lineWidth: 1)
//                        )
//                }
//                .opacity(buttonOpacity)
//                .padding(.top, 60)
//                Spacer()
//            }
//        }
//        .onAppear {
//            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
//                glowPulse = true
//            }
//            withAnimation(.linear(duration: 60).repeatForever(autoreverses: false)) {
//                coronaRotation = 360
//            }
//            withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
//                outerRingScale = 1.06
//            }
//        }
//    }
//
//    // MARK: - Animation Sequence
//
//    func startSequence() {
//        guard phase == .idle else { return }
//
//        withAnimation(.easeOut(duration: 0.3)) {
//            buttonOpacity = 0
//        }
//
//        // ── Phase 1: Moon shrinks → Sun reveals (0 → 2.2s) ──────────
//        phase = .shrinking
//        withAnimation(.easeInOut(duration: 2.2)) {
//            moonScale  = 0.0
//            sunOpacity = 1.0
//            sunScale   = 1.0
//        }
//
//        // ── Phase 2: Sun blooms briefly (2.2s → 3.4s) ───────────────
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
//            phase = .sunRevealed
//            withAnimation(.easeOut(duration: 0.4)) { sunBloom = 1.18 }
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
//                withAnimation(.easeInOut(duration: 0.5)) { sunBloom = 1.0 }
//            }
//        }
//
//        // ── Phase 3: Moon grows back (3.4s → 5.6s) ──────────────────
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3.4) {
//            phase = .returning
//            withAnimation(.easeInOut(duration: 2.2)) {
//                moonScale  = 1.0
//                sunOpacity = 0.0
//                sunScale   = 0.6
//            }
//        }
//
//        // ── Phase 4: Back to idle (6.0s) ────────────────────────────
//        DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
//            phase    = .idle
//            sunBloom = 1.0
//            withAnimation(.easeIn(duration: 0.5)) {
//                buttonOpacity = 1.0
//            }
//        }
//    }
//
//}
//
//// MARK: - Category
//
//// Mirror your Category enum here (extend as needed)
////enum Category: String, CaseIterable {
////    case work       = "Work"
////    case personal   = "Personal"
////    case health     = "Health"
////    case finance    = "Finance"
////    case learning   = "Learning"
////    case social     = "Social"
////    case other      = "Other"
////
////    var icon: String {
////        switch self {
////        case .work:     return "briefcase.fill"
////        case .personal: return "person.fill"
////        case .health:   return "heart.fill"
////        case .finance:  return "dollarsign.circle.fill"
////        case .learning: return "book.fill"
////        case .social:   return "bubble.left.fill"
////        case .other:    return "circle.fill"
////        }
////    }
////
////    var color: Color {
////        switch self {
////        case .work:     return Color(red: 0.4, green: 0.7, blue: 1.0)
////        case .personal: return Color(red: 0.8, green: 0.6, blue: 1.0)
////        case .health:   return Color(red: 1.0, green: 0.5, blue: 0.6)
////        case .finance:  return Color(red: 0.5, green: 0.9, blue: 0.6)
////        case .learning: return Color(red: 1.0, green: 0.8, blue: 0.3)
////        case .social:   return Color(red: 1.0, green: 0.6, blue: 0.3)
////        case .other:    return Color(white: 0.6)
////        }
////    }
////}
//
//// MARK: - Moon Disc
//
//struct MoonDisc: View {
//    var title: String = ""
//    var taskDescription: String = ""
//    var category: Category = .other
//    var categoryConfig: CategoryConfig {
//        CategoryConfig.from(category)
//    }
//    
//
//    // Enforce character limits
//    private var displayTitle: String {
//        String(title.prefix(30))
//    }
//    private var displayDescription: String {
//        String(taskDescription.prefix(280))
//    }
//
//    var body: some View {
//        ZStack {
//            // ── Base sphere ──────────────────────────────────────────
//            Circle()
//                .fill(
//                    RadialGradient(
//                        colors: [
//                            Color(red: 0.18, green: 0.17, blue: 0.22),
//                            Color(red: 0.10, green: 0.09, blue: 0.14),
//                            Color(red: 0.04, green: 0.03, blue: 0.07)
//                        ],
//                        center: UnitPoint(x: 0.38, y: 0.35),
//                        startRadius: 0,
//                        endRadius: 130
//                    )
//                )
//                .frame(width: 210, height: 210)
//
//            // ── Specular highlight ───────────────────────────────────
//            Circle()
//                .fill(
//                    RadialGradient(
//                        colors: [Color.white.opacity(0.06), Color.clear],
//                        center: UnitPoint(x: 0.3, y: 0.28),
//                        startRadius: 0,
//                        endRadius: 80
//                    )
//                )
//                .frame(width: 210, height: 210)
//
//            // ── Inner shadow ─────────────────────────────────────────
//            Circle()
//                .fill(
//                    RadialGradient(
//                        colors: [Color.clear, Color.black.opacity(0.55)],
//                        center: UnitPoint(x: 0.6, y: 0.75),
//                        startRadius: 30,
//                        endRadius: 120
//                    )
//                )
//                .frame(width: 210, height: 210)
//
//            // ── Content overlay (clipped to circle) ──────────────────
//            VStack(spacing: 0) {
//
//                // Category badge
//                if !title.isEmpty || !taskDescription.isEmpty {
//                    HStack(spacing: 4) {
//                        Image(systemName: categoryConfig.icon)
//                            .font(.system(size: 7, weight: .semibold))
//                        Text(category.rawValue.uppercased())
//                            .font(.system(size: 7, weight: .bold, design: .monospaced))
//                            .tracking(1.5)
//                    }
//                    .foregroundColor(categoryConfig.color)
//                    .padding(.horizontal, 8)
//                    .padding(.vertical, 4)
//                    .background(
//                        Capsule()
//                            .fill(categoryConfig.color.opacity(0.15))
//                            .overlay(
//                                Capsule()
//                                    .strokeBorder(categoryConfig.color.opacity(0.35), lineWidth: 0.5)
//                            )
//                    )
//                    .padding(.bottom, 7)
//                }
//
//                // Title
//                if !displayTitle.isEmpty {
//                    Text(displayTitle)
//                        .font(.system(size: 13, weight: .semibold, design: .rounded))
//                        .foregroundColor(.white.opacity(0.92))
//                        .multilineTextAlignment(.center)
//                        .lineLimit(2)
//                        .padding(.bottom, 6)
//                }
//
//                // Thin divider
//                if !displayTitle.isEmpty && !displayDescription.isEmpty {
//                    Rectangle()
//                        .fill(
//                            LinearGradient(
//                                colors: [
//                                    Color.clear,
//                                    Color.white.opacity(0.12),
//                                    Color.clear
//                                ],
//                                startPoint: .leading,
//                                endPoint: .trailing
//                            )
//                        )
//                        .frame(height: 0.5)
//                        .padding(.horizontal, 16)
//                        .padding(.bottom, 6)
//                }
//
//                // Description
//                if !displayDescription.isEmpty {
//                    Text(displayDescription)
//                        .font(.system(size: 9, weight: .regular, design: .rounded))
//                        .foregroundColor(.white.opacity(0.55))
//                        .multilineTextAlignment(.center)
//                        .lineLimit(5)
//                        .lineSpacing(2)
//                }
//            }
//            .padding(.horizontal, 22)
//            .frame(width: 210, height: 210)
//            .clipShape(Circle())
//        }
//        .shadow(color: Color(red: 1.0, green: 0.55, blue: 0.1).opacity(0.6), radius: 28)
//        .shadow(color: Color(red: 1.0, green: 0.3, blue: 0.0).opacity(0.25), radius: 55)
//    }
//}
//
//// MARK: - Corona Rays
//
//struct CoronaRaysView: View {
//    let rotation: Double
//    let rayCount = 24
//
//    var body: some View {
//        ZStack {
//            ForEach(0..<rayCount, id: \.self) { i in
//                let angle   = Double(i) / Double(rayCount) * 360.0
//                let isLong  = i % 3 == 0
//                let length: CGFloat = isLong ? 95 : (i % 2 == 0 ? 65 : 50)
//                let opacity: Double = isLong ? 0.35 : 0.18
//
//                Rectangle()
//                    .fill(
//                        LinearGradient(
//                            colors: [
//                                Color(red: 1.0, green: 0.75, blue: 0.3).opacity(opacity),
//                                Color.clear
//                            ],
//                            startPoint: .bottom,
//                            endPoint: .top
//                        )
//                    )
//                    .frame(width: isLong ? 2 : 1.2, height: length)
//                    .offset(y: -(110 + length / 2))
//                    .rotationEffect(.degrees(angle))
//            }
//        }
//        .rotationEffect(.degrees(rotation))
//        .blur(radius: 2.5)
//    }
//}
//
//// MARK: - Star Field
//
//struct StarFieldView: View {
//    let stars: [(CGFloat, CGFloat, CGFloat, Double)] = (0..<120).map { _ in
//        (
//            CGFloat.random(in: -200...200),
//            CGFloat.random(in: -420...420),
//            CGFloat.random(in: 0.8...2.5),
//            Double.random(in: 0.2...0.9)
//        )
//    }
//
//    var body: some View {
//        ZStack {
//            ForEach(0..<stars.count, id: \.self) { i in
//                Circle()
//                    .fill(Color.white.opacity(stars[i].3))
//                    .frame(width: stars[i].2, height: stars[i].2)
//                    .offset(x: stars[i].0, y: stars[i].1)
//            }
//        }
//    }
//}
//
//// MARK: - Preview
//
//#Preview {
//    
//    EclipseView(
//        taskTitle: "Design Review",
//        taskDescription: "Go through the latest mockups with the team and collect feedback on the new onboarding flow before Thursday's deadline.",
//        taskCategory: .work
//    )
//}

import SwiftUI

// MARK: - Animation Phase

enum EclipsePhase {
    case idle        // Default eclipse state
    case shrinking   // Moon shrinks, sun reveals
    case sunRevealed // Sun fully visible, brief pause
    case returning   // Moon grows back to original size
}

// MARK: - EclipseView

struct EclipseView: View {

    // Task data
    var taskTitle: String = ""
    var taskDescription: String = ""
    var taskCategory: Category = .other

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

    var body: some View {
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
                endRadius: 520
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
                        startRadius: 160,
                        endRadius: 340
                    )
                )
                .frame(width: 680, height: 680)
                .scaleEffect(outerRingScale)

            // ── Corona rays ─────────────────────────────────────────
            CoronaRaysView(rotation: coronaRotation)
                .frame(width: 520, height: 520)

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
                            startRadius: 78,
                            endRadius: 286
                        )
                    )
                    .frame(width: 572, height: 572)
                    .scaleEffect(sunBloom)
                    .blur(radius: 30)

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
                            startRadius: 39,
                            endRadius: 169
                        )
                    )
                    .frame(width: 338, height: 338)
                    .blur(radius: 14)

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
                            startRadius: 36,
                            endRadius: 104
                        )
                    )
                    .frame(width: 208, height: 208)
                    .blur(radius: 6)

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
                            endRadius: 68
                        )
                    )
                    .frame(width: 136, height: 136)
                    .blur(radius: 8)

                // Layer 5: Sparkle point
                Circle()
                    .fill(Color.white)
                    .frame(width: 22, height: 22)
                    .blur(radius: 3)
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
                        startRadius: 110,
                        endRadius: 188
                    )
                )
                .frame(width: 376, height: 376)
                .blur(radius: 6)
                .opacity(moonScale > 0.1 ? 1.0 : 0.0)

            // ── Moon disc ────────────────────────────────────────────
            MoonDisc(
                title: taskTitle,
                taskDescription: taskDescription,
                category: taskCategory
            )
            .scaleEffect(moonScale)
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
                .frame(width: 36, height: 234)
                .offset(x: 126)
                .blur(radius: 4)
                .opacity(moonScale > 0.3 ? moonScale : 0)

            // ── Label ────────────────────────────────────────────────
            VStack {
                Spacer()
                Text("TOTAL SOLAR ECLIPSE")
                    .font(.system(size: 13, weight: .semibold, design: .monospaced))
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
                    .padding(.bottom, 52)
            }

            // ── Tap button ───────────────────────────────────────────
            VStack {
                Button(action: startSequence) {
                    Text("TAP TO ANIMATE")
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .tracking(3)
                        .foregroundColor(Color(red: 1.0, green: 0.8, blue: 0.4).opacity(0.85))
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color(red: 1.0, green: 0.6, blue: 0.1).opacity(0.5), lineWidth: 1)
                        )
                }
                .opacity(buttonOpacity)
                .padding(.top, 60)
                Spacer()
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                glowPulse = true
            }
            withAnimation(.linear(duration: 60).repeatForever(autoreverses: false)) {
                coronaRotation = 360
            }
            withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
                outerRingScale = 1.06
            }
        }
    }

    // MARK: - Animation Sequence

    func startSequence() {
        guard phase == .idle else { return }

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
        }

        // ── Phase 3: Moon grows back (3.4s → 5.6s) ──────────────────
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.4) {
            phase = .returning
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
            }
        }
    }

}

// MARK: - Moon Disc

struct MoonDisc: View {
    var title: String = ""
    var taskDescription: String = ""
    var category: Category = .other
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
    EclipseView(
        taskTitle: "Design Review ",
        taskDescription: "Go through the latest mockups with the team and collect feedback on the new onboarding flow before Thursday's deadline.",
        taskCategory: .home
    )
}
