"use client";

import Link from "next/link";
import { useSearchParams } from "next/navigation";
import { Suspense, useEffect, useState } from "react";
import { CheckCircle2, XCircle, ArrowRight, ShoppingBag } from "lucide-react";
import { Button } from "@/components/ui/Button";
import { formatCurrency } from "@/lib/format";

function MomoResultContent() {
  const searchParams = useSearchParams();
  const [orderId, setOrderId] = useState<string | null>(null);
  const [success, setSuccess] = useState<boolean>(false);
  const [amount, setAmount] = useState<string | null>(null);
  const [message, setMessage] = useState<string | null>(null);

  useEffect(() => {
    const extraData = searchParams.get("extraData");
    const resultCode = searchParams.get("resultCode");
    const amt = searchParams.get("amount");
    const msg = searchParams.get("message");

    if (extraData) {
      try {
        const decoded = atob(extraData);
        setOrderId(decoded);
      } catch (e) {
        console.error("Failed to decode extraData", e);
      }
    }

    setSuccess(resultCode === "0");
    setAmount(amt);
    setMessage(msg);
  }, [searchParams]);

  return (
    <div className="mx-auto max-w-xl px-6 py-16 md:py-24">
      <div className="flex flex-col items-center text-center">
        {success ? (
          <>
            <div className="flex h-20 w-20 items-center justify-center rounded-full bg-emerald-50 text-emerald-600 ring-8 ring-emerald-50/50">
              <CheckCircle2 className="h-10 w-10" />
            </div>
            <h1 className="mt-8 font-serif text-3xl md:text-4xl text-[color:var(--color-ink)]">
              Thanh toán thành công
            </h1>
            <p className="mt-4 text-sm text-[color:var(--color-muted)] max-w-md">
              Cảm ơn bạn đã lựa chọn mua sắm tại Simply Beauty. Giao dịch MoMo của bạn đã hoàn thành thành công và đơn hàng đang được xử lý.
            </p>
          </>
        ) : (
          <>
            <div className="flex h-20 w-20 items-center justify-center rounded-full bg-rose-50 text-rose-600 ring-8 ring-rose-50/50">
              <XCircle className="h-10 w-10" />
            </div>
            <h1 className="mt-8 font-serif text-3xl md:text-4xl text-[color:var(--color-ink)]">
              Thanh toán thất bại
            </h1>
            <p className="mt-4 text-sm text-[color:var(--color-muted)] max-w-md">
              Giao dịch qua Ví MoMo đã bị hủy hoặc xảy ra lỗi ({message || "Giao dịch không thành công"}). Đơn hàng của bạn vẫn được lưu ở trạng thái chờ thanh toán.
            </p>
          </>
        )}

        <div className="mt-8 w-full rounded-2xl border border-[color:var(--color-border)] bg-white p-6 text-left">
          <h2 className="font-serif text-lg font-medium border-b border-[color:var(--color-border)] pb-3 mb-4 text-[color:var(--color-ink)]">
            Chi tiết giao dịch
          </h2>
          <div className="space-y-3 text-sm">
            {orderId && (
              <div className="flex justify-between">
                <span className="text-[color:var(--color-muted)]">Mã đơn hàng:</span>
                <span className="font-mono font-medium">LM-{orderId.padStart(6, "0")}</span>
              </div>
            )}
            {amount && (
              <div className="flex justify-between">
                <span className="text-[color:var(--color-muted)]">Số tiền thanh toán:</span>
                <span className="font-serif font-medium">{formatCurrency(parseInt(amount))}</span>
              </div>
            )}
            <div className="flex justify-between">
              <span className="text-[color:var(--color-muted)]">Phương thức:</span>
              <span className="font-medium text-[#ae2070]">Ví điện tử MoMo</span>
            </div>
            <div className="flex justify-between">
              <span className="text-[color:var(--color-muted)]">Trạng thái:</span>
              <span className={`font-semibold ${success ? "text-emerald-700" : "text-rose-600"}`}>
                {success ? "Đã thanh toán" : "Chưa hoàn tất"}
              </span>
            </div>
          </div>
        </div>

        <div className="mt-10 flex flex-col sm:flex-row gap-3 w-full justify-center">
          {orderId ? (
            <Link href={`/don-hang/${orderId}`} className="w-full sm:w-auto">
              <Button className="w-full justify-center" variant="primary">
                Xem chi tiết đơn hàng
                <ArrowRight className="ml-2 h-4 w-4" />
              </Button>
            </Link>
          ) : (
            <Link href="/don-hang" className="w-full sm:w-auto">
              <Button className="w-full justify-center" variant="primary">
                Xem danh sách đơn hàng
                <ArrowRight className="ml-2 h-4 w-4" />
              </Button>
            </Link>
          )}

          <Link href="/" className="w-full sm:w-auto">
            <Button className="w-full justify-center" variant="outline">
              <ShoppingBag className="mr-2 h-4 w-4" />
              Tiếp tục mua sắm
            </Button>
          </Link>
        </div>
      </div>
    </div>
  );
}

export default function MomoResultPage() {
  return (
    <Suspense
      fallback={
        <div className="py-20 text-center text-sm text-[color:var(--color-muted)]">
          Đang tải kết quả giao dịch...
        </div>
      }
    >
      <MomoResultContent />
    </Suspense>
  );
}
