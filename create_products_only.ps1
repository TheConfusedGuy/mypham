# create_products_only.ps1
# Images already uploaded. Categories already created with IDs 1-4.
# Just create the 10 products.

$BASE = "http://localhost:8080"

# 1. Login
$loginBody = '{"email":"admin@mypham.local","matKhau":"admin12345"}'
$loginResp = Invoke-RestMethod -Uri "$BASE/api/auth/login" -Method POST `
    -ContentType "application/json" -Body $loginBody
$TOKEN = $loginResp.data.token
if (-not $TOKEN) { Write-Error "Login failed!"; exit 1 }
Write-Host "Logged in OK" -ForegroundColor Green
$AUTH = "Bearer $TOKEN"

# Re-upload images to get fresh URLs (or use previously uploaded ones)
function Upload-Image {
    param([string]$filePath)
    $fileName = [System.IO.Path]::GetFileName($filePath)
    $bytes = [System.IO.File]::ReadAllBytes($filePath)
    $boundary = [System.Guid]::NewGuid().ToString()
    $ms = New-Object System.IO.MemoryStream
    $header = [System.Text.Encoding]::ASCII.GetBytes("--$boundary`r`nContent-Disposition: form-data; name=`"file`"; filename=`"$fileName`"`r`nContent-Type: image/jpeg`r`n`r`n")
    $ms.Write($header, 0, $header.Length)
    $ms.Write($bytes, 0, $bytes.Length)
    $footer = [System.Text.Encoding]::ASCII.GetBytes("`r`n--$boundary--`r`n")
    $ms.Write($footer, 0, $footer.Length)
    $bodyBytes = $ms.ToArray()
    $resp = Invoke-WebRequest -Uri "$BASE/api/admin/upload" -Method POST `
        -Headers @{ Authorization = $AUTH } `
        -ContentType "multipart/form-data; boundary=$boundary" `
        -Body $bodyBytes
    $json = $resp.Content | ConvertFrom-Json
    return $json.data.url
}

$IMAGES = "F:\tmdt-my-pham 2\tmdt-my-pham\images"

Write-Host "Uploading images..." -ForegroundColor Cyan
$u1  = Upload-Image "$IMAGES\content-pixie-ZB4eQcNqVUs-unsplash.jpg"
Write-Host "  u1=$u1"
$u2  = Upload-Image "$IMAGES\laura-chouette-KL_SE98J4_0-unsplash.jpg"
Write-Host "  u2=$u2"
$u3  = Upload-Image "$IMAGES\mobina-ghazazani-lnbuoKz2GlM-unsplash.jpg"
Write-Host "  u3=$u3"
$u4  = Upload-Image "$IMAGES\mostafa-mahmoudi-J4DnKxz_3sA-unsplash.jpg"
Write-Host "  u4=$u4"
$u5  = Upload-Image "$IMAGES\simona-sergi-LhPNosJWKuE-unsplash.jpg"
Write-Host "  u5=$u5"
$u6  = Upload-Image "$IMAGES\genesis-warner-Fh-fnNyZbUo-unsplash.jpg"
Write-Host "  u6=$u6"
$u7  = Upload-Image "$IMAGES\personalgraphic-com-glY1L-eo0Fc-unsplash.jpg"
Write-Host "  u7=$u7"
$u8  = Upload-Image "$IMAGES\personalgraphic-com-zxPo13geJ5U-unsplash.jpg"
Write-Host "  u8=$u8"
$u9  = Upload-Image "$IMAGES\vimal-s-P9EY1oR7PMs-unsplash.jpg"
Write-Host "  u9=$u9"
$u10 = Upload-Image "$IMAGES\background-foto-pixell-design-wGTO-1EuXYY-unsplash.jpg"
Write-Host "  u10=$u10"

# Category IDs from previous run
$catTuiXach = 1
$catViCam   = 3
$catBalo    = 4

function Post-Product {
    param([string]$json)
    $bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($json)
    $resp = Invoke-WebRequest -Uri "$BASE/api/admin/products" -Method POST `
        -Headers @{ Authorization = $AUTH } `
        -ContentType "application/json; charset=utf-8" `
        -Body $bodyBytes
    $obj = $resp.Content | ConvertFrom-Json
    return $obj.data.id
}

Write-Host "Creating products..." -ForegroundColor Cyan
$count = 0

# SP001
try {
    $j = "{`"maSanPham`":`"SP001`",`"tenSanPham`":`"Tui Xach Valentino Lock Mini`",`"gia`":2850000,`"loaiDa`":`"ALL`",`"danhMucId`":$catTuiXach,`"moTa`":`"Tui xach mini phong cach Valentino voi day xich vang sang trong. Thiet ke tinh te, phu hop ca cong so lan dao pho.`",`"thuongHieu`":`"Valentino Style`",`"hinhAnh`":[`"$u1`"]}"
    $id = Post-Product $j
    Write-Host "  SP001 OK id=$id" -ForegroundColor Green; $count++
} catch { Write-Host "  SP001 FAIL: $_" -ForegroundColor Red }

# SP002
try {
    $j = "{`"maSanPham`":`"SP002`",`"tenSanPham`":`"Tui Xach Prada Cahier Mini`",`"gia`":3450000,`"loaiDa`":`"ALL`",`"danhMucId`":$catTuiXach,`"moTa`":`"Phong cach Prada Cahier dang cap voi thiet ke tui hop doc dao. Ket hop da Saffiano va da tron, logo Prada Milano noi bat.`",`"thuongHieu`":`"Prada Style`",`"hinhAnh`":[`"$u2`"]}"
    $id = Post-Product $j
    Write-Host "  SP002 OK id=$id" -ForegroundColor Green; $count++
} catch { Write-Host "  SP002 FAIL: $_" -ForegroundColor Red }

# SP003
try {
    $j = "{`"maSanPham`":`"SP003`",`"tenSanPham`":`"Tui Bowling Mini Khoa Doi`",`"gia`":1250000,`"loaiDa`":`"ALL`",`"danhMucId`":$catTuiXach,`"moTa`":`"Tui bowling mini thoi thuong voi hai khoa bac dac trung. Thiet ke nho gon nhung van du chua do thiet yeu. Day deo co the dieu chinh.`",`"thuongHieu`":`"MiniBag Co.`",`"hinhAnh`":[`"$u3`"]}"
    $id = Post-Product $j
    Write-Host "  SP003 OK id=$id" -ForegroundColor Green; $count++
} catch { Write-Host "  SP003 FAIL: $_" -ForegroundColor Red }

# SP004
try {
    $j = "{`"maSanPham`":`"SP004`",`"tenSanPham`":`"Mini Satchel Xam Khoa Vang`",`"gia`":980000,`"loaiDa`":`"ALL`",`"danhMucId`":$catTuiXach,`"moTa`":`"Tui satchel mini mau xam tro nhe nhang voi khoa vang sang trong. Hai quai cai vang o phia truoc tao diem nhan thoi trang.`",`"thuongHieu`":`"GrayLux`",`"hinhAnh`":[`"$u4`"]}"
    $id = Post-Product $j
    Write-Host "  SP004 OK id=$id" -ForegroundColor Green; $count++
} catch { Write-Host "  SP004 FAIL: $_" -ForegroundColor Red }

# SP005
try {
    $j = "{`"maSanPham`":`"SP005`",`"tenSanPham`":`"Tui Deo Cheo Xanh Olive`",`"gia`":1680000,`"loaiDa`":`"ALL`",`"danhMucId`":$catTuiXach,`"moTa`":`"Tui tote size lon mau xanh olive ca tinh, chat lieu da hat mem mai. Khoa co dien mau dong tao net vintage. Phu hop di lam, di choi hay du lich.`",`"thuongHieu`":`"OliveLeather`",`"hinhAnh`":[`"$u5`"]}"
    $id = Post-Product $j
    Write-Host "  SP005 OK id=$id" -ForegroundColor Green; $count++
} catch { Write-Host "  SP005 FAIL: $_" -ForegroundColor Red }

# SP006
try {
    $j = "{`"maSanPham`":`"SP006`",`"tenSanPham`":`"Tui Top Handle Xanh Baby`",`"gia`":2200000,`"loaiDa`":`"ALL`",`"danhMucId`":$catTuiXach,`"moTa`":`"Tui top handle mau xanh baby diu dang voi chat lieu da Saffiano ben dep. Khoa xoay mau bac tinh te. Thiet ke hinh thang co dien.`",`"thuongHieu`":`"BluePastel`",`"hinhAnh`":[`"$u6`"]}"
    $id = Post-Product $j
    Write-Host "  SP006 OK id=$id" -ForegroundColor Green; $count++
} catch { Write-Host "  SP006 FAIL: $_" -ForegroundColor Red }

# SP007
try {
    $j = "{`"maSanPham`":`"SP007`",`"tenSanPham`":`"Vi Da Nu Nho Gon`",`"gia`":450000,`"loaiDa`":`"ALL`",`"danhMucId`":$catViCam,`"moTa`":`"Vi nho gon tien loi voi nhieu ngan dung the va tien mat. Chat lieu da PU cao cap, chong nuoc nhe.`",`"thuongHieu`":`"WalletPro`",`"hinhAnh`":[`"$u7`"]}"
    $id = Post-Product $j
    Write-Host "  SP007 OK id=$id" -ForegroundColor Green; $count++
} catch { Write-Host "  SP007 FAIL: $_" -ForegroundColor Red }

# SP008
try {
    $j = "{`"maSanPham`":`"SP008`",`"tenSanPham`":`"Vi Cam Tay Da Tiec`",`"gia`":580000,`"loaiDa`":`"ALL`",`"danhMucId`":$catViCam,`"moTa`":`"Vi cam tay sang trong danh cho cac buoi tiec va su kien dac biet. Be mat bong cao cap, co the cam tay hoac deo vai.`",`"thuongHieu`":`"EveningLux`",`"hinhAnh`":[`"$u8`"]}"
    $id = Post-Product $j
    Write-Host "  SP008 OK id=$id" -ForegroundColor Green; $count++
} catch { Write-Host "  SP008 FAIL: $_" -ForegroundColor Red }

# SP009
try {
    $j = "{`"maSanPham`":`"SP009`",`"tenSanPham`":`"Tui Tote Da Bo Don Gian`",`"gia`":1950000,`"loaiDa`":`"ALL`",`"danhMucId`":$catTuiXach,`"moTa`":`"Tui tote da bo that kieu dang don gian, ben bi theo thoi gian. Dung tich lon phu hop di lam moi ngay.`",`"thuongHieu`":`"LeatherBasic`",`"hinhAnh`":[`"$u9`"]}"
    $id = Post-Product $j
    Write-Host "  SP009 OK id=$id" -ForegroundColor Green; $count++
} catch { Write-Host "  SP009 FAIL: $_" -ForegroundColor Red }

# SP010
try {
    $j = "{`"maSanPham`":`"SP010`",`"tenSanPham`":`"Bo Suu Tap Tui Mua He`",`"gia`":3200000,`"loaiDa`":`"ALL`",`"danhMucId`":$catBalo,`"moTa`":`"Bo suu tap tui mua he da dang phong cach. Thiet ke tre trung, nang dong voi tong mau tuoi sang. Chat lieu vai canvas cao cap.`",`"thuongHieu`":`"SummerCollection`",`"hinhAnh`":[`"$u10`"]}"
    $id = Post-Product $j
    Write-Host "  SP010 OK id=$id" -ForegroundColor Green; $count++
} catch { Write-Host "  SP010 FAIL: $_" -ForegroundColor Red }

Write-Host ""
Write-Host "Created $count/10 products!" -ForegroundColor Yellow
