# NodeJS入门 学习笔记

## 0. Core of server.js

```javascript
var http = require("http")
http.createServer(function).listen(port)
```
这里的function有两个参数, request & response.

## 1.server.js
```javascript
var http = require("http");

http.createServer(function(request, response) {
  response.writeHead(200, {"Content-Type": "text/plain"});
  response.write("Hello World");
  response.end();
}).listen(8888);
```
基于事件的回调：
- 当我们与往常一样，运行node server.js 时，它会马上在命令行上输出"Server has started."
- 当我们向服务器发出请求时, "Request received." 这条消息就会在命令行中出现.

## 2. 把server.js变成一个模块
**server.js**:
```javascript
var http = require("http");
...
http.createServer(...)

exports.start = start;
```
**index.js**:
```javascript
var server = require("./server");
server.start();
```
当1、2完成后，我们可以接收HTTP请求，但对于不同的URL请求，服务器应该有不同的反应。所以继续：

## 3.route.js
- 我们要为route提供请求的URL和其他需要的GET和POST参数
- route需要根据这些数据来执行相应的代码
- 因此，我们需要查看HTTP请求，从中提取请求的URL以及GET/POST参数
- 所有数据都会包含在request对象中，该对象作为onRequest()回调函数的第一个参数传递。

