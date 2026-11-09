# Material 3 token consistency check.
#
# This is deliberately dependency-free so it can run in CI before Gradle has
# downloaded anything. It catches the failures that are easy to miss in review:
# a token added only to the light palette, an undeclared theme attr, a missing
# text appearance, or a new screen that bypasses MoonlightTheme.
$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
Push-Location $repoRoot
try {
    $failures = New-Object System.Collections.Generic.List[string]
    $resRoot = Join-Path $repoRoot "app/src/main/res"

    function Read-Resource {
        param([string]$Path)
        if (-not (Test-Path $Path)) {
            $failures.Add("Missing resource file: $Path")
            return ""
        }
        return Get-Content -Raw -Encoding UTF8 $Path
    }

    $lightTokens = Read-Resource (Join-Path $resRoot "values/m3_tokens.xml")
    $nightTokens = Read-Resource (Join-Path $resRoot "values-night/m3_tokens.xml")
    $attrs = Read-Resource (Join-Path $resRoot "values/attrs.xml")
    $typography = Read-Resource (Join-Path $resRoot "values/m3_typography.xml")

    $tokenRegex = [regex]'<color\s+name="(m3_[^"]+)"'
    $lightNames = @($tokenRegex.Matches($lightTokens) | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique)
    $nightNames = @($tokenRegex.Matches($nightTokens) | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique)

    foreach ($name in $lightNames) {
        if ($name -notin $nightNames) { $failures.Add("Token '$name' exists in values but not values-night.") }
    }
    foreach ($name in $nightNames) {
        if ($name -notin $lightNames) { $failures.Add("Token '$name' exists in values-night but not values.") }
    }

    $declaredAttrRegex = [regex]'<attr\s+name="(m3Color[^"]+)"'
    $declaredAttrs = @($declaredAttrRegex.Matches($attrs) | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique)
    $referencedAttrs = @()
    Get-ChildItem $resRoot -Recurse -Filter "*.xml" | ForEach-Object {
        $text = Get-Content -Raw -Encoding UTF8 $_.FullName
        $referencedAttrs += [regex]::Matches($text, '\?attr/(m3Color[A-Za-z0-9_]+)') |
            ForEach-Object { $_.Groups[1].Value }
    }
    foreach ($name in ($referencedAttrs | Sort-Object -Unique)) {
        if ($name -notin $declaredAttrs) { $failures.Add("Theme attr '?attr/$name' is used but not declared in values/attrs.xml.") }
    }

    $styleRegex = [regex]'<style\s+name="(TextAppearance\.Moonlight\.M3\.[^"]+)"'
    $declaredStyles = @($styleRegex.Matches($typography) | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique)
    $referencedStyles = @()
    Get-ChildItem $resRoot -Recurse -Filter "*.xml" | ForEach-Object {
        $text = Get-Content -Raw -Encoding UTF8 $_.FullName
        $referencedStyles += [regex]::Matches($text, '@style/(TextAppearance\.Moonlight\.M3\.[A-Za-z0-9_.]+)') |
            ForEach-Object { $_.Groups[1].Value }
    }
    foreach ($name in ($referencedStyles | Sort-Object -Unique)) {
        if ($name -notin $declaredStyles) { $failures.Add("Text appearance '$name' is referenced but not declared.") }
    }

    # Screens that still build a private scheme are migration debt, not a build
    # failure. Keep the list visible so new code does not copy the pattern.
    $privateSchemes = @()
    Get-ChildItem (Join-Path $repoRoot "app/src/main/java") -Recurse -Filter "*.kt" | ForEach-Object {
        $relative = $_.FullName.Substring($repoRoot.Length + 1)
        if ($relative.Replace('\', '/').EndsWith("ui/theme/MoonlightTheme.kt")) { return }
        $text = Get-Content -Raw -Encoding UTF8 $_.FullName
        if ($text -match 'darkColorScheme\s*\(|lightColorScheme\s*\(') {
            $privateSchemes += $relative
        }
    }

    Write-Host "M3 tokens: $($lightNames.Count) light / $($nightNames.Count) dark"
    Write-Host "M3 attrs:  $($declaredAttrs.Count) declared"
    Write-Host "M3 styles: $($declaredStyles.Count) text appearances"
    if ($privateSchemes.Count -gt 0) {
        Write-Warning "Screens still creating a private Compose scheme (migrate to MoonlightTheme):"
        $privateSchemes | ForEach-Object { Write-Host "  - $_" }
    }

    if ($failures.Count -gt 0) {
        Write-Host ""
        $failures | ForEach-Object { Write-Error $_ -ErrorAction Continue }
        exit 1
    }

    Write-Host "M3 token check passed."
}
finally {
    Pop-Location
}
