# Introduction

This code is written for the MSP430F5510-STK board from Olimex.

It was originally cloned from https://github.com/lonetech/nim-msp430
and then heavily modified to make it functional.

The board is programmed using an MSP430F5529 Launchpad with the SBW
interface.

# Setup

  1. Download the latest stable MSPGCC for MSP430 from TI and copy
      the folder gcc to the top level of the repository.
  2. Clone mspdebug from https://github.com/dlbeer/mspdebug and build.
  3. Copy the executable mspdebug to the toplevel of the repository

# Building

```
make
```

Builds the elf file.

```
make listing
```

Generates `asm.lst` for your assembly browsing and debugging pleasure.

```
make ezFetToTILib
```

Uses mspdebug to update the firmware on the Launchpad ezFet emulator to
be more like the MSPFET430UIF JTAG probe. mspdebug worked using the tilib only.

Solution discovered at:
https://www.pabigot.com/msp430/exp430fr5969-launchpad-first-experiences/

As noted in blog post above, sudo is needed to update firmware as udev rule
won't apply throughout the firmware update process.

```
make mspdebug
```

OR (for gdb as provided by TI)

```
make debugserver
make debug
```

Starts debug session and ensures that libmsp430.so (or dll if on windows) can be
found by mspdebug. mspdebug uses sudo currently because I haven't written
a udev rule yet. Feel free to do so yourself.

Now gdb is working. I had forgotten to add the libmsp430.so path to the dynamic loader.

# Project State

The project compiles, but I'm not sure of the optimal way to write to registers.
Type annotating them is very irritating and manual labor intensive in the header
file. Nim is not coercing them to an appropriate type yet. Perhaps that will
be fixed in the language or I will discover (aka be told how on https://forum.nim-lang.org/)
a better method.
