# Industria

[![Build Status](https://travis-ci.org/weinholt/industria.svg?branch=master)](https://travis-ci.org/weinholt/industria)

Industria is a collection of portable R6RS Scheme libraries for
cryptography. It implements low-level algorithms like AES, RSA, DSA,
ECDSA, etc and high-level protocols such as OpenPGP, Off-The-Record
messaging, DNS and Secure Shell (SSH).

Many of the libraries that were previously part of Industria have been
removed in version 2.0.0. See [NEWS.org](NEWS.org) for the new
locations of these libraries.

# Documentation

The latest [released manual is available online](https://weinholt.se/industria/manual/).

The sources for the manual are available in Texinfo format in the docs
directory. Use these commands from that directory to build the manual:

```bash
makeinfo industria.texi                    # info format
makeinfo --plaintext industria.texi        # text format
makeinfo --no-split --html industria.texi  # html format
texi2pdf industria.texi                    # pdf format
```
