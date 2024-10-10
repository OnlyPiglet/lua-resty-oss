local http = require("resty.http")
local ngx = ngx
local ngx_encode_base64 = ngx.encode_base64
local ngx_md5_bin = ngx.md5_bin
local ngx_hmac_sha1 = ngx.hmac_sha1

local _M = {
	__version = "0.01",
}

local mt = { __index = _M }

local function new(oss_config)
	if not oss_config.endpoint or not oss_config.bucket then
		return nil,"missing oss endpoint or bucket"
	end
	if not oss_config.scheme then
		oss_config.scheme = "http"
	end
	if not oss_config.timeout then
		oss_config.timeout = 30
	end
	return setmetatable(oss_config, mt),nil
end

local function _sign(self, str)
	local key = ngx_encode_base64(ngx_hmac_sha1(self.accessSecret, str))
	local stab = { "OSS ", self.accessKey, ":", key }
	return table.concat(stab, "")
end

local function _send_http_request(self, url, method, headers, body)
	local httpc = http.new()
	httpc:set_timeout(self.timeout * 1000)
	local res, err = httpc:request_uri(url, {
		method = method,
		headers = headers,
		body = body,
	})
	httpc:set_keepalive(self.timeout * 1000, 20)
	return res, err
end

local function _build_headers(self, verb, content, content_type, object_name)
	local bucket = self.bucket
	local endpoint = self.endpoint
	local bucket_host = bucket .. "." .. endpoint
	local Date = ngx.http_time(ngx.time())
	local MD5 = ngx_encode_base64(ngx_md5_bin(content))
	local _content_type = content_type or "application/octet-stream"
	local resource = "/" .. bucket .. "/" .. (object_name or "")
	local CL = "\n"
	local params = { verb, MD5, _content_type, Date, resource }

	local check_param = table.concat(params, CL)

	local headers = {
		["Date"] = Date,
		["Content-MD5"] = MD5,
		["Content-Type"] = _content_type,
		["Authorization"] = self:sign(check_param),
		["Connection"] = "keep-alive",
		["Host"] = bucket_host,
	}

	return headers
end

local function get_object(self, object_name, content_type)
	content_type = content_type or "application/octet-stream"
	local headers = self:build_headers("GET", "", content_type, object_name)
	local url = self.scheme.. "://" .. headers["Host"] .. "/" .. object_name
	local res, err = self:send_http_request(url, "GET", headers, "")
	if err then
		return nil, err
	end
	if not res then
		return nil, "response from oss is nil"
	end

	if res.status ~= 200 then
		return nil, res.body
	end

	return res.body, nil
end

_M.new = new
_M.get_object = get_object
_M.build_headers = _build_headers
_M.sign = _sign
_M.send_http_request = _send_http_request

return _M
