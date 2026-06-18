import gleam/http/request
import gleam/http/response
import gleam/javascript/promise.{type Promise}

pub type JsReq

pub type JsResp

pub type Env

pub type KvStore

@external(javascript, "./chains_ffi.mjs", "bind_kv")
pub fn bind_kv(env env: Env, key key: String) -> Promise(Result(KvStore, Nil))

@external(javascript, "./chains_ffi.mjs", "kv_put")
pub fn kv_put(
  kv kv: KvStore,
  key key: String,
  value value: String,
) -> Promise(Result(Nil, Nil))

@external(javascript, "./chains_ffi.mjs", "kv_put_expiry")
pub fn kv_put_expiry(
  kv kv: KvStore,
  key key: String,
  value value: String,
  expiration expiration: Int,
) -> Promise(Result(Nil, Nil))

@external(javascript, "./chains_ffi.mjs", "kv_get")
pub fn kv_get(kv kv: KvStore, key key: String) -> Promise(Result(String, Nil))

@external(javascript, "./chains_ffi.mjs", "js_req_to_gleam")
pub fn js_req_to_http(request: JsReq) -> request.Request(String)

@external(javascript, "./chains_ffi.mjs", "http_to_js_response")
pub fn http_to_js_response(response: response.Response(String)) -> JsResp
// pub fn kv_delete(kv kv: KvStore, key key: String) -> Promise(Result(Nil, Nil)) {
//   promise.resolve(Error(Nil))
// }
//
// pub fn kv_list(
//   kv kv: KvStore,
//   key key: String,
// ) -> Promise(Result(List(#(String, String)), Nil)) {
//   promise.resolve(Error(Nil))
// }
