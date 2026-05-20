"""
pgvector top-K cosine similarity retriever.
Trả ra sản phẩm + score để LLM ground câu trả lời.
"""
from __future__ import annotations

from typing import Any

from app.core.embedding import vector_to_pg_literal
from app.db import get_pool


async def retrieve_similar(
    query_vector: list[float],
    top_k: int = 5,
    exclude_ids: list[int] | None = None,
) -> list[dict[str, Any]]:
    """
    Trả top-K sản phẩm ACTIVE gần nhất với query vector.
    Mỗi item: {sanPhamId, tenSanPham, gia, loaiDa, thuongHieu, moTa, hinhAnh, score}
    """
    exclude_ids = exclude_ids or []

    sql = """
        SELECT
            sp.id           AS san_pham_id,
            sp.ten_san_pham AS ten_san_pham,
            sp.gia          AS gia,
            sp.loai_da      AS loai_da,
            sp.thuong_hieu  AS thuong_hieu,
            sp.mo_ta        AS mo_ta,
            (SELECT url FROM san_pham_anh
              WHERE san_pham_id = sp.id ORDER BY thu_tu LIMIT 1) AS hinh_anh,
            pe.embedding    AS embedding
        FROM product_embeddings pe
        JOIN san_pham sp ON sp.id = pe.san_pham_id
        JOIN danh_muc dm ON dm.id = sp.danh_muc_id
        WHERE sp.trang_thai = 'ACTIVE'
          AND dm.trang_thai = 'ACTIVE'
          AND ($1::bigint[] IS NULL OR sp.id <> ALL($1::bigint[]))
    """

    pool = get_pool()
    async with pool.acquire() as conn:
        rows = await conn.fetch(
            sql,
            exclude_ids if exclude_ids else None,
        )

    import math

    def cosine_similarity(v1, v2) -> float:
        dot_product = sum(x * y for x, y in zip(v1, v2))
        norm_v1 = math.sqrt(sum(x * x for x in v1))
        norm_v2 = math.sqrt(sum(x * x for x in v2))
        if not norm_v1 or not norm_v2:
            return 0.0
        return dot_product / (norm_v1 * norm_v2)

    results = []
    for r in rows:
        emb = r["embedding"]
        if not emb:
            continue
        if isinstance(emb, str):
            # Parse in case it is loaded as string
            vec = [float(x) for x in emb[1:-1].split(",")]
        else:
            vec = list(emb)
        
        score = cosine_similarity(query_vector, vec)
        results.append({
            "sanPhamId": r["san_pham_id"],
            "tenSanPham": r["ten_san_pham"],
            "gia": float(r["gia"]) if r["gia"] is not None else None,
            "loaiDa": r["loai_da"],
            "thuongHieu": r["thuong_hieu"],
            "moTa": r["mo_ta"],
            "hinhAnh": r["hinh_anh"],
            "score": round(score, 4),
        })

    # Sort descending by similarity score
    results.sort(key=lambda x: x["score"], reverse=True)
    return results[:top_k]


async def retrieve_by_keyword(
    query_text: str,
    top_k: int = 5,
) -> list[dict[str, Any]]:
    """
    Fallback keyword search khi Embedding API gặp lỗi quota/key.
    Tìm kiếm và tính điểm khớp từ khóa trong tên, mô tả, thương hiệu, loại da.
    """
    sql = """
        SELECT
            sp.id           AS san_pham_id,
            sp.ten_san_pham AS ten_san_pham,
            sp.gia          AS gia,
            sp.loai_da      AS loai_da,
            sp.thuong_hieu  AS thuong_hieu,
            sp.mo_ta        AS mo_ta,
            (SELECT url FROM san_pham_anh
              WHERE san_pham_id = sp.id ORDER BY thu_tu LIMIT 1) AS hinh_anh
        FROM san_pham sp
        JOIN danh_muc dm ON dm.id = sp.danh_muc_id
        WHERE sp.trang_thai = 'ACTIVE'
          AND dm.trang_thai = 'ACTIVE'
    """
    pool = get_pool()
    async with pool.acquire() as conn:
        rows = await conn.fetch(sql)

    # Tách từ khóa để tìm kiếm (bỏ các từ quá ngắn)
    words = [w.lower().strip() for w in query_text.split() if len(w.strip()) > 1]
    if not words:
        words = [query_text.lower().strip()]

    results = []
    for r in rows:
        score = 0.0
        text_to_search = f"{r['ten_san_pham']} {r['mo_ta'] or ''} {r['thuong_hieu'] or ''} {r['loai_da'] or ''}".lower()
        for w in words:
            if w in text_to_search:
                score += 1.0
        
        # Điểm tương đồng tương đối dựa trên số từ khóa khớp
        final_score = 0.5 + (0.5 * (score / len(words))) if words else 0.5
        if score > 0 or not words:
            results.append({
                "sanPhamId": r["san_pham_id"],
                "tenSanPham": r["ten_san_pham"],
                "gia": float(r["gia"]) if r["gia"] is not None else None,
                "loaiDa": r["loai_da"],
                "thuongHieu": r["thuong_hieu"],
                "moTa": r["mo_ta"],
                "hinhAnh": r["hinh_anh"],
                "score": round(final_score, 4),
            })

    # Nếu không khớp bất kỳ từ khóa nào, trả về top_k sản phẩm đầu tiên với điểm mặc định 0.5 để không bị trống
    if not results:
        for r in rows[:top_k]:
            results.append({
                "sanPhamId": r["san_pham_id"],
                "tenSanPham": r["ten_san_pham"],
                "gia": float(r["gia"]) if r["gia"] is not None else None,
                "loaiDa": r["loai_da"],
                "thuongHieu": r["thuong_hieu"],
                "moTa": r["mo_ta"],
                "hinhAnh": r["hinh_anh"],
                "score": 0.5,
            })

    results.sort(key=lambda x: x["score"], reverse=True)
    return results[:top_k]

