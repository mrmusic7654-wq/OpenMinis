package com.mrmusic.fin.ui.theme

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.ColorScheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Shapes
import androidx.compose.material3.Typography
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.remember
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

// Accent: iOS blue, desaturated. [T-android-accent-blue-parity]
//
// The stock accent (AppTheme.DEFAULT) is iOS's AccentColor hue with saturation
// dialled back ~30% so it doesn't glare on Android's darker surfaces:
//   light  #3686EE  S84% L57%  ->  #528AD2  S59% L57%
//   dark   #5490E4  S73% L61%  ->  #6A94CE  S51% L61%
// Lightness is deliberately NOT raised — that would push light-mode contrast on
// white from 3.62 to 2.62, below WCAG AA's 4.5 for text. Desaturating keeps
// dark mode at 5.93 (passing) and leaves light mode where it was.
//
// [T-app-themes] Every colour that gives the app its *character* now lives in
// `AppTheme` (one light + one dark `ThemeVariant` per theme). This file only
// (a) folds a variant into a Material3 ColorScheme and (b) derives the chat
// palette from it, so the 90+ `MaterialTheme.colorScheme.*` and `ChatColors.*`
// call sites are untouched and every screen re-themes at once.

private fun lightScheme(v: ThemeVariant): ColorScheme = lightColorScheme(
    primary = v.primary,
    onPrimary = v.onPrimary,
    primaryContainer = v.primaryContainer,
    onPrimaryContainer = v.onPrimaryContainer,
    secondary = v.secondary,
    onSecondary = v.onSecondary,
    secondaryContainer = v.secondaryContainer,
    onSecondaryContainer = v.onSecondaryContainer,
    tertiary = v.tertiary,
    onTertiary = v.onTertiary,
    tertiaryContainer = v.tertiaryContainer,
    onTertiaryContainer = v.onTertiaryContainer,
    // Neutral grouped-card surfaces (iOS-style system-grouped background).
    // Material3's tonal `surfaceContainer*` is overridden so cards don't pick
    // up the primary tint — the theme's own `card` colour decides that.
    background = v.background,
    onBackground = v.onBackground,
    surface = v.background,
    onSurface = v.onBackground,
    surfaceVariant = v.card,
    onSurfaceVariant = v.onSurfaceVariant,
    surfaceContainerLowest = v.background,
    surfaceContainerLow = v.card,
    surfaceContainer = v.card,
    surfaceContainerHigh = v.cardElevated,
    surfaceContainerHighest = v.cardElevated,
    outline = v.outline,
    outlineVariant = v.outline,
)

private fun darkScheme(v: ThemeVariant): ColorScheme = darkColorScheme(
    primary = v.primary,
    onPrimary = v.onPrimary,
    primaryContainer = v.primaryContainer,
    onPrimaryContainer = v.onPrimaryContainer,
    secondary = v.secondary,
    onSecondary = v.onSecondary,
    secondaryContainer = v.secondaryContainer,
    onSecondaryContainer = v.onSecondaryContainer,
    tertiary = v.tertiary,
    onTertiary = v.onTertiary,
    tertiaryContainer = v.tertiaryContainer,
    onTertiaryContainer = v.onTertiaryContainer,
    background = v.background,
    onBackground = v.onBackground,
    surface = v.background,
    onSurface = v.onBackground,
    surfaceVariant = v.card,
    onSurfaceVariant = v.onSurfaceVariant,
    surfaceContainerLowest = v.background,
    surfaceContainerLow = v.card,
    surfaceContainer = v.card,
    surfaceContainerHigh = v.cardElevated,
    surfaceContainerHighest = v.cardElevated,
    outline = v.outline,
    outlineVariant = v.outline,
)

/**
 * Derive the semantic chat palette for a theme variant. The mode's base
 * palette ([LightChatPalette] / [DarkChatPalette]) supplies the neutrals that
 * were tuned for legibility on real displays (see T153 in ChatColors.kt);
 * the variant overrides only the colours that carry the theme's identity.
 * `AppTheme.DEFAULT` reproduces the pre-theme palettes exactly.
 */
internal fun chatPaletteFor(theme: AppTheme, darkTheme: Boolean): ChatPalette {
    val base = if (darkTheme) DarkChatPalette else LightChatPalette
    if (theme == AppTheme.DEFAULT) return base
    val v = theme.variant(darkTheme)
    return if (darkTheme) {
        base.copy(
            background = v.chatBackground,
            secondaryBg = v.card,
            inputBg = v.cardElevated,
            inputIconBg = v.card,
            userBubble = v.userBubble,
            toolBg = v.cardElevated,
            toolCapsuleBg = v.card,
            codeBlockBg = v.codeBlockBg,
            codeBlockText = v.codeBlockText,
            inlineCodeBg = v.cardElevated,
            inlineCodeText = v.inlineCodeText,
            link = v.link,
            blockquoteBar = v.primary.copy(alpha = 0.5f),
            thinking = v.thinking,
            toastBg = v.primary.copy(alpha = 0.18f),
            sheetHeaderBg = v.cardElevated,
            fabAccent = v.fabAccent,
        )
    } else {
        base.copy(
            background = v.chatBackground,
            secondaryBg = v.background,
            inputBg = v.card,
            inputIconBg = v.background,
            userBubble = v.userBubble,
            toolBg = v.background,
            toolCapsuleBg = v.background,
            codeBlockBg = v.codeBlockBg,
            codeBlockText = v.codeBlockText,
            inlineCodeBg = v.background,
            inlineCodeText = v.inlineCodeText,
            link = v.link,
            blockquoteBar = v.primary.copy(alpha = 0.5f),
            thinking = v.thinking,
            toastBg = v.primary.copy(alpha = 0.18f),
            sheetHeaderBg = v.card,
            fabAccent = v.fabAccent,
        )
    }
}

// App-wide FAB accent color (warm beige on the default theme, matching the iOS
// New Chat button; theme accent otherwise). Reads from ChatPalette so it
// follows the in-app theme override (theme_mode / app_theme prefs), not
// android.isSystemInDarkTheme(), which only tracks the system setting.
@Composable
fun finFabColor(): Color = LocalChatPalette.current.fabAccent

// App-wide shape system — larger corners for a modern, friendly feel
// DropdownMenu uses extraSmall, Dialog uses extraLarge, BottomSheet uses extraLarge
private val FinShapes = Shapes(
    extraSmall = RoundedCornerShape(12.dp),   // DropdownMenu, Tooltip, OutlinedTextField default
    small = RoundedCornerShape(12.dp),        // Chip, TextField
    medium = RoundedCornerShape(20.dp),       // Card, Snackbar
    large = RoundedCornerShape(24.dp),        // NavigationDrawer
    extraLarge = RoundedCornerShape(28.dp),   // Dialog, BottomSheet
)

@Composable
fun FinTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    appTheme: AppTheme = AppTheme.DEFAULT,
    fontScale: Float = 1f,
    content: @Composable () -> Unit,
) {
    val variant = appTheme.variant(darkTheme)
    val colorScheme = remember(variant, darkTheme) {
        if (darkTheme) darkScheme(variant) else lightScheme(variant)
    }
    val typography = scaledTypography(fontScale)
    val chatPalette = remember(appTheme, darkTheme) { chatPaletteFor(appTheme, darkTheme) }

    MaterialTheme(
        colorScheme = colorScheme,
        shapes = FinShapes,
        typography = typography,
    ) {
        CompositionLocalProvider(
            LocalChatPalette provides chatPalette,
            LocalAppTheme provides appTheme,
            content = content,
        )
    }
}

private fun TextStyle.scale(factor: Float): TextStyle =
    if (factor == 1f) this else copy(fontSize = fontSize * factor)

private fun scaledTypography(factor: Float): Typography {
    val base = Typography()
    return Typography(
        displayLarge = base.displayLarge.scale(factor),
        displayMedium = base.displayMedium.scale(factor),
        displaySmall = base.displaySmall.scale(factor),
        headlineLarge = base.headlineLarge.scale(factor),
        headlineMedium = base.headlineMedium.scale(factor),
        headlineSmall = base.headlineSmall.scale(factor),
        titleLarge = base.titleLarge.scale(factor),
        titleMedium = base.titleMedium.scale(factor),
        titleSmall = base.titleSmall.scale(factor),
        bodyLarge = base.bodyLarge.scale(factor),
        bodyMedium = base.bodyMedium.scale(factor),
        bodySmall = base.bodySmall.scale(factor),
        labelLarge = base.labelLarge.scale(factor),
        labelMedium = base.labelMedium.scale(factor),
        labelSmall = base.labelSmall.scale(factor),
    )
}
