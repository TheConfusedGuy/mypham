# -*- coding: utf-8 -*-
# reset_and_seed_cosmetics.py
# 1. Xoá toàn bộ sản phẩm & danh mục cũ
# 2. Upload 16 ảnh mỹ phẩm mới
# 3. Tạo danh mục mỹ phẩm
# 4. Tạo sản phẩm mỹ phẩm tiếng Việt có dấu

import urllib.request
import urllib.error
import json
import sys
import os

sys.stdout.reconfigure(encoding='utf-8')

BASE = "http://localhost:8080"
IMAGES_DIR = r"F:\tmdt-my-pham 2\tmdt-my-pham\images"

# ── 1. Login ──────────────────────────────────────────────
print("[1] Đăng nhập admin...")
login_data = json.dumps({"email": "admin@mypham.local", "matKhau": "admin12345"}).encode("utf-8")
req = urllib.request.Request(f"{BASE}/api/auth/login", data=login_data,
                              headers={"Content-Type": "application/json"}, method="POST")
with urllib.request.urlopen(req) as r:
    resp = json.loads(r.read())
TOKEN = resp["data"]["token"]
HEADERS = {"Authorization": f"Bearer {TOKEN}", "Content-Type": "application/json; charset=utf-8"}
print(f"  ✓ Token: {TOKEN[:25]}...")

# ── 2. Xoá sản phẩm cũ ────────────────────────────────────
print("\n[2] Xoá sản phẩm cũ...")
req = urllib.request.Request(f"{BASE}/api/admin/products", headers=HEADERS)
with urllib.request.urlopen(req) as r:
    prods = json.loads(r.read())

for p in prods["data"]:
    pid = p["id"]
    del_req = urllib.request.Request(f"{BASE}/api/admin/products/{pid}",
                                      headers=HEADERS, method="DELETE")
    try:
        with urllib.request.urlopen(del_req) as r:
            pass
        print(f"  ✓ Đã xoá sản phẩm ID={pid}: {p['tenSanPham']}")
    except urllib.error.HTTPError as e:
        print(f"  ✗ Lỗi xoá SP {pid}: {e.read().decode()}")

# ── 3. Xoá danh mục cũ ────────────────────────────────────
print("\n[3] Xoá danh mục cũ...")
req = urllib.request.Request(f"{BASE}/api/admin/categories", headers=HEADERS)
with urllib.request.urlopen(req) as r:
    cats = json.loads(r.read())

for c in cats["data"]:
    cid = c["id"]
    del_req = urllib.request.Request(f"{BASE}/api/admin/categories/{cid}",
                                      headers=HEADERS, method="DELETE")
    try:
        with urllib.request.urlopen(del_req) as r:
            pass
        print(f"  ✓ Đã xoá danh mục ID={cid}: {c['tenDanhMuc']}")
    except urllib.error.HTTPError as e:
        print(f"  ✗ Lỗi xoá DM {cid}: {e.read().decode()}")

# ── 4. Upload ảnh mỹ phẩm ─────────────────────────────────
print("\n[4] Upload ảnh mỹ phẩm...")

def upload_image(filepath):
    filename = os.path.basename(filepath)
    with open(filepath, "rb") as f:
        file_bytes = f.read()
    boundary = "----FormBoundary7MA4YWxkTrZu0gW"
    body = (
        f"--{boundary}\r\n"
        f'Content-Disposition: form-data; name="file"; filename="{filename}"\r\n'
        f"Content-Type: image/jpeg\r\n\r\n"
    ).encode("ascii") + file_bytes + f"\r\n--{boundary}--\r\n".encode("ascii")
    req = urllib.request.Request(
        f"{BASE}/api/admin/upload",
        data=body,
        headers={
            "Authorization": f"Bearer {TOKEN}",
            "Content-Type": f"multipart/form-data; boundary={boundary}"
        },
        method="POST"
    )
    with urllib.request.urlopen(req) as r:
        result = json.loads(r.read())
    return result["data"]["url"]

images = {
    "amanda":       "amanda-dalbjorn-t7WrWaewbtw-unsplash.jpg",
    "ashley":       "ashley-piszek-2avqIBH252Y-unsplash.jpg",
    "cierra":       "cierra-henderson-LWIQp-0_b98-unsplash.jpg",
    "curology":     "curology-DGH1u80sZik-unsplash.jpg",
    "glenna":       "glenna-haug-DuNXXPScbJM-unsplash.jpg",
    "karly":        "karly-jones-jaV6cvSEqao-unsplash.jpg",
    "laura1":       "laura-jaeger-92Nny2OVWp0-unsplash.jpg",
    "laura2":       "laura-jaeger-So9x2NfXSxg-unsplash.jpg",
    "laura3":       "laura-jaeger-_dSHqe4mcWE-unsplash.jpg",
    "lina":         "lina-verovaya-hdvqsYqvdqI-unsplash.jpg",
    "liubov":       "liubov-ilchuk-x_ujfGcrAyU-unsplash.jpg",
    "mathilde":     "mathilde-langevin-p3O5f4u95Lo-unsplash.jpg",
    "nataliya":     "nataliya-melnychuk-51sGDpm5S78-unsplash.jpg",
    "natallia1":    "natallia-photo-IKl2pPdEBlg-unsplash.jpg",
    "natallia2":    "natallia-photo-wbr1UHzpwyM-unsplash.jpg",
    "skindinavia":  "skindinavia-cosmetics-TpvValHKUO0-unsplash.jpg",
}

urls = {}
for key, fname in images.items():
    fpath = os.path.join(IMAGES_DIR, fname)
    print(f"  Uploading {key}...", end="", flush=True)
    try:
        url = upload_image(fpath)
        urls[key] = url
        print(f" ✓ {url}")
    except Exception as e:
        print(f" ✗ {e}")
        urls[key] = None

# ── 5. Tạo danh mục mỹ phẩm ───────────────────────────────
print("\n[5] Tạo danh mục mỹ phẩm...")

def create_category(name, order):
    body = json.dumps({"tenDanhMuc": name, "thuTu": order}, ensure_ascii=False).encode("utf-8")
    req = urllib.request.Request(f"{BASE}/api/admin/categories", data=body,
                                  headers=HEADERS, method="POST")
    with urllib.request.urlopen(req) as r:
        result = json.loads(r.read())
    return result["data"]["id"]

cat_duong_da     = create_category("Dưỡng Da", 1)
cat_trang_diem   = create_category("Trang Điểm", 2)
cat_chong_nang   = create_category("Chống Nắng", 3)
cat_lam_sach     = create_category("Làm Sạch", 4)
cat_duong_toc    = create_category("Dưỡng Tóc", 5)
cat_nuoc_hoa     = create_category("Nước Hoa", 6)

print(f"  ✓ Dưỡng Da (ID={cat_duong_da})")
print(f"  ✓ Trang Điểm (ID={cat_trang_diem})")
print(f"  ✓ Chống Nắng (ID={cat_chong_nang})")
print(f"  ✓ Làm Sạch (ID={cat_lam_sach})")
print(f"  ✓ Dưỡng Tóc (ID={cat_duong_toc})")
print(f"  ✓ Nước Hoa (ID={cat_nuoc_hoa})")

# ── 6. Tạo sản phẩm mỹ phẩm ───────────────────────────────
print("\n[6] Tạo sản phẩm mỹ phẩm...")

def create_product(ma, ten, gia, loai_da, danh_muc_id, mo_ta, thuong_hieu, hinh_anh_list):
    body = {
        "maSanPham":  ma,
        "tenSanPham": ten,
        "gia":        gia,
        "loaiDa":     loai_da,
        "danhMucId":  danh_muc_id,
        "moTa":       mo_ta,
        "thuongHieu": thuong_hieu,
        "hinhAnh":    [u for u in hinh_anh_list if u],
    }
    data = json.dumps(body, ensure_ascii=False).encode("utf-8")
    req = urllib.request.Request(f"{BASE}/api/admin/products", data=data,
                                  headers=HEADERS, method="POST")
    with urllib.request.urlopen(req) as r:
        result = json.loads(r.read())
    return result["data"]["id"]

products = [
    # Dưỡng Da
    dict(ma="MP001", ten="Serum Dưỡng Ẩm Hyaluronic Acid",       gia=285000,  loai_da="DRY",         dm=cat_duong_da,   thuong_hieu="La Roche-Posay",
         mo_ta="Serum cấp ẩm chuyên sâu với Hyaluronic Acid đậm đặc, giúp da căng mịn và tươi sáng suốt 24 giờ. Phù hợp cho da khô và da nhạy cảm.",
         img=urls["amanda"]),
    dict(ma="MP002", ten="Kem Dưỡng Phục Hồi Da Ban Đêm",         gia=320000,  loai_da="DRY",         dm=cat_duong_da,   thuong_hieu="Neutrogena",
         mo_ta="Kem dưỡng đêm giàu dưỡng chất giúp phục hồi và tái tạo da trong khi ngủ. Công thức nâng cao với retinol và niacinamide.",
         img=urls["ashley"]),
    dict(ma="MP003", ten="Tinh Chất Dưỡng Trắng Vitamin C",       gia=450000,  loai_da="NORMAL",      dm=cat_duong_da,   thuong_hieu="The Ordinary",
         mo_ta="Tinh chất Vitamin C 20% giúp làm đều màu da, mờ thâm nám và tăng cường sức đề kháng cho da. Kết cấu nhẹ, thấm nhanh.",
         img=urls["cierra"]),
    dict(ma="MP004", ten="Kem Dưỡng Ẩm Cho Da Dầu",               gia=195000,  loai_da="OILY",        dm=cat_duong_da,   thuong_hieu="Cetaphil",
         mo_ta="Kem dưỡng ẩm dạng gel nhẹ không gây bít lỗ chân lông, kiểm soát bã nhờn hiệu quả. Phù hợp da dầu và da hỗn hợp.",
         img=urls["curology"]),

    # Trang Điểm
    dict(ma="MP005", ten="Kem Nền Che Phủ Hoàn Hảo SPF30",        gia=380000,  loai_da="ALL",         dm=cat_trang_diem, thuong_hieu="Maybelline",
         mo_ta="Kem nền che phủ cao, giúp lớp trang điểm bền lâu 24 giờ. Tích hợp SPF30 bảo vệ da khỏi tia UV. Có 20 tông màu phù hợp mọi tông da.",
         img=urls["glenna"]),
    dict(ma="MP006", ten="Phấn Phủ Kiềm Dầu Dạng Bột",            gia=165000,  loai_da="OILY",        dm=cat_trang_diem, thuong_hieu="NYX",
         mo_ta="Phấn phủ dạng bột mịn giúp kiểm soát dầu nhờn, giữ trang điểm bền lâu. Công thức siêu nhẹ không gây nặng mặt.",
         img=urls["karly"]),
    dict(ma="MP007", ten="Son Môi Lì Không Lem Màu",               gia=125000,  loai_da="ALL",         dm=cat_trang_diem, thuong_hieu="MAC",
         mo_ta="Son lì dạng kem với độ che phủ hoàn hảo, không lem không phai suốt 8 giờ. Dưỡng ẩm môi, cho màu sắc rực rỡ tươi tắn.",
         img=urls["laura1"]),

    # Chống Nắng
    dict(ma="MP008", ten="Kem Chống Nắng Vật Lý SPF50+ PA++++",   gia=245000,  loai_da="SENSITIVE",   dm=cat_chong_nang, thuong_hieu="Anessa",
         mo_ta="Kem chống nắng vật lý nhẹ không gây kích ứng, bảo vệ toàn diện khỏi UVA/UVB với SPF50+ PA++++. Không gây nhờn rít, phù hợp da nhạy cảm.",
         img=urls["laura2"]),
    dict(ma="MP009", ten="Xịt Chống Nắng Dưỡng Ẩm SPF40",         gia=185000,  loai_da="COMBINATION", dm=cat_chong_nang, thuong_hieu="Bioderma",
         mo_ta="Dạng xịt tiện lợi, bảo vệ da khỏi ánh nắng mặt trời, đồng thời cung cấp độ ẩm cần thiết. Có thể dùng trực tiếp lên trang điểm.",
         img=urls["laura3"]),

    # Làm Sạch
    dict(ma="MP010", ten="Sữa Rửa Mặt Tạo Bọt Dịu Nhẹ",           gia=95000,   loai_da="SENSITIVE",   dm=cat_lam_sach,   thuong_hieu="Cetaphil",
         mo_ta="Sữa rửa mặt tạo bọt mịn màng, làm sạch sâu mà không làm khô da. Công thức không chứa xà phòng, phù hợp da nhạy cảm và da khô.",
         img=urls["lina"]),
    dict(ma="MP011", ten="Tẩy Trang Dầu Làm Sạch Sâu",             gia=145000,  loai_da="ALL",         dm=cat_lam_sach,   thuong_hieu="DHC",
         mo_ta="Dầu tẩy trang hoà tan makeup không thấm nước, bã nhờn và bụi bẩn. Chứa dầu olive nguyên chất dưỡng da mềm mịn sau khi rửa mặt.",
         img=urls["liubov"]),
    dict(ma="MP012", ten="Tẩy Da Chết Vật Lý Với Hạt Jojoba",      gia=175000,  loai_da="NORMAL",      dm=cat_lam_sach,   thuong_hieu="St. Ives",
         mo_ta="Tẩy da chết vật lý với hạt jojoba vi mô nhẹ nhàng, loại bỏ tế bào chết, thông thoáng lỗ chân lông. Da sáng mịn ngay sau lần dùng đầu.",
         img=urls["mathilde"]),

    # Dưỡng Tóc
    dict(ma="MP013", ten="Dầu Dưỡng Tóc Argan Siêu Mượt",          gia=215000,  loai_da="ALL",         dm=cat_duong_toc,  thuong_hieu="Moroccanoil",
         mo_ta="Tinh dầu Argan Morocco chính hãng giúp phục hồi tóc hư tổn, giảm xơ rối và tăng độ bóng mượt. Mùi hương nhẹ nhàng quyến rũ.",
         img=urls["nataliya"]),
    dict(ma="MP014", ten="Kem Ủ Tóc Phục Hồi Chuyên Sâu",           gia=265000,  loai_da="DRY",         dm=cat_duong_toc,  thuong_hieu="TRESemmé",
         mo_ta="Kem ủ tóc với công thức Keratin và Biotin giúp phục hồi tóc hư tổn, giảm gãy rụng và làm mềm tóc từ sâu bên trong.",
         img=urls["natallia1"]),

    # Nước Hoa
    dict(ma="MP015", ten="Nước Hoa Hồng Cân Bằng Da",               gia=135000,  loai_da="COMBINATION", dm=cat_nuoc_hoa,   thuong_hieu="Klairs",
         mo_ta="Nước hoa hồng cân bằng độ pH, se khít lỗ chân lông và chuẩn bị da hấp thụ dưỡng chất tốt hơn. Không cồn, phù hợp mọi loại da.",
         img=urls["natallia2"]),
    dict(ma="MP016", ten="Xịt Khoáng Dưỡng Ẩm Làm Dịu Da",         gia=115000,  loai_da="SENSITIVE",   dm=cat_nuoc_hoa,   thuong_hieu="Avène",
         mo_ta="Xịt khoáng thiên nhiên giúp làm dịu, cấp ẩm tức thì và bảo vệ da khỏi kích ứng. Phù hợp dùng mọi lúc để giữ ẩm và refresh trang điểm.",
         img=urls["skindinavia"]),
]

count = 0
for p in products:
    try:
        pid = create_product(
            p["ma"], p["ten"], p["gia"], p["loai_da"],
            p["dm"], p["mo_ta"], p["thuong_hieu"], [p["img"]]
        )
        print(f"  ✓ [{p['ma']}] {p['ten']} (ID={pid})")
        count += 1
    except urllib.error.HTTPError as e:
        err = e.read().decode()
        print(f"  ✗ [{p['ma']}] FAIL: {err}")

print(f"\n✅ Hoàn thành! Đã tạo {count}/16 sản phẩm mỹ phẩm.")
print(f"   Frontend: http://localhost:3000")
print(f"   Admin:    http://localhost:3000/admin")
