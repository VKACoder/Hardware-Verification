OUTPUT obtained:

<img width="921" height="1139" alt="Screenshot (18)" src="https://github.com/user-attachments/assets/54107684-380d-405f-8d85-498a0c3864f4" />

Image 1

<img width="921" height="1139" alt="Screenshot (19)" src="https://github.com/user-attachments/assets/03373a3c-7ca6-421e-8deb-6fe2e2b657c7" />

Image 2

From the above images, it can inferred that the verification is successful if Cin = 0, i.e., during addition. However when Cin = 1, all the testcases are unsuccessful, even though the obtained output from DUT is correct (Image 1, 4th testcase). To find cause of testcase failure, I added display statment to print the golden data and actual data received from DUT. Found that golden_cout is the inverted version of actual cout (trans_mon.cout) with the difference (golden_sum and trans_mon.sum) being the same.

Cause:
The DUT failed in sign extension, i.e., when A = 1000, B = 1111 and Cin = 1 (Subtraction), the difference and cout must be 1001 and 1 (all in binary system). However, the DUT produced 1001 as difference and 0 as cout, causing the corresponding testcase to fail.

Fix:
Invert cout when Cin = 1.

FINAL OUTPUT OF TESTBENCH:

<img width="921" height="1139" alt="Screenshot (20)" src="https://github.com/user-attachments/assets/4f4770cf-d535-494f-a699-1f804b41fc50" />

Image 3

<img width="921" height="1139" alt="Screenshot (21)" src="https://github.com/user-attachments/assets/f62db05e-44c4-4c75-aa33-0704ea0214fe" />

Image 4
