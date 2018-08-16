#!/usr/bin/env scheme-script
;; -*- mode: scheme; coding: utf-8 -*- !#
;; Copyright © 2009, 2010, 2011, 2013, 2018 Göran Weinholt <goran@weinholt.se>

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
        (industria base64))

(define (string->base64 x)
  (base64-encode (string->utf8 x)))

;; From RFC 4658

(test-begin "base64-rfc4658")
(test-equal "" (string->base64 ""))
(test-equal "Zg==" (string->base64 "f"))
(test-equal "Zm8=" (string->base64 "fo"))
(test-equal "Zm9v" (string->base64 "foo"))
(test-equal "Zm9vYg==" (string->base64 "foob"))
(test-equal "Zm9vYmE=" (string->base64 "fooba"))
(test-equal "Zm9vYmFy" (string->base64 "foobar"))
(test-end)

;; Non-strict mode

(test-begin "base64-non-strict")
(test-equal #vu8(0 16) (base64-decode "ABC= " base64-alphabet #f #f))
(test-equal #vu8(0 16) (base64-decode "ABC =" base64-alphabet #f #f))
(test-equal #vu8(0 16) (base64-decode "AB==C=" base64-alphabet #f #f))
(test-equal #vu8(0 16) (base64-decode "AB==C =" base64-alphabet #f #f))
(test-equal #vu8(0 16) (base64-decode "A B = = C = " base64-alphabet #f #f))
(test-end)

;; Decoding inputs with no padding

(define (base64->string/nopad x)
  (utf8->string (base64-decode x base64-alphabet #f #t #f)))

(test-begin "base64-decode-nopadding")

;; Example from rfc7515
(test-equal "{\"iss\":\"joe\",\r\n \"exp\":1300819380,\r\n \"http://example.com/is_root\":true}"
            (utf8->string
             (base64-decode "eyJpc3MiOiJqb2UiLA0KICJleHAiOjEzMDA4MTkzODAsDQogImh0dHA6Ly9leGFtcGxlLmNvbS9pc19yb290Ijp0cnVlfQ"
                            base64url-alphabet #f #t #f)))

(test-equal "" (base64->string/nopad ""))
(test-equal "f" (base64->string/nopad "Zg"))
(test-equal "fo" (base64->string/nopad "Zm8"))
(test-equal "foo" (base64->string/nopad "Zm9v"))
(test-equal "foob" (base64->string/nopad "Zm9vYg"))
(test-equal "fooba" (base64->string/nopad "Zm9vYmE"))
(test-equal "foobar" (base64->string/nopad "Zm9vYmFy"))

(test-end)

;; ad-hoc

(test-begin "base64")

(define (base64-linewrapped str)
  (let ((bv (string->utf8 str)))
    (base64-encode bv 0 (bytevector-length bv) 76 #f)))

(test-equal "TXkgbmFtZSBpcyBPenltYW5kaWFzLCBraW5nIG9mIGtpbmdzOgpMb29rIG9uIG15IHdvcmtzLCB5\n\
             ZSBNaWdodHksIGFuZCBkZXNwYWlyIQ=="
            (base64-linewrapped
             "My name is Ozymandias, king of kings:\n\
              Look on my works, ye Mighty, and despair!"))

(test-end)

;; ascii armor

(test-begin "base64-ascii-armor")

(test-equal '("EXAMPLE" #vu8(0 1 2 3 4 5 6))
            (call-with-values
              (lambda ()
                (get-delimited-base64
                 (open-string-input-port
                  "-----BEGIN EXAMPLE-----\n\
AAECAwQFBg==\n\
-----END EXAMPLE-----\n")))
         list))

;; ignoring header and crc-24 checksum
(test-equal '("EXAMPLE" #vu8(0 1 2 3 4 5 6))
            (call-with-values
              (lambda ()
                (get-delimited-base64
                 (open-string-input-port
                  "Example follows\n\
\n\
-----BEGIN EXAMPLE-----\n\
Header: data\n\
Header2: data2\n\
 etc
foo
\n\
AAECAwQFBg==\n\
=2wOb\n\
-----END EXAMPLE-----\n")))
         list))

(let-values (((p extract) (open-string-output-port))
             ((str) "Crusoe's Law: With every new C++ standard, its syntax\n\
                     asymptotically approaches that of a PERL regex."))
  (put-delimited-base64 p "TEST" (string->utf8 str))
  (let-values (((type str*) (get-delimited-base64 (open-string-input-port
                                                   (string-append
                                                    "This is garbage\n"
                                                    (extract))))))
    (test-equal "TEST" type)
    (test-equal str (utf8->string str*))
    #f))

(test-end)

(exit (if (zero? (test-runner-fail-count (test-runner-get))) 0 1))
