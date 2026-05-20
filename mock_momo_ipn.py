import asyncio
import asyncpg
import base64
import hashlib
import hmac
import json
import sys
import time
import urllib.request
import uuid

# Configuration matching MomoConfig.java Sandbox keys
PARTNER_CODE = "MOMOBKUN20180529"
ACCESS_KEY = "klm05TvNBzhg7h7j"
SECRET_KEY = b"at67qH6mk8w5Y1nAyMoYKMWACiEi2bsa"
IPN_URL = "http://localhost:8080/api/orders/momo-ipn"

async def main():
    # Parse CLI arguments for order ID
    order_id = None
    if len(sys.argv) > 1:
        try:
            order_id = int(sys.argv[1])
        except ValueError:
            print("Usage: python mock_momo_ipn.py [order_id]")
            sys.exit(1)

    print("Connecting to database...")
    try:
        conn = await asyncpg.connect(
            "postgresql://neondb_owner:npg_kz2XlVfvY4Pe@ep-soft-snow-aogwnxwf.c-2.ap-southeast-1.aws.neon.tech/neondb?sslmode=require"
        )
    except Exception as e:
        print(f"Error connecting to database: {e}")
        sys.exit(1)

    if order_id is None:
        # Fetch the latest order
        print("No order ID provided. Querying the latest order...")
        row = await conn.fetchrow("SELECT id, tong_tien FROM don_hang ORDER BY id DESC LIMIT 1;")
        if not row:
            print("No orders found in the database.")
            await conn.close()
            sys.exit(1)
        order_id = row['id']
        tong_tien = int(row['tong_tien'])
    else:
        # Fetch specific order
        print(f"Querying order #{order_id}...")
        row = await conn.fetchrow("SELECT id, tong_tien FROM don_hang WHERE id = $1;", order_id)
        if not row:
            print(f"Order #{order_id} not found.")
            await conn.close()
            sys.exit(1)
        tong_tien = int(row['tong_tien'])

    await conn.close()

    print(f"\n--- Order Details ---")
    print(f"Order ID: {order_id} (LM-{str(order_id).zfill(6)})")
    print(f"Amount:   {tong_tien:,} VND")
    print(f"---------------------\n")

    # Construct the payload
    timestamp_ms = int(time.time() * 1000)
    order_id_str = f"SB-{order_id}-{timestamp_ms}"
    request_id = str(uuid.uuid4())
    order_info = f"Thanh toan don hang LM-{str(order_id).zfill(6)} tai Simply Beauty"
    extra_data = base64.b64encode(str(order_id).encode("utf-8")).decode("utf-8")
    trans_id = str(timestamp_ms)[:10] + "12" # Mock 12-digit transaction ID

    # accessKey=$accessKey&amount=$amount&extraData=$extraData&message=$message&orderId=$orderId&orderInfo=$orderInfo&partnerCode=$partnerCode&requestId=$requestId&responseTime=$responseTime&resultCode=$resultCode&transId=$transId
    message = "Thanh toán thành công."
    result_code = 0
    response_time = timestamp_ms

    raw_signature = (
        f"accessKey={ACCESS_KEY}"
        f"&amount={tong_tien}"
        f"&extraData={extra_data}"
        f"&message={message}"
        f"&orderId={order_id_str}"
        f"&orderInfo={order_info}"
        f"&partnerCode={PARTNER_CODE}"
        f"&requestId={request_id}"
        f"&responseTime={response_time}"
        f"&resultCode={result_code}"
        f"&transId={trans_id}"
    )

    # Compute HMAC-SHA256 signature
    signature = hmac.new(SECRET_KEY, raw_signature.encode("utf-8"), hashlib.sha256).hexdigest()

    payload = {
        "partnerCode": PARTNER_CODE,
        "orderId": order_id_str,
        "requestId": request_id,
        "amount": tong_tien,
        "orderInfo": order_info,
        "message": message,
        "transId": trans_id,
        "resultCode": result_code,
        "responseTime": response_time,
        "extraData": extra_data,
        "signature": signature
    }

    print("Sending Mock MoMo Webhook IPN Callback...")
    print(f"URL: {IPN_URL}")
    
    try:
        data = json.dumps(payload).encode("utf-8")
        req = urllib.request.Request(
            IPN_URL,
            data=data,
            headers={"Content-Type": "application/json"}
        )
        with urllib.request.urlopen(req) as response:
            res_body = response.read().decode("utf-8")
            print(f"Success! Status Code: {response.status}")
            print(f"Response from backend: {res_body}")
            print(f"\nOrder LM-{str(order_id).zfill(6)} has been successfully marked as PAID.")
    except Exception as e:
        print(f"Error sending callback: {e}")
        sys.exit(1)

if __name__ == "__main__":
    asyncio.run(main())
