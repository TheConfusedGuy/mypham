# seed_products.ps1 - Seed categories + products with images

$BASE = "http://localhost:8080"
$IMAGES_DIR = "F:\tmdt-my-pham 2\tmdt-my-pham\images"

# 1. Login
Write-Host "[1] Logging in as admin..." -ForegroundColor Cyan
$loginBody = '{"email":"admin@mypham.local","matKhau":"admin12345"}'
$loginResp = Invoke-RestMethod -Uri "$BASE/api/auth/login" -Method POST `
    -ContentType "application/json" -Body $loginBody
$TOKEN = $loginResp.data.token
if (-not $TOKEN) { Write-Error "Login failed!"; exit 1 }
Write-Host "  OK: Got token" -ForegroundColor Green

$HEADERS = @{ Authorization = "Bearer $TOKEN" }

# 2. Upload images
Write-Host "[2] Uploading images..." -ForegroundColor Cyan

function Upload-Image {
    param([string]$filePath)
    $fileName = [System.IO.Path]::GetFileName($filePath)
    $bytes    = [System.IO.File]::ReadAllBytes($filePath)
    $boundary = [System.Guid]::NewGuid().ToString()
    $CRLF = [System.Text.Encoding]::ASCII.GetBytes("`r`n")
    
    $ms = New-Object System.IO.MemoryStream
    
    # boundary + headers
    $header = [System.Text.Encoding]::ASCII.GetBytes("--$boundary`r`nContent-Disposition: form-data; name=`"file`"; filename=`"$fileName`"`r`nContent-Type: image/jpeg`r`n`r`n")
    $ms.Write($header, 0, $header.Length)
    $ms.Write($bytes, 0, $bytes.Length)
    $footer = [System.Text.Encoding]::ASCII.GetBytes("`r`n--$boundary--`r`n")
    $ms.Write($footer, 0, $footer.Length)
    $bodyBytes = $ms.ToArray()

    $resp = Invoke-RestMethod -Uri "$BASE/api/admin/upload" -Method POST `
        -Headers $HEADERS `
        -ContentType "multipart/form-data; boundary=$boundary" `
        -Body $bodyBytes
    return $resp.data.url
}

$imageFiles = @{
    "content-pixie"    = "$IMAGES_DIR\content-pixie-ZB4eQcNqVUs-unsplash.jpg"
    "laura-chouette"   = "$IMAGES_DIR\laura-chouette-KL_SE98J4_0-unsplash.jpg"
    "mobina"           = "$IMAGES_DIR\mobina-ghazazani-lnbuoKz2GlM-unsplash.jpg"
    "mostafa"          = "$IMAGES_DIR\mostafa-mahmoudi-J4DnKxz_3sA-unsplash.jpg"
    "simona"           = "$IMAGES_DIR\simona-sergi-LhPNosJWKuE-unsplash.jpg"
    "genesis"          = "$IMAGES_DIR\genesis-warner-Fh-fnNyZbUo-unsplash.jpg"
    "personal1"        = "$IMAGES_DIR\personalgraphic-com-glY1L-eo0Fc-unsplash.jpg"
    "personal2"        = "$IMAGES_DIR\personalgraphic-com-zxPo13geJ5U-unsplash.jpg"
    "vimal"            = "$IMAGES_DIR\vimal-s-P9EY1oR7PMs-unsplash.jpg"
    "background"       = "$IMAGES_DIR\background-foto-pixell-design-wGTO-1EuXYY-unsplash.jpg"
}

$urls = @{}
foreach ($key in $imageFiles.Keys) {
    $path = $imageFiles[$key]
    Write-Host "  Uploading $key..." -NoNewline
    try {
        $url = Upload-Image $path
        $urls[$key] = $url
        Write-Host " OK: $url" -ForegroundColor Green
    } catch {
        Write-Host " FAILED: $_" -ForegroundColor Red
        $urls[$key] = $null
    }
}

# 3. Create categories
Write-Host "[3] Creating categories..." -ForegroundColor Cyan

function Create-Category {
    param([string]$name, [int]$order)
    $body = "{`"tenDanhMuc`":`"$name`",`"thuTu`":$order}"
    $resp = Invoke-RestMethod -Uri "$BASE/api/admin/categories" -Method POST `
        -Headers $HEADERS -ContentType "application/json" -Body $body
    return $resp.data.id
}

$catTuiXach = Create-Category "Tui Xach" 1
$catPhuKien = Create-Category "Phu Kien" 2
$catViCam   = Create-Category "Vi Cam Tay" 3
$catBalo    = Create-Category "Balo" 4
Write-Host "  OK: Created 4 categories (IDs: $catTuiXach, $catPhuKien, $catViCam, $catBalo)" -ForegroundColor Green

# 4. Create products
Write-Host "[4] Creating products..." -ForegroundColor Cyan

function Create-Product {
    param($ma, $ten, $gia, $loaiDa, $danhMucId, $moTa, $thuongHieu, [string[]]$hinhAnh)
    # Build JSON manually to ensure hinhAnh is always an array
    $validImgs = @($hinhAnh | Where-Object { $_ })
    $imgJsonParts = $validImgs | ForEach-Object { "`"$_`"" }
    $imgJson = "[" + ($imgJsonParts -join ",") + "]"
    
    $body = "{`"maSanPham`":`"$ma`",`"tenSanPham`":`"$ten`",`"gia`":$gia,`"loaiDa`":`"$loaiDa`",`"danhMucId`":$danhMucId,`"moTa`":`"$moTa`",`"thuongHieu`":`"$thuongHieu`",`"hinhAnh`":$imgJson}"
    $bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($body)
    $resp = Invoke-RestMethod -Uri "$BASE/api/admin/products" -Method POST `
        -Headers $HEADERS -ContentType "application/json; charset=utf-8" -Body $bodyBytes
    return $resp.data.id
}

$count = 0

# Product 1
try {
    $id = Create-Product "SP001" "Tui Xach Valentino Lock Mini" 2850000 "ALL" $catTuiXach `
        "Tui xach mini phong cach Valentino voi day xich vang sang trong. Thiet ke tinh te, phu hop ca cong so lan dao pho." `
        "Valentino Style" @($urls["content-pixie"])
    Write-Host "  OK: SP001 ID=$id" -ForegroundColor Green; $count++
} catch { Write-Host "  FAIL SP001: $_" -ForegroundColor Red }

# Product 2
try {
    $id = Create-Product "SP002" "Tui Xach Prada Cahier Mini" 3450000 "ALL" $catTuiXach `
        "Phong cach Prada Cahier dang cap voi thiet ke tui hop doc dao. Ket hop da Saffiano va da tron, logo Prada Milano noi bat." `
        "Prada Style" @($urls["laura-chouette"])
    Write-Host "  OK: SP002 ID=$id" -ForegroundColor Green; $count++
} catch { Write-Host "  FAIL SP002: $_" -ForegroundColor Red }

# Product 3
try {
    $id = Create-Product "SP003" "Tui Bowling Mini Khoa Doi" 1250000 "ALL" $catTuiXach `
        "Tui bowling mini thoi thuong voi hai khoa bac dac trung. Thiet ke nho gon nhung van du chua do thiet yeu. Day deo co the dieu chinh." `
        "MiniBag Co." @($urls["mobina"])
    Write-Host "  OK: SP003 ID=$id" -ForegroundColor Green; $count++
} catch { Write-Host "  FAIL SP003: $_" -ForegroundColor Red }

# Product 4
try {
    $id = Create-Product "SP004" "Mini Satchel Xam Khoa Vang" 980000 "ALL" $catTuiXach `
        "Tui satchel mini mau xam tro nhe nhang voi khoa vang sang trong. Hai quai cai vang o phia truoc tao diem nhan thoi trang." `
        "GrayLux" @($urls["mostafa"])
    Write-Host "  OK: SP004 ID=$id" -ForegroundColor Green; $count++
} catch { Write-Host "  FAIL SP004: $_" -ForegroundColor Red }

# Product 5
try {
    $id = Create-Product "SP005" "Tui Deo Cheo Xanh Olive" 1680000 "ALL" $catTuiXach `
        "Tui tote size lon mau xanh olive ca tinh, chat lieu da hat mem mai. Khoa co dien mau dong tao net vintage. Phu hop di lam, di choi hay di du lich." `
        "OliveLeather" @($urls["simona"])
    Write-Host "  OK: SP005 ID=$id" -ForegroundColor Green; $count++
} catch { Write-Host "  FAIL SP005: $_" -ForegroundColor Red }

# Product 6
try {
    $id = Create-Product "SP006" "Tui Top Handle Xanh Baby" 2200000 "ALL" $catTuiXach `
        "Tui top handle mau xanh baby diu dang voi chat lieu da Saffiano ben dep. Khoa xoay mau bac tinh te. Thiet ke hinh thang co dien, ket hop duoc nhieu trang phuc." `
        "BluePastel" @($urls["genesis"])
    Write-Host "  OK: SP006 ID=$id" -ForegroundColor Green; $count++
} catch { Write-Host "  FAIL SP006: $_" -ForegroundColor Red }

# Product 7
try {
    $id = Create-Product "SP007" "Vi Da Nu Nho Gon" 450000 "ALL" $catViCam `
        "Vi nho gon tien loi voi nhieu ngan dung the va tien mat. Chat lieu da PU cao cap, chong nuoc nhe. Co the dung nhu vi tien hoac cam tay di su kien." `
        "WalletPro" @($urls["personal1"])
    Write-Host "  OK: SP007 ID=$id" -ForegroundColor Green; $count++
} catch { Write-Host "  FAIL SP007: $_" -ForegroundColor Red }

# Product 8
try {
    $id = Create-Product "SP008" "Vi Cam Tay Da Tiec" 580000 "ALL" $catViCam `
        "Vi cam tay sang trong danh cho cac buoi tiec va su kien dac biet. Thiet ke nho gon nhung dung vua dien thoai, son va the. Be mat bong cao cap." `
        "EveningLux" @($urls["personal2"])
    Write-Host "  OK: SP008 ID=$id" -ForegroundColor Green; $count++
} catch { Write-Host "  FAIL SP008: $_" -ForegroundColor Red }

# Product 9
try {
    $id = Create-Product "SP009" "Tui Tote Da Bo Don Gian" 1950000 "ALL" $catTuiXach `
        "Tui tote da bo that kieu dang don gian, ben bi theo thoi gian. Dung tich lon phu hop di lam moi ngay. Co them tui nho ben trong de dung dien thoai va chia khoa." `
        "LeatherBasic" @($urls["vimal"])
    Write-Host "  OK: SP009 ID=$id" -ForegroundColor Green; $count++
} catch { Write-Host "  FAIL SP009: $_" -ForegroundColor Red }

# Product 10
try {
    $id = Create-Product "SP010" "Bo Suu Tap Tui Mua He" 3200000 "ALL" $catBalo `
        "Bo suu tap tui mua he da dang phong cach. Thiet ke tre trung, nang dong voi tong mau tuoi sang. Chat lieu vai canvas cao cap ket hop da PU, nhe nhang va ben dep." `
        "SummerCollection" @($urls["background"])
    Write-Host "  OK: SP010 ID=$id" -ForegroundColor Green; $count++
} catch { Write-Host "  FAIL SP010: $_" -ForegroundColor Red }

Write-Host ""
Write-Host "Done! Created $count/10 products." -ForegroundColor Yellow
Write-Host "Frontend: http://localhost:3000" -ForegroundColor Cyan
Write-Host "Admin:    http://localhost:3000/admin" -ForegroundColor Cyan
