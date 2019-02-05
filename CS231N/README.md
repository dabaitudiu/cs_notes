# CS231N (Convolutional Neural Networks)
## 7.1 Fancier Optimizers 

### 7-1-1. Review
1. Optimization
```python
while True:
    weights_grad = evaluate_gradient(loss_function, weights)
    weights += -step_size * weights_grad
```
2. Loss function tells us how good or bad is that value of the weights doing on our problem.

### 7-1-2. Optimization: Problems with SGD (stochastic gradient descent)

问题A: 速率过快或过缓
![Fig1](https://github.com/dabaitudiu/cs_notes/blob/master/CS231N/fig1.png)
![Fig2](https://github.com/dabaitudiu/cs_notes/blob/master/CS231N/fig2.png)
Suppose our target function is like above, one is 2D view, the other is 3D view. When we are changeing in horizontal directions, our loss changes slowly; but if we move up & down, our loss changes sensitively in the vertical direction.
![Fig3](https://github.com/dabaitudiu/cs_notes/blob/master/CS231N/fig3.png)
![Fig4](https://github.com/dabaitudiu/cs_notes/blob/master/CS231N/fig4.png)
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

### 7-1-3: Fancier Optimizer 1: SGD + Momentum


