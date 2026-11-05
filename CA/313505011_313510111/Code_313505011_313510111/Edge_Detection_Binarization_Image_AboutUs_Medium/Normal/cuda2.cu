#include <cuda_runtime.h>
#include <device_launch_parameters.h>
#include <stdio.h>

#define TILE_WIDTH 16
#define MAX_KERNEL_SIZE 7
#define MAX_MASK_RADIUS (MAX_KERNEL_SIZE / 2)

__constant__ int SOBEL_X_7x7[MAX_KERNEL_SIZE * MAX_KERNEL_SIZE];
__constant__ int SOBEL_Y_7x7[MAX_KERNEL_SIZE * MAX_KERNEL_SIZE];

// --- Fast 3x3 Global Memory Version ---
__global__ void sobel_gpu_3x3_fast(unsigned char* input, unsigned char* output, int width, int height) {
    int x = blockIdx.x * blockDim.x + threadIdx.x;
    int y = blockIdx.y * blockDim.y + threadIdx.y;

    if (x >= 1 && x < width - 1 && y >= 1 && y < height - 1) {
        int Gx = 0;
        int Gy = 0;

        #pragma unroll
        for (int i = -1; i <= 1; ++i) {
            #pragma unroll
            for (int j = -1; j <= 1; ++j) {
                int pixel = input[(y + i) * width + (x + j)];
                int kx = SOBEL_X_7x7[(i + 1) * 3 + (j + 1)];
                int ky = SOBEL_Y_7x7[(i + 1) * 3 + (j + 1)];
                Gx += kx * pixel;
                Gy += ky * pixel;
            }
        }

        //int mag = abs(Gx) + abs(Gy);
        int mag = (int)sqrtf((float)(Gx * Gx + Gy * Gy));

	output[y * width + x] = mag > 255 ? 255 : mag;
	//if (mag > 255) mag = 255;
        //output[y * width + x] = (unsigned char)mag;
    }
}

// --- Shared Memory General Version ---
__global__ void sobel_gpu_general(unsigned char* input, unsigned char* output, int width, int height, int kernelSize) {
    int offset = kernelSize / 2;
    __shared__ unsigned char smem[TILE_WIDTH + MAX_KERNEL_SIZE - 1][TILE_WIDTH + MAX_KERNEL_SIZE - 1];

    int tx = threadIdx.x;
    int ty = threadIdx.y;
    int row_o = blockIdx.y * TILE_WIDTH + ty;
    int col_o = blockIdx.x * TILE_WIDTH + tx;
    int row_i = row_o - offset;
    int col_i = col_o - offset;

    if (row_i >= 0 && row_i < height && col_i >= 0 && col_i < width) {
        smem[ty][tx] = input[row_i * width + col_i];
    } else {
        smem[ty][tx] = 0;
    }

    __syncthreads();

    if (ty >= offset && ty < TILE_WIDTH + offset &&
        tx >= offset && tx < TILE_WIDTH + offset &&
        row_o < height && col_o < width) {

        int Gx = 0;
        int Gy = 0;

        #pragma unroll
        for (int i = 0; i < MAX_KERNEL_SIZE; ++i) {
            #pragma unroll
            for (int j = 0; j < MAX_KERNEL_SIZE; ++j) {
                int ky = i - offset;
                int kx = j - offset;

                if (i < kernelSize && j < kernelSize) {
                    int pixel = smem[ty + ky][tx + kx];
                    Gx += SOBEL_X_7x7[i * kernelSize + j] * pixel;
                    Gy += SOBEL_Y_7x7[i * kernelSize + j] * pixel;
                }
            }
        }

	int mag = (int)sqrtf((float)(Gx * Gx + Gy * Gy));
        //int mag = abs(Gx) + abs(Gy);
        if (mag > 255) mag = 255;
        output[row_o * width + col_o] = (unsigned char)mag;
    }
}

extern "C" void sobel_gpu2(
    const unsigned char* input_host,
    unsigned char* output_host,
    const int* kernelX_host,
    const int* kernelY_host,
    int width, int height, int kernelSize
) {
    int size = width * height;
    int kernel_len = kernelSize * kernelSize;

    unsigned char *d_input, *d_output;
    cudaMalloc((void**)&d_input, size);
    cudaMalloc((void**)&d_output, size);
    cudaMemcpy(d_input, input_host, size, cudaMemcpyHostToDevice);

    cudaMemcpyToSymbol(SOBEL_X_7x7, kernelX_host, kernel_len * sizeof(int));
    cudaMemcpyToSymbol(SOBEL_Y_7x7, kernelY_host, kernel_len * sizeof(int));

    if (kernelSize == 3) {
        dim3 blockDim(16, 16);
        dim3 gridDim((width + 15) / 16, (height + 15) / 16);
        sobel_gpu_3x3_fast<<<gridDim, blockDim>>>(d_input, d_output, width, height);
    } else {
        dim3 blockDim(TILE_WIDTH + MAX_KERNEL_SIZE - 1, TILE_WIDTH + MAX_KERNEL_SIZE - 1);
        dim3 gridDim((width + TILE_WIDTH - 1) / TILE_WIDTH, (height + TILE_WIDTH - 1) / TILE_WIDTH);
        sobel_gpu_general<<<gridDim, blockDim>>>(d_input, d_output, width, height, kernelSize);
    }

    cudaMemcpy(output_host, d_output, size, cudaMemcpyDeviceToHost);

    cudaFree(d_input);
    cudaFree(d_output);
}
