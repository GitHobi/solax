# solax
Interface to talk to solax hybrid inverter

## Sign on:
The first call needs to be to "Login" to get a token.
```
curl "http://www.solax-portal.com/api/v1/user/Login?username=USERNAME&password=PASSWORD"

{"data":{"id":21928,"token":"dd754cf8dfb14b3a9249f85fe59eeb6a"},"successful":true,"message":null}
```

The "token" is in subsequent calls needed to authenticate.
