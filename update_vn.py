# -*- coding: utf-8 -*-
import urllib.request
import urllib.error
import json
import sys
sys.stdout.reconfigure(encoding='utf-8')

BASE = "http://localhost:8080"

# 1. Login
login_data = json.dumps({"email": "admin@mypham.local", "matKhau": "admin12345"}).encode("utf-8")
req = urllib.request.Request(f"{BASE}/api/auth/login", data=login_data,
                              headers={"Content-Type": "application/json"}, method="POST")
with urllib.request.urlopen(req) as r:
    resp = json.loads(r.read())
TOKEN = resp["data"]["token"]
print(f"Login OK, token={TOKEN[:20]}...")
HEADERS = {"Authorization": f"Bearer {TOKEN}", "Content-Type": "application/json; charset=utf-8"}

# 2. Get existing products (to preserve image URLs)
req = urllib.request.Request(f"{BASE}/api/admin/products", headers=HEADERS)
with urllib.request.urlopen(req) as r:
    prod_resp = json.loads(r.read())
img_map = {p["id"]: p["hinhAnh"] for p in prod_resp["data"]}
print(f"Got {len(img_map)} products")

# 3. Product data in proper Vietnamese
products = [
    {"id": 1,  "maSanPham": "SP001", "tenSanPham": "Túi Xách Valentino Lock Mini", "gia": 2850000,
     "loaiDa": "ALL", "danhMucId": 1, "thuongHieu": "Valentino Style",
     "moTa": "Túi xách mini phong cách Valentino với dây xích vàng sang trọng. Thiết kế tinh tế, phù hợp cả công sở lẫn dạo phố. Chất liệu da PU cao cấp, khóa kim loại mạ vàng bền đẹp."},
    {"id": 2,  "maSanPham": "SP002", "tenSanPham": "Túi Xách Prada Cahier Mini", "gia": 3450000,
     "loaiDa": "ALL", "danhMucId": 1, "thuongHieu": "Prada Style",
     "moTa": "Phong cách Prada Cahier đẳng cấp với thiết kế túi hộp độc đáo. Kết hợp da Saffiano và da trơn, logo Prada Milano nổi bật. Có thể đeo chéo hoặc cầm tay tùy thích."},
    {"id": 3,  "maSanPham": "SP003", "tenSanPham": "Túi Bowling Mini Khóa Đôi", "gia": 1250000,
     "loaiDa": "ALL", "danhMucId": 1, "thuongHieu": "MiniBag Co.",
     "moTa": "Túi bowling mini thời thượng với hai khóa bạc đặc trưng. Thiết kế nhỏ gọn nhưng vẫn đủ chứa đồ thiết yếu. Dây đeo có thể điều chỉnh độ dài linh hoạt theo nhu cầu."},
    {"id": 4,  "maSanPham": "SP004", "tenSanPham": "Mini Satchel Xám Khóa Vàng", "gia": 980000,
     "loaiDa": "ALL", "danhMucId": 1, "thuongHieu": "GrayLux",
     "moTa": "Túi satchel mini màu xám tro nhẹ nhàng với khóa vàng sang trọng. Hai quai cài vàng ở phía trước tạo điểm nhấn thời trang. Chất liệu da hạt pebbled mềm mại, bền đẹp theo năm tháng."},
    {"id": 5,  "maSanPham": "SP005", "tenSanPham": "Túi Đeo Chéo Xanh Olive", "gia": 1680000,
     "loaiDa": "ALL", "danhMucId": 1, "thuongHieu": "OliveLeather",
     "moTa": "Túi tote size lớn màu xanh olive cá tính, chất liệu da hạt mềm mại. Khóa cổ điển màu đồng tạo nét vintage thanh lịch. Phù hợp đi làm, đi chơi hay đi du lịch ngắn ngày."},
    {"id": 6,  "maSanPham": "SP006", "tenSanPham": "Túi Top Handle Xanh Baby", "gia": 2200000,
     "loaiDa": "ALL", "danhMucId": 1, "thuongHieu": "BluePastel",
     "moTa": "Túi top handle màu xanh baby dịu dàng với chất liệu da Saffiano bền đẹp. Khóa xoay màu bạc tinh tế. Thiết kế hình thang cổ điển, dễ kết hợp với nhiều trang phục khác nhau."},
    {"id": 7,  "maSanPham": "SP007", "tenSanPham": "Ví Da Nữ Nhỏ Gọn", "gia": 450000,
     "loaiDa": "ALL", "danhMucId": 3, "thuongHieu": "WalletPro",
     "moTa": "Ví nhỏ gọn tiện lợi với nhiều ngăn đựng thẻ và tiền mặt. Chất liệu da PU cao cấp, chống nước nhẹ. Có thể dùng như ví tiền hoặc cầm tay đi sự kiện sang trọng."},
    {"id": 8,  "maSanPham": "SP008", "tenSanPham": "Ví Cầm Tay Dạ Tiệc", "gia": 580000,
     "loaiDa": "ALL", "danhMucId": 3, "thuongHieu": "EveningLux",
     "moTa": "Ví cầm tay sang trọng dành cho các buổi tiệc và sự kiện đặc biệt. Thiết kế nhỏ gọn nhưng đựng vừa điện thoại, son và thẻ. Bề mặt bóng cao cấp, tôn lên vẻ đẹp thanh lịch."},
    {"id": 9,  "maSanPham": "SP009", "tenSanPham": "Túi Tote Da Bò Đơn Giản", "gia": 1950000,
     "loaiDa": "ALL", "danhMucId": 1, "thuongHieu": "LeatherBasic",
     "moTa": "Túi tote da bò thật kiểu dáng đơn giản, bền bỉ theo thời gian. Dung tích lớn phù hợp đi làm mỗi ngày. Có thêm túi nhỏ bên trong để đựng điện thoại và chìa khóa tiện lợi."},
    {"id": 10, "maSanPham": "SP010", "tenSanPham": "Bộ Sưu Tập Túi Mùa Hè", "gia": 3200000,
     "loaiDa": "ALL", "danhMucId": 4, "thuongHieu": "Summer Collection",
     "moTa": "Bộ sưu tập túi mùa hè đa dạng phong cách. Thiết kế trẻ trung, năng động với tông màu tươi sáng. Chất liệu vải canvas cao cấp kết hợp da PU, nhẹ nhàng và bền đẹp lý tưởng cho mùa hè."},
]

count = 0
print("\nCập nhật sản phẩm...")
for p in products:
    pid = p.pop("id")
    img = img_map.get(pid, [])
    p["hinhAnh"] = img if isinstance(img, list) else [img]
    body = json.dumps(p, ensure_ascii=False).encode("utf-8")
    req = urllib.request.Request(f"{BASE}/api/admin/products/{pid}", data=body,
                                  headers=HEADERS, method="PUT")
    try:
        with urllib.request.urlopen(req) as r:
            result = json.loads(r.read())
        print(f"  [{pid}] ✓ {result['data']['tenSanPham']}")
        count += 1
    except urllib.error.HTTPError as e:
        print(f"  [{pid}] ✗ {e.code}: {e.read().decode()}")

# 4. Update category names
print("\nCập nhật danh mục...")
categories = [
    {"id": 1, "tenDanhMuc": "Túi Xách", "thuTu": 1},
    {"id": 2, "tenDanhMuc": "Phụ Kiện", "thuTu": 2},
    {"id": 3, "tenDanhMuc": "Ví & Cầm Tay", "thuTu": 3},
    {"id": 4, "tenDanhMuc": "Balo", "thuTu": 4},
]
for c in categories:
    cid = c.pop("id")
    body = json.dumps(c, ensure_ascii=False).encode("utf-8")
    req = urllib.request.Request(f"{BASE}/api/admin/categories/{cid}", data=body,
                                  headers=HEADERS, method="PUT")
    try:
        with urllib.request.urlopen(req) as r:
            result = json.loads(r.read())
        print(f"  Cat[{cid}] ✓ {result['data']['tenDanhMuc']}")
    except urllib.error.HTTPError as e:
        print(f"  Cat[{cid}] ✗ {e.code}: {e.read().decode()}")

print(f"\n✅ Hoàn thành! Đã cập nhật {count}/10 sản phẩm với tiếng Việt có dấu.")
