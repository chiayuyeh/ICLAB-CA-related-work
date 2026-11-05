#include <cuda_runtime.h>
#include <cmath>
#include <cstdio>

__global__ void sobel_kernel1(
    const unsigned char* input, unsigned char* output,
    const int* kernelX, const int* kernelY,
    int width, int height, int kernelSize, int offset
) {
    int totalThreads = gridDim.x * gridDim.y * blockDim.x * blockDim.y;
    int totalPixels = width * height;
    int stripe = (totalPixels + totalThreads - 1) / totalThreads;  // ceiling division

    // 將 2D block/thread ID 展平成 global linear thread ID
    int blockId = blockIdx.y * gridDim.x + blockIdx.x;
    int threadIdInBlock = threadIdx.y * blockDim.x + threadIdx.x;
    int globalThreadId = blockId * (blockDim.x * blockDim.y) + threadIdInBlock;


    int head = globalThreadId * stripe;
    int limit = min(head + stripe, totalPixels);

    for (int idx = head; idx < limit; ++idx) {
        int x = idx % width;
        int y = idx / width;

        if (x < offset || y < offset || x >= width - offset || y >= height - offset) continue;

        int sumX = 0, sumY = 0;
        for (int i = 0; i < kernelSize; ++i) {
            for (int j = 0; j < kernelSize; ++j) {
                int px = input[(y - offset + i) * width + (x - offset + j)];
                sumX += kernelX[i * kernelSize + j] * px;
                sumY += kernelY[i * kernelSize + j] * px;
            }
        }
        int magnitude = (int)sqrtf((float)(sumX * sumX + sumY * sumY));
        output[y * width + x] = magnitude > 255 ? 255 : magnitude;
    }
}
extern "C" void sobel_gpu1(
    const unsigned char* input_host,
    unsigned char* output_host,
    const int* kernelX_host,
    const int* kernelY_host,
    int width, int height, int kernelSize
) {
    int img_size = width * height;
    int kernel_len = kernelSize * kernelSize;
    int offset = kernelSize / 2;

    unsigned char *d_input, *d_output;
    int *d_kernelX, *d_kernelY;

    cudaMalloc(&d_input, img_size);
    cudaMalloc(&d_output, img_size);
    cudaMalloc(&d_kernelX, kernel_len * sizeof(int));
    cudaMalloc(&d_kernelY, kernel_len * sizeof(int));

    cudaMemcpy(d_input, input_host, img_size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_kernelX, kernelX_host, kernel_len * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_kernelY, kernelY_host, kernel_len * sizeof(int), cudaMemcpyHostToDevice);

    dim3 block(16, 16);
    dim3 grid((width + 15) / 16, (height + 15) / 16);
    sobel_kernel1<<<grid, block>>>(d_input, d_output, d_kernelX, d_kernelY, width, height, kernelSize, offset);

    cudaMemcpy(output_host, d_output, img_size, cudaMemcpyDeviceToHost);

    cudaFree(d_input);
    cudaFree(d_output);
    cudaFree(d_kernelX);
    cudaFree(d_kernelY);
}


