#include <iostream>
#include <stdio.h>
#include <time.h>
#include <stdlib.h>
#include <unistd.h>
#include <parameters.h>

extern float GPU_kernel_1(int* image, int* result_sobel);
extern float GPU_kernel_2(int* image, int* result_sobel);

float sobelX[9] = {
	-1, 0, 1,
	-2, 0, 2,
	-1, 0, 1
};

float sobelY[9] = {
	1, 2, 1,
	0,  0,  0,
	-1, -2, -1
};

void EdgeDetect(int* image, int* result){
	for(int i=0; i<SIZE; i++){
		for(int j=0; j<SIZE; j++){
			int gx = 0;
			int gy = 0;
			for(int m=0;m<3;m++){
				for(int n=0;n<3;n++){
					int px = image[(i + m)*(SIZE+2)+(j+n)];
					gx += px * sobelX[m*3 + n];
					gy += px * sobelY[m*3 + n];
				}
			}
			int mag = sqrt(gx*gx + gy*gy);
			if(mag > 128)mag=255;
			if(mag < 128)mag = 0;
			result[i*SIZE +j]=mag;
		}
	}
}

int main()
{
	srand(0);
	FILE *ori_image = fopen("image.txt", "w");
	int* image = new int[(SIZE + 2)*(SIZE + 2)];
	printf("\n============image==============\n");
	for(int i=0;i<SIZE+2;i++){
		for(int j=0;j<SIZE+2;j++){
			if(i==0 || i == SIZE+1 || j == SIZE+1 || j==0){
				image[i
*(SIZE + 2) + j] = 0;
			}else{
				image[i*(SIZE + 2) + j] = rand()%256;
			}
			fprintf(ori_image, "%+d\t", image[i*(SIZE + 2) + j]);
			printf("%+d\t", image[i*(SIZE + 2) + j]);
		}
		fprintf(ori_image, "\n");
		printf("\n");
	}
	printf("\n=========CPU=========\n");
	FILE *fp_CPU = fopen("CPU.txt", "w");
	int* image_sobel = new int[SIZE*SIZE];
	
	struct timespec tbegin, tend;
	clock_gettime(CLOCK_MONOTONIC_RAW, &tbegin);
	EdgeDetect(image, image_sobel);
	clock_gettime(CLOCK_MONOTONIC_RAW, &tend);

	printf("\n========after sobel=======\n");
	for(int i=0; i<SIZE; i++){
		for(int j=0; j<SIZE; j++){
			int value = image_sobel[i*SIZE + j];
			printf("%+d\t",value);
			fprintf(fp_CPU, "%+d\t",value);
		}
		printf("\n");
		fprintf(fp_CPU, "\n");
	}

	printf("\n========GPU=======\n");
	int* result_sobel1 = new int[SIZE*SIZE];
	int* result_sobel2 = new int[SIZE*SIZE];
	float time1 = GPU_kernel_1(image, result_sobel1);
	float time2 = GPU_kernel_2(image, result_sobel2);

	FILE *fp_sobel1,  *fp_sobel2;
	fp_sobel1 = fopen("GPU_sobel1.txt","w");
	fp_sobel2 = fopen("GPU_sobel2.txt","w");





	printf("\n========GPU1=======\n");
	for(int i=0; i<SIZE; i++){
		for(int j=0; j<SIZE; j++){
			int value = image_sobel[i*SIZE + j];
			printf("%+d\t",value);
			fprintf(fp_sobel1, "%+d\t",value);
		}
		printf("\n");
		fprintf(fp_sobel1, "\n");
	}

	printf("\n========GPU2=======\n");
	for(int i=0; i<SIZE; i++){
		for(int j=0; j<SIZE; j++){
			int value = image_sobel[i*SIZE + j];
			printf("%+d\t",value);
			fprintf(fp_sobel2, "%+d\t",value);
		}
		printf("\n");
		fprintf(fp_sobel2, "\n");
	}

	printf("\n==================================\n");
	printf("GPU1 = %5.2f ms\n", time1);
	printf("GPU2 = %5.2f ms\n", time2);
	printf("CPU = %f ms\n", ((tend.tv_nsec - tbegin.tv_nsec)/100000.0 + (tend.tv_sec - tbegin.tv_sec)*1000));

	getchar();

















































}



















