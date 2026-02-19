import SwiftUI

// MARK: - ToastOverlayView
// Root SwiftUI view with slide/spring animation.

struct ToastOverlayView: View {
    @ObservedObject var manager = NotificationManager.shared
    @State private var animateIn = false
    @State private var spriteAnimating = true
    @State private var spriteStopTask: DispatchWorkItem?

    var body: some View {
        ZStack {
            if let payload = manager.currentPayload, manager.isVisible {
                ToastContentView(
                    payload: payload,
                    isAnimating: spriteAnimating,
                    onTap: {
                        manager.executeAction()
                    }
                )
                .offset(y: animateIn ? 0 : -80)
                .opacity(animateIn ? 1.0 : 0.0)
                .animation(
                    animateIn
                        ? .spring(response: 0.45, dampingFraction: 0.72, blendDuration: 0)
                        : .easeIn(duration: 0.25),
                    value: animateIn
                )
                .transition(.identity)
                .onAppear {
                    withAnimation {
                        animateIn = true
                    }
                    startSpriteTimer(duration: payload.effectiveDuration)
                }
                .onChange(of: payload.message) { _ in
                    // Content updated — restart animation
                    spriteAnimating = true
                    if let p = manager.currentPayload {
                        startSpriteTimer(duration: p.effectiveDuration)
                    }
                }
            }
        }
        .frame(width: 420, height: 64)
        .onChange(of: manager.isVisible) { visible in
            if visible {
                withAnimation {
                    animateIn = true
                }
            } else {
                withAnimation(.easeIn(duration: 0.25)) {
                    animateIn = false
                }
                spriteAnimating = false
                spriteStopTask?.cancel()
            }
        }
    }

    private func startSpriteTimer(duration: Double) {
        spriteStopTask?.cancel()
        spriteAnimating = true
        let stopDelay = min(duration * 0.45, 1.5)
        let task = DispatchWorkItem { [self] in
            spriteAnimating = false
        }
        spriteStopTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + stopDelay, execute: task)
    }
}
