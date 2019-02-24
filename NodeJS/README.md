# NodeJS入门 学习笔记

Reference: [NodeJS](https://www.nodebeginner.org/index-zh-cn.html)

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
要想从requestHandler获取返回信息，最直接的想法时在模块最后return value, 不过这样会产生一些问题.<br/>
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

## 6.产生非阻塞error的例子
**requestHandler.js**:
```javascript
var exec = require("child_process").exec;

function start() {
  console.log("Request handler 'start' was called.");
  var content = "empty";

  exec("ls -lah", function (error, stdout, stderr) {
    content = stdout;
  });

  return content;
}

function upload() {
  console.log("Request handler 'upload' was called.");
  return "Hello Upload";
}

exports.start = start;
exports.upload = upload;
```
访问"http://localhost:8888/start", 载入的web页面显示"empty"而不是"ls-lah"的结果. 这是因为exec()的操作时异步的，所以返回content="empty".
所以要想办法避免因为异步而return了一个没有按预期赋值的variable.

## 7. 解决因异步加载而无法return expected value
为避免return,还想从requestHandler中获得结果传给response,可以反过来将response传入.
**server.js**:
```javascript
var http = require("http");
var url = require("url");

function start(route, handle) {
  function onRequest(request, response) {
    var pathname = url.parse(request.url).pathname;
    console.log("Request for " + pathname + " received.");

    route(handle, pathname, response);
  }

  http.createServer(onRequest).listen(8888);
  console.log("Server has started.");
}

exports.start = start;
```
**router.js**:
```javascript
function route(handle, pathname, response) {
  console.log("About to route a request for " + pathname);
  if (typeof handle[pathname] === 'function') {
    handle[pathname](response);
  } else {
    console.log("No request handler found for " + pathname);
    response.writeHead(404, {"Content-Type": "text/plain"});
    response.write("404 Not found");
    response.end();
  }
}

exports.route = route;
```
**requestHandler.js**:
```javascript
var exec = require("child_process").exec;

function start(response) {
  console.log("Request handler 'start' was called.");

  exec("ls -lah", function (error, stdout, stderr) {
    response.writeHead(200, {"Content-Type": "text/plain"});
    response.write(stdout);
    response.end();
  });
}

function upload(response) {
  console.log("Request handler 'upload' was called.");
  response.writeHead(200, {"Content-Type": "text/plain"});
  response.write("Hello Upload");
  response.end();
}

exports.start = start;
exports.upload = upload;
```
## 8. 处理POST请求
**requestHandler.js**:
```javascript
function start(response) {
  console.log("Request handler 'start' was called.");

  var body = '<html>'+
    '<head>'+
    '<meta http-equiv="Content-Type" content="text/html; '+
    'charset=UTF-8" />'+
    '</head>'+
    '<body>'+
    '<form action="/upload" method="post">'+
    '<textarea name="text" rows="20" cols="60"></textarea>'+
    '<input type="submit" value="Submit text" />'+
    '</form>'+
    '</body>'+
    '</html>';

    response.writeHead(200, {"Content-Type": "text/html"});
    response.write(body);
    response.end();
}

function upload(response) {
  console.log("Request handler 'upload' was called.");
  response.writeHead(200, {"Content-Type": "text/plain"});
  response.write("Hello Upload");
  response.end();
}

exports.start = start;
exports.upload = upload;
```
- 表单内容在body中.当用户提交表单时，出发/upload, 请求requestHandler处理POST时：很自然的想到采用**异步回调**来实现非阻塞地处理POST请求的数据.
- 为了使整个过程非阻塞，Node.js会将POST数据拆分成很多小的数据块，然后通过出发特定的事件，将这些小数据传递给回调函数。这里的特定时间有：data事件(表示新的小数据块到达了)，以及end事件(表示所有的数据都已经接收完毕).
- 我们需要告诉Node.js，当这些事件出发的时候，回调哪些函数.我们通过在request对象上注册监听器(listener)来实现.这里的request对象使每次接收到HTTP请求的时候，都会把该对象传递给onRequest回调函数.
```javascript
request.addListener("data", function(chunk) {
  // called when a new chunk of data was received
});

request.addListener("end", function() {
  // called when all chunks of data have been received
});
```
那么上面这部分逻辑写在哪里呢？<br/>
HTTP服务器处理POST数据 -> Data传给route & requestHandler<br/>
思路总结：
- 将data和end事件的回调函数直接放在服务器中
- 在data事件中手机所有的POST数据
- 当接收到所有数据，出发end事件后，callback 请求route,并传递data
- route把data再传给requestHandler

**server.js**:
```javascript
var http = require("http");
var url = require("url");

function start(route, handle) {
  function onRequest(request, response) {
    var postData = "";
    var pathname = url.parse(request.url).pathname;
    console.log("Request for " + pathname + " received.");

    request.setEncoding("utf8");

    request.addListener("data", function(postDataChunk) {
      postData += postDataChunk;
      console.log("Received POST data chunk '"+
      postDataChunk + "'.");
    });

    request.addListener("end", function() {
      route(handle, pathname, response, postData);
    });

  }

  http.createServer(onRequest).listen(8888);
  console.log("Server has started.");
}

exports.start = start;
```
上述代码做了3件事情:
- 设置了接收数据的编码格式为UTF-8
- 注册了“data”事件的监听器，用于收集每次接收到的新数据块，并将其赋值给postData 变量，
- 最后，我们将请求路由的调用移到end事件处理程序中，以确保它只会当所有数据接收完毕后才触发，并且只触发一次。我们同时还把POST数据传递给请求路由，因为这些数据，请求处理程序会用到。

**route.js**:
```javascript
function route(handle, pathname, response, postData) {
  console.log("About to route a request for " + pathname);
  if (typeof handle[pathname] === 'function') {
    handle[pathname](response, postData);
  } else {
    console.log("No request handler found for " + pathname);
    response.writeHead(404, {"Content-Type": "text/plain"});
    response.write("404 Not found");
    response.end();
  }
}

exports.route = route;
```
**requestHandler.js**:
```javascript
function start(response, postData) {
  console.log("Request handler 'start' was called.");

  var body = '<html>'+
    '<head>'+
    '<meta http-equiv="Content-Type" content="text/html; '+
    'charset=UTF-8" />'+
    '</head>'+
    '<body>'+
    '<form action="/upload" method="post">'+
    '<textarea name="text" rows="20" cols="60"></textarea>'+
    '<input type="submit" value="Submit text" />'+
    '</form>'+
    '</body>'+
    '</html>';

    response.writeHead(200, {"Content-Type": "text/html"});
    response.write(body);
    response.end();
}

function upload(response, postData) {
  console.log("Request handler 'upload' was called.");
  response.writeHead(200, {"Content-Type": "text/plain"});
  response.write("You've sent: " + postData);
  response.end();
}

exports.start = start;
exports.upload = upload;
```
当前我们是把请求的整个消息体传递给route & requestHandler, 我们应该只把POST数据中的text传递. 这可以用querystring模块实现。
```javascript
var querystring = require("querystring");

function start(response, postData) {
  console.log("Request handler 'start' was called.");

  var body = '<html>'+
    '<head>'+
    '<meta http-equiv="Content-Type" content="text/html; '+
    'charset=UTF-8" />'+
    '</head>'+
    '<body>'+
    '<form action="/upload" method="post">'+
    '<textarea name="text" rows="20" cols="60"></textarea>'+
    '<input type="submit" value="Submit text" />'+
    '</form>'+
    '</body>'+
    '</html>';

    response.writeHead(200, {"Content-Type": "text/html"});
    response.write(body);
    response.end();
}

function upload(response, postData) {
  console.log("Request handler 'upload' was called.");
  response.writeHead(200, {"Content-Type": "text/plain"});
  response.write("You've sent the text: "+
  querystring.parse(postData).text);
  response.end();
}

exports.start = start;
exports.upload = upload;
```
## 9. 上传图片/文件
在了解了处理POST请求的过程后，我们来实现最终目标：上传图片。与POST相似，图片文件也是在server.js被获取，之后传给route & requestHandler. 不过POST只是文本，土坯那需要额外的模块来解析，而不是直接把解析对象传给route & requestHandler. 所以这次把request也一并传递
**server.js**:
```javascript
var http = require("http");
var url = require("url");

function start(route, handle) {
  function onRequest(request, response) {
    var pathname = url.parse(request.url).pathname;
    console.log("Request for " + pathname + " received.");
    route(handle, pathname, response, request);
  }

  http.createServer(onRequest).listen(8888);
  console.log("Server has started.");
}

exports.start = start;
```
**router.js**:
```javascript
function route(handle, pathname, response, request) {
  console.log("About to route a request for " + pathname);
  if (typeof handle[pathname] === 'function') {
    handle[pathname](response, request);
  } else {
    console.log("No request handler found for " + pathname);
    response.writeHead(404, {"Content-Type": "text/html"});
    response.write("404 Not found");
    response.end();
  }
}

exports.route = route;
```
**requestHandler.js**:
```javascript
var querystring = require("querystring"),
    fs = require("fs"),
    formidable = require("formidable");

function start(response) {
  console.log("Request handler 'start' was called.");

  var body = '<html>'+
    '<head>'+
    '<meta http-equiv="Content-Type" content="text/html; '+
    'charset=UTF-8" />'+
    '</head>'+
    '<body>'+
    '<form action="/upload" enctype="multipart/form-data" '+
    'method="post">'+
    '<input type="file" name="upload" multiple="multiple">'+
    '<input type="submit" value="Upload file" />'+
    '</form>'+
    '</body>'+
    '</html>';

    response.writeHead(200, {"Content-Type": "text/html"});
    response.write(body);
    response.end();
}

function upload(response, request) {
  console.log("Request handler 'upload' was called.");

  var form = new formidable.IncomingForm();
  console.log("about to parse");
  form.parse(request, function(error, fields, files) {
    console.log("parsing done");
    fs.renameSync(files.upload.path, "/tmp/test.png");
    response.writeHead(200, {"Content-Type": "text/html"});
    response.write("received image:<br/>");
    response.write("<img src='/show' />");
    response.end();
  });
}

function show(response) {
  console.log("Request handler 'show' was called.");
  fs.readFile("/tmp/test.png", "binary", function(error, file) {
    if(error) {
      response.writeHead(500, {"Content-Type": "text/plain"});
      response.write(error + "\n");
      response.end();
    } else {
      response.writeHead(200, {"Content-Type": "image/png"});
      response.write(file, "binary");
      response.end();
    }
  });
}

exports.start = start;
exports.upload = upload;
exports.show = show;
```
