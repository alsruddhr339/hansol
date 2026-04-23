Add-Type -AssemblyName System.Drawing

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$folders   = @('rooftop', 'parking', 'preaction', 'other')
$quality   = 75
$maxWidth  = 1920

$encoder = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() |
           Where-Object { $_.MimeType -eq 'image/jpeg' }
$params  = New-Object System.Drawing.Imaging.EncoderParameters(1)
$params.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter(
    [System.Drawing.Imaging.Encoder]::Quality, [long]$quality)

foreach ($folder in $folders) {
    $path = Join-Path $scriptDir "images\$folder"
    if (-not (Test-Path $path)) { continue }

    $files = Get-ChildItem $path -Filter '*.jpg'
    Write-Host "[$folder] $($files.Count)개 처리 중..." -ForegroundColor Cyan

    foreach ($file in $files) {
        try {
            $img = [System.Drawing.Image]::FromFile($file.FullName)

            if ($img.Width -gt $maxWidth) {
                $ratio = $maxWidth / $img.Width
                $newW  = $maxWidth
                $newH  = [int]($img.Height * $ratio)
                $bmp   = New-Object System.Drawing.Bitmap($newW, $newH)
                $g     = [System.Drawing.Graphics]::FromImage($bmp)
                $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
                $g.DrawImage($img, 0, 0, $newW, $newH)
                $g.Dispose()
                $img.Dispose()
                $img = $bmp
            }

            $tmp = $file.FullName + '.tmp'
            $img.Save($tmp, $encoder, $params)
            $img.Dispose()

            Remove-Item $file.FullName -Force
            Rename-Item $tmp $file.FullName
            Write-Host "  OK: $($file.Name)" -ForegroundColor Green
        } catch {
            Write-Host "  오류: $($file.Name)" -ForegroundColor Red
        }
    }
}

Write-Host ""
Write-Host "압축 완료!" -ForegroundColor Yellow
Write-Host "아무 키나 누르면 닫힙니다..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
