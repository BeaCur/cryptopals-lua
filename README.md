## Cryptopals crypto Challenges in Lua

This repository contains my solutions for the Cryptopals crypto challenges (actually challenges 1-24), implemented in Lua using Zenroom.

## Requirements
- [Zenroom](https://zenroom.org/)
- Lua support provided by Zenroom

## Project Structure
* Each challenge is contained in a separate `.lua` file.
* Additional `.txt` files contain the inputs and dataset required by specific challenges. 

## Usage
You can execute the challenges using the `run.sh` script provided. 

### Basic execution:
```bash
./run.sh challenge1.lua
```

### Execution with an input data file:
```bash
./run.sh -a 4.txt challenge4.lua
```
