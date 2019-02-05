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

### CS231N (Convolutional Neural Networks)
#### 7.1 Fancier Optimizers 

##### 7-1-1. Review
1. Review: Optimization
```python
while True:
    weights_grad = evaluate_gradient(loss_function, weights)
    weights += -step_size * weights_grad
```
2. Loss function tells us how good or bad is that value of the weights doing on our problem.

##### 7-1-2. Optimization: Problems with SGD (stochastic gradient descent)
本部分讨论随机梯度下降法带来的一些问题.

问题A: 速率过快或过缓
![Fig1](http://github.com/master.jpg)
![Fig2](http://github.com/master.jpg)
Suppose our target function is like above, one is 2D view, the other is 3D view. When we are changeing in horizontal directions, our loss changes slowly; but if we move up & down, our loss changes sensitively in the vertical direction.
![Fig3](http://github.com/master.jpg)
![Fig4](http://github.com/master.jpg)
1. 在Fig 1&2 上的点P:
- 对于loss value, 在这一点上是很坏的情况
- 它是Hessian matrix 中最大奇异值与最小奇异值之比
2. 在这样的目标函数上使用SGD:
- very slow progress along shallow dimension, jitter along steep direction.
- Loss function has high condition number (ratio of largest to smallest singualr value).
3. 在高维空间中，这个问题更加普遍。

问题B: Local minima & Saddle points
![Fig5](http://github.com/master.jpg)
![Fig6](http://github.com/master.jpg)
- 在local minima上，target function 会卡住困在局部最小值而不是全局最小值
- 在saddle points上，由于gradient == 0, 不会再继续optimize.

问题C： "S" (stochastic)
- Loss function is typically defined by computing the loss over many different examples. If N is your whole training set, Parameters can be large as million. Hence, each time when computing the loss would be very expensive. Hence, in practice, we often estimate the loss and estimate the gradient using a **mini batch** of examples. This means: 1) we're not actually getting the true information about the gradient at every time step. Instead, we're just getting some noisy estimate of the gradient at our current point.2) If there's noise in your gradient estimates, then vanilla SGD will tend to meander around the space, which takes a long time to reach the minia.
- In short, Stochastic => Meander => Very Long Time

##### 7-1-3: Fancier Optimizer 1: SGD + Momentum


