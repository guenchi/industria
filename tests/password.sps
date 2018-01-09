#!/usr/bin/env scheme-script
;; -*- mode: scheme; coding: utf-8 -*- !#
;; Copyright © 2009, 2010, 2018 Göran Weinholt <goran@weinholt.se>

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
        (industria password))

;;; DES

(test-begin "password-des")

(test-equal "..o6avrdNBOA6" (crypt "foodbard" ".."))

(test-equal "..9sjyf8zL76k" (crypt "test" ".."))

(test-equal "..XhpOnw6KMZg" (crypt "X" ".."))

(test-equal "AxTdjVtckZ0Rs" (crypt "foobar" "Ax"))

(test-equal "zz/CBDeUpwD26" (crypt "ZZZZ" "zz"))

(test-equal "..X8NBuQ4l6uQ" (crypt "" ".."))

(test-equal "ZZvIHp4MBMwSE" (crypt "" "ZZ"))

(test-end)

;;; MD5

(test-begin "password-md5")

(test-equal "$1$oKnN0HHt$Aul2g/J4edgga3WE/03cN/"
            (crypt "hello" "$1$oKnN0HHt$"))

(test-equal "$1$oKnN0HHt$KtM1JhHfFNyQOq5OgbGo.1"
            (crypt "this is a password longer than 16 characters" "$1$oKnN0HHt$"))

(test-end)

;;; SHA from http://people.redhat.com/drepper/SHA-crypt.txt

;; SHA-256

(test-begin "password-sha-256")
(test-skip 7)

(test-equal "$5$saltstring$5B8vYYiY.CVt1RlTTf8KbXBH3hsxY/GNooZaBBGWEc5"
            (crypt "Hello world!"
                   "$5$saltstring"))

(test-equal "$5$rounds=10000$saltstringsaltst$3xv.VbSHBb41AL9AvLeujZkZRBAwqFMz2.opqey6IcA"
            (crypt "Hello world!"
                   "$5$rounds=10000$saltstringsaltstring"))

(test-equal "$5$rounds=5000$toolongsaltstrin$Un/5jzAHMgOGZ5.mWJpuVolil07guHPvOW8mGRcvxa5"
            (crypt "This is just a test"
                   "$5$rounds=5000$toolongsaltstring"))

(test-equal "$5$rounds=1400$anotherlongsalts$Rx.j8H.h8HjEDGomFU8bDkXm3XIUnzyxf12oP84Bnq1"
            (crypt "a very much longer text to encrypt.  This one even stretches over morethan one line."
                   "$5$rounds=1400$anotherlongsaltstring"))

(test-equal "$5$rounds=77777$short$JiO1O3ZpDAxGJeaDIuqCoEFysAe1mZNJRs3pw0KQRd/"
            (crypt "we have a short salt string but not a short password"
                   "$5$rounds=77777$short"))

(test-equal "$5$rounds=123456$asaltof16chars..$gP3VQ/6X7UUEW3HkBn2w1/Ptq2jxPyzV/cZKmF/wJvD"
            (crypt "a short string"
                   "$5$rounds=123456$asaltof16chars.."))

(test-equal "$5$rounds=1000$roundstoolow$yfvwcWrQ8l/K0DAWyuPMDNHpIVlTQebY9l/gL972bIC"
            (crypt "the minimum number is still observed"
                   "$5$rounds=10$roundstoolow"))

(test-end)

;; SHA-512

(test-begin "password-sha-512")
(test-skip 7)
(test-equal "$6$saltstring$svn8UoSVapNtMuq1ukKS4tPQd8iKwSMHWjl/O817G3uBnIFNjnQJuesI68u4OTLiBFdcbYEdFCoEOfaS35inz1"
            (crypt "Hello world!"
                   "$6$saltstring"))

(test-equal "$6$rounds=10000$saltstringsaltst$OW1/O6BYHV6BcXZu8QVeXbDWra3Oeqh0sbHbbMCVNSnCM/UrjmM0Dp8vOuZeHBy/YTBmSK6H9qs/y3RnOaw5v."
            (crypt "Hello world!"
                   "$6$rounds=10000$saltstringsaltstring"))

(test-equal "$6$rounds=5000$toolongsaltstrin$lQ8jolhgVRVhY4b5pZKaysCLi0QBxGoNeKQzQ3glMhwllF7oGDZxUhx1yxdYcz/e1JSbq3y6JMxxl8audkUEm0"
            (crypt "This is just a test"
                   "$6$rounds=5000$toolongsaltstring"))

(test-equal "$6$rounds=1400$anotherlongsalts$POfYwTEok97VWcjxIiSOjiykti.o/pQs.wPvMxQ6Fm7I6IoYN3CmLs66x9t0oSwbtEW7o7UmJEiDwGqd8p4ur1"
            (crypt "a very much longer text to encrypt.  This one even stretches over morethan one line."
                   "$6$rounds=1400$anotherlongsaltstring"))

(test-equal "$6$rounds=77777$short$WuQyW2YR.hBNpjjRhpYD/ifIw05xdfeEyQoMxIXbkvr0gge1a1x3yRULJ5CCaUeOxFmtlcGZelFl5CxtgfiAc0"
            (crypt "we have a short salt string but not a short password"
                   "$6$rounds=77777$short"))

(test-equal "$6$rounds=123456$asaltof16chars..$BtCwjqMJGx5hrJhZywWvt0RLE8uZ4oPwcelCjmw2kSYu.Ec6ycULevoBK25fs2xXgMNrCzIMVcgEJAstJeonj1"
            (crypt "a short string"
                   "$6$rounds=123456$asaltof16chars.."))

(test-equal "$6$rounds=1000$roundstoolow$kUMsbe306n21p9R.FRkW3IGn.S9NPN0x50YhH1xhLsPuWGsUSklZt58jaTfF4ZEQpyUNGc0dqbpBYYBaHHrsX."
            (crypt "the minimum number is still observed"
                   "$6$rounds=10$roundstoolow"))

(test-end)

(exit (if (zero? (test-runner-fail-count (test-runner-get))) 0 1))
