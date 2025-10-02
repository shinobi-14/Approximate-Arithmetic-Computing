# Approximate Arithmetic Design using Dynamic and Runtime Techniques
Approximate computing is a way to save power and resources by allowing a trade-off in accuracy. Most existing designs use a fixed level of approximation, which makes them less flexible.

This project proposes **dynamic techniques** with a **runtime-configurable arithmetic unit** that can switch between exact and approximate modes depending on what the system needs or performance constraints. This makes the design more energy-efficient, faster, and still good enough in terms of output quality, which can be useful for many applications.


To demonstrate this, I have tried implementing the technique on a 4-bit Ripple Carry Adder (RCA) and a 16-bit RCA, with their simulation outputs/reports included in the repository.

This project is still under development, and I’m still trying to have better control over power, delay, and accuracy trade-offs 😅.

<br>

## Functional Block Diagram

```mermaid
flowchart TD
    Input["All Inputs necessary to <br/>drive the arithmetic circuit<br/>(A, B and Cin)"]
    
    RCA["Ripple Carry Adder<br/>━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━<br/>Mode 0: Exact RCA | Full FA Chain                                           <br/>Mode 1: Carry Cut | FA0 & FA1 -> exact | FA2 & FA3 -> XOR      <br/>Mode 2: Lower Part OR gate logic | FA1-FA3 -> exact                <br/>Mode 3: OR + Speculative Carry | FA0 -> OR | FA3 -> Prediction"]
    
    Output["Output Generated"]
    
    Error["Error Metrics<br/>━━━━━━━━━━━━━━━━━━<br/>error > threshold → accurate mode<br/>error < threshold → approximate mode"]
    
    FSM["FSM Controller<br/>━━━━━━━━━━━━━━━━━<br/>Generates mode signals<br/>Monitors error metrics<br/>Decides operation mode"]
    
    Input --> RCA
    FSM -->|mode bit 0| RCA
    FSM -->|mode bit 1| RCA
    RCA --> Output
    Output --> Error
    Error --> FSM
```

## Working
```
FSM Controller
|
|_ Inputs: user-defined mode, quality estimate/application requirements and runtime feedback from the error monitor.
|
|_ Output control signals: mode[1:0] (00 = Exact, 01 = Mode1, 10 = Mode2, 11 = Mode3), along with carry_cut_en, or_en, and spec_pred_en.


Control Signal Distribution
|
|_ These signals control multiplexers and enables inside the 4-bit and 16-bit RCA, allowing it to reconfigure dynamically without resynthesis.


Error Monitor
|
|_ Continuously compares Approx Sum vs Exact Sum.
|_ If error > threshold → FSM switches to a more accurate mode.
|_ If error < threshold → FSM allows more approximation for better speed/power.

```


## Operating Modes
<div align="center">

| **Mode 0 (Exact RCA)** | **Mode 1 (Low Approx – Carry Cut @ FA1→FA2)** | **Mode 2 (Medium Approx – Lower-Part OR in FA0)** | **Mode 3 (High Approx – OR + Speculative Carry Prediction)** |
|:-----------------------|:-----------------------------------------------|:---------------------------------------------------|:--------------------------------------------------------------|
| <ul style="margin:0; padding-left:20px;"><li>Standard ripple-carry through FA0→FA3.</li><br><li><strong>Control:</strong> carry_cut_en=0, or_en=0, spec_pred_en=0 (No error, baseline accuracy and delay)</li></ul> | <ul style="margin:0; padding-left:20px;"><li>Carry propagation is blocked after FA1.</li><li><strong>Implementation:</strong> Multiplexer at carry wire forces Cin to FA2=0 when carry_cut_en=1.</li><li><strong>Effect:</strong><ul style="margin:0; padding-left:20px;"><li>Faster (carry chain depth = 2 instead of 4).</li><li>Error arises if FA1 generates a carry that should influence FA2/FA3.</li></ul></li></ul> | <ul style="margin:0; padding-left:20px;"><li>FA0 is replaced by an OR gate (Sum0 = A0&#124;B0).</li><li>Cin to FA1 is forced = 0 when or_en=1.</li><li>FA1–FA3 operate exactly.</li><li><strong>Effect:</strong><ul style="margin:0; padding-left:20px;"><li>Error ≤ 1 LSB.</li><li>Very small impact on accuracy, significant power reduction.</li></ul></li></ul> | <ul style="margin:0; padding-left:20px;"><li>Combines Mode 2 (FA0 → OR gate) + Speculative predictor for FA3.</li><li><strong>Implementation:</strong> Predictor guesses Cin to FA3 from inputs (e.g., if A2 & B2=1 → Cin3=1).</li><li><strong>Effect:</strong><ul style="margin:0; padding-left:20px;"><li>Eliminates long carry dependency.</li><li>Large potential errors if prediction is wrong.</li><li>Best performance and power savings.</li></ul></li></ul> |

</div>

Author: Prithvi Raj Singh (shinobi-14)

