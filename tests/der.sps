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

(import
  (rnrs (6))
  (srfi :64 testing)
  (industria bit-strings)
  (industria bytevectors)
  (prefix (industria der) der:))

(test-begin "der-subjectaltname")

(define (SubjectAltName)
  `(sequence-of 1 +inf.0 ,(GeneralName)))

(define (GeneralName)
  `(choice #;(otherName (implicit context 0 ,(OtherName)))
           (rfc822Name (implicit context 1 ia5-string))
           (dNSName (implicit context 2 ia5-string))
           #;etc...))

(test-equal '(sequence 0 32
                       (((prim context 2) 2 17
                         #vu8(119 119 119 46 119 101 105 110 104 111 108 116 46 115 101))
                        ((prim context 2) 19 13
                         #vu8(119 101 105 110 104 111 108 116 46 115 101))))
            (der:decode #vu8(48 30 130 15 119 119 119 46 119 101 105 110 104 111 108 116
                                46 115 101 130 11 119 101 105 110 104 111 108 116 46 115 101)))

(test-equal '("www.weinholt.se" "weinholt.se")
            (der:translate
             (der:decode #vu8(48 30 130 15 119 119 119 46 119 101 105 110 104 111 108 116
                              46 115 101 130 11 119 101 105 110 104 111 108 116 46 115 101))
             (SubjectAltName)))
(test-end)

(test-begin "der-encode-boolean")
(test-equal #vu8(#x01 #x01 #x00) (der:encode #f '(boolean 0 0 #f)))
(test-equal #vu8(#x01 #x01 #xff) (der:encode #f '(boolean 0 0 #t)))
(test-equal '(boolean 0 3 #f) (der:decode (der:encode #f '(boolean 0 0 #f))))
(test-equal '(boolean 0 3 #t) (der:decode (der:encode #f '(boolean 0 0 #t))))
(test-end)

(test-begin "der-encode-integer")
(test-equal #vu8(#x02 #x01 0) (der:encode #f '(integer 0 0 0)))
(test-equal #vu8(#x02 #x01 42) (der:encode #f '(integer 0 0 42)))
(test-equal #vu8(#x02 #x01 #xd6) (der:encode #f '(integer 0 0 -42)))
(test-equal #vu8(#x02 #x01 #x80) (der:encode #f '(integer 0 0 -128)))
(do ((i -514 (+ i 1)))
    ((= i 514))
  (test-equal i (der:data-value (der:decode (der:encode #f `(integer 0 0 ,i))))))
(test-end)

(test-begin "der-encode-bit-string")
(let ((b (integer->bit-string #x0A3B5F291CD 44)))
  (test-equal #vu8(#x03 #x07 #x04 #x0A #x3B #x5F #x29 #x1C #xD0)
              (der:encode #f (list 'bit-string 0 0 b)))
  (let ((x (der:decode #vu8(#x03 #x07 #x04 #x0A #x3B #x5F #x29 #x1C #xD0))))
    (test-equal (der:data-type x) 'bit-string)
    (test-equal (der:data-start-index x) 0)
    (test-equal (der:data-length x) 9)
    (test-equal (bit-string->bytevector (der:data-value x))
                (bit-string->bytevector b))
    (test-equal (bit-string-length (der:data-value x))
                (bit-string-length b))))
(let ((b (integer->bit-string 0 0)))
  (test-equal #vu8(#x03 #x01 #x00) (der:encode #f (list 'bit-string 0 0 b)))
  (let ((x (der:decode #vu8(#x03 #x01 #x00))))
    (test-equal (der:data-type x) 'bit-string)
    (test-equal (der:data-start-index x) 0)
    (test-equal (der:data-length x) 3)
    (test-equal (bit-string->bytevector (der:data-value x))
                (bit-string->bytevector b))
    (test-equal (bit-string-length (der:data-value x))
                (bit-string-length b))))
(test-end)

(test-begin "der-encode-octet-string")
(test-equal #vu8(#x04 #x00) (der:encode #f '(octet-string 0 0 #vu8())))
(test-equal #vu8(#x04 #x01 1) (der:encode #f '(octet-string 0 0 #vu8(1))))
(test-equal '(octet-string 0 2 #vu8())
            (der:decode (der:encode #f '(octet-string 0 0 #vu8()))))
(test-equal '(octet-string 0 3 #vu8(1))
            (der:decode (der:encode #f '(octet-string 0 0 #vu8(1)))))
(test-end)

(test-begin "der-encode-null")
(test-equal #vu8(#x05 #x00) (der:encode #f '(null 0 0 #f)))
(test-equal '(null 0 2 #f)
            (der:decode (der:encode #f '(null 0 0 #f))))
(test-end)

(test-begin "der-encode-utf8-string")
(let ((jones #vu8(#x0c #x06 195 165 195 164 195 182)))
  (test-equal '(utf8-string 0 8 "åäö") (der:decode jones))
  (test-equal jones (der:encode #f '(utf8-string 0 0 "åäö"))))
(test-end)

(test-begin "der-encode-printable-string")
(let ((jones #vu8(#x13 #x05 #x4A #x6F #x6E #x65 #x73)))
  (test-equal '(printable-string 0 7 "Jones") (der:decode jones))
  (test-equal jones (der:encode #f '(printable-string 0 0 "Jones"))))
(test-end)

(test-begin "der-encode-t61-string")
(let ((jones #vu8(#x14 #x05 #x4A #x6F #x6E #x65 #x73)))
  (test-equal '(t61-string 0 7 "Jones") (der:decode jones))
  (test-equal jones (der:encode #f '(t61-string 0 0 "Jones"))))
(test-end)

(test-begin "der-encode-ia5string")
(let ((smith #vu8(#x16 #x05 83 109 105 116 104)))
  (test-equal '(ia5-string 0 7 "Smith") (der:decode smith))
  (test-equal #vu8(#x16 #x00) (der:encode #f '(ia5-string 0 0 "")))
  (test-equal smith (der:encode #f '(ia5-string 0 0 "Smith")))
  (test-equal #vu8(#x16 3 #x30 #x0a #x30)
              (der:encode #f '(ia5-string 0 0 "0\n0"))))
(test-end)

(test-begin "der-encode-visible-string")
(let ((jones #vu8(#x1A #x05 #x4A #x6F #x6E #x65 #x73)))
  (test-equal '(visible-string 0 7 "Jones") (der:decode jones))
  (test-equal jones (der:encode #f '(visible-string 0 0 "Jones"))))
(test-end)

(test-begin "der-encode-sequence")
(let ((example #vu8(#x30 #x0a #x16 #x05 83 109 105 116 104
                         #x01 #x01 #xff)))
  (test-equal '(sequence 0 12 ((ia5-string 2 7 "Smith")
                               (boolean 9 3 #t)))
              (der:decode example))
  (test-equal example
              (der:encode #f '(sequence 0 0 ((ia5-string 0 0 "Smith")
                                             (boolean 0 0 #t))))))
(test-end)

(test-begin "der-encode-set")
(let ((example #vu8(#x31 #x0a #x16 #x05 83 109 105 116 104
                         #x01 #x01 #xff)))
  (test-equal '(set 0 12 ((ia5-string 2 7 "Smith")
                          (boolean 9 3 #t)))
              (der:decode example))
  (test-equal example
              (der:encode #f '(set 0 0 ((ia5-string 0 0 "Smith")
                                        (boolean 0 0 #t))))))
(test-end)

(test-begin "der-encode-object-id")
(let ((example #vu8(#x06 #x03 #x81 #x34 #x03)))
  (test-equal '(object-identifier 0 5 (2 100 3))
              (der:decode example))
  (test-equal example
              (der:encode #f '(object-identifier 0 0 (2 100 3)))))
(do ((x 0 (+ x 1)))
    ((= x 2))
  (do ((y 0 (+ y 1)))
      ((> y 39))
    (do ((z 0 (+ z 1)))
        ((> z 300))
      (test-equal `(,x ,y ,z)
                  (der:data-value
                   (der:decode
                    (der:encode #f `(object-identifier 0 0 (,x ,y ,z)))))))))
(test-end)

(test-begin "der-encode-relative-object-id")
(let ((example #vu8(#x0D #x04 #xC2 #x7B #x03 #x02)))
  (test-equal '(relative-oid 0 6 (8571 3 2))
              (der:decode example))
  (test-equal example
              (der:encode #f '(relative-oid 0 0 (8571 3 2)))))
(test-end)

(test-begin "der-encode-digest")
(define (DigestInfo)
  '(sequence (digestAlgorithm (sequence (algorithm object-identifier)
                                        (parameters ANY (default #f))))
             (digest octet-string)))
(let ((example #vu8(#x30 #x31 #x30 #x0d #x06 #x09 #x60 #x86 #x48 #x01  ;RFC3447
                         #x65 #x03 #x04 #x02 #x01 #x05 #x00 #x04 #x20
                         1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16
                         1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16))
      (decoded
       '(sequence 0 51 ((sequence 2 15 ((object-identifier 4 11 (2 16 840 1 101 3 4 2 1))
                                        (null 15 2 #f)))
                        (octet-string 17 34 #vu8(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16
                                                   1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16))))))
  (test-equal decoded (der:decode example))
  (test-equal example (der:encode #f decoded))
  (test-equal decoded (der:decode (der:encode #f decoded)))
  (test-equal '((digestAlgorithm (algorithm . (2 16 840 1 101 3 4 2 1))
                                 (parameters . (null 15 2 #f)))
                (digest . #vu8(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16
                                 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16)))
              (der:translate decoded (DigestInfo)
                             (lambda (name type value start len)
                               (cons name value)))))
(test-end)

(test-begin "der-encode-long")
(test-equal #vu8(#x1A #b10000001 #b11001001)
            (subbytevector (der:encode #f `(visible-string 0 0 ,(make-string 201 #\x)))
                           0 3))
(test-equal #vu8(#x40 0) (der:encode #f `((prim application 0) 0 0 #vu8())))
(test-equal #vu8(#x60 0) (der:encode #f `((cons application 0) 0 0 ())))
(test-equal #vu8(#x5f 31 0)
            (der:encode #f `((prim application 31) 0 0 #vu8())))
(let ((decoded '((prim application #b110110011) 0 4 #vu8()))
      (binary #vu8(#x5f #b10000011 #b00110011 0)))
  (test-equal binary (der:encode #f decoded))
  (test-equal decoded (der:decode binary)))
(let ((decoded '((cons application #b110110011) 0 4 ()))
      (binary #vu8(#x7f #b10000011 #b00110011 0)))
  (test-equal binary (der:encode #f decoded))
  (test-equal decoded (der:decode binary)))
(test-end)

(test-begin "der-encode-long-example")
(letrec ((utf8 (lambda (str) (bytevector->u8-list (string->utf8 str)))))
  (let ((binary (u8-list->bytevector    ;from X.690 (07/2002)
                 `(#x60 #x81 #x85
                        #x61 #x10
                             #x1A #x04 ,@(utf8 "John")
                             #x1A #x01 ,@(utf8 "P")
                             #x1A #x05 ,@(utf8 "Smith")
                        #xA0 #x0A
                             #x1A #x08 ,@(utf8 "Director")
                        #x42 #x01 #x33
                        #xA1 #x0A
                             #x43 #x08 ,@(utf8 "19710917")
                        #xA2 #x12
                             #x61 #x10
                                  #x1A #x04 ,@(utf8 "Mary")
                                  #x1A #x01 ,@(utf8 "T")
                                  #x1A #x05 ,@(utf8 "Smith")
                        #xA3 #x42
                             #x31 #x1F
                                  #x61 #x11
                                       #x1A #x05 ,@(utf8 "Ralph")
                                       #x1A #x01 ,@(utf8 "T")
                                       #x1A #x05 ,@(utf8 "Smith")
                                  #xA0 #x0A
                                       #x43 #x08 ,@(utf8 "19571111")
                             #x31 #x1F
                                  #x61 #x11
                                       #x1A #x05 ,@(utf8 "Susan")
                                       #x1A #x01 ,@(utf8 "B")
                                       #x1A #x05 ,@(utf8 "Jones")
                                  #xA0 #x0A
                                       #x43 #x08 ,@(utf8 "19590717"))))
        (decoded `((cons application 0) 0 136
                   (((cons application 1) 3 18
                     ((visible-string 5 6 "John")
                      (visible-string 11 3 "P")
                      (visible-string 14 7 "Smith")))
                    ((cons context 0) 21 12
                     ((visible-string 23 10 "Director")))
                    ((prim application 2) 33 3
                     #vu8(#x33))
                    ((cons context 1) 36 12
                     (((prim application 3) 38 10
                       ,(string->utf8 "19710917"))))
                    ((cons context 2) 48 20
                     (((cons application 1) 50 18
                       ((visible-string 52 6 "Mary")
                        (visible-string 58 3 "T")
                        (visible-string 61 7 "Smith")))))
                    ((cons context 3) 68 68
                     ((set 70 33
                           (((cons application 1) 72 19
                             ((visible-string 74 7 "Ralph")
                              (visible-string 81 3 "T")
                              (visible-string 84 7 "Smith")))
                            ((cons context 0) 91 12
                             (((prim application 3) 93 10
                               ,(string->utf8 "19571111"))))))
                      (set 103 33
                           (((cons application 1) 105 19
                             ((visible-string 107 7 "Susan")
                              (visible-string 114 3 "B")
                              (visible-string 117 7 "Jones")))
                            ((cons context 0) 124 12
                             (((prim application 3) 126 10
                               ,(string->utf8 "19590717"))))))))))))

    (test-equal decoded (der:decode binary))
    (test-equal binary (der:encode #f decoded))))
(test-end)

(exit (if (zero? (test-runner-fail-count (test-runner-get))) 0 1))
