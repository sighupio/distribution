#!/bin/bash
# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

openssl genrsa -out ca-key.pem 2048
openssl req -x509 -new -days 365 -nodes -key ca-key.pem -out ca.crt -subj "/CN=ingress-ca"
openssl genrsa -out tls.key 2048
openssl req -new -key tls.key -out csr.pem -subj "/CN=ingress-ca" -config req-dns.cnf
openssl x509 -req -in csr.pem -CA ca.crt -CAkey ca-key.pem -CAcreateserial -out tls.crt -days 365 -extensions v3_req -extfile req-dns.cnf