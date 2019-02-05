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
**Problem A: Decaying too fast or too slow in different directions**
<br/>
<img src="https://github.com/dabaitudiu/cs_notes/blob/master/CS231N/fig1.png" width = "128" height = "128" alt="fig1" align=left padding= "100" />
<img src="https://github.com/dabaitudiu/cs_notes/blob/master/CS231N/fig2.png" width = "128" height = "128" alt="fig2" align=left />
<img src="https://github.com/dabaitudiu/cs_notes/blob/master/CS231N/fig3.png" width = "128" height = "128" alt="fig3" align=left />
<img src="https://github.com/dabaitudiu/cs_notes/blob/master/CS231N/fig4.png" width = "128" height = "128" alt="fig4"  />
<br/>

Suppose our target function is like above, one is 2D view, the other is 3D view. When we are changeing in horizontal directions, our loss changes slowly; but if we move up & down, our loss changes sensitively in the vertical direction.
1. Point P in Figure 1&2:
- This is a very bad point for Loss Function
- Ratio of Largest to smallest singularvalue in the Hessian Matrix
2. Using SGD in such target function:
- very slow progress along shallow dimension, jitter along steep direction.
- Loss function has high condition number (ratio of largest to smallest singualr value).
3. This issue is more common in higher dimensional problems.

**Problem B: Local minima & Saddle points**
<br/>
<img src="https://github.com/dabaitudiu/cs_notes/blob/master/CS231N/fig3.png" width = "128" height = "128" alt="fig3" align=left />
<img src="https://github.com/dabaitudiu/cs_notes/blob/master/CS231N/fig3.png" width = "128" height = "128" alt="fig3"  />
<br/>
- At local minima，target function will be stuck and stop approaching global minia.
- At saddle points，as gradient == 0, optimization will pause.

**Problem C： "S" (stochastic)**
- Loss function is typically defined by computing the loss over many different examples. If N is your whole training set, Parameters can be large as million. Hence, each time when computing the loss would be very expensive. Hence, in practice, we often estimate the loss and estimate the gradient using a **mini batch** of examples. This means: 1) we're not actually getting the true information about the gradient at every time step. Instead, we're just getting some noisy estimate of the gradient at our current point.2) If there's noise in your gradient estimates, then vanilla SGD will tend to meander around the space, which takes a long time to reach the minia.
- In short, Stochastic => Meander => Very Long Time

### 7-1-3: Fancier Optimizer 1: SGD + Momentum


