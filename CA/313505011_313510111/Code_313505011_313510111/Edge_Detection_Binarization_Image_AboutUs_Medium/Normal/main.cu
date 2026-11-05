#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"

#include <iostream>
#include <fstream>
#include <vector>
#include <cmath>
#include <string>
#include <sstream>
#include <time.h>
#include <iostream>
#include <stdio.h>
#include <time.h>
#include <stdlib.h>
#include <unistd.h>
using namespace std;

//extern "C" void sobel_gpu1(unsigned char* input, unsigned char* output, const int* kernelX_host, const int* kernelY_host, int width, int height, int size);
extern "C" void sobel_gpu1(unsigned char* input, unsigned char* output, const int* kernelX_host, const int* kernelY_host, int width, int height, int size);
extern "C" void sobel_gpu2(unsigned char* input, unsigned char* output, const int* kernelX_host, const int* kernelY_host, int width, int height, int size);

bool writePGM(const string& filename, const vector<vector<unsigned char> >& image, int width, int height) {
    ofstream file(filename.c_str(), ios::binary);
    if (!file) return false;

    file << "P5\n" << width << " " << height << "\n255\n";
    for (int i = 0; i < height; ++i) {
        file.write(reinterpret_cast<const char*>(image[i].data()), width);
    }
    return true;
}

vector<vector<int> > generateSobelX(int size) {
    if (size == 3) {
        vector<vector<int> > kernel(3, vector<int>(3));
        kernel[0][0] = -1; kernel[0][1] = 0; kernel[0][2] = 1;
        kernel[1][0] = -2; kernel[1][1] = 0; kernel[1][2] = 2;
        kernel[2][0] = -1; kernel[2][1] = 0; kernel[2][2] = 1;
        return kernel;
    } else if (size == 5) {
        int values[5][5] = {
            {-2, -1, 0, 1, 2},
            {-3, -2, 0, 2, 3},
            {-4, -3, 0, 3, 4},
            {-3, -2, 0, 2, 3},
            {-2, -1, 0, 1, 2}
        };
        vector<vector<int> > kernel(5, vector<int>(5));
        for (int i = 0; i < 5; ++i)
            for (int j = 0; j < 5; ++j)
                kernel[i][j] = values[i][j];
        return kernel;
    } else if (size == 7) {
        int values[7][7] = {
            {-3, -2, -1, 0, 1, 2, 3},
            {-4, -3, -2, 0, 2, 3, 4},
            {-5, -4, -3, 0, 3, 4, 5},
            {-6, -5, -4, 0, 4, 5, 6},
            {-5, -4, -3, 0, 3, 4, 5},
            {-4, -3, -2, 0, 2, 3, 4},
            {-3, -2, -1, 0, 1, 2, 3}
        };
        vector<vector<int> > kernel(7, vector<int>(7));
        for (int i = 0; i < 7; ++i)
            for (int j = 0; j < 7; ++j)
                kernel[i][j] = values[i][j];
        return kernel;
    }
    return vector<vector<int> >();
}

vector<vector<int> > generateSobelY(const vector<vector<int> >& kernelX) {
    int size = kernelX.size();
    vector<vector<int> > kernelY(size, vector<int>(size));
    for (int i = 0; i < size; ++i)
        for (int j = 0; j < size; ++j)
            kernelY[i][j] = kernelX[j][i];
    return kernelY;
}

void applySobel(
    const vector<vector<unsigned char> >& src,
    vector<vector<unsigned char> >& dst,
    const vector<vector<int> >& kernelX,
    const vector<vector<int> >& kernelY,
    int width, int height, int size)
{
    int offset = size / 2;
    dst.assign(height, vector<unsigned char>(width, 0));

    for (int y = offset; y < height - offset; ++y) {
        for (int x = offset; x < width - offset; ++x) {
            int sumX = 0, sumY = 0;
            for (int i = 0; i < size; ++i) {
                for (int j = 0; j < size; ++j) {
                    int px = src[y - offset + i][x - offset + j];
                    sumX += kernelX[i][j] * px;
                    sumY += kernelY[i][j] * px;
                }
            }
            int mag = static_cast<int>(sqrt(sumX * sumX + sumY * sumY));
            dst[y][x] = static_cast<unsigned char>(min(255, mag));
        }
    }
}







int main() {
	cudaEvent_t start1, start2, stop1, stop2;
	cudaEventCreate(&start1);
	cudaEventCreate(&start2);
	cudaEventCreate(&stop1);
	cudaEventCreate(&stop2);
	float time1 = 0.0f, time2 = 0.0f;

    int width, height, channels;
    unsigned char* data = stbi_load("test.jpg", &width, &height, &channels, 1);
    if (!data) {
        cerr << "no test.jpg" << endl;
        return 1;
    }

    vector<vector<unsigned char> > image(height, vector<unsigned char>(width));
    for (int y = 0; y < height; ++y)
        for (int x = 0; x < width; ++x)
            image[y][x] = data[y * width + x];

    stbi_image_free(data);

    for (int n = 1; n <= 3; ++n) {
        int size = 1 + 2 * n;
        vector<vector<int> > kernelX = generateSobelX(size);
        vector<vector<int> > kernelY = generateSobelY(kernelX);

        vector<vector<unsigned char> > sobel_result;
        applySobel(image, sobel_result, kernelX, kernelY, width, height, size);
	printf("\n=========CPU=========\n");

	struct timespec tbegin, tend;
	clock_gettime(CLOCK_MONOTONIC_RAW, &tbegin);


        stringstream ss;
        ss << "CPU_" << size << "x" << size << ".pgm";
        writePGM(ss.str(), sobel_result, width, height);
        cout << "out: " << ss.str() << endl;


	clock_gettime(CLOCK_MONOTONIC_RAW, &tend);
        
	printf("\n========GPU=======\n");
    vector<unsigned char> flat_image(width * height);
    for (int y = 0; y < height; ++y)
        for (int x = 0; x < width; ++x)
            flat_image[y * width + x] = image[y][x];



    vector<unsigned char> gpu_out1(width * height, 0);
	
    vector<unsigned char> gpu_out2(width * height, 0);


	vector<int>kernelX_1d(size*size);
	vector<int>kernelY_1d(size*size);
	for(int i=0;i<size;++i)
		for(int j=0;j<size;++j){
			kernelX_1d[i*size+j]=kernelX[i][j];
			kernelY_1d[i*size+j]=kernelY[i][j];
		}


	
	//printf("\n========GPU1=======\n");
	cudaEventRecord(start1, 0);
    sobel_gpu1(flat_image.data(), gpu_out1.data(), kernelX_1d.data(), kernelY_1d.data(), width, height, size);
	cudaEventRecord(stop1, 0);
	cudaEventSynchronize(stop1);
	cudaEventElapsedTime(&time1, start1, stop1);


	//printf("\n========GPU2=======\n");
	cudaEventRecord(start2, 0);
    sobel_gpu2(flat_image.data(), gpu_out2.data(), kernelX_1d.data(), kernelY_1d.data(), width, height, size);
	cudaEventRecord(stop2, 0);
	cudaEventSynchronize(stop2);
	cudaEventElapsedTime(&time2, start2, stop2);


    vector<vector<unsigned char> > gpu_img1(height, vector<unsigned char>(width));
    vector<vector<unsigned char> > gpu_img2(height, vector<unsigned char>(width));
    for (int y = 0; y < height; ++y) {
        for (int x = 0; x < width; ++x) {
            gpu_img1[y][x] = gpu_out1[y * width + x];
            gpu_img2[y][x] = gpu_out2[y * width + x];
        }
    }

    stringstream g1, g2;
    g1 << "GPU1_" << size << "x" << size << "_.pgm";
    g2 << "GPU2_" << size << "x" << size << "_.pgm";

    writePGM(g1.str(), gpu_img1, width, height);
    writePGM(g2.str(), gpu_img2, width, height);
    cout << "out: " << g1.str() << " and " << g2.str() << endl;
	printf("\n=============time=================\n");
	printf("GPU1 = %.3f ms\n", time1);
	printf("GPU2 = %.3f ms\n", time2);
	printf("CPU = %f ms\n", ((tend.tv_nsec - tbegin.tv_nsec)/100000.0 + (tend.tv_sec - tbegin.tv_sec)*1000));

    }

    return 0;
}


