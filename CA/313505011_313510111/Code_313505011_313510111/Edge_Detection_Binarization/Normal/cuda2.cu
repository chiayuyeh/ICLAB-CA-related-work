#include <iostream>
#include <cuda.h>
#include <cuda_runtime.h>
#include <math.h>
#include "parameters.h"
using namespace std;



__global__ void sobelCUDA2(int* image, int* image_sobel){
	

	int totalThreads = blockDim.x * gridDim.x;
	int totalPixels = SIZE * SIZE;
	int stripe = totalPixels/totalThreads;
	int head = (blockIdx.x * blockDim.x + threadIdx.x) * stripe;
	int limit = head + stripe;

	

	int sobelX[9] = {
		-1, 0, 1,
		-2, 0, 2,
		-1, 0, 1
	};

	int sobelY[9] = {
		 1,  2, 1,
		 0,  0,  0,
		-1, -2, -1
	};
	int gx = 0;
	int gy = 0;

	for(int i=head;i<SIZE*SIZE;i+=stripe){
		//if(i >= SIZE*SIZE)break;
		int row = i / SIZE;
		int col = i % SIZE;
		
		for(int m=0;m<3;m++){
			for(int n=0;n<3;n++){
				int pixel = image[(row + m)*(SIZE+2)+(col+n)];
				gx += pixel * sobelX[m*3 + n];
				gy += pixel * sobelY[m*3 + n];
			}
		}
		int mag = sqrtf((float)(gx*gx + gy*gy));
		if(mag >255)mag = 255;
		if(mag<0)mag = 0;
		image_sobel[i]=mag;
	}
}

float GPU_kernel_2(int* image, int* result_sobel){
	int* d_img;
	int* d_result;

	cudaEvent_t start, stop;
	cudaEventCreate(&start);
	cudaEventCreate(&stop);

	cudaMalloc((void**)&d_img, sizeof(int) * (SIZE+2) * (SIZE+2));
	cudaMalloc((void**)&d_result, sizeof(int) * (SIZE) * (SIZE));

	cudaMemcpy(result_sobel, d_result, sizeof(int) * SIZE *SIZE, cudaMemcpyDeviceToHost);
	cudaMemset(d_result, 0, sizeof(int)*SIZE*SIZE);





	cudaEventRecord(start,0);
	dim3 dimGrid(4);
	dim3 dimBlock(8);
	
	sobelCUDA2<<<dimGrid, dimBlock>>>(d_img, d_result);
	cudaEventRecord(stop, 0);
	cudaEventSynchronize(stop);

	cudaMemcpy(result_sobel, d_result, sizeof(int) * SIZE *SIZE, cudaMemcpyDeviceToHost);
	cudaFree(d_img);
	cudaFree(d_result);

	float elapsedTime;
	cudaEventElapsedTime(&elapsedTime, start, stop);
	return elapsedTime;





}































