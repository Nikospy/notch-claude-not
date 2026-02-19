import Foundation

// MARK: - MessageVariants
// Fun, Anthropic-vibe message variants per notification kind.
// When no explicit message is provided, a random one is picked.

struct MessageVariants {

    // MARK: - Waiting
    static let waiting: [String] = [
        "Claude czeka na Twoją decyzję",
        "Hej, potrzebuję Twojego inputu ✋",
        "Claude zamyślił się… i czeka na Ciebie",
        "Twój ruch, człowieku 🎲",
        "Claude wisi na Twojej odpowiedzi",
        "Pauza. Piłka po Twojej stronie",
        "Claude medytuje… ale potrzebuje wskazówki",
        "*tipuje palcami po biurku* …czekam",
        "Claude zrobił herbatę i czeka ☕",
        "Deliberuję, ale decyzja jest Twoja",
        "Claude tu jest. Cierpliwie. Spokojnie. Czeka.",
        "Ping! Claude potrzebuje chwili uwagi",
        "Wstrzymałem się — Twoja kolej 🤔",
        "Claude patrzy w okno i czeka na znak",
        "Potrzebuję danych od człowieka w pętli",
    ]

    // MARK: - Success
    static let success: [String] = [
        "Gotowe! Wszystko poszło gładko ✓",
        "Zadanie wykonane. High five! 🖐️",
        "Sukces — mogę iść na kawę ☕",
        "Zrobione! Claude dostarcza 💪",
        "Operacja zakończona pomyślnie ✨",
        "Bam! Done. Następne?",
        "Misja wykonana. Over and out 🎯",
        "Claude strikes again — gotowe!",
        "Wszystko działa. Jak zegarek ⌚",
        "Skompilowane, przetestowane, dostarczone 📦",
        "Sukces! Nawet elektrony się cieszą",
        "Zadanie ✓ — czas na pixel-artową celebrację",
        "100% complete. Zero błędów. Perfekcja.",
        "Claude zrobił coś pięknego 🎨",
        "git commit -m 'it works' 🎉",
    ]

    // MARK: - Error
    static let error: [String] = [
        "Ups. Coś poszło nie tak 😬",
        "Houston, mamy problem",
        "Błąd! Ale nie panikujemy… jeszcze",
        "Coś się wysypało — sprawdź logi",
        "Exception caught. Dosłownie.",
        "Claude potknął się o kabel 🔌",
        "Error 🫠 — ale to naprawialne",
        "Kompilator mówi: nie dziś, koleś",
        "To nie bug, to… nie, to bug 🐛",
        "Oops. Nawet AI się myli czasem",
        "Segfault emocjonalny. Trzeba debugować.",
        "Coś eksplodowało, ale cicho. Sprawdź.",
        "Claude próbował. Claude zawiódł. Claude przeprasza.",
        "Red alert! Ale spokojnie — to do ogarnięcia",
        "Runtime error: za mało kawy ☕❌",
    ]

    // MARK: - Info
    static let info: [String] = [
        "Mała informacja od Claude'a",
        "FYI — coś się wydarzyło 📋",
        "Aktualizacja statusu od Claude'a",
        "Heads up! Jest nowy update",
        "Claude raportuje z frontu",
        "Info: rzeczy się dzieją 🔄",
        "Krótki update — nic pilnego",
        "Claude chciał Ci coś powiedzieć",
        "Notatka od asystenta AI 📝",
        "Status update: all systems go",
        "Claude ma dla Ciebie newsa",
        "Informacja prosto z silników Claude'a ⚙️",
        "Ping — mały update od AI",
        "Claude wysyła sygnał dymny 🏔️",
        "Wiadomość w butelce od Claude'a 🍾",
    ]

    // MARK: - Random picker
    static func random(for kind: NotificationKind) -> String {
        let pool: [String]
        switch kind {
        case .waiting: pool = waiting
        case .success: pool = success
        case .error:   pool = error
        case .info:    pool = info
        }
        return pool.randomElement() ?? pool[0]
    }
}
