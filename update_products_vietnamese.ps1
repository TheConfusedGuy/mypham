# update_products_vietnamese.ps1
# Update all products with proper Vietnamese names and descriptions

$BASE = "http://localhost:8080"

# 1. Login
$loginBody = '{"email":"admin@mypham.local","matKhau":"admin12345"}'
$loginResp = Invoke-RestMethod -Uri "$BASE/api/auth/login" -Method POST `
    -ContentType "application/json" -Body $loginBody
$TOKEN = $loginResp.data.token
if (-not $TOKEN) { Write-Error "Dang nhap that bai!"; exit 1 }
Write-Host "Dang nhap thanh cong" -ForegroundColor Green
$AUTH = "Bearer $TOKEN"

function Update-Product {
    param([int]$id, [string]$jsonBody)
    $bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($jsonBody)
    $resp = Invoke-WebRequest -Uri "$BASE/api/admin/products/$id" -Method PUT `
        -Headers @{ Authorization = $AUTH } `
        -ContentType "application/json; charset=utf-8" `
        -Body $bodyBytes
    $obj = $resp.Content | ConvertFrom-Json
    return $obj.data.tenSanPham
}

# Lay danh sach san pham hien tai de biet hinh anh URL
$prods = Invoke-RestMethod -Uri "$BASE/api/admin/products" -Headers @{ Authorization = $AUTH }
$prodMap = @{}
foreach ($p in $prods.data) { $prodMap[$p.id] = $p }

Write-Host "Cap nhat san pham voi tieng Viet co dau..." -ForegroundColor Cyan
$count = 0

# SP001 - id=1
try {
    $img = $prodMap[1].hinhAnh
    $json = [System.Text.Encoding]::UTF8.GetString([System.Text.Encoding]::UTF8.GetBytes("{""maSanPham"":""SP001"",""tenSanPham"":""Túi Xách Valentino Lock Mini"",""gia"":2850000,""loaiDa"":""ALL"",""danhMucId"":1,""moTa"":""Túi xách mini phong cách Valentino với dây xích vàng sang trọng. Thiết kế tinh tế, phù hợp cả công sở lẫn dạo phố. Chất liệu da PU cao cấp, khóa kim loại mạ vàng bền đẹp."",""thuongHieu"":""Valentino Style"",""hinhAnh"":[""$img""]}"))
    $name = Update-Product 1 $json
    Write-Host "  [1] OK: $name" -ForegroundColor Green; $count++
} catch { Write-Host "  [1] FAIL: $_" -ForegroundColor Red }

# SP002 - id=2
try {
    $img = $prodMap[2].hinhAnh
    $json = [System.Text.Encoding]::UTF8.GetString([System.Text.Encoding]::UTF8.GetBytes("{""maSanPham"":""SP002"",""tenSanPham"":""Túi Xách Prada Cahier Mini"",""gia"":3450000,""loaiDa"":""ALL"",""danhMucId"":1,""moTa"":""Phong cách Prada Cahier đẳng cấp với thiết kế túi hộp độc đáo. Kết hợp da Saffiano và da trơn, logo Prada Milano nổi bật. Có thể đeo chéo hoặc cầm tay."",""thuongHieu"":""Prada Style"",""hinhAnh"":[""$img""]}"))
    $name = Update-Product 2 $json
    Write-Host "  [2] OK: $name" -ForegroundColor Green; $count++
} catch { Write-Host "  [2] FAIL: $_" -ForegroundColor Red }

# SP003 - id=3
try {
    $img = $prodMap[3].hinhAnh
    $json = [System.Text.Encoding]::UTF8.GetString([System.Text.Encoding]::UTF8.GetBytes("{""maSanPham"":""SP003"",""tenSanPham"":""Túi Bowling Mini Khóa Đôi"",""gia"":1250000,""loaiDa"":""ALL"",""danhMucId"":1,""moTa"":""Túi bowling mini thời thượng với hai khóa bạc đặc trưng. Thiết kế nhỏ gọn nhưng vẫn đủ chứa đồ thiết yếu. Dây đeo có thể điều chỉnh độ dài linh hoạt."",""thuongHieu"":""MiniBag Co."",""hinhAnh"":[""$img""]}"))
    $name = Update-Product 3 $json
    Write-Host "  [3] OK: $name" -ForegroundColor Green; $count++
} catch { Write-Host "  [3] FAIL: $_" -ForegroundColor Red }

# SP004 - id=4
try {
    $img = $prodMap[4].hinhAnh
    $json = [System.Text.Encoding]::UTF8.GetString([System.Text.Encoding]::UTF8.GetBytes("{""maSanPham"":""SP004"",""tenSanPham"":""Mini Satchel Xám Khóa Vàng"",""gia"":980000,""loaiDa"":""ALL"",""danhMucId"":1,""moTa"":""Túi satchel mini màu xám tro nhẹ nhàng với khóa vàng sang trọng. Hai quai cài vàng ở phía trước tạo điểm nhấn thời trang. Chất liệu da hạt pebbled mềm mại, bền đẹp."",""thuongHieu"":""GrayLux"",""hinhAnh"":[""$img""]}"))
    $name = Update-Product 4 $json
    Write-Host "  [4] OK: $name" -ForegroundColor Green; $count++
} catch { Write-Host "  [4] FAIL: $_" -ForegroundColor Red }

# SP005 - id=5
try {
    $img = $prodMap[5].hinhAnh
    $json = [System.Text.Encoding]::UTF8.GetString([System.Text.Encoding]::UTF8.GetBytes("{""maSanPham"":""SP005"",""tenSanPham"":""Túi Đeo Chéo Xanh Olive"",""gia"":1680000,""loaiDa"":""ALL"",""danhMucId"":1,""moTa"":""Túi tote size lớn màu xanh olive cá tính, chất liệu da hạt mềm mại. Khóa cổ điển màu đồng tạo nét vintage thanh lịch. Phù hợp đi làm, đi chơi hay đi du lịch ngắn ngày."",""thuongHieu"":""OliveLeather"",""hinhAnh"":[""$img""]}"))
    $name = Update-Product 5 $json
    Write-Host "  [5] OK: $name" -ForegroundColor Green; $count++
} catch { Write-Host "  [5] FAIL: $_" -ForegroundColor Red }

# SP006 - id=6
try {
    $img = $prodMap[6].hinhAnh
    $json = [System.Text.Encoding]::UTF8.GetString([System.Text.Encoding]::UTF8.GetBytes("{""maSanPham"":""SP006"",""tenSanPham"":""Túi Top Handle Xanh Baby"",""gia"":2200000,""loaiDa"":""ALL"",""danhMucId"":1,""moTa"":""Túi top handle màu xanh baby dịu dàng với chất liệu da Saffiano bền đẹp. Khóa xoay màu bạc tinh tế. Thiết kế hình thang cổ điển, dễ kết hợp với nhiều trang phục khác nhau."",""thuongHieu"":""BluePastel"",""hinhAnh"":[""$img""]}"))
    $name = Update-Product 6 $json
    Write-Host "  [6] OK: $name" -ForegroundColor Green; $count++
} catch { Write-Host "  [6] FAIL: $_" -ForegroundColor Red }

# SP007 - id=7
try {
    $img = $prodMap[7].hinhAnh
    $json = [System.Text.Encoding]::UTF8.GetString([System.Text.Encoding]::UTF8.GetBytes("{""maSanPham"":""SP007"",""tenSanPham"":""Ví Da Nữ Nhỏ Gọn"",""gia"":450000,""loaiDa"":""ALL"",""danhMucId"":3,""moTa"":""Ví nhỏ gọn tiện lợi với nhiều ngăn đựng thẻ và tiền mặt. Chất liệu da PU cao cấp, chống nước nhẹ. Có thể dùng như ví tiền hoặc cầm tay đi sự kiện sang trọng."",""thuongHieu"":""WalletPro"",""hinhAnh"":[""$img""]}"))
    $name = Update-Product 7 $json
    Write-Host "  [7] OK: $name" -ForegroundColor Green; $count++
} catch { Write-Host "  [7] FAIL: $_" -ForegroundColor Red }

# SP008 - id=8
try {
    $img = $prodMap[8].hinhAnh
    $json = [System.Text.Encoding]::UTF8.GetString([System.Text.Encoding]::UTF8.GetBytes("{""maSanPham"":""SP008"",""tenSanPham"":""Ví Cầm Tay Dạ Tiệc"",""gia"":580000,""loaiDa"":""ALL"",""danhMucId"":3,""moTa"":""Ví cầm tay sang trọng dành cho các buổi tiệc và sự kiện đặc biệt. Thiết kế nhỏ gọn nhưng đựng vừa điện thoại, son và thẻ. Bề mặt bóng cao cấp, tôn lên vẻ đẹp thanh lịch."",""thuongHieu"":""EveningLux"",""hinhAnh"":[""$img""]}"))
    $name = Update-Product 8 $json
    Write-Host "  [8] OK: $name" -ForegroundColor Green; $count++
} catch { Write-Host "  [8] FAIL: $_" -ForegroundColor Red }

# SP009 - id=9
try {
    $img = $prodMap[9].hinhAnh
    $json = [System.Text.Encoding]::UTF8.GetString([System.Text.Encoding]::UTF8.GetBytes("{""maSanPham"":""SP009"",""tenSanPham"":""Túi Tote Da Bò Đơn Giản"",""gia"":1950000,""loaiDa"":""ALL"",""danhMucId"":1,""moTa"":""Túi tote da bò thật kiểu dáng đơn giản, bền bỉ theo thời gian. Dung tích lớn phù hợp đi làm mỗi ngày. Có thêm túi nhỏ bên trong để đựng điện thoại và chìa khóa."",""thuongHieu"":""LeatherBasic"",""hinhAnh"":[""$img""]}"))
    $name = Update-Product 9 $json
    Write-Host "  [9] OK: $name" -ForegroundColor Green; $count++
} catch { Write-Host "  [9] FAIL: $_" -ForegroundColor Red }

# SP010 - id=10
try {
    $img = $prodMap[10].hinhAnh
    $json = [System.Text.Encoding]::UTF8.GetString([System.Text.Encoding]::UTF8.GetBytes("{""maSanPham"":""SP010"",""tenSanPham"":""Bộ Sưu Tập Túi Mùa Hè"",""gia"":3200000,""loaiDa"":""ALL"",""danhMucId"":4,""moTa"":""Bộ sưu tập túi mùa hè đa dạng phong cách. Thiết kế trẻ trung, năng động với tông màu tươi sáng. Chất liệu vải canvas cao cấp kết hợp da PU, nhẹ nhàng và bền đẹp, lý tưởng cho mùa hè."",""thuongHieu"":""SummerCollection"",""hinhAnh"":[""$img""]}"))
    $name = Update-Product 10 $json
    Write-Host "  [10] OK: $name" -ForegroundColor Green; $count++
} catch { Write-Host "  [10] FAIL: $_" -ForegroundColor Red }

# Cập nhật tên danh mục
Write-Host "" 
Write-Host "Cap nhat ten danh muc..." -ForegroundColor Cyan

function Update-Category {
    param([int]$id, [string]$jsonBody)
    $bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($jsonBody)
    $resp = Invoke-WebRequest -Uri "$BASE/api/admin/categories/$id" -Method PUT `
        -Headers @{ Authorization = $AUTH } `
        -ContentType "application/json; charset=utf-8" `
        -Body $bodyBytes
    $obj = $resp.Content | ConvertFrom-Json
    return $obj.data.tenDanhMuc
}

try {
    $n = Update-Category 1 ([System.Text.Encoding]::UTF8.GetString([System.Text.Encoding]::UTF8.GetBytes("{""tenDanhMuc"":""Túi Xách"",""thuTu"":1}")))
    Write-Host "  Cat 1: $n" -ForegroundColor Green
} catch { Write-Host "  Cat 1 FAIL: $_" -ForegroundColor Red }

try {
    $n = Update-Category 2 ([System.Text.Encoding]::UTF8.GetString([System.Text.Encoding]::UTF8.GetBytes("{""tenDanhMuc"":""Phụ Kiện"",""thuTu"":2}")))
    Write-Host "  Cat 2: $n" -ForegroundColor Green
} catch { Write-Host "  Cat 2 FAIL: $_" -ForegroundColor Red }

try {
    $n = Update-Category 3 ([System.Text.Encoding]::UTF8.GetString([System.Text.Encoding]::UTF8.GetBytes("{""tenDanhMuc"":""Ví & Cầm Tay"",""thuTu"":3}")))
    Write-Host "  Cat 3: $n" -ForegroundColor Green
} catch { Write-Host "  Cat 3 FAIL: $_" -ForegroundColor Red }

try {
    $n = Update-Category 4 ([System.Text.Encoding]::UTF8.GetString([System.Text.Encoding]::UTF8.GetBytes("{""tenDanhMuc"":""Balo"",""thuTu"":4}")))
    Write-Host "  Cat 4: $n" -ForegroundColor Green
} catch { Write-Host "  Cat 4 FAIL: $_" -ForegroundColor Red }

Write-Host ""
Write-Host "Hoan thanh! Da cap nhat $count/10 san pham voi tieng Viet co dau." -ForegroundColor Yellow
