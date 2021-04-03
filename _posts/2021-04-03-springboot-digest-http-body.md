---
layout    : post
category  : テク
title     : Hash against request body without breaking data binding
tags      : [springboot]
date      : 2021-04-03 17:00:00 +8
published : true
lang      : en-US
reference : [
  'https://www.javaboy.org/2021/0309/springboot-encrypt-decrypt.html',
  'https://github.com/pingu-no-hitorigoto/demo-http-body-digest'
]
---

We use checksum to ensure the integrity of files, memory bits, packets and others. But what about the http request itself?

<!--more-->

## Why bother?

About 2 or 3 year ago, I'm asked to take over a poorly designed, PHP-written chat bot. It was designed to handle messages from Naver LINE, an instant messaging service popular in Asia.

I'm not going to talk about how terrible the bot is or how unfriendly the LINE Messaging API documents are. But there is an interesting design in the LINE messaging API that often come to mind even in nowadays. That is, every message we sent or received must have a hash against its content, putten in header.

Recently, a poorly designed signature validation evoke my memories. The procedure rebuild the source data from binded POJO, than verify the content against the signature.

The problem is Spring drop all unknown and ignored fields during unserializing. Even the source is well normalized and the formattion isn't a problem, it's impossible to generate identical hash from incomplete fields (generally speaking).

Usually the input stream inside HttpServletRequest will come to our mind in first.

## The blind spot

Looking for inputstream is a correct beginning since we need the firsthand of user input. But it's onetime resource and you can't ask the client sent it again. Once the inputstream been consumed, the spring data binding won't work anymore.

To gathering inputs without break anything, we need to find a way process inputstream that also preserve a copy for downstream. On the other hand, we can also record it and consume the copy later.

Umm, record the data that passthrough? Doesn't it sounds like the thing command `tee` did on linux box? The `tee` command read from stdin then write to stdout as well as the given files. After s short searching, there is a class provided by Apache commons IO named `TeeInputStream` that provide what we are looking for.

```java
TeeInputStream(InputStream input, OutputStream branch, boolean closeBranch)
```

Given a way to duplicate the inputstream, we still need an entry point to hook it onto. Luckily Spring prepared it for us, which named `RequestBodyAdvice`.

## Take action

A `RequestBodyAdvice` will be invoked before and after http body been read, thus we can hook on the `TeeInputStream` at first, dump the input once InputStream been consumed.

```java
private ByteArrayOutputStream cc;

public boolean supports(
  MethodParameter parameter,
  Type targetType,
  Class<? extends HttpMessageConverter<?>> converterType
) {
  return true;
}

public HttpInputMessage beforeBodyRead(
  HttpInputMessage inputMessage,
  MethodParameter parameter,
  Type targetType,
  Class<? extends HttpMessageConverter<?>> converterType
) throws IOException {
  cc = new ByteArrayOutputStream();
  InputStream wrapped = new TeeInputStream(inputMessage.getBody(), cc, true);

  return super.beforeBodyRead(new HttpInputMessage() {
    public InputStream getBody() throws IOException {
      return wrapped;
    }

    public HttpHeaders getHeaders() {
      return inputMessage.getHeaders();
    }
  }, parameter, targetType, converterType);
}
```

We can calculate against the dump after read completed, just collect cached bytes from ByteArrayOutputStream.

```java
public Object afterBodyRead(
  Object body,
  HttpInputMessage inputMessage,
  MethodParameter parameter,
  Type targetType,
  Class<? extends HttpMessageConverter<?>> converterType
) {
  String sha256Calc = DigestUtils.sha256Hex(cc.toByteArray());
  String sha256Prov = inputMessage.getHeaders().getFirst("X-MESSAGE-DIGEST");

  if (!StringUtils.equalsIgnoreCase(sha256Calc, sha256Prov))
    throw new ResponseStatusException(BAD_REQUEST, "DIGEST MISMATCH");
  return super.afterBodyRead(body, inputMessage, parameter, targetType, converterType);
}
```

Although I pick SHA256 for demonstration, you can do anything you want from byte-by-byte logging to digital signature validation.

After above steps the advice wont work, unless you tell Spring when it should get involved.

```java
public boolean supports(
  MethodParameter parameter,
  Type targetType,
  Class<? extends HttpMessageConverter<?>> converterType
) {
  return true;
}
```

## Conclusion

After put them all together, don't forget the interface and annotation, our application begin verifying all incoming message and reject any invalid request.

With RequestBodyAdvice, we can do many things we usually can't do within controller, without the need of filter or inteceptor. Not only processing with raw message, we can also manipulate the raw message before they reach controller.
