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

**server.js**:
```javascript
var http = require("http");
var url = require("url");

function start(route) {
  function onRequest(request, response) {
    var pathname = url.parse(request.url).pathname;
    console.log("Request for " + pathname + " received.");

    route(pathname);

    response.writeHead(200, {"Content-Type": "text/plain"});
    response.write("Hello World");
    response.end();
  }

  http.createServer(onRequest).listen(8888);
  console.log("Server has started.");
}

exports.start = start;
```
**router.js**:
```javascript
function route(pathname) {
  console.log("About to route a request for " + pathname);
}

exports.route = route;
```
**index.js**:
```javascript
var server = require("./server");
var router = require("./router");

server.start(router.route);
```
3之后，HTTP服务器和请求route模块已经可以相互交流了，但是，我们针对不同的URL要有不同的处理方式，例如/start的业务逻辑就应该和/upload的不同。在当前的implementation下，路由过程会在路由模块中结束。路由模块不是真正针对请求"采取行动"的模块.因此，我们加入新的模块：requestHandlers.

## 4. requestHandlers.js
**requestHandlers.js**:
```javascript
function start() {
  console.log("Request handler 'start' was called.");
}

function upload() {
  console.log("Request handler 'upload' was called.");
}

exports.start = start;
exports.upload = upload;
```
为了建立requestHandler和route之间的关系，有两种选择：
- 在route.js中，import requestHandler模块
- 把requestHandler的内容作为参数，在index.js中注入给route
- 第二种方法的好处时：route和request之间的耦合更加松散，route的重复利用性更高.(即route在以后还可以用来干别的，干别的的时候用不到requestHandler.)
**index.js**:
```javascript
var server = require("./server");
var router = require("./router");
var requestHandlers = require("./requestHandlers");

var handle = {}
handle["/"] = requestHandlers.start;
handle["/start"] = requestHandlers.start;
handle["/upload"] = requestHandlers.upload;

server.start(router.route, handle);
```
**server.js**:
```javascript
var http = require("http");
var url = require("url");

function start(route, handle) {
  function onRequest(request, response) {
    var pathname = url.parse(request.url).pathname;
    console.log("Request for " + pathname + " received.");

    route(handle, pathname);

    response.writeHead(200, {"Content-Type": "text/plain"});
    response.write("Hello World");
    response.end();
  }

  http.createServer(onRequest).listen(8888);
  console.log("Server has started.");
}

exports.start = start;
```
**route.js**：
```javascript
function route(handle, pathname) {
  console.log("About to route a request for " + pathname);
  if (typeof handle[pathname] === 'function') {
    handle[pathname]();
  } else {
    console.log("No request handler found for " + pathname);
  }
}

exports.route = route;
```
4之后，我们希望requestHandler向浏览器返回一些有意义的信息，而并非全是"Hello World"

## 5. Retrieve Information from RequestHandler
要想从requestHandler获取返回信息，最直接的想法时在模块最后return value, 不过这样会产生一些问题.
**requestHandler.js**:
```javascript
function start() {
  console.log("Request handler 'start' was called.");
  return "Hello Start";
}

function upload() {
  console.log("Request handler 'upload' was called.");
  return "Hello Upload";
}

exports.start = start;
exports.upload = upload;
```
**router.js**:
```javascript
function route(handle, pathname) {
  console.log("About to route a request for " + pathname);
  if (typeof handle[pathname] === 'function') {
    return handle[pathname]();
  } else {
    console.log("No request handler found for " + pathname);
    return "404 Not found";
  }
}

exports.route = route;
```
**server.js**:
```javascript
var http = require("http");
var url = require("url");

function start(route, handle) {
  function onRequest(request, response) {
    var pathname = url.parse(request.url).pathname;
    console.log("Request for " + pathname + " received.");

    response.writeHead(200, {"Content-Type": "text/plain"});
    var content = route(handle, pathname)
    response.write(content);
    response.end();
  }

  http.createServer(onRequest).listen(8888);
  console.log("Server has started.");
}

exports.start = start;
```
5写完之后，看似没什么问题，访问'/start, /upload, /unknown'都会返回相应的值。然而当requestHandler.js中出现'非阻塞'型function时，由于node.js异步加载的特性，会返回一个unexptected return value.