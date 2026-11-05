#include <iostream>
#include <stdio.h>
#include <time.h>
#include <stdlib.h>
#include <unistd.h>
#include <parameters.h>

extern float GPU_kernel_1(int* image, int* result_CV);
extern float GPU_kernel_2(int* image, int* result_CV);

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
			if(mag > 255)mag=255;
			if(mag < 0)mag = 0;
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
	int* image_CV = new int[SIZE*SIZE];
	
	struct timespec tbegin, tend;
	clock_gettime(CLOCK_MONOTONIC_RAW, &tbegin);
	EdgeDetect(image, image_CV);
	clock_gettime(CLOCK_MONOTONIC_RAW, &tend);

	printf("\n========after sobel=======\n");
	for(int i=0; i<SIZE; i++){
		for(int j=0; j<SIZE; j++){
			int value = image_CV[i*SIZE + j];
			printf("%+d\t",value);
			fprintf(fp_CPU, "%+d\t",value);
		}
		printf("\n");
		fprintf(fp_CPU, "\n");
	}

	printf("\n========GPU=======\n");
	int* result_CV1 = new int[SIZE*SIZE];
	int* result_CV2 = new int[SIZE*SIZE];
	float time1 = GPU_kernel_1(image, result_CV1);
	float time2 = GPU_kernel_2(image, result_CV2);

	FILE *fp_CV1,  *fp_CV2;
	fp_CV1 = fopen("GPU_CV1.txt","w");
	fp_CV2 = fopen("GPU_CV2.txt","w");





	printf("\n========GPU1=======\n");
	for(int i=0; i<SIZE; i++){
		for(int j=0; j<SIZE; j++){
			int value = image_CV[i*SIZE + j];
			printf("%+d\t",value);
			fprintf(fp_CV1, "%+d\t",value);
		}
		printf("\n");
		fprintf(fp_CV1, "\n");
	}

	printf("\n========GPU2=======\n");
	for(int i=0; i<SIZE; i++){
		for(int j=0; j<SIZE; j++){
			int value = image_CV[i*SIZE + j];
			printf("%+d\t",value);
			fprintf(fp_CV2, "%+d\t",value);
		}
		printf("\n");
		fprintf(fp_CV2, "\n");
	}

	printf("\n==================================\n");
	printf("GPU1 = %5.2f ms\n", time1);
	printf("GPU2 = %5.2f ms\n", time2);
	printf("CPU = %f ms\n", ((tend.tv_nsec - tbegin.tv_nsec)/100000.0 + (tend.tv_sec - tbegin.tv_sec)*1000));

	getchar();

















































}



















