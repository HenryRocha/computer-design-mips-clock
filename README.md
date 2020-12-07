# Computer Design MIPS Clock

Projeto de Design de Computadores com o objetivo de criar um processador com arquitetura MIPS, usando a FPGA DEV0-CV.

# Features

- [X] Impletação de instruções tipo R
- [X] Impletação de instruções tipo I
- [X] Impletação de instruções tipo J
- [X] Subgrupo A
- [X] Subgrupo B
- [X] UC para Opcode
- [X] UC para ULA
- [X] ULA bit a bit

# Manual de Instruções

O _clock_ é controlado pelo botão FPGA_RESET.

Os _switches_ SW0 e SW1 controlam qual valor será mostrado no display HEX.
- 00 : Saída do PC
- 01 : Saída da ULA
- 10 : Saída do MUX que escolhe entre ULA, MEM, LUI e JAL
- 11 : Sempre zero.
