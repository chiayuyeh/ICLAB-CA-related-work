#include <iostream>
#include <cuda.h>
#include <cuda_runtime.h>
#include <math.h>
#include "parameters.h"
#include <stdio.h>
using namespace std;



__global__ void sobelCUDA1(int* image, int* result){
	
	
	int totalThreads = blockDim.x * gridDim.x;
	int totalPixels = SIZE * SIZE;
	int stripe = totalPixels/totalThreads;
	
	int head = (blockIdx.x * blockDim.x + threadIdx.x) * stripe;
	int limit = head + stripe;


	int sobelX[3][3] = {
		{-1, 0, 1},
		{-2, 0, 2},
		{-1, 0, 1}
	};

	int sobelY[3][3] = {
		{1, 2, 1},
		{0, 0, 0},
		{-1, -2, -1}
	};
	
	int gx = 0;
	int gy = 0;
	
	for(int i =head;i<limit;i++){
		int row = i / SIZE;
		int col = i % SIZE;
		for(int m=0;m<3;m++){
			for(int n=0;n<3;n++){
				int r = row + m;
				int c = col + n;
				int pixel = image[(r)*(SIZE+2)+(c)];
				gx += pixel * sobelX[m][n];
				gy += pixel * sobelY[m][n];
			}
		}
		int mag = sqrtf((float)(gx * gx + gy * gy));
		if(mag >128)mag = 255;
		if(mag <128)mag = 0;
		result[row*SIZE + col]=mag;
	
	
	
}
}
float GPU_kernel_1(int* image, int* result_sobel){
	
	int* d_img;
	int* d_result;

	cudaEvent_t start, stop;
	
	cudaEventCreate(&start);
	cudaEventCreate(&stop);
	
	cudaMalloc((void**)&d_img, sizeof(int) * (SIZE+2) * (SIZE+2));
	cudaMalloc((void**)&d_result, sizeof(int) * (SIZE) * (SIZE));
	cudaEventRecord(start,0);
	
	//int totalThreads = SIZE *SIZE;
	//int blocksize = 64;


	//int numblocks = (totalThreads + blocksize - 1)/blocksize;
	//sobelCUDA1<<<numblocks, blocksize>>>(d_img, d_result);
	
	//cudaMemcpy(result_CV, d_result, sizeof(int) * SIZE *SIZE, cudaMemcpyDeviceToHost);
	//cudaMemset(d_result, 0, sizeof(int)*SIZE*SIZE);





	//cudaEventRecord(start,0);
	dim3 dimGrid(4);
	dim3 dimBlock(4);
	
	sobelCUDA1<<<dimGrid, dimBlock>>>(d_img, d_result);
	

	
	cudaEventRecord(stop, 0);
	cudaEventSynchronize(stop);
	
	cudaMemcpy(result_sobel, d_result, sizeof(int) * SIZE *SIZE, cudaMemcpyDeviceToHost);

	cudaFree(d_img);
	cudaFree(d_result);

	float elapsedTime;
	cudaEventElapsedTime(&elapsedTime, start, stop);
	return elapsedTime;





}































