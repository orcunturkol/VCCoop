# Images "Tommy The Buddy" (version du groupe) : logos, ecran de chargement, fond des menus, ecran de fermeture.
# Lancer avant make-art.ps1 (qui compose le fond du lanceur et l'icone a partir de launcher\logo.png).
# Les fonds d'origine sont relus depuis l'historique git (premiere version), puis retouches : les palmiers restent.
Add-Type -AssemblyName System.Drawing
$root = Split-Path $PSScriptRoot
$ui = Join-Path $root 'dist\files\VCCoop\interface'
$pink = [System.Drawing.Color]::FromArgb(255, 255, 79, 139); $orange = [System.Drawing.Color]::FromArgb(255, 255, 138, 91)
$peach = [System.Drawing.Color]::FromArgb(255, 236, 196, 150)

function Original([string]$name) {
    $tmp = Join-Path $env:TEMP "brand-$name"
    cmd /c "git -C `"$root`" show upstream/main:dist/files/VCCoop/interface/$name > `"$tmp`""
    $b = [System.Drawing.Bitmap]::FromFile($tmp); $c = New-Object System.Drawing.Bitmap $b; $b.Dispose(); Remove-Item $tmp; return $c
}

function SpacedText($gr, [string]$t, $font, $brush, [float]$cx, [float]$y, [float]$gap) {
    $sf = [System.Drawing.StringFormat]::GenericTypographic
    $ws = @(); $tot = 0
    foreach ($ch in $t.ToCharArray()) { $w = $gr.MeasureString([string]$ch, $font, 4000, $sf).Width; if ($ch -eq ' ') { $w = $font.Size * 0.35 }; $ws += $w; $tot += $w + $gap }
    $x = $cx - ($tot - $gap) / 2; $i = 0
    foreach ($ch in $t.ToCharArray()) { $gr.DrawString([string]$ch, $font, $brush, $x, $y, $sf); $x += $ws[$i] + $gap; $i++ }
}

function RoundPath([System.Drawing.RectangleF]$r, [float]$rad) {
    $p = New-Object System.Drawing.Drawing2D.GraphicsPath; $d = $rad * 2
    $p.AddArc($r.X, $r.Y, $d, $d, 180, 90); $p.AddArc($r.Right - $d, $r.Y, $d, $d, 270, 90)
    $p.AddArc($r.Right - $d, $r.Bottom - $d, $d, $d, 0, 90); $p.AddArc($r.X, $r.Bottom - $d, $d, $d, 90, 90); $p.CloseFigure(); return $p
}

# Logo : "TOMMY" gras italique, "THE BUDDY" espace dessous. $fill : pinceau (degrade ou noir).
function DrawLogo($g, [float]$cx, [float]$top, [float]$scale, $fill, $sub) {
    $g.SmoothingMode = 'AntiAlias'; $g.TextRenderingHint = 'AntiAliasGridFit'
    $big = New-Object System.Drawing.Font 'Segoe UI Black', (112 * $scale), ([System.Drawing.FontStyle]::Italic), ([System.Drawing.GraphicsUnit]::Pixel)
    $small = New-Object System.Drawing.Font 'Segoe UI Black', (40 * $scale), ([System.Drawing.FontStyle]::Regular), ([System.Drawing.GraphicsUnit]::Pixel)
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $sf = New-Object System.Drawing.StringFormat; $sf.Alignment = 'Center'
    $path.AddString('TOMMY', $big.FontFamily, [int][System.Drawing.FontStyle]::Italic, $big.Size, (New-Object System.Drawing.PointF $cx, $top), $sf)
    $g.FillPath($fill, $path)
    SpacedText $g 'THE BUDDY' $small $sub $cx ($top + 128 * $scale) (12 * $scale)
    $big.Dispose(); $small.Dispose(); $path.Dispose()
}

function GradientBrush([float]$x0, [float]$x1) { New-Object System.Drawing.Drawing2D.LinearGradientBrush (New-Object System.Drawing.PointF $x0, 0), (New-Object System.Drawing.PointF $x1, 0), $pink, $orange }

# 1. Logos 512x512 : lanceur (degrade) et menus du jeu (noir)
foreach ($target in @(@{ Path = (Join-Path $PSScriptRoot 'logo.png'); Color = $true }, @{ Path = (Join-Path $ui 'logo.png'); Color = $false })) {
    $bmp = New-Object System.Drawing.Bitmap 512, 512; $g = [System.Drawing.Graphics]::FromImage($bmp); $g.Clear([System.Drawing.Color]::Transparent)
    if ($target.Color) { $fill = GradientBrush 40 470; $sub = GradientBrush 40 470 } else { $fill = [System.Drawing.Brushes]::Black; $sub = [System.Drawing.Brushes]::Black }
    DrawLogo $g 256 150 1.0 $fill $sub
    $g.Dispose(); $bmp.Save($target.Path, [System.Drawing.Imaging.ImageFormat]::Png); $bmp.Dispose(); "Ecrit : $($target.Path)"
}

# Encart "fan mod" (remplace celui de VCCoop) a la position donnee
function Notice($g, [float]$x, [float]$y) {
    $g.SmoothingMode = 'AntiAlias'; $g.TextRenderingHint = 'AntiAliasGridFit'
    $dark = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 28, 28, 28))
    $p1 = RoundPath (New-Object System.Drawing.RectangleF $x, $y, 507, 54) 12; $g.FillPath($dark, $p1)
    $p2 = RoundPath (New-Object System.Drawing.RectangleF $x, ($y + 58), 507, 158) 12; $g.FillPath($dark, $p2)
    $t = New-Object System.Drawing.Font 'Segoe UI Semibold', 14, ([System.Drawing.FontStyle]::Regular), ([System.Drawing.GraphicsUnit]::Pixel)
    $b = New-Object System.Drawing.Font 'Segoe UI', 15, ([System.Drawing.FontStyle]::Regular), ([System.Drawing.GraphicsUnit]::Pixel)
    $bb = New-Object System.Drawing.Font 'Segoe UI Semibold', 15, ([System.Drawing.FontStyle]::Regular), ([System.Drawing.GraphicsUnit]::Pixel)
    $gb = GradientBrush ($x + 60) ($x + 450); $pe = New-Object System.Drawing.SolidBrush $peach
    SpacedText $g 'TOMMY THE BUDDY IS AN UNOFFICIAL,' $t $gb ($x + 253) ($y + 9) 3.4
    SpacedText $g 'NON-COMMERCIAL FAN MODIFICATION.' $t $gb ($x + 253) ($y + 28) 3.4
    $sf = New-Object System.Drawing.StringFormat; $sf.Alignment = 'Center'
    $lines = @(@('Built on VCCoop by Parricidium.', $bb), @('It is not affiliated with, endorsed, sponsored or approved by', $b), @('Rockstar Games or Take-Two Interactive Software, Inc.', $bb),
               @('Grand Theft Auto, Vice City and related names and logos', $b), @('are trademarks of their respective owners.', $b), @('A legally purchased copy of Grand Theft Auto: Vice City is required.', $bb))
    $yy = $y + 68
    foreach ($l in $lines) { $g.DrawString($l[0], $l[1], $pe, (New-Object System.Drawing.RectangleF $x, $yy, 507, 22), $sf); $yy += 23 }
    $dark.Dispose(); $t.Dispose(); $b.Dispose(); $bb.Dispose()
}

# 2. Fond propre (palmiers, sans encart) : fond_menu d'origine, coin bas-gauche repris du chargement d'origine
$menu = Original 'fond_menu.png'; $load = Original 'chargement1.png'
$clean = New-Object System.Drawing.Bitmap $menu; $g = [System.Drawing.Graphics]::FromImage($clean)
$g.DrawImage($load, (New-Object System.Drawing.Rectangle 0, 840, 540, 240), (New-Object System.Drawing.Rectangle 0, 840, 540, 240), [System.Drawing.GraphicsUnit]::Pixel); $g.Dispose()

# 3. Fond des menus : encart en bas a gauche
$bmp = New-Object System.Drawing.Bitmap $clean; $g = [System.Drawing.Graphics]::FromImage($bmp); Notice $g 8 852; $g.Dispose()
$bmp.Save((Join-Path $ui 'fond_menu.png'), [System.Drawing.Imaging.ImageFormat]::Png); $bmp.Dispose(); 'Ecrit : fond_menu.png'

# 4. Chargement : grand logo au centre, encart en haut a gauche
$bmp = New-Object System.Drawing.Bitmap $clean; $g = [System.Drawing.Graphics]::FromImage($bmp)
DrawLogo $g 960 330 1.9 ([System.Drawing.Brushes]::Black) (GradientBrush 760 1160)
Notice $g 15 17; $g.Dispose()
$bmp.Save((Join-Path $ui 'chargement1.png'), [System.Drawing.Imaging.ImageFormat]::Png); $bmp.Dispose(); 'Ecrit : chargement1.png'

# 5. Fermeture : panneau depoli sur l'ancien texte central, nouveau titre
$bye = Original 'fermeture.png'; $g = [System.Drawing.Graphics]::FromImage($bye); $g.SmoothingMode = 'AntiAlias'; $g.TextRenderingHint = 'AntiAliasGridFit'
$panel = RoundPath (New-Object System.Drawing.RectangleF 330, 420, 1260, 300) 26
$g.FillPath((New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 236, 234, 236))), $panel)
$ink = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(235, 30, 26, 34))
$f1 = New-Object System.Drawing.Font 'Segoe UI Light', 64, ([System.Drawing.FontStyle]::Regular), ([System.Drawing.GraphicsUnit]::Pixel)
$f2 = New-Object System.Drawing.Font 'Segoe UI', 18, ([System.Drawing.FontStyle]::Regular), ([System.Drawing.GraphicsUnit]::Pixel)
$f3 = New-Object System.Drawing.Font 'Segoe UI', 26, ([System.Drawing.FontStyle]::Regular), ([System.Drawing.GraphicsUnit]::Pixel)
SpacedText $g 'TOMMY THE BUDDY' $f1 $ink 960 452 26
$g.FillRectangle((GradientBrush 620 1300), 620, 548, 680, 3)
SpacedText $g 'HAH SHIT BRARARARAA  ·  COMONN' $f2 (GradientBrush 680 1240) 960 566 6
SpacedText $g 'TOMMY THE BUDDY IS AN UNOFFICIAL, NON-COMMERCIAL FAN MODIFICATION.' (New-Object System.Drawing.Font 'Segoe UI', 13, ([System.Drawing.FontStyle]::Regular), ([System.Drawing.GraphicsUnit]::Pixel)) $ink 960 604 3
SpacedText $g 'made with' $f3 $ink 960 632 5
# coeur
$hx = 960; $hy = 690; $h = New-Object System.Drawing.Drawing2D.GraphicsPath
$h.AddBezier($hx, $hy + 14, $hx - 34, $hy - 8, $hx - 16, $hy - 34, $hx, $hy - 16); $h.AddBezier($hx, $hy - 16, $hx + 16, $hy - 34, $hx + 34, $hy - 8, $hx, $hy + 14)
$g.FillPath((GradientBrush 930 990), $h); $g.Dispose()
$bye.Save((Join-Path $ui 'fermeture.png'), [System.Drawing.Imaging.ImageFormat]::Png); $bye.Dispose(); 'Ecrit : fermeture.png'
$menu.Dispose(); $load.Dispose(); $clean.Dispose()
