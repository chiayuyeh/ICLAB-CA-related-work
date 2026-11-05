執行步驟:

1.在Terminal直接執行make
  ->會產生執行檔

2.在Terminal執行./main
  ->test.jpg會執行Sobel3x3 5x5 7x7的矩陣，並產生3種不同結果。
  ->CPU : CPU_3x3, CPU_5x5, CPU_7x7, 
  ->CUDA1 : GPU1_3x3, GPU1_5x5, GPU1_7x7,
  ->CUDA2 : GPU2_3x3, GPU2_5x5, GPU2_7x7,

並且在terminal會顯示執行時間，以證明CUDA2的exacution time 小於CUDA1，整體運算效能較佳。