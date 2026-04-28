$files = Get-ChildItem -Path lib -Recurse -Filter *.dart
foreach ($f in $files) {
    $content = [System.IO.File]::ReadAllText($f.FullName, [System.Text.Encoding]::UTF8)
    $modified = $false

    if ($content -match "white26") { $content = $content -replace "Colors\.white26", "Colors.white24"; $modified = $true }
    if ($content -match "white87") { $content = $content -replace "Colors\.white87", "Colors.white70"; $modified = $true }
    if ($content -match "white45") { $content = $content -replace "Colors\.white45", "Colors.white54"; $modified = $true }
    if ($content -match "BorderStyle\.dash") { $content = $content -replace "BorderStyle\.dash", "BorderStyle.solid"; $modified = $true }
    if ($content -match "siberGold\.shade700") { $content = $content -replace "siberGold\.shade700", "siberGold"; $modified = $true }
    if ($content -match "temaRengi\.shade700") { $content = $content -replace "temaRengi\.shade700", "temaRengi"; $modified = $true }

    if ($content -cmatch "const (?=[A-Z\[\{])") {
        $content = $content -creplace "const (?=[A-Z\[\{])", ""
        $modified = $true
    }

    if ($content -match "SiberTema" -and $content -notmatch "package:otodna/core/siber_tema.dart") {
        $content = "import 'package:otodna/core/siber_tema.dart';
" + $content
        $modified = $true
    }

    if ($modified) {
        [System.IO.File]::WriteAllText($f.FullName, $content, [System.Text.Encoding]::UTF8)
    }
}
Write-Host "Fix completed."
