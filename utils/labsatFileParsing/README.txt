These utility functions can be used to parse Labsat 3 Wideband (ls3w) IQ files into 8 + 8-bit IQ format

Functions:
ls3wToIQ:
    Main function to call. The function parses a single IQ-file for every channel in the ls3w input
    
ls3wReadIni:
    A helper function to extract LabSat configuration parameters from .ini files

ls3wDecodeRegisters:
    A helper function that parses multiple ls3w registers into 8 + 8-bit IQ.
    Outputs two matrices, one for in-phase (I) and one for quadrature (Q) component.