G-Pascal Source organization
===========================

Author: Nick Gammon
Date:   21 June 2011
____________________________________________________________________

I'll just explain the source organisation a bit. 

This was written before I had even heard of "linkers". My fundamental
problem was that the Merlin assembler had to hold, in the memory of an
Apple 2, both the source and the object, at one time, as this was an
in-memory compiler.

However the source was much too large to all fit in memory.

So I broke the source down into logical, and fairly self-contained
parts:

- Part 1 - tokenization and general utilities
- Part 2 - compiler (produces P-codes)
- Part 3 - menu, file handling
- Part 4 - interpreter (interprets P-codes)
- Part 5 - text editor
- Part 6 - more of the compiler (processing a 'block')

Now the issue was, how to "link" the parts together. So first I
allocated "global" variables by simply assigning them addresses in
memory, and having an EQU instruction at the start of each file,
giving each variable the same address.

Then to make it easy for something in part 3 to call something in part
2 (say), I made a "jump table" at the start of each part (which is
probably exactly what compilers/linkers to these days). For example,
in part 1 on page 4 there is a list of important subroutines I might
want to use from other files:

                     289   * VECTORS
                           ************************************************
    8013: 4C 97 80   291                     JMP   INIT
    8016: 4C 07 81   292                     JMP   GETNEXT
    8019: 4C 5A 81   293                     JMP   COMSTL
    801C: 4C 71 81   294                     JMP   ISITHX
    801F: 4C 95 81   295                     JMP   ISITAL
    8022: 4C A9 81   296                     JMP   ISITNM
    8025: 4C 3A 81   297                     JMP   CHAR
    8028: 4C 78 89   298                     JMP   GEN2:B
    802B: 4C FE 86   299                     JMP   DISHX



By trial-and-error I worked out how much memory each file used, and
assigned them all starting addresses like this:

                      10     P1             EQU   $8013
                      11     P2             EQU   $8DD4
                      12     P3             EQU   $992E
                      13     P4             EQU   $A380
                      14     P5             EQU   $B384
                      15     P6             EQU   $BCB8

So now each file knows that part 1 starts at address $8013 (which you
can see from the above would be the "JMP INIT" line. So now the other
files can just reference the jump table without needing to know
exactly where it jumps to. For example in part 2:

                     287   INIT       EQU   V1
                     288   GETNEXT    EQU   V1+3
                     289   COMSTL     EQU   V1+6
                     290   ISITHX     EQU   V1+9
                     291   ISITAL     EQU   V1+12
                     292   ISITNM     EQU   V1+15
                     293   CHAR       EQU   V1+18
                     294   GEN2:B     EQU   V1+21
                     295   DISHX      EQU   V1+24

So if part 2 needs to call ISITHX (is it hex) then it does a JSR to
ISITHX (which will be $8013 + 9) which takes it to the "JMP ISITHX" in
part 1, which then jumps to the actual subroutine, which then does a
RTS in the normal way.

The jump tables are different sizes depending on what functions needed
exporting (effectively, depending on whether they were internal to the
same file, or needed to be exported to other files).

The whole thing worked out fairly smoothly.

The other things about the source is that I found myself very tight
for memory, so in quite a few places I replaced something like this:

    ... blah blah ...
    JSR GTOKEN       ; get token for one-token lookahead
    RTS              ; done with this function

by this:

    ... blah blah ...
    JMP GTOKEN       ; get token for lookahead, and then done

This had the same effect (I believe it is called "tail recursion"
these days). Rather than calling GTOKEN, returning and then returning
again, by jumping to GTOKEN the return from GTOKEN actually returns
from the caller. This saved one byte each place I did it (and a few
machine cycles too).
