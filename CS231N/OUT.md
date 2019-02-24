---
title: "CNN 7.1"
output:
  pdf_document:
    path: /Exports/Habits.pdf
---
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
<img src="https://github.com/dabaitudiu/cs_notes/blob/master/CS231N/fig5.png" width = "128" height = "128" alt="fig5" align=left />
<img src="https://github.com/dabaitudiu/cs_notes/blob/master/CS231N/fig6.png" width = "128" height = "128" alt="fig6"  />
<br/>
- At local minima，target function will be stuck and stop approaching global minia.
- At saddle points，as gradient == 0, optimization will pause.

**Problem C： "S" (stochastic)**
- Loss function is typically defined by computing the loss over many different examples. If N is your whole training set, Parameters can be large as million. Hence, each time when computing the loss would be very expensive. Hence, in practice, we often estimate the loss and estimate the gradient using a **mini batch** of examples. This means: 1) we're not actually getting the true information about the gradient at every time step. Instead, we're just getting some noisy estimate of the gradient at our current point.2) If there's noise in your gradient estimates, then vanilla SGD will tend to meander around the space, which takes a long time to reach the minia.
- In short, Stochastic => Meander => Very Long Time

### 7-1-3: Fancier Optimizer 1: SGD + Momentum
**SGD:**
x<sub>t+1</sub> = x<sub>t</sub> - a*f<sup>'</sup>(x<sub>t</sub>)
```python
while True:
    dx = compute_gradient(x)
    x += learning_rate * dx
```
**SGD + Momentum:**
v<sub>t+1</sub> = p * v<sub>t</sub> - f<sup>'</sup>(x<sub>t</sub>)
x<sub>t+1</sub> = x<sub>t</sub> - a*v<sub>t+1</sub>
```python
vx = 0
while True:
    dx = compute_gradient(x)
    vx = rho * vx + dx
    x += learning_rate *vx
```

Idea:
- Build up "velocity" as a running mean of gradients
- Rho gives "friction"; typically tho = 0.9 or 0.99

理解:
<img src="https://github.com/dabaitudiu/cs_notes/blob/master/CS231N/fig7.png" width = "128" height = "128" alt="fig5" align=left />
<img src="https://github.com/dabaitudiu/cs_notes/blob/master/CS231N/fig8.png" width = "128" height = "128" alt="fig5"  />
<br/>
- 保持一个不随时间变化的速度，并且我们将梯度估计值添加到这个速度上，然后再这个速度的方向上前进，而不是在梯度的方向上前进。(这样可以越过gradient=0)
- Intuitively, velocity is a weighted mean of gradients
- 随着梯度的权重越来越大，在每一步，我们都采用旧速度，通过摩擦系数衰减，然后加上当前的梯度，可以把它看成是一个最近梯度平均值的平滑移动，并且在梯度上有一个能够几时回来的指数衰减权重。

### 7-1-3: Fancier Optimizer 2: Nesterov Momentum
<img src="https://github.com/dabaitudiu/cs_notes/blob/master/CS231N/fig9.png" width = "128" height = "128" alt="fig5" align=left />
<img src="https://github.com/dabaitudiu/cs_notes/blob/master/CS231N/fig10.png" width = "128" height = "128" alt="fig5"  />
<br/>

Normal: $\overrightarrow{velocity} + \overrightarrow{gradient} \rightarrow \overrightarrow{actual-step}$
Nestrov: $\overrightarrow{velocity} + \overrightarrow{gradient-start-at- velocity} \rightarrow \overrightarrow{actual step}$

If your velocity direction was actaully a little bit wrong, it lets you incorporate gradient information from a little bit longer parts of the objective landscape.

SGD + Momemtum:
$v_{t+1} = \rho v_t + \nabla f(x_t)$
$x_{t+1} = x_t - \alpha v_{t+1}$

Nestrov Momentum:
$v_{t+1} = \rho v_t - \alpha \nabla f(x_t + \rho v_t)$
$x_{t+1} = x_t + v_{t+1}$
<br/>
Problem: $\nabla f(x_t + \rho v_t)$ is quite annoying. Usually we want to update $x_t, \nabla f(x_t)$ at the same time.
Solution: Change variable $\widetilde{x_t} = x_t + \rho v_t$
$v_{t+1} = \rho v_t - \alpha \nabla f(\widetilde{x_t})$
$
\begin{aligned}
\widetilde{x_{t+1}} &= \widetilde{x_t} - \rho v_t + (1+\rho)v_t + 1 \\
  &= \widetilde{x_t} + v_{t+1} + \rho(v_{t+1} - v_t)
\end{aligned}
$
Code:
```python
dx = compute_gradient(x)
old_v = v
v = rho * v - learning_rate * dx
x += -rho * old_v + (1+rho) * v
```
总结：Nestrov Momentum 包含了当前速度向量和之前速度向量的误差修正. SGD with Momentum 和 Nestrov 的一个不同就是，由于Nestrov有校正因子的存在，与常规的方法相比，它不会那么剧烈的越过局部极小值点.

### 7-1-4: Fancier Optimizer 3: AdaGrad
```python
grad_squared = 0
while True:
    dx = compute_gradient(x)
    grad_squared += dx * dx
    x -= learning_rate * dx / (np.sqrt(grad_sqeared) + 1e-7)
```
Idea:
- During the course of the optimization, you're going to keep a running estimate / running sum of all the square gradients that you see during traning. 
- Rather than having a velocity term, instead we have a grad squared term. During training, we're going to just keep adding the squared gradients to this grad squared term.
- Now when we update our parameter vector, we will divide by this grad squared term when we're making our update step.

Q1: What happens with AdaGrad? (大除大，小除小)
- Ans:The idea is that if we have two coordinates, one that always have a very high gradient, and one that alwasy has a very small gradient, then as we add the sum of the squares of the small gradients, we're going to be divided by a small number, so we'll accelerate movement along the slow dimension. Then along the other dimension, where the gradients tend to be very large, then we'll be divided by a large number, so we'll kind of slow down our progress along the wiggling dimension. 

Q2: What happens to the step size over long time?
- Ans: With Adagrad, the steps actually gets smaller and smaller because we just continue updating this estimate of the squared gradients over time, so this estimate just grows and grows monotically over the course of training. Now this causes our step size to get smaller and smaller over time. Again, in a convex case, there is really nice theory showing that this is actually good. Because in convex case, as you approach to a minimum, you kind of want to slow down so you actually converge. Bu in the non-convex case, as you come towards a saddle point, you might get stucked with AdaGrad. 
- In short: grad_square持续增大, step越来越小，遇到非凸函数会卡在saddle points.

**AdaGrad's Problem: grad_squared keeps increasing which causes steps too small**
To solve the above problem, a variation of AdaGrad is proposed.

### 7-1-5: Fancier Optimizer 4: RMSPROP
```python
grad_squared = 0
while True:
    dx = compute_gradient(x)
    grad_squared = decay_rate * grad_squared + (1-decay_rate)*dx*dx
    x -= learning_rate * dx / (np.sqrt(grad_squared) + 1e-7)
```
Idea:
- 在RMSPROP中，我们仍然计算梯度的平方，但我们并不是仅仅简单的在训练中累加梯度平方，我们会让平方梯度按照一定比率下降。它看起来就和Momentum Optimizer很像，除了我们是给梯度的平方加上动量，而不是给梯度本身加动量

**RMSPROP's Problem: Training will always become slow**

### 7-1-6: Fancier Optimizer 5: Adam-version 1.0
```python
first_moment = 0
second_moment = 0
while True:
    dx = compute_gradient(x)
    first_moment = beta1 * first_moment + (1-beta1) * dx  # Momentum Optimizer
    second_moment = beta2 * second_moment + (1-beta2) * dx * dx # RMSPROP Optimizer
    x-= learning_rate * first_moment / (np.sqrt(second_moment) + 1e-7)
```
Idea:
- Sort of like combining RMSPROP with momentum

Q1: What happens at the very first timestep?
- Ans: At the very first time step, at the beginning, we've initialized our second moment with zero. After one update of the second moment, typically this beta two, second moment decay rate, is something like 0.9/0.99, our second moment is still very close to 0. Now when we're making our update step here and we divide by our second moment, we're actually divided by a very small number. We thus will have a very large step at the beginning. And the very large step at the beginning is not really due to the geometry of the problem, but because we initially set second-moment to zero. And that's why we set constant = 1e-7 but not 0.

Adam为了避免上述在开始时得到很多big Step size的情况，添加了偏置校正项：
### 7-1-7: Fancier Optimizer 6: Adam-version 2.0(Full form)
```python
first_moment = 0
second_moment = 0
for t in range(num_iterations):
    dx = compute_gradient(x)
    first_moment = beta1 * first_moment + (1-beta1) * dx
    second_moment = beta2 * second_moment + (1-beta2) * dx * dx
    first_unbias = first_moment / (1 - beta1 ** t)
    second_unbias = second_moment / (1 - beta2 ** t)
    x -= learning_rate * first_unbias / (np.sqrt(second_unbias) + 1e-7)
```
- Bias correction for the fact that first and second moment estimates start at zero.
- Adam with beta1 = 0.9, beta2 = 0.999, learning rate_rate = 1e-3/5e-4 is a great starting point for many models!

### 7-1-8: Learning Rate Analysis
SGD,SGD+Momentum,AdaGrad,RMSProp, Adam all have learning rate as a hyper parameter.
Q: Which one of these learning rate is best to use?
<img src="https://github.com/dabaitudiu/cs_notes/blob/master/CS231N/fig11.png" width = "128" height = "128" alt="fig5" align=center />
<br/>
=> Learning rate decay over time!
- step decay: decay learning rate by half every few epochs.
- exponential decay: $\alpha = \alpha_0 e^{-kt}$
- 1/t decay: $\alpha = \alpha_0 / (1 + kt)$
<img src="https://github.com/dabaitudiu/cs_notes/blob/master/CS231N/fig12.png" width = "128" height = "128" alt="fig5" align=center />
Idea:
- 假设模型已经接近一个比较不错的取值区域，但是此时的梯度已经很小了，保持原有的学习速率只能在最优点附近来回徘徊。如果我们降低了学习率，目标函数仍然能够进一步降低，即在损失函数上进一步取得进步。

### 7-1-9: Orders of Optimizations
1. First-Order Optimization
- use gradient form linear approximation
- step to minimize the approximation.

<img src="https://github.com/dabaitudiu/cs_notes/blob/master/CS231N/fig13.png" width = "128" height = "128" alt="fig5" align=center />

2. Second-Order Optimization
- use gradient and Hessian to form quadratic approximation
- step to the minima of the approximation
- 同时考虑一阶和二阶偏导信息，现在我们对函数做一个二姐泰勒逼近。因为是二次函数，可以直接跳到最小值点。

<img src="https://github.com/dabaitudiu/cs_notes/blob/master/CS231N/fig14.png" width = "128" height = "128" alt="fig5" align=center />

当把上述思想推广到多维的情况时，就会得到一个叫做牛顿步长的东西。计算这个Hessian Matrix, 即二阶偏导矩阵，接着求Hessian Matrix的逆矩阵，以便直接走到对你的函数用二次逼近后的最小值的地方。
Second-Order Taylor expansion:
$J(\theta) \approx J(\theta_0) + (\theta - \theta_0)^T \nabla J(\theta_0) + 1/2 (\theta - \theta_0)^T H(\theta - \theta_0)$
Solving for the critical point, we obtain theNewton parameter update:
$\theta^* = \theta_0 - H^{-1}\nabla J(\theta_0)$

Q1: What is nice about this update?
- Ans: There isn't a learning rate.

Q2: What's the problem with these formulas?
- Ans: Hessian has $O(N^2)$ elements. Inverting it takes $O(N^3)$. N = (Tens or Hundreds of ) Millions
- 内存不够，没法求矩阵的逆.

Solution: 拟牛顿法代替牛顿法
- Quasi-Newton methos(BGFs most popular): instead of inverting the Hessian $O(n^3)$, approximate inverse Hessian with rank 1 updates over time ($O(N^2)$ each)
- L-BFGS(Limited Memory BFGS): Does not form / store the full inverse Hessian.

### 7-1-10: L-BFGS

- Usually works very well in full batch, deterministic mode. i.e., if you have a single, deterministic f(x) then L-BFGS will probably work very nicely.
- Does not transfer very well to mini-batch setting. Gives bad results. Adapting L-BFGS to large-scale, stochastic setting is an active area of research.

In practice:
- Adam is a good default choice in most cases.
- If you can afford to do full batch updates then try out L-BFGS (and don't forget to disable all sources of noise).
- L-BFGS在训练神经网络时不会很有用，但在后续问题如风格迁移中会用的上。这类问题有很少的随机性，参数也更少。

目前我们讲过的所有策略都是在减少训练误差并最小化目标函数，如果我们已经在优化目标函数上取得了好的效果，要怎么做来减少训练和测试之间的误差擦话剧，以使我们的模型在没见过给的数据上表现的更好呢？

### 7-1-11: Model Ensembles
1. 不同模型间的融合
- Train multiple independent models
- At test time average their results
- Enjoy 2% extra performance

2. 同一个模型不同快照融合
- 有时候可以不用独立地训练不同的模型，你可以在训练的过程中，保留多个模型的快照，然后用这些模型来做继承学习。然后在测试阶段，你仍然需要把这些多个快照的预测结果做平均，但是你可以在训练的过程中收集这些快照。
- Paper on ICLR: 学习率刚开始很慢，然后非常快，接着又很慢，接着又很快，交替变化。这样的学习率会使得训练过程中模型会收敛到目标函数的不同区域。但是结果仍然还不错。在过程中取快照并做平均，虽然你只进行了一次训练，最后会获得一个结果很好的模型。

3. 超参数融合
- Instead of using actual parameter vector, keep a moving average of the parameter vecotr and use that at test time(Polyak averaging)
```python
while True:
    data_batch = dataset.sample_data_batch()
    loss = nework.forward(data_batch)
    dx = network.backward()
    x += -learning_rate * dx
    x_test = 0.995 * x_test + 0.005 * x
```


