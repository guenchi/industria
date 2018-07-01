#!/usr/bin/env scheme-script
;; -*- mode: scheme; coding: utf-8 -*- !#
;; Copyright © 2018 Göran Weinholt <goran@weinholt.se>
;; SPDX-License-Identifier: MIT
#!r6rs

(import
  (rnrs (6))
  (srfi :64 testing)
  (industria base64)
  (industria crypto rsa))

(test-begin "rsa")

(define key1
  (let-values (((type bv)
                (get-delimited-base64
                 (open-string-input-port
                  "-----BEGIN RSA PRIVATE KEY-----
MIIBOQIBAAJBAL2bw7FiKE/lZF4Dr2lrAqs5ejaFEtqRsDgF3xb84f95uxSoXQTz
Otj17exVOwTdExeftzM/DoY1H/gtSRxB7mMCAwEAAQJAYShl+Ikhuv8ClSIySkRp
U6/aLgG2jYVF1Q89J5xhefTVvXHRYrrfVjpQJ3QeiN5oq+DR8mJ8j0kcGIMyihnl
EQIhAPNgEAvigymKH+gMV2srL6vG5w5bGFtLxnOHvfsUOg4XAiEAx3GyoCq+uPpb
8XZFk3+A9tdpIul3tihC5Bsu3bet/ZUCIDpANdcCYi5hFv3tZkcKUSCmPMtc1lmT
q24fgUNFNhgFAiB505mo/HNDyqoe9H/LeTbtkOdHzBSz0CQL8g7OoERHgQIgVQvJ
tFUNdC4lxiB9Q4n4PbkpeyVLJ9n6qdo9LTM/OPQ=
-----END RSA PRIVATE KEY-----"))))
      (rsa-private-key-from-bytevector bv)))

(test-equal '(((1 2 840 113549 2 5) (null 14 2 #f))
              #vu8(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0))
            (rsa-pkcs1-decrypt-digest
             (rsa-pkcs1-encrypt-digest 'md5 (make-bytevector 16 0) key1)
             (rsa-private->public key1)))

(let ((key (make-rsa-private-key
            288412728347463293650191476303670753583
            65537
            190905048380501971055612558936725496993)))
  (test-equal "Hello"
              (utf8->string
               (rsa-pkcs1-decrypt
                (rsa-pkcs1-encrypt (string->utf8 "Hello")
                                   (rsa-private->public key))
                key))))

(rsa-pkcs1-decrypt-signature
             (rsa-pkcs1-encrypt-signature (make-bytevector 16 1)
                                          key1)
             (rsa-private->public key1))

(test-equal (make-bytevector 16 1)
            (rsa-pkcs1-decrypt-signature
             (rsa-pkcs1-encrypt-signature (make-bytevector 16 1)
                                          key1)
             (rsa-private->public key1)))

(test-end)

(exit (if (zero? (test-runner-fail-count (test-runner-get))) 0 1))
