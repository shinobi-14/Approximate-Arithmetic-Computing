---
dg-publish: true
---


## Power - Efficient Hardware Implementation of L-Mul

>[!attention]
This paper thus presents a power-efficient FPGA-based hardware implementation (approximate FP8 multiplier) for L-Mul
 [Paper](https://arxiv.org/pdf/2412.18948v1)

 >[!Point]-  **Acronyms**
 >1. FP8 --> 8-bit floating point
 >2. INT8 --> 8-bit integer
 >3. L-Mul --> Linear-Complexity Multiplication
 >4. FP --> Fixed Point

### **Main contribution**
---
1. We implement L-Mul, an approximate multiplication method for FP8 computations, on FPGA. Using LUT and carry-chain primitives, we achieve fine-grained optimization to minimize resource usage and power consumption. To the best of our knowledge, this is the first FPGA-based FP8 approximate multiplier design.
2. We validate our design on AMD UltraScale/UltraScale+ devices. Compared to previous FPGA-based 8-bit approximate multiplier designs, our approach reduces resource consumption by an average of 10% while maintaining comparable performance. Additionally, we integrate our design into a CNN accelerator, and experiments demonstrate that, among 8-bit designs, ours achieves the highest accuracy, energy efficiency, and the lowest latency.


>[!Note] Note
- Linear-complexity multiplication, has been deployed on GPUs for large language models, providing initial validation of its effectiveness.
- FP8, compared to INT8, offer better dynamic range and computational precision, suitable for  adoption in NN computations.
	& to enhance the computational efficiency of FP8, specialized hardware modules for FP8 acceleration have become a new trend.

|
######  **FPGA based Approximate Multiplier Design**
---
 Points to keep in mind -->
	1. FPGA reconfigurable logic is typically based on fixed-size lookup tables (LUTs)
	2. FPGAs also integrate DSP hardware multiplier units, these units are physically fixed and limited in quantity.
	3. Therefore, improving the efficiency of LUT-based multiplication in terms of speed, power consumption, and resource utilization becomes particularly critical.
```
Designs -->
1. approximate multipliers covering data bit-widths from 4-bit to 32-bit.
2. dynamically reconfigurable INT8 approximate multiplier design, which includes a floating-point conversion unit.
3.  DSP-based approximate multiplier design for floating-point computations, integrated into a CNN accelerator.
```
 
### **Questions?**
1. What is L-Mul?
	Linear-Complexity Multiplication an algorithm to improve energy efficiency in AI models by approximating floating point multiplication with simple integer addition which has a way better efficient computational complexity compared to traditional floating-point multiplication.

2. What is a 8-bit floating point (FP8)? 
	A numerical format used to represent a wide range of values, including very large and very small numbers, in a small memory footprint

---


## Learned Approximate Computing: Algorithm Hardware Co-optimization

> [!attention]
> Application and hardware can be **co-optimized via approximate computing** to balance quality and performance by **simultaneously optimizing algorithms and hardware**. This enables **automatic selection of approximate hardware configurations** that achieve **similar accuracy to fixed, dedicated designs**, maximizing quality while improving **efficiency, adaptability, and scalability**.


 >[!Point]- **Acronyms**
 >1. LAC --> Learned Approximate Computing
 >2. ACH --> Approximate Computing Hardware
 
### Main Contribution
---
1. Instead of optimizing the approximate computing hardware for a fixed application we optimize the application kernel for both a fixed and trained hardware configuration.
2. During this process, we also search for approximate hardware config that is most suitable for the application as the coefficients of the kernel are automatically adjusted to the error properties of the ACH.
   
> [!NOTE] Contributions
> 1. Develop the LAC methodology to train almost arbitrary parameterizable application kernels.
> 2. When hardware changes, LAC searches for the optimal hardware while tuning the algorithm.

###### FIXED HARDWARE LAC
![[FIXED Hardware LAC.png]]

---


## Fast and Low-Cost Approximate Multiplier for FPGAs using Dynamic Reconﬁguration

>[!attention]
>This paper thus introduces an original FPGA-based approximate multiiplier speciﬁcally optimized for machine learning computations. It utilizes dynamically reconﬁgurable lookup table (LUT) primitives 
in AMD-Xilinx technology to realize the core part of the computations. 


> [!NOTE]- Acroynyms
>    1. LUT --> Lookup Table
>    2. DyRecMul --> Dynamically Reconfigurable Approximate Multiplier
>    3. ML --> Machine Learning
>    4. INT8 --> 8-bit Fixed point arithmetic
>    5. FP8 --> 8-bit Floating point aritmetic

### Main Contribution 
---
1. This paper uses DyRecMul for FPGAs and has following advantages -->
    - optimized for ML computation
    - shorter critical paths 
    - small number of LUTs
2. It utilizes AMD-Xilinx technology's reconfig LUT primitives to approximate multiplication without significant accuracy degradation.
3. It transform fixed point operand to FP8 format using cost-effective encoder and a decoder to revert back.
4.  This paper present the design details and evaluation result of an INT8 version of DyRecMul as INT8 is a popular datatype in cost-effective machine learning computing
5. 5. The multiplier used has negligible accuracy loss and use less numbers of LUTs 
   
> [!NOTE] Contributions
> 1. Utilization of dynamically reconﬁgurable LUTs (CFG-LUTs) in AMD-Xilinx FPGAs to make a low-cost and fast short-bitwidth multiplier.
> 2. Internal conversion of ﬁxed-point to a ﬂoating-point format to preserve dynamic range that is beneﬁcial for machine learning and deep learning applications.
> 3. For an INT8 case study, illustration of the design detail of a highly optimized encoder circuit to convert INT8 to 8- bit ﬂoating point format and a low-cost decoder to convert 8-bit ﬂoating point format to INT8

###### Architecture of DyRecMul
![[LUT Mapping.png]]

###### INT8 to float (1, 2, 5) encoder, LUT mapping and corresponding truth tables
![[Architecture of DyRecMul.png]]


---
