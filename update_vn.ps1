# update_vn.ps1 - Use here-strings saved as UTF-8 files to bypass encoding issues

$BASE = "http://localhost:8080"

# Login
$loginBody = '{"email":"admin@mypham.local","matKhau":"admin12345"}'
$loginResp = Invoke-RestMethod -Uri "$BASE/api/auth/login" -Method POST `
    -ContentType "application/json" -Body $loginBody
$TOKEN = $loginResp.data.token
Write-Host "Login OK" -ForegroundColor Green
$AUTH = "Bearer $TOKEN"

# Get current products to preserve image URLs
$prodResp = Invoke-RestMethod -Uri "$BASE/api/admin/products" -Headers @{ Authorization = $AUTH }
$prodMap = @{}
foreach ($p in $prodResp.data) { $prodMap[[int]$p.id] = $p.hinhAnh }

function Update-Product {
    param([int]$id, [hashtable]$data)
    $img = $prodMap[$id]
    $data.hinhAnh = @($img)
    $json = $data | ConvertTo-Json -Compress
    $bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($json)
    $resp = Invoke-WebRequest -Uri "$BASE/api/admin/products/$id" -Method PUT `
        -Headers @{ Authorization = $AUTH } `
        -ContentType "application/json; charset=utf-8" `
        -Body $bodyBytes
    $obj = $resp.Content | ConvertFrom-Json
    return $obj.data.tenSanPham
}

function Update-Category {
    param([int]$id, [hashtable]$data)
    $json = $data | ConvertTo-Json -Compress
    $bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($json)
    $resp = Invoke-WebRequest -Uri "$BASE/api/admin/categories/$id" -Method PUT `
        -Headers @{ Authorization = $AUTH } `
        -ContentType "application/json; charset=utf-8" `
        -Body $bodyBytes
    $obj = $resp.Content | ConvertFrom-Json
    return $obj.data.tenDanhMuc
}

$count = 0
Write-Host "Cap nhat san pham..." -ForegroundColor Cyan

$products = @(
    @{ id=1;  maSanPham="SP001"; tenSanPham="T├ói X├ích Valentino Lock Mini"; gia=2850000; loaiDa="ALL"; danhMucId=1; thuongHieu="Valentino Style"; moTa="T├ói x├ích mini phong c├ích Valentino v╞ói d├óy x├│ch v├áng sang tr╗ìng. Thi╗┐t k╗┐ tinh t╗┐, ph├╣ h╞íp c╒g c├┤ng s╒í l╒ín d╒ío ph╒í. Ch╒ót li╒íu da PU cao c╒óp, kh├│a kim lo╒íi m╒í v├áng b╒ín ╒í╒íp." },
    @{ id=2;  maSanPham="SP002"; tenSanPham="T├ói X├ích Prada Cahier Mini"; gia=3450000; loaiDa="ALL"; danhMucId=1; thuongHieu="Prada Style"; moTa="Phong c├ích Prada Cahier ╒í╒ìng c╒óp v╞ói thi╒┐t k╒┐ t├╣i h╒íp ╒í╒íc ╒í├óo. K╒┐t h╒íp da Saffiano v├á da tr╔n, logo Prada Milano n╒íi b╒ót. C├│ th╒í ╒í╒ío ch├ío ho╒íc c╒óm tay." },
    @{ id=3;  maSanPham="SP003"; tenSanPham="T├ói Bowling Mini Kh├│a ╒û├┤i"; gia=1250000; loaiDa="ALL"; danhMucId=1; thuongHieu="MiniBag Co."; moTa="T├ói bowling mini th╒íi th╞í╞íng v╞ói hai kh├│a b╒íc ╒í╒íc tr╞íng. Thi╒┐t k╒┐ nh╒í g╒ín nh╞íng v╒ón ╒í╒ö ch╞íc ╒í╒ö thi╒┐t y╒┐u. D├óy ╒í╒ío c├│ th╒í ╒íi╒öu ch╒ónh ╒í╒í d├íi linh ho╒ít." },
    @{ id=4;  maSanPham="SP004"; tenSanPham="Mini Satchel X├óm Kh├│a V├áng"; gia=980000; loaiDa="ALL"; danhMucId=1; thuongHieu="GrayLux"; moTa="T├ói satchel mini m├áu x├óm tro nh╒┐ nh├áng v╞ói kh├│a v├áng sang tr╒ìng. Hai quai c├íi v├áng ╒í ph├ía tr╞í╞íc t╒ío ╒íi╒ím nh╒ón th╒íi trang. Ch╒ót li╒íu da h╒ít pebbled m╒öm m╒íi, b╒ón ╒í╒íp." },
    @{ id=5;  maSanPham="SP005"; tenSanPham="T├ói ╒û╒ío Ch├ío Xanh Olive"; gia=1680000; loaiDa="ALL"; danhMucId=1; thuongHieu="OliveLeather"; moTa="T├ói tote size l╞ín m├áu xanh olive c├í t├ính, ch╒ót li╒íu da h╒ít m╒öm m╒íi. Kh├│a c╒í ╒íi╒ín m├áu ╒í╒öng t╒ío n├ít vintage thanh l╒ịch. Ph├╣ h╒íp ╒íi l├ím, ╒íi ch╔i hay ╒íi du l╒ịch ng╒ón ng├íy." },
    @{ id=6;  maSanPham="SP006"; tenSanPham="T├ói Top Handle Xanh Baby"; gia=2200000; loaiDa="ALL"; danhMucId=1; thuongHieu="BluePastel"; moTa="T├ói top handle m├áu xanh baby d╒ịu d├áng v╞ói ch╒ót li╒íu da Saffiano b╒ón ╒í╒íp. Kh├│a xoay m├áu b╒íc tinh t╒┐. Thi╒┐t k╒┐ h├ình thang c╒í ╒íi╒ín, d╒ö k╒┐t h╒íp v╞ói nhi╒öu trang ph╒íc kh├ích nhau." },
    @{ id=7;  maSanPham="SP007"; tenSanPham="V├í Da N╒ö Nh╒í G╒ín"; gia=450000; loaiDa="ALL"; danhMucId=3; thuongHieu="WalletPro"; moTa="V├í nh╒í g╒ín ti╒ín l╒íi v╞ói nhi╒öu ng╒ón ╒í╒íng th╒┐ v├á ti╒ön m╒ót. Ch╒ót li╒íu da PU cao c╒óp, ch╒íng n╞í╞íc nh╒┐. C├│ th╒í d├╣ng nh╞í v├í ti╒ön ho╒íc c╒óm tay ╒íi s╒í ki╒ín sang tr╒ìng." },
    @{ id=8;  maSanPham="SP008"; tenSanPham="V├í C╒óm Tay D╒í Ti╒íc"; gia=580000; loaiDa="ALL"; danhMucId=3; thuongHieu="EveningLux"; moTa="V├í c╒óm tay sang tr╒ìng d├ánh cho c├íc bu╒íi ti╒íc v├á s╒í ki╒ín ╒í╒íc bi╒ít. Thi╒┐t k╒┐ nh╒í g╒ín nh╞íng ╒í╒íng v╒ía ╒íi╒ín tho╒íi, son v├á th╒┐. B╒ö m╒ót b├│ng cao c╒óp, t├┤n l├ön v╒┐ ╒í╒íp thanh l╒ịch." },
    @{ id=9;  maSanPham="SP009"; tenSanPham="T├ói Tote Da B├▓ ╒û╔n Gi╒ón"; gia=1950000; loaiDa="ALL"; danhMucId=1; thuongHieu="LeatherBasic"; moTa="T├ói tote da b├▓ th╒ót ki╒íu d├óng ╒í╔n gi╒ón, b╒ón b╒ó theo th╒íi gian. Dung t├ích l╞ín ph├╣ h╒íp ╒íi l├ím m╒íi ng├íy. C├│ th├óm t├ói nh╒í b├ón trong ╒í╒í ╒í╒íng ╒íi╒ín tho╒íi v├á ch├ía kh├│a." },
    @{ id=10; maSanPham="SP010"; tenSanPham="B╒í S╞íu T╒óp T├ói M├╣a H├¿"; gia=3200000; loaiDa="ALL"; danhMucId=4; thuongHieu="SummerCollection"; moTa="B╒í s╞íu t╒óp t├ói m├╣a h├¿ ╒ía d╒íng phong c├ích. Thi╒┐t k╒┐ tr╒┐ trung, n╒öng ╒í╒íng v╞ói t├┤ng m├áu t╞í╔i s├íng. Ch╒ót li╒íu v╒íi canvas cao c╒óp k╒┐t h╒íp da PU, nh╒┐ nh├áng v├á b╒ón ╒í╒íp cho m├╣a h├¿." }
)

foreach ($p in $products) {
    $id = $p.id
    $p.Remove("id")
    try {
        $name = Update-Product $id $p
        Write-Host "  [$id] OK: $name" -ForegroundColor Green
        $count++
    } catch {
        Write-Host "  [$id] FAIL: $_" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Cap nhat danh muc..." -ForegroundColor Cyan

$cats = @(
    @{ id=1; tenDanhMuc="T├ói X├ích"; thuTu=1 },
    @{ id=2; tenDanhMuc="Ph├╣ Ki╒ín"; thuTu=2 },
    @{ id=3; tenDanhMuc="V├í " + [char]0x0026 + " C╒óm Tay"; thuTu=3 },
    @{ id=4; tenDanhMuc="Balo"; thuTu=4 }
)

foreach ($c in $cats) {
    $id = $c.id
    $c.Remove("id")
    try {
        $name = Update-Category $id $c
        Write-Host "  Cat[$id] OK: $name" -ForegroundColor Green
    } catch {
        Write-Host "  Cat[$id] FAIL: $_" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Hoan thanh! $count/10 san pham da cap nhat." -ForegroundColor Yellow
