Browse : [Swift](https://github.com/michel-leonard/ciede2000-swift) · [TypeScript](https://github.com/michel-leonard/ciede2000-typescript) · [VBA](https://github.com/michel-leonard/ciede2000-vba) · [Wolfram Language](https://github.com/michel-leonard/ciede2000-wolfram-language) · [AWK](https://github.com/michel-leonard/ciede2000-awk) · **BC** · [C#](https://github.com/michel-leonard/ciede2000-csharp) · [C++](https://github.com/michel-leonard/ciede2000-cpp) · [C99](https://github.com/michel-leonard/ciede2000-c) · [Dart](https://github.com/michel-leonard/ciede2000-dart) · [Go](https://github.com/michel-leonard/ciede2000-go)

# CIEDE2000 color difference formula in BC

This page presents the CIEDE2000 color difference, implemented in the Basic Calculator.

![Logo](https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/docs/assets/images/logo.jpg)

## About

Here you’ll find the first rigorously correct implementation of CIEDE2000 that doesn’t use any conversion between degrees and radians. Set parameter `canonical` to obtain results in line with your existing pipeline.

`canonical`|The algorithm operates...|
|:--:|-|
`0`|in accordance with the CIEDE2000 values currently used by many industry players|
`1`|in accordance with the CIEDE2000 values provided by [this](https://hajim.rochester.edu/ece/sites/gsharma/ciede2000/) academic MATLAB function|

## Our CIEDE2000 offer

This production-ready file, released in 2026, contain the CIEDE2000 algorithm.

Source File|Type|Bits|Purpose|Advantage|
|:--:|:--:|:--:|:--:|:--:|
[ciede2000.bc](./ciede2000.bc)|`number`|Unlimited|Metrology|CSV processing ready with [ciede2000.sh](./ciede2000.sh)|

The script is capable of calculating thousands of scientifically accurate CIEDE2000s per second.

### Software Versions

- macOS 26
- Ubuntu 24
- [bc 7.1](https://github.com/gavinhoward/bc/releases)
- bc 1.07.1

### Example Usage

We calculate CIEDE2000s with 40 correct decimal places and a canonical compliance.

```sh
# Gives permission to execute the file.
chmod 700 ./ciede2000.sh;

# We provide a CSV file where each line contains either:
# - 6 columns:  L1,a1,b1,L2,a2,b2
# - 9 columns:  L1,a1,b1,L2,a2,b2,kL,kC,kH

# Displays the CSV file, with a new column containing the corresponding CIEDE2000 values.
./ciede2000.sh --quiet --canonical --precision 40 < demo.csv;
```

### Test Results

LEONARD’s tests are based on well-chosen L\*a\*b\* colors, with various parametric factors `kL`, `kC` and `kH`.

<details>
<summary>Display test results for 10 correct decimal places</summary>

```
CIEDE2000 Verification Summary :
          Compliance : [ ] CANONICAL [X] SIMPLIFIED
  First Checked Line : 40.0,0.5,-128.0,49.91,0.0,24.0,1.0,1.0,1.0,51.01866090771
           Precision : 10 decimal digits
           Successes : 10000000
               Error : 0
            Duration : 1633.52 seconds
     Average Delta E : 67.12
   Average Deviation : 2.5e-12
   Maximum Deviation : 5.3e-12
```

```
CIEDE2000 Verification Summary :
          Compliance : [X] CANONICAL [ ] SIMPLIFIED
  First Checked Line : 40.0,0.5,-128.0,49.91,0.0,24.0,1.0,1.0,1.0,51.01846301970
           Precision : 10 decimal digits
           Successes : 10000000
               Error : 0
            Duration : 1703.49 seconds
     Average Delta E : 67.12
   Average Deviation : 2.5e-12
   Maximum Deviation : 5.3e-12
```
</details>

<details>
<summary>Display test results for 40 correct decimal places</summary>

```
CIEDE2000 Verification Summary :
          Compliance : [ ] CANONICAL [X] SIMPLIFIED
  First Checked Line : 20.0,0.05,-30.0,30.0,0.0,128.0,1.0,1.0,1.0,53.41746217641312453653848817...
           Precision : 40 decimal digits
           Successes : 10000000
               Error : 0
            Duration : 6525.13 seconds
     Average Delta E : 67.14
   Average Deviation : 2.5e-42
   Maximum Deviation : 5e-42
```

```
CIEDE2000 Verification Summary :
          Compliance : [X] CANONICAL [ ] SIMPLIFIED
  First Checked Line : 20.0,0.05,-30.0,30.0,0.0,128.0,1.0,1.0,1.0,53.41765416511742222830573092...
           Precision : 40 decimal digits
           Successes : 10000000
               Error : 0
            Duration : 6469.87 seconds
     Average Delta E : 67.14
   Average Deviation : 2.5e-42
   Maximum Deviation : 5e-42
```
</details>

<details>
<summary>Display test results for 150 correct decimal places</summary>

```
CIEDE2000 Verification Summary :
          Compliance : [ ] CANONICAL [X] SIMPLIFIED
  First Checked Line : 60.0,-0.0,32.0,68.0,0.00008,-127.9995,1.0,1.0,1.0,54.1596074560009369878...
           Precision : 150 decimal digits
           Successes : 10000000
               Error : 0
            Duration : 41322.64 seconds
     Average Delta E : 67.12
   Average Deviation : 2.5e-152
   Maximum Deviation : 5e-152
```

```
CIEDE2000 Verification Summary :
          Compliance : [X] CANONICAL [ ] SIMPLIFIED
  First Checked Line : 60.0,-0.0,32.0,68.0,0.00008,-127.9995,1.0,1.0,1.0,54.1594168095316725038...
           Precision : 150 decimal digits
           Successes : 10000000
               Error : 0
            Duration : 41932.08 seconds
     Average Delta E : 67.12
   Average Deviation : 2.5e-152
   Maximum Deviation : 5e-152
```
</details>

## Public Domain Licence

You are free to use these files, even for commercial purposes.
