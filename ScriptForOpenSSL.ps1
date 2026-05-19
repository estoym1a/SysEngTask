New-SelfSignedCertificate -DnsName "portall.cyberlab.local" `
-CertStoreLocation "Cert:\LocalMachine\My" `
-KeyLength 2048 -KeyAlgorithm RSA -HashAlgorithm SHA256