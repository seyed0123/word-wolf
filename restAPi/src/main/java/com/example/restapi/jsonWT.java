package com.example.restapi;
import com.auth0.jwt.JWT;
import com.auth0.jwt.JWTVerifier;
import com.auth0.jwt.algorithms.Algorithm;
import com.auth0.jwt.interfaces.DecodedJWT;

import java.util.Date;
public class jsonWT {
    private static final String SECRET = "salam";

    public static String createToken(String userId, Date expireDate) {
        Algorithm algorithm = Algorithm.HMAC256(SECRET);
        return JWT.create()
                .withClaim("userid", userId)
                .withClaim("expiredate", expireDate)
                .sign(algorithm);
    }
    public static DecodedJWT verifyToken(String token) {
        Algorithm algorithm = Algorithm.HMAC256(SECRET);
        JWTVerifier verifier = JWT.require(algorithm).build();
        return verifier.verify(token);
    }
//    public void main(String[] args) {
//        String token = "received-token-from-flutter";
//        DecodedJWT jwt = verifyToken(token);
//        String userId = jwt.getClaim("userid").asString();
//        Date expireDate = jwt.getClaim("expiredate").asDate();
//        String deviceId = jwt.getClaim("deviceid").asString();
//    }
}
