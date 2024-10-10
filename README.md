# lua-resty-oss
aliyun oss lib for openresty 

## Reference
http://doc.oss.aliyuncs.com/#_Toc336676770

https://github.com/362228416/lua-resty-oss

## Table Of Contents

[TOC]


## Description

``lua-resty-oss`` is a alibaba oss client lib with pure lua  for openresty.

## Status

Experimental.

##  Synopsis

This library is base of ``resty.http`` and openresty lua-module like,``ngx.encode_base64,ngx.hamc_sha1,ngx.md5_bin``

### oss.new

``syntax: local oss_client,err = oss.new(oss_config)``

craete a oss client with oss config，

The oss_config options tables has following fields:

* `scheme`:              scheme of oss endpoint, http or https,default is http
* ``endpoint``:          oss endpoints
* ``bucket``:              oss bucket name
* ``timeout``:            oss request timeout with seconds,default is 30(seconds)
* ``accessKey``:        oss access key
* ``accessSecret``: oss access secret

```lua
local oss = require("resty.oss")

local oss_client = oss.new({
    accessKey = "xxx",
		accessSecret = "xxx",
		bucket = "xxx",
  	endpoint = "xxx",
		timeout = 30,
		scheme = "http"
  })
```

### oss_client:get_object

``syntax: local resource,err = oss_client:get_object(object_name,content_type)`` 

get object within oss bucket, ``resource`` is the content of object.if there is any mistakes during get object, the ``err`` will not be ``nil`

The params of function get_object has following fields: 

* ``object_name`` the full path of object, if you have a  foo.png in bar directory within test bucket, the object_name should be ``bar/foo.png``
* ``cotent_type`` the object type,default is ``application/octet-stream``

