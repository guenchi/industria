# Industria

Industria is a collection of portable R6RS Scheme libraries for
cryptography. It implements low-level algorithms like AES, RSA, DSA,
ECDSA, etc and high-level protocols such as OpenPGP, Off-The-Record
messaging and Secure Shell (SSH).

The assembler, disassembler and binary format libraries have been
moved to the [machine-code](https://github.com/weinholt/machine-code)
project.

The structure pack/unpack syntax has been moved to
the [struct-pack](https://github.com/weinholt/struct-pack/) project.

The decompression code has been moved to
the [compression](https://github.com/weinholt/compression/) project.

The CRC library and hash algorithms have been moved to
the [hashing](https://github.com/weinholt/hashing/) project.

# Current status

This project is being split into smaller projects.
See [issue #4](https://github.com/weinholt/industria/issues/4).

# Documentation

The latest [released manual is available online](https://weinholt.se/industria/manual/).

The sources for the manual are available in Texinfo format in the
documentation directory. Use these commands from that directory to
build the manual:

```bash
makeinfo industria.texinfo                    # info format
makeinfo --plaintext industria.texinfo        # text format
makeinfo --no-split --html industria.texinfo  # html format
texi2pdf industria.texinfo                    # pdf format
```
