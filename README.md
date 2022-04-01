# 



<br />
<div align="center">
  <h1 align="center">Computer Architectures Project</h1>
  <p align="center">
    This repository contains the implementation for the laboratory project of Computer Architectures class at the University of Florence
  </p>
</div>

<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#getting-started">Getting Started</a>
    </li>
    <li>
      <a href="#Description-of-the-ciphers">Description of the ciphers</a>
      <ul>
        <li><a href="#substitute-cipher">Substitute cipher / Caesar cipher</a></li>
        <li><a href="#block-cipher">Block cipher</a></li>
        <li><a href="#occurrences-cipher">Occurrences cipher</a></li>
        <li><a href="#dictionary-encryption">Dictionary encryption</a></li>
      </ul>
    </li>
    <li><a href="#running-instructions">Running instructions</a></li>
    <li><a href="#assignment-&-report">Assignment & report</a></li>
    <li><a href="#license">License</a></li>
  </ol>
</details>

# Getting Started

In order to run the source code, download version v2.1.0 of the Ripes simuletor on the relative [github page](https://github.com/mortbopet/Ripes/releases/tag/v2.1.0) build for the [RISC-V instruction set architecture](https://riscv.org/wp-content/uploads/2017/05/riscv-spec-v2.2.pdf).

# Description of the ciphers

RISC-V assembly code that simulates some encryption and decryption functions of a text message, interpreted as sequence of ASCII characters.

### 1. Substitute cipher / Caesar cipher

It is a mono-alphabetic substitution cipher in which each letter of the plaintext is replaced by the letter found a number of places later in the alphabet.

Then, the standard 8-bit ASCII code of each character of the text message is changed by adding an integer constant K, modulo 256.

For Example:

$$ pt= LOVE AssEMbLY \\  k = 1$$

|Pt|L|O|V|E| |A|s|s|E|M|b|L|Y|
|--|-|-|-|-|-|-|-|-|-|-|-|-|-|
|Cod(pt)|76|79|86|69|32|65|115|115|69|77|98|76|89|
|Cod(k)|77|80|87|70|32|66|116|116|70|78|99|77|90|
|Ct|M|P|W|F| |B|t|t|F|N|c|M|Z|

### Block cipher

A block cipher encrypts by considering m characters for the block to be encrypted and k characters for the key to be used during encryption, returning m  characters in output for the cyphertext.

The word is partitioned into nb blocks, obtained as nb = m / k rounded up to the integer.

Each block in $$B = {b_1, b_2,...,b_{nb}}$$ contains at most k consecutive elements of the string to be encrypted. Each element of each block is encrypted by adding the ASCII encoding of a key character to the ASCII encoding of the character.
$$ For\ each\ b_i\ in\ B(1 ≤ i ≤ nb) \\ cb_i = cod(b_{ij} ) + cod(key_j ), 1 ≤ j ≤ k $$

With cyphertext $$ ct = {cb_1, cb_2, ... cb_{nb}}$$ defined of nb blocks.

For Example:

$$ pt= GRADUATE \\  key = OLE$$

Calculate Cod (O) = 79, Cod (L) = 76, Cod (E) = 69 by consulting the ASCII table

|Pt|G|R|A|D|U|A|T|E|
|--|-|-|-|-|-|-|-|-|
|Cod(pt)|71|82|65|68|85|65|84|69|
|Key|O|L|E|O|L|E|O|L|
|Cod(key)|79|76|69|79|76|69|79|76|
|Cod(ct)|150|158|134|147|161|137|163|145

### 3. Occurrences cipher

Starting from the first character of the plaintext (at the position
1), the message is encrypted as a sequence of strings separated by exactly 1 space:

* each string has the form $$x-p_1 -...-p_k$$ where x is the first occurrence of each character present in the message
* and $$p_1 ... p_k$$ are the k positions in which the character x appears in the message
* each position is preceded by the separator character '-' (to distinguish the elements of the sequence of positions).

For Example:

$$ Pt = "example\ 1" $$

Encrypting with this algorithm will produce the cyphertext:

$$ ct = "e-1-7\ x-2\ a-3\ m-4\ p-5\ l-6\ \ -8\ 1-9"$$

* In the string "-8" the encoded character is the space, which appears in position 8 of the message.
* In the string "1-9 the encoded character is '1', which appears in position 9 of the message.

### 4. Dictionary encryption

Each possible ASCII symbol is mapped to another ASCII symbol according to a certain function defined by cases. It requires that the single ASCII characters $$c_i$$ of the string to be encoded belong to the reduced encoding $$ (0 ≤ cod (c_i) ≤ 127)$$

* If the character is a lowercase letter, it is replaced with the uppercase equivalent of the reverse alphabet. $$ Z = ct (a), A = ct (z) $$
* If the character is an uppercase letter, it is replaced with the lowercase equivalent of the reverse alphabet. $$ z = ct (A), y = ct (B), a = ct (Z) $$
* If the character is a number.
$$ ct (num) = ASCII (cod (9) - num) $$
* In all other cases (sym), remains unchanged,  $$ ct (sym) = sym $$

For Example:

$$ Pt = "myStr0ng P4ssW_"$$

Pt|m|y|S|t|r|0|n|g| |P|4|s|s|W|_|
----|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|
Type$$c_i$$| low| low| upp| low| low| num| low| low| sym| upp| num| low| low| upp|sym|
ct|N|B|h|G|I|‚|M|T| |k|©|H|H|d|_|

## Running instructions

The program allows you to encrypt and decrypt a text message (plaintext) provided by the user as a string type myplaintext variable (.string in RIPES).

* A. Substitute cipher / Caesar cipher
* B. Block cipher
* C. Occurrences Cipher
* D. Dictionary encryption

In addition to the variable myplaintext (maximum size 100 characters, characters c which can only be such that 32 ≤ cod (c) ≤ 127 to avoid special ASCII characters), the program requires an additional input that specifies how to apply the ciphers. This mycypher variable is a string S = "S_1...S_n" made up of a maximum of 5 characters (therefore with 1≤n≤5), where each character S i (with 1≤i≤n) corresponds to one of the characters 'A', 'B', 'C', 'D', and identifies the cipher to be applied to the message. The order of the ciphers is therefore established by the order in which the characters appear in the string. Furthermore, each cipher returns a cyphertext which is a sequence of characters c, 32 ≤ cod (c) ≤ 127.

As an example, some possible keywords are reported: "C", or "ADC", or "DADD", .... For example, the encryption of the text message with the keyword "ADC" will determine the application of algorithm A, then of algorithm D (on the message already encrypted with A) and finally of algorithm C (on the message already encrypted first with A and then with D).

The program considers the variables myplaintext and mycypher, applying the specified ciphers to produce a video output, the various cypthertext obtained after applying each cipher are separated by a newline. In the same way, the decryption functions are applied starting from the previously encrypted message in reverse order with respect to the ciphers. The last message printed on the screen corresponds to the original plaintext.

## Assignment & report

You can have a look at both the project [assignment](doc/Project_Assignment_aa_19-20.pdf) and the written [report](doc/Report.pdf), but beware that they have been written in Italian.
While all the souce code is well commented in English.

## License

Distributed under the GNU GENERAL PUBLIC LICENSE.  See [LICENSE.txt](LICENSE) for more information.
