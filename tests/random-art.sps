#!/usr/bin/env scheme-script
;; -*- mode: scheme; coding: utf-8 -*- !#
;; Copyright © 2010, 2018 Göran Weinholt <goran@weinholt.se>

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

(import (rnrs)
        (srfi :64 testing)
        (industria base64)
        (industria ssh random-art))

(test-begin "ssh-random-art-rsa")

(test-equal (string-append
             "+---[RSA 2048]----+\n"
             "|        .        |\n"
             "|       + .       |\n"
             "|      . B .      |\n"
             "|     o * +       |\n"
             "|    X * S        |\n"
             "|   + O o . .     |\n"
             "|    .   E . o    |\n"
             "|       . . o     |\n"
             "|        . .      |\n"
             "+------[MD5]------+\n")
            (random-art #vu8(#x16 #x27 #xac #xa5 #x76 #x28 #x2d #x36 #x63 #x1b
                                  #x56 #x4d #xeb #xdf #xa6 #x48)
                        "RSA 2048" "MD5"))

(test-equal (string-append
             "+---[RSA 2048]----+\n"
             "| =+o...+=o..     |\n"
             "|o++... *o .      |\n"
             "|*.o.  *o.        |\n"
             "|oo.  ..o.= .     |\n"
             "|.+o. .. S =      |\n"
             "|*=+ .  o = .     |\n"
             "|OE .  . o        |\n"
             "| o     .         |\n"
             "|                 |\n"
             "+----[SHA256]-----+\n")
            (random-art (base64-decode "nThbg6kXUpJWGl7E1IGOCspRomTxdCARLviKw6E5SY8="
                                       base64-alphabet #f #f)
                        "RSA 2048" "SHA256"))

(test-end)

(exit (if (zero? (test-runner-fail-count (test-runner-get))) 0 1))
