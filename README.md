# Notes and Comments for Modules and Assignments

### Database Systems: 
**Assignment 1:** 
- Q3 做了贼久，我是真欠练

### Design and Analysis of Algorithms
**2019/Jan/27 Assignment 1:**
- 第一题，思路是首先先分组，否则俩俩比较太慢，不太现实。 g[1,7] 一组, g[2,8,5]一组, g[3,4,6]一组。首次分组可能不对，后续慢慢调整。
- 比较大小三种方法: a. L'Hopital's Rule b. 两边疯狂取log c. 直观法，比如n^3 << n^lgn
- 第二题，前两题常规题，c小问就是高中数列题，首先求出a<sub>n</sub>和a<sub>n-1</sub>的递推关系，此题里是a<sub>n</sub> = (n/n-1)a<sub>n-1</sub> + 10即a<sub>n</sub> = f(n)a<sub>n-1</sub> + h(n)形式且h(n)不为0. 回顾高中数列递推公式，没有这种形式的解。遂用代入法，一项项替换，最后获得an和a1的关系
- 第三题，很简单，就是考定义，o(n)是对所有常数c， O(n)是存在常数c.
- 答案参考已上传至repo.

### CS231N (Convolutional Neural Networks)
