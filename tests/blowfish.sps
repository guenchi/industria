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

(import (industria crypto blowfish)
        (srfi :64 testing)
        (rnrs))

;; Test vectors from http://www.schneier.com/code/vectors.txt

(define (test key* plaintext*)
  (let ((key (make-bytevector 8))
        (plaintext (make-bytevector 8)))
    (bytevector-u64-set! key 0 key* (endianness big))
    (bytevector-u64-set! plaintext 0 plaintext* (endianness big))
    (let ((enc (make-bytevector 8 0))
          (dec (make-bytevector 8 0)))
      (let* ((sched (expand-blowfish-key key))
             (desched (reverse-blowfish-schedule sched)))
        (blowfish-encrypt! plaintext 0 enc 0 sched)
        (blowfish-decrypt! enc 0 dec 0 desched)
        (clear-blowfish-schedule! sched)
        (clear-blowfish-schedule! desched)
        (and (equal? dec plaintext)
             (bytevector-u64-ref enc 0 (endianness big)))))))

(test-begin "blowfish vectors")
(test-equal #x4EF997456198DD78 (test #x0000000000000000 #x0000000000000000))
(test-equal #x51866FD5B85ECB8A (test #xFFFFFFFFFFFFFFFF #xFFFFFFFFFFFFFFFF))
(test-equal #x7D856F9A613063F2 (test #x3000000000000000 #x1000000000000001))
(test-equal #x2466DD878B963C9D (test #x1111111111111111 #x1111111111111111))
(test-equal #x61F9C3802281B096 (test #x0123456789ABCDEF #x1111111111111111))
(test-equal #x7D0CC630AFDA1EC7 (test #x1111111111111111 #x0123456789ABCDEF))
(test-equal #x4EF997456198DD78 (test #x0000000000000000 #x0000000000000000))
(test-equal #x0ACEAB0FC6A0A28D (test #xFEDCBA9876543210 #x0123456789ABCDEF))
(test-equal #x59C68245EB05282B (test #x7CA110454A1A6E57 #x01A1D6D039776742))
(test-equal #xB1B8CC0B250F09A0 (test #x0131D9619DC1376E #x5CD54CA83DEF57DA))
(test-equal #x1730E5778BEA1DA4 (test #x07A1133E4A0B2686 #x0248D43806F67172))
(test-equal #xA25E7856CF2651EB (test #x3849674C2602319E #x51454B582DDF440A))
(test-equal #x353882B109CE8F1A (test #x04B915BA43FEB5B6 #x42FD443059577FA2))
(test-equal #x48F4D0884C379918 (test #x0113B970FD34F2CE #x059B5E0851CF143A))
(test-equal #x432193B78951FC98 (test #x0170F175468FB5E6 #x0756D8E0774761D2))
(test-equal #x13F04154D69D1AE5 (test #x43297FAD38E373FE #x762514B829BF486A))
(test-equal #x2EEDDA93FFD39C79 (test #x07A7137045DA2A16 #x3BDD119049372802))
(test-equal #xD887E0393C2DA6E3 (test #x04689104C2FD3B2F #x26955F6835AF609A))
(test-equal #x5F99D04F5B163969 (test #x37D06BB516CB7546 #x164D5E404F275232))
(test-equal #x4A057A3B24D3977B (test #x1F08260D1AC2465E #x6B056E18759F5CCA))
(test-equal #x452031C1E4FADA8E (test #x584023641ABA6176 #x004BD6EF09176062))
(test-equal #x7555AE39F59B87BD (test #x025816164629B007 #x480D39006EE762F2))
(test-equal #x53C55F9CB49FC019 (test #x49793EBC79B3258F #x437540C8698F3CFA))
(test-equal #x7A8E7BFA937E89A3 (test #x4FB05E1515AB73A7 #x072D43A077075292))
(test-equal #xCF9C5D7A4986ADB5 (test #x49E95D6D4CA229BF #x02FE55778117F12A))
(test-equal #xD1ABB290658BC778 (test #x018310DC409B26D6 #x1D9D5C5018F728C2))
(test-equal #x55CB3774D13EF201 (test #x1C587F1C13924FEF #x305532286D6F295A))
(test-equal #xFA34EC4847B268B2 (test #x0101010101010101 #x0123456789ABCDEF))
(test-equal #xA790795108EA3CAE (test #x1F1F1F1F0E0E0E0E #x0123456789ABCDEF))
(test-equal #xC39E072D9FAC631D (test #xE0FEE0FEF1FEF1FE #x0123456789ABCDEF))
(test-equal #x014933E0CDAFF6E4 (test #x0000000000000000 #xFFFFFFFFFFFFFFFF))
(test-equal #xF21E9A77B71C49BC (test #xFFFFFFFFFFFFFFFF #x0000000000000000))
(test-equal #x245946885754369A (test #x0123456789ABCDEF #x0000000000000000))
(test-equal #x6B5C5A9C5D9E0A5A (test #xFEDCBA9876543210 #xFFFFFFFFFFFFFFFF))
(test-end)

(define (testv keylen key*)
  (let ((key (make-bytevector keylen))
        (plaintext (make-bytevector 8)))
    (bytevector-uint-set! key 0 key* (endianness big) keylen)
    (bytevector-u64-set! plaintext 0 #xFEDCBA9876543210 (endianness big))
    (let ((enc (make-bytevector 8 0))
          (dec (make-bytevector 8 0)))
      (let* ((sched (expand-blowfish-key key))
             (desched (reverse-blowfish-schedule sched)))
        (blowfish-encrypt! plaintext 0 enc 0 sched)
        (blowfish-decrypt! enc 0 dec 0 desched)
        (clear-blowfish-schedule! sched)
        (clear-blowfish-schedule! desched)
        (and (equal? dec plaintext)
             (bytevector-u64-ref enc 0 (endianness big)))))))

(test-begin "blowfish keys")
(test-equal #xF9AD597C49DB005E (testv 1 #xF0))
(test-equal #xE91D21C1D961A6D6 (testv 2 #xF0E1))
(test-equal #xE9C2B70A1BC65CF3 (testv 3 #xF0E1D2))
(test-equal #xBE1E639408640F05 (testv 4 #xF0E1D2C3))
(test-equal #xB39E44481BDB1E6E (testv 5 #xF0E1D2C3B4))
(test-equal #x9457AA83B1928C0D (testv 6 #xF0E1D2C3B4A5))
(test-equal #x8BB77032F960629D (testv 7 #xF0E1D2C3B4A596))
(test-equal #xE87A244E2CC85E82 (testv 8 #xF0E1D2C3B4A59687))
(test-equal #x15750E7A4F4EC577 (testv 9 #xF0E1D2C3B4A5968778))
(test-equal #x122BA70B3AB64AE0 (testv 10 #xF0E1D2C3B4A596877869))
(test-equal #x3A833C9AFFC537F6 (testv 11 #xF0E1D2C3B4A5968778695A))
(test-equal #x9409DA87A90F6BF2 (testv 12 #xF0E1D2C3B4A5968778695A4B))
(test-equal #x884F80625060B8B4 (testv 13 #xF0E1D2C3B4A5968778695A4B3C))
(test-equal #x1F85031C19E11968 (testv 14 #xF0E1D2C3B4A5968778695A4B3C2D))
(test-equal #x79D9373A714CA34F (testv 15 #xF0E1D2C3B4A5968778695A4B3C2D1E))
(test-equal #x93142887EE3BE15C (testv 16 #xF0E1D2C3B4A5968778695A4B3C2D1E0F))
(test-equal #x03429E838CE2D14B (testv 17 #xF0E1D2C3B4A5968778695A4B3C2D1E0F00))
(test-equal #xA4299E27469FF67B (testv 18 #xF0E1D2C3B4A5968778695A4B3C2D1E0F0011))
(test-equal #xAFD5AED1C1BC96A8 (testv 19 #xF0E1D2C3B4A5968778695A4B3C2D1E0F001122))
(test-equal #x10851C0E3858DA9F (testv 20 #xF0E1D2C3B4A5968778695A4B3C2D1E0F00112233))
(test-equal #xE6F51ED79B9DB21F (testv 21 #xF0E1D2C3B4A5968778695A4B3C2D1E0F0011223344))
(test-equal #x64A6E14AFD36B46F (testv 22 #xF0E1D2C3B4A5968778695A4B3C2D1E0F001122334455))
(test-equal #x80C7D7D45A5479AD (testv 23 #xF0E1D2C3B4A5968778695A4B3C2D1E0F00112233445566))
(test-equal #x05044B62FA52D080 (testv 24 #xF0E1D2C3B4A5968778695A4B3C2D1E0F0011223344556677))
(test-end)

(exit (if (zero? (test-runner-fail-count (test-runner-get))) 0 1))
