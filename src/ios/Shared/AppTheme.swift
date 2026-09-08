import Combine
import Foundation
import SwiftUI
import UIKit

// MARK: - Theme catalogue
//
// [T-app-themes] A visual theme is an *aesthetic* — accent hue, surface tints,
// bubble colours — layered on top of the light / dark decision, which stays
// with the existing System / Light / Dark picker (`appearanceMode`). Every
// theme therefore carries a light AND a dark rendition, so "Crystal" reads
// icy-white in light mode and deep-teal in dark mode, and flipping the OS
// appearance never changes the theme the user chose.
//
// Persistence: `UserDefaults["appTheme"]` holds the `id` string (not an index)
// so adding or reordering themes never silently changes a user's pick. The
// same tokens are exposed to the agent as `appearance.app_theme`.
//
// Adding a theme = one enum case + one `ThemeVariant` per mode + a label.
// Nothing else needs to change.

enum AppTheme: String, CaseIterable, Identifiable {
    case `default`, space, sun, moon, dragon, crystal, forest, ocean, sakura

    var id: String { rawValue }

    static let storageKey = "appTheme"

    /// All ids in display order — reused by the config registry enum.
    static var ids: [String] { allCases.map(\.rawValue) }

    static func from(id: String?) -> AppTheme {
        id.flatMap(AppTheme.init(rawValue:)) ?? .default
    }

    /// Localised display name (keys live in Localizable.xcstrings).
    var title: LocalizedStringKey {
        switch self {
        case .default: return "Default"
        case .space: return "Space"
        case .sun: return "Sun"
        case .moon: return "Moon"
        case .dragon: return "Dragon"
        case .crystal: return "Crystal"
        case .forest: return "Forest"
        case .ocean: return "Ocean"
        case .sakura: return "Sakura"
        }
    }

    /// Decorative glyph on the picker card.
    var glyph: String {
        switch self {
        case .default: return "✨"
        case .space: return "🪐"
        case .sun: return "☀️"
        case .moon: return "🌙"
        case .dragon: return "🐉"
        case .crystal: return "💎"
        case .forest: return "🌲"
        case .ocean: return "🌊"
        case .sakura: return "🌸"
        }
    }

    func variant(dark: Bool) -> ThemeVariant { dark ? darkVariant : lightVariant }

    // The DEFAULT theme intentionally has no fixed colours: it resolves to the
    // system semantic colours (systemBackground, label, …) so the stock look is
    // byte-identical to what shipped before themes existed. `ThemePalette`
    // special-cases it.
    var lightVariant: ThemeVariant {
        switch self {
        case .default:
            return ThemeVariant(
                accent: 0x3686EE, background: 0xFFFFFF, groupedBackground: 0xF2F2F7,
                card: 0xFFFFFF, cardElevated: 0xF7F7FA, primaryText: 0x000000,
                secondaryText: 0x3C3C43, outline: 0xC6C6C8, userBubble: 0x787880,
                userBubbleAlpha: 0.12, inputBackground: 0xFFFFFF, toolBackground: 0xF2F2F7,
                link: 0x007AFF, thinking: 0x007AFF, fabAccent: 0xB7AF96, codeBlockBg: 0x000000,
                codeBlockText: 0x34C759, inlineCodeText: 0xFF9500,
                swatch: [0xF2F2F7, 0x3686EE, 0xFFFFFF])
        case .space:
            return ThemeVariant(
                accent: 0x5B4FCF, background: 0xF7F6FD, groupedBackground: 0xEEEDF7,
                card: 0xFFFFFF, cardElevated: 0xF4F2FF, primaryText: 0x1B1B2B,
                secondaryText: 0x474554, outline: 0xCAC6DC, userBubble: 0x5B4FCF,
                userBubbleAlpha: 0.18, inputBackground: 0xFFFFFF, toolBackground: 0xEEEDF7,
                link: 0x5B4FCF, thinking: 0x7A5375, fabAccent: 0x7B70E0, codeBlockBg: 0x0E0B2A,
                codeBlockText: 0xB6ABFF, inlineCodeText: 0x8E3ED6,
                swatch: [0xEEEDF7, 0x5B4FCF, 0xFFD6FA])
        case .sun:
            return ThemeVariant(
                accent: 0xD9822B, background: 0xFFFBF4, groupedBackground: 0xFBF3E7,
                card: 0xFFFCF6, cardElevated: 0xFFF4E6, primaryText: 0x241A10,
                secondaryText: 0x574335, outline: 0xE6D5C3, userBubble: 0xD9822B,
                userBubbleAlpha: 0.20, inputBackground: 0xFFFCF6, toolBackground: 0xFBF3E7,
                link: 0xC96A00, thinking: 0xD9822B, fabAccent: 0xE39A4D, codeBlockBg: 0x2B1D0E,
                codeBlockText: 0xFFC978, inlineCodeText: 0xB5541C,
                swatch: [0xFBF3E7, 0xD9822B, 0xFFDCC2])
        case .moon:
            return ThemeVariant(
                accent: 0x546A8A, background: 0xF6F8FC, groupedBackground: 0xEEF1F6,
                card: 0xFAFBFE, cardElevated: 0xF1F4FA, primaryText: 0x1B1F27,
                secondaryText: 0x444A56, outline: 0xCBD2DE, userBubble: 0x546A8A,
                userBubbleAlpha: 0.18, inputBackground: 0xFAFBFE, toolBackground: 0xEEF1F6,
                link: 0x3F5B85, thinking: 0x6F5F86, fabAccent: 0x8A9BB8, codeBlockBg: 0x1A2130,
                codeBlockText: 0xBFD3F5, inlineCodeText: 0x4F6C97,
                swatch: [0xEEF1F6, 0x546A8A, 0xD7E3FA])
        case .dragon:
            return ThemeVariant(
                accent: 0xB4262E, background: 0xFEF8F6, groupedBackground: 0xF8F0EE,
                card: 0xFFFBFA, cardElevated: 0xFCEFEC, primaryText: 0x241716,
                secondaryText: 0x574140, outline: 0xE3CFCC, userBubble: 0xB4262E,
                userBubbleAlpha: 0.20, inputBackground: 0xFFFBFA, toolBackground: 0xF8F0EE,
                link: 0xA1141C, thinking: 0x9A6E00, fabAccent: 0xC9A227, codeBlockBg: 0x250B0C,
                codeBlockText: 0xFFB4AB, inlineCodeText: 0xB4262E,
                swatch: [0xF8F0EE, 0xB4262E, 0xFFDF9E])
        case .crystal:
            return ThemeVariant(
                accent: 0x0B8A8F, background: 0xF6FCFD, groupedBackground: 0xEDF6F7,
                card: 0xFFFFFF, cardElevated: 0xF1FAFB, primaryText: 0x161D1E,
                secondaryText: 0x3F4949, outline: 0xC6DADB, userBubble: 0x0B8A8F,
                userBubbleAlpha: 0.18, inputBackground: 0xFFFFFF, toolBackground: 0xEDF6F7,
                link: 0x00767B, thinking: 0x4B607C, fabAccent: 0x6FC5C9, codeBlockBg: 0x0A2224,
                codeBlockText: 0x8FE3E6, inlineCodeText: 0x0B8A8F,
                swatch: [0xEDF6F7, 0x0B8A8F, 0xBDEFF1])
        case .forest:
            return ThemeVariant(
                accent: 0x3B7D4A, background: 0xF7FAF5, groupedBackground: 0xEFF4EC,
                card: 0xFCFDFA, cardElevated: 0xF1F6EE, primaryText: 0x191D18,
                secondaryText: 0x424940, outline: 0xCCD6C8, userBubble: 0x3B7D4A,
                userBubbleAlpha: 0.18, inputBackground: 0xFCFDFA, toolBackground: 0xEFF4EC,
                link: 0x2C6B3B, thinking: 0x6B5E36, fabAccent: 0x8FB08A, codeBlockBg: 0x0F1F12,
                codeBlockText: 0xA8E5AD, inlineCodeText: 0x3B7D4A,
                swatch: [0xEFF4EC, 0x3B7D4A, 0xF3E1AE])
        case .ocean:
            return ThemeVariant(
                accent: 0x0E6FB8, background: 0xF5F9FE, groupedBackground: 0xECF3FA,
                card: 0xFCFDFF, cardElevated: 0xF0F5FC, primaryText: 0x161C22,
                secondaryText: 0x41474E, outline: 0xC8D5E3, userBubble: 0x0E6FB8,
                userBubbleAlpha: 0.18, inputBackground: 0xFCFDFF, toolBackground: 0xECF3FA,
                link: 0x005DA1, thinking: 0x00696B, fabAccent: 0x6AA9DE, codeBlockBg: 0x071A2B,
                codeBlockText: 0x8FD3FF, inlineCodeText: 0x0E6FB8,
                swatch: [0xECF3FA, 0x0E6FB8, 0x9CF1F2])
        case .sakura:
            return ThemeVariant(
                accent: 0xC2416F, background: 0xFEF7F9, groupedBackground: 0xFAF0F3,
                card: 0xFFFBFC, cardElevated: 0xFDEFF3, primaryText: 0x22191C,
                secondaryText: 0x524345, outline: 0xE8D0D6, userBubble: 0xC2416F,
                userBubbleAlpha: 0.20, inputBackground: 0xFFFBFC, toolBackground: 0xFAF0F3,
                link: 0xAD2E5C, thinking: 0x7B5733, fabAccent: 0xE79AB5, codeBlockBg: 0x2A0F19,
                codeBlockText: 0xFFB1C8, inlineCodeText: 0xC2416F,
                swatch: [0xFAF0F3, 0xC2416F, 0xFFD9E2])
        }
    }

    var darkVariant: ThemeVariant {
        switch self {
        case .default:
            return ThemeVariant(
                accent: 0x5490E4, background: 0x000000, groupedBackground: 0x000000,
                card: 0x1C1C1E, cardElevated: 0x2C2C2E, primaryText: 0xFFFFFF,
                secondaryText: 0xEBEBF5, outline: 0x38383A, userBubble: 0x787880,
                userBubbleAlpha: 0.24, inputBackground: 0x1F1F1F, toolBackground: 0x2C2C2E,
                link: 0x0A84FF, thinking: 0x0A84FF, fabAccent: 0x504C42, codeBlockBg: 0x262626,
                codeBlockText: 0x8CF38C, inlineCodeText: 0xFF9F0A,
                swatch: [0x000000, 0x5490E4, 0x1C1C1E])
        case .space:
            return ThemeVariant(
                accent: 0xA89CFF, background: 0x05041A, groupedBackground: 0x05041A,
                card: 0x14122E, cardElevated: 0x1F1C40, primaryText: 0xE6E3F5,
                secondaryText: 0xC9C5DC, outline: 0x3A3757, userBubble: 0x2B2670,
                userBubbleAlpha: 1.0, inputBackground: 0x1F1C40, toolBackground: 0x1F1C40,
                link: 0xB8AEFF, thinking: 0xEAB9E1, fabAccent: 0x4D43B3, codeBlockBg: 0x0E0C28,
                codeBlockText: 0xB6ABFF, inlineCodeText: 0xFFB2F4,
                swatch: [0x05041A, 0xA89CFF, 0x2B2670])
        case .sun:
            return ThemeVariant(
                accent: 0xFFB86B, background: 0x140E08, groupedBackground: 0x140E08,
                card: 0x241A11, cardElevated: 0x32261A, primaryText: 0xF2E6D9,
                secondaryText: 0xDCC5B2, outline: 0x4A3A2B, userBubble: 0x5A3A16,
                userBubbleAlpha: 1.0, inputBackground: 0x32261A, toolBackground: 0x32261A,
                link: 0xFFB86B, thinking: 0xFFC978, fabAccent: 0x8A5A20, codeBlockBg: 0x221810,
                codeBlockText: 0xFFC978, inlineCodeText: 0xFFA24C,
                swatch: [0x140E08, 0xFFB86B, 0x5A3A16])
        case .moon:
            return ThemeVariant(
                accent: 0xB8CBEA, background: 0x0B0E14, groupedBackground: 0x0B0E14,
                card: 0x171B24, cardElevated: 0x222733, primaryText: 0xDDE2EB,
                secondaryText: 0xC0C7D3, outline: 0x353C4A, userBubble: 0x2C3A55,
                userBubbleAlpha: 1.0, inputBackground: 0x222733, toolBackground: 0x222733,
                link: 0xB8CBEA, thinking: 0xD5C4EE, fabAccent: 0x4D5D7A, codeBlockBg: 0x141924,
                codeBlockText: 0xBFD3F5, inlineCodeText: 0xA9BEE6,
                swatch: [0x0B0E14, 0xB8CBEA, 0x2C3A55])
        case .dragon:
            return ThemeVariant(
                accent: 0xFF7A6E, background: 0x120909, groupedBackground: 0x120909,
                card: 0x221213, cardElevated: 0x301B1C, primaryText: 0xF1DEDC,
                secondaryText: 0xDDC0BD, outline: 0x4A3435, userBubble: 0x5E1E22,
                userBubbleAlpha: 1.0, inputBackground: 0x301B1C, toolBackground: 0x301B1C,
                link: 0xFF9B90, thinking: 0xF2C14E, fabAccent: 0x8A6A12, codeBlockBg: 0x1E0F10,
                codeBlockText: 0xFFB4AB, inlineCodeText: 0xF2C14E,
                swatch: [0x120909, 0xFF7A6E, 0xF2C14E])
        case .crystal:
            return ThemeVariant(
                accent: 0x7FDCDF, background: 0x061416, groupedBackground: 0x061416,
                card: 0x102224, cardElevated: 0x183032, primaryText: 0xDCE6E7,
                secondaryText: 0xBEC9C9, outline: 0x2E4446, userBubble: 0x1B4A4D,
                userBubbleAlpha: 1.0, inputBackground: 0x183032, toolBackground: 0x183032,
                link: 0x8FE3E6, thinking: 0xB3C8E8, fabAccent: 0x2E7376, codeBlockBg: 0x0C1E20,
                codeBlockText: 0x8FE3E6, inlineCodeText: 0x7FDCDF,
                swatch: [0x061416, 0x7FDCDF, 0x1B4A4D])
        case .forest:
            return ThemeVariant(
                accent: 0x9DD8A3, background: 0x0A120B, groupedBackground: 0x0A120B,
                card: 0x152017, cardElevated: 0x1F2D21, primaryText: 0xDFE5DC,
                secondaryText: 0xC1CABD, outline: 0x33423A, userBubble: 0x244A2E,
                userBubbleAlpha: 1.0, inputBackground: 0x1F2D21, toolBackground: 0x1F2D21,
                link: 0xA8E5AD, thinking: 0xD7C594, fabAccent: 0x3F6B47, codeBlockBg: 0x101C12,
                codeBlockText: 0xA8E5AD, inlineCodeText: 0x9DD8A3,
                swatch: [0x0A120B, 0x9DD8A3, 0x244A2E])
        case .ocean:
            return ThemeVariant(
                accent: 0x7CC4FF, background: 0x040D18, groupedBackground: 0x040D18,
                card: 0x0E1B2A, cardElevated: 0x17283B, primaryText: 0xDCE3EC,
                secondaryText: 0xC0C8D2, outline: 0x2B3D51, userBubble: 0x184064,
                userBubbleAlpha: 1.0, inputBackground: 0x17283B, toolBackground: 0x17283B,
                link: 0x8FD3FF, thinking: 0x80D4D6, fabAccent: 0x2A6796, codeBlockBg: 0x0A1826,
                codeBlockText: 0x8FD3FF, inlineCodeText: 0x7CC4FF,
                swatch: [0x040D18, 0x7CC4FF, 0x184064])
        case .sakura:
            return ThemeVariant(
                accent: 0xFFB0C8, background: 0x15090E, groupedBackground: 0x15090E,
                card: 0x24151B, cardElevated: 0x321E26, primaryText: 0xF0DEE3,
                secondaryText: 0xD7C1C7, outline: 0x4A363E, userBubble: 0x5C2A42,
                userBubbleAlpha: 1.0, inputBackground: 0x321E26, toolBackground: 0x321E26,
                link: 0xFFB0C8, thinking: 0xEEBE92, fabAccent: 0x8A4A65, codeBlockBg: 0x20121A,
                codeBlockText: 0xFFB1C8, inlineCodeText: 0xFFB0C8,
                swatch: [0x15090E, 0xFFB0C8, 0x5C2A42])
        }
    }
}

/// One light-or-dark rendition of an `AppTheme`. Colours are sRGB hex so the
/// catalogue stays scannable; `ThemePalette` turns them into dynamic UIColors.
struct ThemeVariant {
    let accent: UInt32
    let background: UInt32
    let groupedBackground: UInt32
    let card: UInt32
    let cardElevated: UInt32
    let primaryText: UInt32
    let secondaryText: UInt32
    let outline: UInt32
    let userBubble: UInt32
    let userBubbleAlpha: CGFloat
    let inputBackground: UInt32
    let toolBackground: UInt32
    let link: UInt32
    let thinking: UInt32
    let fabAccent: UInt32
    let codeBlockBg: UInt32
    let codeBlockText: UInt32
    let inlineCodeText: UInt32
    /// Three colours the theme picker paints as a preview swatch.
    let swatch: [UInt32]
}

extension UIColor {
    convenience init(hex: UInt32, alpha: CGFloat = 1) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: alpha)
    }

    /// Builds a dynamic colour from a per-theme resolver so that light/dark
    /// resolution keeps working through trait collections (sheets, popovers,
    /// `overrideUserInterfaceStyle`), exactly like the system semantic colours.
    fileprivate static func themed(_ resolve: @escaping @Sendable (ThemeVariant) -> UIColor) -> UIColor {
        UIColor { traits in
            // Dynamic providers run on whatever thread UIKit resolves the colour
            // on, so read the lock-protected snapshot, never the @MainActor
            // manager.
            let theme = ThemeSnapshot.current
            return resolve(theme.variant(dark: traits.userInterfaceStyle == .dark))
        }
    }
}

extension Color {
    init(hex: UInt32, alpha: CGFloat = 1) { self.init(UIColor(hex: hex, alpha: alpha)) }
}

// MARK: - Manager

/// Thread-safe snapshot of the active theme for code that cannot hop to the
/// main actor (UIColor dynamic providers, background formatters). Kept in
/// lock-step with `ThemeManager.theme`.
enum ThemeSnapshot {
    private static let lock = NSLock()
    nonisolated(unsafe) private static var value: AppTheme =
        AppTheme.from(id: UserDefaults.standard.string(forKey: AppTheme.storageKey))

    static var current: AppTheme {
        lock.lock(); defer { lock.unlock() }
        return value
    }

    fileprivate static func update(_ theme: AppTheme) {
        lock.lock(); value = theme; lock.unlock()
    }
}

/// Single source of truth for the active theme.
///
/// Changing the theme re-keys the whole view tree (see `FinApp.swift`, where
/// `ThemeManager.theme` is part of the root `.id`) — the same mechanism the
/// language picker uses. That is deliberate: colours are read through
/// `ChatColors` / `ThemePalette` inside hundreds of view bodies and cached in
/// the render tree, and SwiftUI offers no cheaper global "re-resolve every
/// colour" than dropping and re-mounting the tree.
@MainActor
final class ThemeManager: ObservableObject {
    static let shared = ThemeManager()

    @Published private(set) var theme: AppTheme {
        didSet { ThemeSnapshot.update(theme) }
    }

    private var defaultsObserver: NSObjectProtocol?

    private init() {
        let initial = AppTheme.from(id: UserDefaults.standard.string(forKey: AppTheme.storageKey))
        theme = initial
        ThemeSnapshot.update(initial)
        // Writes that bypass `set(_:)` — the agent's config registry
        // (`appearance.app_theme`), a debug RPC — still propagate through
        // UserDefaults. Same observer shape as `KeepScreenAwakeController`:
        // main-queue delivery, singleton call (no `self` capture needed —
        // this object lives for the process lifetime).
        defaultsObserver = NotificationCenter.default.addObserver(
            forName: UserDefaults.didChangeNotification,
            object: nil, queue: .main
        ) { _ in
            Task { @MainActor in ThemeManager.shared.reloadFromDefaults() }
        }
    }

    /// User-initiated change (theme picker). Persists, publishes, retints.
    func set(_ newTheme: AppTheme) {
        guard newTheme != theme else { return }
        UserDefaults.standard.set(newTheme.rawValue, forKey: AppTheme.storageKey)
        commit(newTheme)
    }

    /// External write (config registry / another process) landed in
    /// UserDefaults; adopt it if it differs.
    private func reloadFromDefaults() {
        let stored = AppTheme.from(id: UserDefaults.standard.string(forKey: AppTheme.storageKey))
        guard stored != theme else { return }
        commit(stored)
    }

    private func commit(_ newTheme: AppTheme) {
        // [T-ios-stacknav-transition-attributegraph-race] Publishing `theme`
        // re-keys the root (FinApp's `.id`), i.e. a whole-tree teardown — and
        // the agent may be mid-stream when it flips `appearance.app_theme`
        // itself. Pin every processing vm across the remount, exactly as the
        // language picker does. No-op when nothing is streaming.
        ViewModelCache.shared.suspendAllForTreeRemount()
        theme = newTheme            // didSet refreshes ThemeSnapshot
        applyWindowTint()
    }

    /// UIKit-hosted controls (alerts, share sheets, UITextView link colour,
    /// navigation bar buttons in UIKit containers) read `window.tintColor`,
    /// not SwiftUI's `.tint`. Keep both in sync.
    func applyWindowTint() {
        let tint = ThemePalette.accentUIColor
        for scene in UIApplication.shared.connectedScenes {
            guard let ws = scene as? UIWindowScene else { continue }
            for window in ws.windows { window.tintColor = tint }
        }
    }
}

// MARK: - Palette

/// Dynamic (light/dark aware) colours for the ACTIVE theme. Each accessor
/// returns a `UIColor` dynamic provider, so a `Color` built from it keeps
/// tracking the trait collection. The default theme maps 1:1 onto the system
/// semantic colours so the stock appearance is unchanged.
enum ThemePalette {
    private static var isDefault: Bool { ThemeSnapshot.current == .default }

    static var accentUIColor: UIColor {
        .themed { UIColor(hex: $0.accent) }
    }
    static var accent: Color { Color(accentUIColor) }

    static var background: UIColor {
        isDefault ? UIColor.systemBackground : UIColor.themed { UIColor(hex: $0.background) }
    }
    static var groupedBackground: UIColor {
        isDefault ? UIColor.systemGroupedBackground : UIColor.themed { UIColor(hex: $0.groupedBackground) }
    }
    /// Mirrors `secondarySystemBackground`'s asymmetry: a grey inset in light
    /// mode, a lifted card surface in dark mode (where the page is near-black
    /// and the grouped colour would vanish into it).
    static var secondaryBackground: UIColor {
        if isDefault { return UIColor.secondarySystemBackground }
        return UIColor { traits in
            let dark = traits.userInterfaceStyle == .dark
            let v = ThemeSnapshot.current.variant(dark: dark)
            return UIColor(hex: dark ? v.card : v.groupedBackground)
        }
    }
    static var card: UIColor {
        isDefault ? UIColor.secondarySystemGroupedBackground : UIColor.themed { UIColor(hex: $0.card) }
    }
    static var cardElevated: UIColor {
        isDefault ? UIColor.tertiarySystemBackground : UIColor.themed { UIColor(hex: $0.cardElevated) }
    }
    static var primaryText: UIColor {
        isDefault ? UIColor.label : UIColor.themed { UIColor(hex: $0.primaryText) }
    }
    static var secondaryText: UIColor {
        isDefault ? UIColor.secondaryLabel : UIColor.themed { UIColor(hex: $0.secondaryText, alpha: 0.72) }
    }
    static var tertiaryText: UIColor {
        isDefault ? UIColor.tertiaryLabel : UIColor.themed { UIColor(hex: $0.secondaryText, alpha: 0.42) }
    }
    static var quaternaryText: UIColor {
        isDefault ? UIColor.quaternaryLabel : UIColor.themed { UIColor(hex: $0.secondaryText, alpha: 0.24) }
    }
    static var separator: UIColor {
        isDefault ? UIColor.separator : UIColor.themed { UIColor(hex: $0.outline, alpha: 0.7) }
    }
    static var userBubble: UIColor {
        isDefault ? UIColor.tertiarySystemFill : UIColor.themed { UIColor(hex: $0.userBubble, alpha: $0.userBubbleAlpha) }
    }
    static var inputBackground: UIColor {
        if isDefault {
            return UIColor { $0.userInterfaceStyle == .dark ? UIColor(white: 0.12, alpha: 1) : .white }
        }
        return .themed { UIColor(hex: $0.inputBackground) }
    }
    static var toolBackground: UIColor {
        isDefault ? UIColor.tertiarySystemGroupedBackground : UIColor.themed { UIColor(hex: $0.toolBackground) }
    }
    static var link: Color {
        isDefault ? Color(UIColor.link) : Color(UIColor.themed { UIColor(hex: $0.link) })
    }
    static var thinking: Color {
        isDefault ? Color.blue : Color(UIColor.themed { UIColor(hex: $0.thinking) })
    }
    static var fabAccent: Color { Color(UIColor.themed { UIColor(hex: $0.fabAccent) }) }
    static var codeBlockBackground: Color { Color(UIColor.themed { UIColor(hex: $0.codeBlockBg) }) }
    static var codeBlockText: Color { Color(UIColor.themed { UIColor(hex: $0.codeBlockText) }) }
    static var inlineCodeText: Color { Color(UIColor.themed { UIColor(hex: $0.inlineCodeText) }) }
}

// MARK: - Root modifier

/// Applies the active theme to a view tree: SwiftUI tint + accent (so every
/// `Color.accentColor` / `.tint` control follows the theme), the `appTheme`
/// environment value, and the UIKit window tint for UIKit-hosted controls.
///
/// This modifier does NOT re-key the tree itself — `FinApp` folds
/// `ThemeManager.theme` into the root `.id` next to `appLanguage` so both
/// whole-tree remounts share one code path (and one `pendingSettingsReopen`
/// dance in `AppearanceSettingsView`).
private struct AppThemeRootModifier: ViewModifier {
    @ObservedObject private var manager = ThemeManager.shared

    func body(content: Content) -> some View {
        content
            .tint(ThemePalette.accent)
            // `Color.accentColor` (used ~90× across the app) follows
            // `.accentColor(_:)`, not `.tint(_:)`. Deprecated, but it is the
            // only way to retarget those existing call sites without touching
            // each one.
            .accentColor(ThemePalette.accent)
            .environment(\.appTheme, manager.theme)
            .onAppear { manager.applyWindowTint() }
    }
}

/// Paints the active theme's page colour behind every `List` / `Form` /
/// `ScrollView` in the subtree (`scrollContentBackground` propagates through
/// the environment, including into pushed navigation destinations).
///
/// Strict no-op for the Default theme, so the stock list backgrounds — and
/// the glass/material behaviour tuned against them — are untouched.
private struct ThemedScreenBackground: ViewModifier {
    let grouped: Bool

    func body(content: Content) -> some View {
        if ThemeSnapshot.current == .default {
            content
        } else {
            content
                .scrollContentBackground(.hidden)
                .background(
                    Color(grouped ? ThemePalette.groupedBackground : ThemePalette.background)
                        .ignoresSafeArea()
                )
        }
    }
}

extension View {
    /// Theme the page background of a screen. `grouped: true` for inset-grouped
    /// settings screens, `false` for plain lists and canvases.
    func themedScreenBackground(grouped: Bool = false) -> some View {
        modifier(ThemedScreenBackground(grouped: grouped))
    }
}

private struct AppThemeKey: EnvironmentKey {
    static let defaultValue: AppTheme = .default
}

extension EnvironmentValues {
    /// The active visual theme. Read this only for theme-specific decoration;
    /// colours should go through `ThemePalette` / `ChatColors` so they follow
    /// light/dark automatically.
    var appTheme: AppTheme {
        get { self[AppThemeKey.self] }
        set { self[AppThemeKey.self] = newValue }
    }
}

extension View {
    /// Mount once at the app root (see `FinApp.swift`).
    func appThemeRoot() -> some View { modifier(AppThemeRootModifier()) }
}

// MARK: - Picker

/// Horizontally scrolling theme cards, each a miniature mock-up of the app in
/// that theme's colours for the CURRENT light/dark mode. Used by
/// `AppearanceSettingsView`.
struct AppThemePicker: View {
    /// Runs right before the theme is committed. `AppearanceSettingsView` uses
    /// it to arm the Settings-reopen flag and pin streaming chats across the
    /// root remount that the change triggers.
    var onWillChange: ((AppTheme) -> Void)? = nil

    @ObservedObject private var manager = ThemeManager.shared
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(AppTheme.allCases) { theme in
                    AppThemeCard(
                        theme: theme,
                        variant: theme.variant(dark: colorScheme == .dark),
                        selected: manager.theme == theme
                    ) {
                        guard theme != manager.theme else { return }
                        onWillChange?(theme)
                        manager.set(theme)
                    }
                }
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 6)
        }
        // Full-bleed inside a List row.
        .listRowInsets(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
    }
}

private struct AppThemeCard: View {
    let theme: AppTheme
    let variant: ThemeVariant
    let selected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 6) {
                ZStack(alignment: .topTrailing) {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color(hex: variant.groupedBackground))
                        .frame(width: 92, height: 104)
                        .overlay(alignment: .topLeading) { miniScreen }
                        .overlay(alignment: .bottomLeading) {
                            Text(theme.glyph)
                                .font(.system(size: 15))
                                .padding(.leading, 7)
                                .padding(.bottom, 5)
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(selected ? Color.accentColor : Color.primary.opacity(0.15),
                                        lineWidth: selected ? 2 : 0.5)
                        )
                    if selected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 18))
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.white, Color.accentColor)
                            .padding(5)
                    }
                }
                Text(theme.title)
                    .font(.caption)
                    .fontWeight(selected ? .semibold : .regular)
                    .foregroundStyle(selected ? Color.accentColor : Color.primary)
                    .lineLimit(1)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(theme.title))
        .accessibilityAddTraits(selected ? .isSelected : [])
    }

    /// Header dot + title bar, a card, and a trailing user bubble.
    private var miniScreen: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Circle().fill(Color(hex: variant.accent)).frame(width: 14, height: 14)
                Capsule().fill(Color(hex: variant.primaryText).opacity(0.55)).frame(width: 30, height: 6)
            }
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color(hex: variant.card))
                .frame(height: 26)
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(Color(hex: variant.outline), lineWidth: 0.5)
                )
                .overlay(alignment: .leading) {
                    Capsule().fill(Color(hex: variant.primaryText).opacity(0.35))
                        .frame(width: 34, height: 5).padding(.leading, 6)
                }
            HStack {
                Spacer()
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color(hex: variant.userBubble, alpha: variant.userBubbleAlpha))
                    .frame(width: 44, height: 16)
            }
        }
        .padding(8)
        .frame(width: 92, alignment: .topLeading)
    }
}
