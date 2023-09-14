// please be noted that This programm will not work without nvidia cuda toolKit, or with google colab
// Rank algorithm but in parallel using cuda instructions
// the function is in the device (GPU), but the main is in the host (CPU) 
%%cu
#include <stdio.h>
#include <cuda.h>
#include <random>

__global__ void RankSortAlgorithm(int* in_arr, int* out_arr, int size){
    
  int idx = blockIdx.x * blockDim.x + threadIdx.x;
  int rank = 0;
  if (idx < size) { 
         
    // Count the rank of each index 
    for (int i = 0; i < size; i++) {
    
      if (in_arr[idx] > in_arr[i])
        
        rank++; 
      
        if(in_arr[idx] == in_arr[i] && i < idx)  
          
          rank++;
    }
    
    // copy the results to the output array 
    out_arr[rank] = in_arr[idx]; 
  } 
} 

int main()
{
  int *arr, *sorted_arr;       // initate host copies of arrays
  int *d_arr , *d_sorted_arr; // initate device copies of arrays
  int n = 20;                // predefined size of the array
  int size = sizeof(int) * n;

  // allocate memory in host
  arr = (int*) malloc(size);
  sorted_arr = (int*) malloc(size);
    
 
  printf("The original array : {");
 
  // Random variable assigned for the array  
  for (int i = 0; i < n; i++) {
    arr[i] = rand()%15; 
    printf(" %d ,", arr[i]);
  }
  printf("}\n");

  // allocate memory in device
  cudaMalloc((void**) &d_arr, size);
  cudaMalloc((void**) &d_sorted_arr, size);
 
  // copy to device
  cudaMemcpy(d_arr , arr , size , cudaMemcpyHostToDevice);
 
  // call the kernel
  RankSortAlgorithm <<< n , n >>> (d_arr , d_sorted_arr , n);

  // copy back to the host
  cudaMemcpy(sorted_arr , d_sorted_arr , size, cudaMemcpyDeviceToHost);


  printf("The sorted array : {");
  
  for ( int i = 0; i < n; i++) {
    printf(" %d ,",sorted_arr[i]);
  }
  printf("}");

  // free memory
  free(arr);
  free(sorted_arr);
  cudaFree(d_sorted_arr);
  cudaFree(d_arr);

return 0;
}