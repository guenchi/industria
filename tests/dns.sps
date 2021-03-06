#!/usr/bin/env scheme-script
;; -*- mode: scheme; coding: utf-8 -*- !#
;; Copyright © 2011, 2017, 2018 Göran Weinholt <goran@weinholt.se>

;; Permission is hereby granted, free of charge, to any person obtaining a
;; copy of this software and associated documentation files (the "Software"),
;; to deal in the Software without restriction, including without limitation
;; the rights to use, copy, modify, merge, publish, distribute, sublicense,
;; and/or sell copies of the Software, and to permit persons to whom the
;; Software is furnished to do so, subject to the following conditions:

;; The above copyright notice and this permission notice shall be included in
;; all copies or substantial portions of the Software.

;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
;; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
;; THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
;; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
;; FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
;; DEALINGS IN THE SOFTWARE.
#!r6rs

(import (rnrs (6))
        (srfi :64 testing)
        (ip-address)
        (industria dns)
        (industria dns numbers)
        (industria dns types)
        (industria base64))

(test-begin "dns")

;; Some bogus test data (.test is RFC 2606)
(define dummy-digest
  #vu8(#x10 #x00 #x12 #x23 #x56 #x78 #x9a #xbc #xde #xf0
            #x12 #x34 #x56 #x78 #x9a #xbc #xde #xff #x00 #xff))

(define zone
  (list (make-dns-resource/A (string->dns-labels "test.")
                             3600 (dns-class IN)
                             #vu8(192 0 2 10))
        (make-dns-resource/NS (string->dns-labels "test.")
                              172800 (dns-class IN)
                              (string->dns-labels "ns.test."))
        (make-dns-resource/CNAME (string->dns-labels "mail.test.")
                                 3600 (dns-class IN)
                                 (string->dns-labels "hostname.test."))
        (make-dns-resource/SOA (string->dns-labels "test.")
                               3600 (dns-class IN)
                               (string->dns-labels "ns.test.")
                               (string->dns-labels "hostmaster.test.")
                               1 7200 3600 1209600 3600)
        (make-dns-resource/MX (string->dns-labels "test.")
                              0 (dns-class IN)
                              10 (string->dns-labels "mail.test."))
        (make-dns-resource/AAAA (string->dns-labels "hostname.test.")
                                3600 (dns-class IN)
                                (string->ipv6 "2001:db8::25"))
        (make-dns-resource/SRV (string->dns-labels "_smtp._tcp")
                               3600 (dns-class IN)
                               0 1 25 (string->dns-labels "mail.test."))
        (make-dns-resource/CERT (string->dns-labels "pgp.test.")
                               3600 (dns-class IN)
                               (dns-cert-type PGP) 0 0
                               (base64-decode
                                "mE0ETTwDdAECAM0xBdIz3vVU0oi88xkcAR7SLTTqA/UzZdaUmqDrFLdmhZCG8iKyQidj1gryVwragUHqtpwlXlSqApBhhK8RJG8AEQEAAbQIcGdwQHRlc3SIewQTAQIAJQUCTTwDdAIbAwUJAAFRgAYLCQgHAwIEFQIIAwMWAgECHgECF4AACgkQK7ISMQpt0ptfmQH/bneC8xf2I16I+/f7+PCkges0V03eQ/r/T3TXlKL9No+ywmIhgkomu/ov1ShNb7MlQmawx3yqsb1LiTlfGjOh1w=="))
        (make-dns-resource/CNAME (string->dns-labels "dname.test.")
                                 3600 (dns-class IN)
                                 (string->dns-labels "foobar.test."))
        (make-dns-resource/DS (string->dns-labels "test.")
                              86400 (dns-class IN) 12345 8 1
                              dummy-digest)
        (make-dns-resource/SSHFP (string->dns-labels "test.")
                                 3600 (dns-class IN)
                                 1 1 dummy-digest)
        (make-dns-resource/RRSIG (string->dns-labels "test.")
                                 3600 (dns-class IN)
                                 (dns-rrtype SOA) (dnssec-algorithm RSASHA256)
                                 0 86400 1295780807 1295780809 21639
                                 (string->dns-labels "test.")
                                 (base64-decode "ZF7QELNQOCsbFVTxtugrkl0Zmk9eOeDKlTLohi4ePMHoYSrcnCLS8L/2GwQgyljveecZhRlIICzk/qLOdf9Xh5kJp9YhBm7Nt01FH9TYI56V59g10fk+tF7G2YVp9TLBkIAabeUt/JBkGhRlZNZ0orqCu3KZxsrpvY4Pzh/rtYs="))
        ;; (make-dns-resource/A (string->dns-labels "xyz1.test.") 3600 (dns-class IN)
        ;;                      #vu8(192 0 2 10))
        ;; (make-dns-resource/NSEC (string->dns-labels "xyz1.test.") 3600 (dns-class IN)
        ;;                         (string->dns-labels "xyz2.test.") '(A))
        ;; (make-dns-resource/A (string->dns-labels "xyz2.test.") 3600 (dns-class IN)
        ;;                      #vu8(192 0 2 10))

        (make-dns-resource/DNSKEY (string->dns-labels "test.")
                                  3600 (dns-class IN)
                                  257 3 (dnssec-algorithm RSASHA256)
                                  (base64-decode
                                   "AwEAAagAIKlVZrpC6Ia7gEzahOR+9W29euxhJhVVLOyQbSEW0O8gcCjFFVQUTf6v58fLjwBd0YI0EzrAcQqBGCzh/RStIoO8g0NfnfL2MTJRkxoXbfDaUeVPQuYEhg37NZWAJQ9VnMVDxP/VHL496M/QZxkjf5/Efucp2gaDX6RS6CXpoY68LsvPVjR0ZSwzz1apAzvN9dlzEheX7ICJBBtuA6G3LQpzW5hOA2hzCTMjJPJ8LbqF6dsV6DoBQzgul0sGIcGOYl7OyQdXfZ57relSQageu+ipAdTTJ25AsRTAoub8ONGcLmqrAmRLKBP1dfwhYB4N7knNnulqQxA+Uk1ihz0="))
        (make-dns-resource/TSIG (string->dns-labels "key.test.")
                                0 (dns-class ANY)
                                (string->dns-labels "hmac-md5.sig-alg.reg.int.")
                                0 3600 #vu8(1 2 3 4) 12345 (dns-rcode NOERROR)
                                #vu8(1 2 3 4))))

(define (msg->bytevector msg)
  (call-with-bytevector-output-port
    (lambda (p) (put-dns-message p msg))))

(define (msg->string msg)
  (call-with-string-output-port
    (lambda (p) (print-dns-message msg p))))

;; Not a proper AXFR, but for testing purposes it should contain one
;; of each supported RR type.
(define test-msg
  (make-dns-message 12345
                    (dns-opcode QUERY)
                    (dns-rcode NOERROR)
                    flag-response
                    (list (make-dns-question (string->dns-labels "test.")
                                             (dns-rrtype AXFR)
                                             (dns-class IN)))
                    ;; lists of type resource
                    zone '() '()))

;; Check that the conversion to and from the wire format preserves the
;; message exactly.
(test-equal (msg->string test-msg)
            (msg->string (parse-dns-message (msg->bytevector test-msg))))

(test-equal '() (string->dns-labels "."))
(test-equal (list (string->utf8 "weinholt")
                  (string->utf8 "se"))
            (string->dns-labels "weinholt.se."))

(test-equal (list (string->utf8 "weinholt")
                  (string->utf8 "se"))
            (string->dns-labels "weinholt.se"))

(test-equal (list (string->utf8 "xn--gran-5qa")
                  (string->utf8 "weinholt")
                  (string->utf8 "se"))
            (string->dns-labels "xn--gran-5qa.weinholt.se"))

(test-equal (list (string->utf8 "xn--gran-5qa")
                  (string->utf8 "weinholt")
                  (string->utf8 "se"))
            (string->dns-labels "göran.weinholt.se"))

(test-equal (list #vu8(0 #x2e #x5c #x24)
                  (string->utf8 "test"))
            (string->dns-labels "\\000\\.\\\\\\$.test"))

(string->dns-labels "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.\
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.\
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.\
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.")

(test-end)

(exit (if (zero? (test-runner-fail-count (test-runner-get))) 0 1))
