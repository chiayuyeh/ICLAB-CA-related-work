執行步驟:

1.在Terminal直接執行make
  ->會產生執行檔

2.在Terminal執行./main
  ->會產生image.txt CPU.txt GPU1.txt GPU2.txt
    而CPU.txt GPU1.txt GPU2.txt內容相同，以證明不論是CPU進行演算法或   
    CUDA1,CUDA2執行，結果均相同

並且在terminal會顯示執行時間，以證明CUDA2的exacution time 小於CUDA1，整體運算效能較佳。