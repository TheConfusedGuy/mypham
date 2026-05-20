package com.mypham.don_hang;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.util.Base64;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class MomoService {

    private final MomoConfig momoConfig;
    private final RestTemplate restTemplate = new RestTemplate();

    public String createPaymentUrl(Order order) {
        try {
            String partnerCode = momoConfig.getPartnerCode();
            String accessKey = momoConfig.getAccessKey();
            String secretKey = momoConfig.getSecretKey();
            String endpoint = momoConfig.getEndpoint();
            String ipnUrl = momoConfig.getIpnUrl();
            String redirectUrl = momoConfig.getRedirectUrl();

            String requestId = UUID.randomUUID().toString();
            String orderId = "SB-" + order.getId() + "-" + System.currentTimeMillis();
            String amount = String.valueOf(order.getTongTien().longValue());
            String orderInfo = "Thanh toan don hang LM-" + String.format("%06d", order.getId()) + " tai Simply Beauty";
            
            // Base64 encode the order database ID as extraData to decode in callback
            String extraData = Base64.getEncoder().encodeToString(String.valueOf(order.getId()).getBytes(StandardCharsets.UTF_8));
            String requestType = "captureWallet";

            // Format raw signature:
            // accessKey=$accessKey&amount=$amount&extraData=$extraData&ipnUrl=$ipnUrl&orderId=$orderId&orderInfo=$orderInfo&partnerCode=$partnerCode&redirectUrl=$redirectUrl&requestId=$requestId&requestType=$requestType
            String rawSignature = "accessKey=" + accessKey +
                    "&amount=" + amount +
                    "&extraData=" + extraData +
                    "&ipnUrl=" + ipnUrl +
                    "&orderId=" + orderId +
                    "&orderInfo=" + orderInfo +
                    "&partnerCode=" + partnerCode +
                    "&redirectUrl=" + redirectUrl +
                    "&requestId=" + requestId +
                    "&requestType=" + requestType;

            String signature = hmacSha256(rawSignature, secretKey);

            Map<String, Object> body = new HashMap<>();
            body.put("partnerCode", partnerCode);
            body.put("partnerName", "Simply Beauty");
            body.put("storeId", "Simply Beauty");
            body.put("requestId", requestId);
            body.put("amount", Long.parseLong(amount));
            body.put("orderId", orderId);
            body.put("orderInfo", orderInfo);
            body.put("redirectUrl", redirectUrl);
            body.put("ipnUrl", ipnUrl);
            body.put("requestType", requestType);
            body.put("extraData", extraData);
            body.put("signature", signature);
            body.put("lang", "vi");

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);

            HttpEntity<Map<String, Object>> entity = new HttpEntity<>(body, headers);

            log.info("Sending payment request to MoMo for order: {}", order.getId());
            @SuppressWarnings("unchecked")
            Map<String, Object> response = restTemplate.postForObject(endpoint, entity, Map.class);

            if (response != null) {
                log.info("MoMo response: {}", response);
                Integer resultCode = (Integer) response.get("resultCode");
                if (resultCode != null && resultCode == 0) {
                    return (String) response.get("payUrl");
                } else {
                    log.error("Failed to create MoMo payment, resultCode: {}, message: {}", resultCode, response.get("message"));
                }
            }
        } catch (Exception e) {
            log.error("Error creating MoMo payment URL", e);
        }
        return null;
    }

    public boolean verifySignature(String rawSignature, String signature) {
        try {
            String calculated = hmacSha256(rawSignature, momoConfig.getSecretKey());
            return calculated.equalsIgnoreCase(signature);
        } catch (Exception e) {
            log.error("Error verifying signature", e);
            return false;
        }
    }

    private String hmacSha256(String data, String key) throws Exception {
        byte[] keyBytes = key.getBytes(StandardCharsets.UTF_8);
        SecretKeySpec signingKey = new SecretKeySpec(keyBytes, "HmacSHA256");
        Mac mac = Mac.getInstance("HmacSHA256");
        mac.init(signingKey);
        byte[] rawHmac = mac.doFinal(data.getBytes(StandardCharsets.UTF_8));
        StringBuilder sb = new StringBuilder();
        for (byte b : rawHmac) {
            sb.append(String.format("%02x", b));
        }
        return sb.toString();
    }
}
