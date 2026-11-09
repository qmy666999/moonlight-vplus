package com.limelight.ui.theme

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.ColorScheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Shapes
import androidx.compose.material3.Typography
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.Immutable
import androidx.compose.runtime.ReadOnlyComposable
import androidx.compose.runtime.staticCompositionLocalOf
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.lerp
import androidx.compose.ui.res.colorResource
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.limelight.R
import com.limelight.utils.appAccentColor

/**
 * Moonlight V+ Material 3 theme.
 *
 * One theme feeds every Compose surface (host sheet, quick settings, dialogs,
 * diagnostics) so the app no longer grows a new purple `darkColorScheme()` in
 * each screen. Primary roles come from the same wallpaper-derived accent as the
 * View system; neutral roles come from the semantic `m3_*` resources.
 *
 * Use [MoonlightTheme] instead of a bare [MaterialTheme] wrapper.
 */
@Composable
fun MoonlightTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    surfaceOverride: Color? = null,
    content: @Composable () -> Unit,
) {
    val accent = appAccentColor()
    val scheme = moonlightColorScheme(
        darkTheme = darkTheme,
        accent = accent,
        surfaceOverride = surfaceOverride,
    )
    val extended = if (darkTheme) DarkExtendedColors else LightExtendedColors

    CompositionLocalProvider(LocalMoonlightExtendedColors provides extended) {
        MaterialTheme(
            colorScheme = scheme,
            typography = MoonlightTypography,
            shapes = MoonlightShapes,
            content = content,
        )
    }
}

@Composable
@ReadOnlyComposable
fun moonlightColorScheme(
    darkTheme: Boolean,
    accent: Color = appAccentColor(),
    surfaceOverride: Color? = null,
): ColorScheme {
    val surface = surfaceOverride ?: colorResource(R.color.m3_surface)
    val surfaceContainerLow = colorResource(R.color.m3_surface_container_low)
    val surfaceContainer = colorResource(R.color.m3_surface_container)
    val surfaceContainerHigh = colorResource(R.color.m3_surface_container_high)
    val surfaceContainerHighest = colorResource(R.color.m3_surface_container_highest)
    val onSurface = colorResource(R.color.m3_on_surface)
    val onSurfaceVariant = colorResource(R.color.m3_on_surface_variant)
    val outline = colorResource(R.color.m3_outline)
    val outlineVariant = colorResource(R.color.m3_outline_variant)
    val error = colorResource(R.color.m3_error)

    val primaryContainer = lerp(surface, accent, if (darkTheme) 0.24f else 0.14f)
    val onPrimaryContainer = if (darkTheme) Color(0xFFFFD9E2) else Color(0xFF3A0018)
    val containerLow = if (surfaceOverride == null) surfaceContainerLow else lerp(surface, onSurface, 0.04f)
    val container = if (surfaceOverride == null) surfaceContainer else lerp(surface, onSurface, 0.07f)
    val containerHigh = if (surfaceOverride == null) surfaceContainerHigh else lerp(surface, onSurface, 0.11f)
    val containerHighest = if (surfaceOverride == null) surfaceContainerHighest else lerp(surface, onSurface, 0.16f)

    return if (darkTheme) {
        darkColorScheme(
            primary = accent,
            onPrimary = Color(0xFF3A0018),
            primaryContainer = primaryContainer,
            onPrimaryContainer = onPrimaryContainer,
            inversePrimary = Color(0xFF8E2F55),
            secondary = colorResource(R.color.m3_secondary),
            onSecondary = colorResource(R.color.m3_on_secondary),
            secondaryContainer = colorResource(R.color.m3_secondary_container),
            onSecondaryContainer = colorResource(R.color.m3_on_secondary_container),
            tertiary = colorResource(R.color.m3_tertiary),
            onTertiary = colorResource(R.color.m3_on_tertiary),
            background = surface,
            onBackground = onSurface,
            surface = surface,
            onSurface = onSurface,
            surfaceVariant = containerHigh,
            onSurfaceVariant = onSurfaceVariant,
            surfaceTint = accent,
            inverseSurface = colorResource(R.color.m3_inverse_surface),
            inverseOnSurface = colorResource(R.color.m3_inverse_on_surface),
            error = error,
            onError = colorResource(R.color.m3_on_error),
            errorContainer = colorResource(R.color.m3_error_container),
            onErrorContainer = colorResource(R.color.m3_on_error_container),
            outline = outline,
            outlineVariant = outlineVariant,
            scrim = Color.Black,
            surfaceBright = colorResource(R.color.m3_surface_bright),
            surfaceDim = colorResource(R.color.m3_surface_dim),
            surfaceContainerLowest = colorResource(R.color.m3_surface_container_lowest),
            surfaceContainerLow = containerLow,
            surfaceContainer = container,
            surfaceContainerHigh = containerHigh,
            surfaceContainerHighest = containerHighest,
        )
    } else {
        lightColorScheme(
            primary = accent,
            onPrimary = Color(0xFF3A0018),
            primaryContainer = primaryContainer,
            onPrimaryContainer = onPrimaryContainer,
            inversePrimary = Color(0xFFFFB1C8),
            secondary = colorResource(R.color.m3_secondary),
            onSecondary = colorResource(R.color.m3_on_secondary),
            secondaryContainer = colorResource(R.color.m3_secondary_container),
            onSecondaryContainer = colorResource(R.color.m3_on_secondary_container),
            tertiary = colorResource(R.color.m3_tertiary),
            onTertiary = colorResource(R.color.m3_on_tertiary),
            background = surface,
            onBackground = onSurface,
            surface = surface,
            onSurface = onSurface,
            surfaceVariant = containerHigh,
            onSurfaceVariant = onSurfaceVariant,
            surfaceTint = accent,
            inverseSurface = colorResource(R.color.m3_inverse_surface),
            inverseOnSurface = colorResource(R.color.m3_inverse_on_surface),
            error = error,
            onError = colorResource(R.color.m3_on_error),
            errorContainer = colorResource(R.color.m3_error_container),
            onErrorContainer = colorResource(R.color.m3_on_error_container),
            outline = outline,
            outlineVariant = outlineVariant,
            scrim = Color.Black,
            surfaceBright = colorResource(R.color.m3_surface_bright),
            surfaceDim = colorResource(R.color.m3_surface_dim),
            surfaceContainerLowest = colorResource(R.color.m3_surface_container_lowest),
            surfaceContainerLow = containerLow,
            surfaceContainer = container,
            surfaceContainerHigh = containerHigh,
            surfaceContainerHighest = containerHighest,
        )
    }
}

@Immutable
data class MoonlightExtendedColors(
    val success: Color,
    val warning: Color,
    val onMedia: Color,
    val mediaScrimStart: Color,
    val mediaScrimEnd: Color,
)

val LocalMoonlightExtendedColors = staticCompositionLocalOf {
    LightExtendedColors
}

private val LightExtendedColors = MoonlightExtendedColors(
    success = Color(0xFF2E6B3A),
    warning = Color(0xFF8A5100),
    onMedia = Color.White,
    mediaScrimStart = Color.Transparent,
    mediaScrimEnd = Color(0xB3000000),
)

private val DarkExtendedColors = MoonlightExtendedColors(
    success = Color(0xFF9CD49F),
    warning = Color(0xFFFFB86B),
    onMedia = Color.White,
    mediaScrimStart = Color.Transparent,
    mediaScrimEnd = Color(0xCC000000),
)

private val MoonlightShapes = Shapes(
    extraSmall = androidx.compose.foundation.shape.RoundedCornerShape(4.dp),
    small = androidx.compose.foundation.shape.RoundedCornerShape(8.dp),
    medium = androidx.compose.foundation.shape.RoundedCornerShape(12.dp),
    large = androidx.compose.foundation.shape.RoundedCornerShape(16.dp),
    extraLarge = androidx.compose.foundation.shape.RoundedCornerShape(28.dp),
)

private val MoonlightTypography = Typography(
    displayLarge = TextStyle(
        fontFamily = FontFamily.SansSerif,
        fontWeight = FontWeight.Normal,
        fontSize = 57.sp,
        lineHeight = 64.sp,
        letterSpacing = (-0.25).sp,
    ),
    headlineLarge = TextStyle(
        fontFamily = FontFamily.SansSerif,
        fontWeight = FontWeight.Normal,
        fontSize = 32.sp,
        lineHeight = 40.sp,
    ),
    headlineMedium = TextStyle(
        fontFamily = FontFamily.SansSerif,
        fontWeight = FontWeight.Normal,
        fontSize = 28.sp,
        lineHeight = 36.sp,
    ),
    headlineSmall = TextStyle(
        fontFamily = FontFamily.SansSerif,
        fontWeight = FontWeight.Normal,
        fontSize = 24.sp,
        lineHeight = 32.sp,
    ),
    titleLarge = TextStyle(
        fontFamily = FontFamily.SansSerif,
        fontWeight = FontWeight.Medium,
        fontSize = 22.sp,
        lineHeight = 28.sp,
    ),
    titleMedium = TextStyle(
        fontFamily = FontFamily.SansSerif,
        fontWeight = FontWeight.Medium,
        fontSize = 16.sp,
        lineHeight = 24.sp,
        letterSpacing = 0.15.sp,
    ),
    titleSmall = TextStyle(
        fontFamily = FontFamily.SansSerif,
        fontWeight = FontWeight.Medium,
        fontSize = 14.sp,
        lineHeight = 20.sp,
        letterSpacing = 0.1.sp,
    ),
    bodyLarge = TextStyle(
        fontFamily = FontFamily.SansSerif,
        fontWeight = FontWeight.Normal,
        fontSize = 16.sp,
        lineHeight = 24.sp,
        letterSpacing = 0.5.sp,
    ),
    bodyMedium = TextStyle(
        fontFamily = FontFamily.SansSerif,
        fontWeight = FontWeight.Normal,
        fontSize = 14.sp,
        lineHeight = 20.sp,
        letterSpacing = 0.25.sp,
    ),
    bodySmall = TextStyle(
        fontFamily = FontFamily.SansSerif,
        fontWeight = FontWeight.Normal,
        fontSize = 12.sp,
        lineHeight = 16.sp,
        letterSpacing = 0.4.sp,
    ),
    labelLarge = TextStyle(
        fontFamily = FontFamily.SansSerif,
        fontWeight = FontWeight.Medium,
        fontSize = 14.sp,
        lineHeight = 20.sp,
        letterSpacing = 0.1.sp,
    ),
    labelMedium = TextStyle(
        fontFamily = FontFamily.SansSerif,
        fontWeight = FontWeight.Medium,
        fontSize = 12.sp,
        lineHeight = 16.sp,
        letterSpacing = 0.5.sp,
    ),
    labelSmall = TextStyle(
        fontFamily = FontFamily.SansSerif,
        fontWeight = FontWeight.Medium,
        fontSize = 11.sp,
        lineHeight = 16.sp,
        letterSpacing = 0.5.sp,
    ),
)
