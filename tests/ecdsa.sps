#!/usr/bin/env scheme-script
;; -*- mode: scheme; coding: utf-8 -*- !#
;; Copyright © 2011, 2018 Göran Weinholt <goran@weinholt.se>
;; SPDX-License-Identifier: MIT
#!r6rs

(import
  (rnrs (6))
  (srfi :64 testing)
  (hashing sha-1)
  (industria base64)
  (industria crypto ec)
  (industria crypto ecdsa))

;; Test from SECG's GEC 2

(test-begin "ecdsa")

(define secp160r1
  (make-elliptic-prime-curve
   #xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF7FFFFFFF
   -3
   #x1C97BEFC54BD7A8B65ACF89F81D4D4ADC565FA45
   #x024A96B5688EF573284664698968C38BB913CBFC82
   #x0100000000000000000001F4C8F927AED3CA752257
   #x01))

(test-assert
 (ecdsa-verify-signature (sha-1->bytevector (sha-1 (string->utf8 "abc")))
                         (ecdsa-private->public
                          (make-ecdsa-private-key
                           secp160r1
                           971761939728640320549601132085879836204587084162))
                         1176954224688105769566774212902092897866168635793
                         299742580584132926933316745664091704165278518100))

;; Test all of ecdsa-sha2: make a new key, make a signature and verify it.
(test-assert
 (let*-values (((data) (sha-1->bytevector (sha-1 #vu8(1 2 3))))
               ((key) (make-ecdsa-private-key secp256r1))
               ((r s) (ecdsa-create-signature data key)))
   (ecdsa-verify-signature data (ecdsa-private->public key) r s)))

(define sample-private-key
  (base64-decode "MHcCAQEEIKgM8/Dvw8+2turI8q3gssyFC0qv2O3qGgaWohcMdUahoAoGCCqGSM49AwEHoUQDQgAEocljqkKwpHB4K9/LUHptDKPHbcs4tBZo8sgeR7jKsWLNm9jvwyE8RcRTIfrl6GWPQWLeaLQPNE2iLfvZ7Prv2Q=="))

(let ((key (ecdsa-private-key-from-bytevector sample-private-key)))
  (test-equal secp256r1 (ecdsa-private-key-curve key))
  (test-equal 76011444346765753920874724660285434223367613700067411323239518944589029656225
              (ecdsa-private-key-d key))
  (test-equal 62104687544328297897454217652338518469103144788232680486632155746116502849683244307583428075076255244115567050738992847409342346676093524214243771509567449
              (ecdsa-private-key-Q key)))

(test-end)

(exit (if (zero? (test-runner-fail-count (test-runner-get))) 0 1))
