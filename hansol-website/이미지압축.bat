@echo off
chcp 65001 > nul
echo ============================================
echo  이미지 자동 압축 도구
echo  images 폴더 안의 jpg 파일을 압축합니다
echo ============================================
echo.

:: PowerShell로 이미지 압축 실행
powershell -ExecutionPolicy Bypass -Command "
Add-Type -AssemblyName System.Drawing

$folders = @('rooftop', 'parking', 'preaction', 'other')
$quality  = 75   # 압축 품질 (0~100, 낮을수록 작아짐)
$maxWidth = 1920 # 최대 가로 픽셀

$encoder = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() |
           Where-Object { $_.MimeType -eq 'image/jpeg' }
$params  = New-Object System.Drawing.Imaging.EncoderParameters(1)
$params.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter(
    [System.Drawing.Imaging.Encoder]::Quality, [long]$quality)

foreach ($folder in $folders) {
    $path = Join-Path (Split-Path -Parent $MyInvocation.ScriptName) 'images' $folder
    if (-not (Test-Path $path)) { continue }

    $files = Get-ChildItem $path -Filter '*.jpg'
    Write-Host \"[$folder] $($files.Count)개 처리 중...\"

    foreach ($file in $files) {
        try {
            $img = [System.Drawing.Image]::FromFile($file.FullName)

            # 가로가 maxWidth 초과하면 축소
            if ($img.Width -gt $maxWidth) {
                $ratio  = $maxWidth / $img.Width
                $newW   = $maxWidth
                $newH   = [int]($img.Height * $ratio)
                $bmp    = New-Object System.Drawing.Bitmap($newW, $newH)
                $g      = [System.Drawing.Graphics]::FromImage($bmp)
                $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
                $g.DrawImage($img, 0, 0, $newW, $newH)
                $g.Dispose()
                $img.Dispose()
                $img = $bmp
            }

            $tmpPath = $file.FullName + '.tmp'
            $img.Save($tmpPath, $encoder, $params)
            $img.Dispose()

            Remove-Item $file.FullName -Force
            Rename-Item $tmpPath $file.FullName
            Write-Host \"  OK: $($file.Name)\"
        } catch {
            Write-Host \"  오류: $($file.Name) - $_\"
        }
    }
}

Write-Host ''
Write-Host '압축 완료!'
"

echo.
echo 완료되었습니다. 아무 키나 누르면 닫힙니다.
pause > nul
