此資料夾中一共有5個檔案：
→ Edge_Detection_Binarization
→ Edge_Detection_Binarization_Better
→ Edge_Detection_Binarization_Image_AboutUs_Medium
→ Edge_Detection_Binarization_Image_Cat_Large
→ Edge_Detection_Binarization_Image_Cat_Small


此5個檔案中前2個是以亂數生成矩陣作為測資，進行 Sobel Edge Detection 以及 Binarization 處理；後3個是以真實圖片作為測資，進行 Sobel Edge Detection 以及 Binarization 處理。以下是每個檔案的簡述：

========================亂數生成矩陣========================
→ Edge_Detection_Binarization
使用亂數生成64*64的Gray Scale Image，並以Sobel Edge Detection + Binarization進行圖片處理並輸出。
(亂數生成的Image也能產生大至4096*4096以上，只需修改parameters.h檔內的SIZE即可，且SIZE越大，GPU2加速對於GPU1的效果更顯著)
CPU.txt GPU1.txt GPU2.txt證明我們的實作在CPU，CUDA1，CUDA2的OUTPUT相同。且cuda2運算時間小於cuda1，已成功優化GPU速度。

→ Edge_Detection_Binarization_Better
使用更加優化的切割方法，使本資料夾中的cuda2的運算時間相較於Edge_Detection_Binarization更短，整體運算效能進一步提升。

========================真實圖片實作========================
後3個以真實圖片做測試(3個資料夾裡面的程式碼完全相同，此處只是想驗證我們寫的code能成功跑不同像素的圖片，且無論圖片大小、長寬，都能成功優化)。
首先經過灰階，並執行3x3，5x5，7x7的Sobel運算子，再進行Binarization 處理：

→ Edge_Detection_Binarization_Image_AboutUs_Medium
真實圖片測試，照片為本次作業的2位同學。
Medium的Pixel大小為960*1706，執行時間約為15分鐘。

→ Edge_Detection_Binarization_Image_Cat_Large
真實圖片測試，照片為睡覺黑白貓貓。
Large的Pixel大小為4032*3024，執行時間約為80分鐘。

→ Edge_Detection_Binarization_Image_Cat_Small
真實圖片測試，照片為嫌棄橘貓貓。
Small的Pixel大小為500*500，執行時間約為5分鐘。