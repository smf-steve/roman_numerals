# roman_numerals
A bash implementation of the EXCEL "roman" function

# Number Construction

# Subtractive Forms


# Styles:
 1. MODERN: 
    - range of values: 1..3999 (MMMCMXCIX)
    - full units: I X C M
    - half units: - V L D
    - max: MMMCMXCIX
 1. VINCULUM:
    - range of values: 1..999,999,999
    - groups of 999
    - full units: I X L M
    - half units: - V L D
    - max: |- CMXCIX -|  |CMXCIX| CMXCIX
 1. EARLY:
    - range of 1..899
    - full units: I X C
    - half units: - V L D
 1. APOSTROPHUS
    - range of 399999:
    - full units: I X C (I) ((I)) (((I)))
    - half units: - V L I) I)) I)))



# FORMS:
  1. STANDARD:

  1. ADDITIVE_ONLY:
     - all subtractive forms are NOT used
     - subtractive forms: IV, IX, XL, XC, CD, CM

  1. SIMPLIFED=
     - 0: Max denominator is 1/10
     - 1: Max denominator is 1/20
     - 2: Max denominator is 1/100
     - 3: Max denominator is 1/200
     - 4: Max denominator is 1/1000



# Excel
# Variants
  - Use of Half Form, i.e., V L D
  - Use of Subtractive Form: 
    * 1/10 of a unit is valid
    * 9 to include: IX (9), XC (90), and CM(900)
    * 4 to include: IV (4), XL (40), and CD (400)
  - Use of Extended Subtractive Form:
    * 8 to include: IIX (8), XXC (80), and CCM (800)
  - 


# Zero:
  * Nila

# Fractions
  * Not supported at this time
  * Unit: S (6/12)
  * Value: 
    - .
    - ..
    - ... (3/12 == 1/4)
    - .... (4/12 == 1/3)
    - ..... (5/12)
    - S .
    - S ..
    - S ...
    - S .... (9/12 == 3/4)
    - S .....



# References
- https://en.wikipedia.org/wiki/Roman_numerals#Apostrophus
- https://www.rapidtables.com/math/symbols/roman_numerals.html

- https://www.fileformat.info/info/unicode/block/number_forms/images.htm

- https://support.microsoft.com/en-us/office/roman-function-d6b0b99e-de46-4704-a518-b45a0f8b56f5

