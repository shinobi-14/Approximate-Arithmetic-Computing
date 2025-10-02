I compared the Accurate 4-bit RCA with the Dynamic Configurable 4-bit RCA to study the trade-offs of using dynamic approximation. 

This sub-repository includes the reports, Verilog code, generated netlist, and simulation PDF for both designs (Accurate and Dynamic). 

For easy reference, the design comparison is given below. 

<br>

``` 
Area 
|
|_ Accurate RCA: Compact design with 4 cells, total area = 78.718 units (only four 1-bit full adders `ADDFXL`).
|
|_ Dynamic RCA: Larger design with 22 cells, total area = 118.076 units (includes adders, multiplexers `MXI2XL`
   and control gates needed to switch between operational modes.)

Power Consumption
|
|_ Accurate RCA: Total power consumption = 2.29435 µW.  
|_ Dynamic RCA: Total power consumption = 3.61904 µW.
```
<br>
 
The dynamic design introduces a ~50% area overhead. I attribute this directly to the extra hardware (multiplexers and control logic).

It has a  ~58% higher power consumption than the accurate design. I expected it, as a large number of cells in the dynamic design contribute to higher leakage and internal power.

The current design is a "vectorless" estimate. It only tells the cost of the hardware itself. I anticipate that the actual power consumption will be significantly lower when we operate the circuit in its power-saving approximate modes.<img width="1602" height="56" alt="image" src="https://github.com/user-attachments/assets/ea902358-66e3-4b44-b23c-1fe45468862f" />

