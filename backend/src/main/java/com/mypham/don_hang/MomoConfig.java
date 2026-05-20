package com.mypham.don_hang;

import lombok.Getter;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

@Component
@Getter
public class MomoConfig {

    @Value("${momo.partner-code:MOMOBKUN20180529}")
    private String partnerCode;

    @Value("${momo.access-key:klm05TvNBzhg7h7j}")
    private String accessKey;

    @Value("${momo.secret-key:at67qH6mk8w5Y1nAyMoYKMWACiEi2bsa}")
    private String secretKey;

    @Value("${momo.endpoint:https://test-payment.momo.vn/v2/gateway/api/create}")
    private String endpoint;

    @Value("${momo.ipn-url:http://localhost:8080/api/orders/momo-ipn}")
    private String ipnUrl;

    @Value("${momo.redirect-url:http://localhost:3000/don-hang/result}")
    private String redirectUrl;
}
