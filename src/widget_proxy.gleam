import chains/chains
import gleam/fetch
import gleam/http
import gleam/http/request
import gleam/http/response
import gleam/int
import gleam/javascript/promise
import gleam/time/timestamp
import gleam/uri

const ttl_seconds = 60

pub fn main() -> Nil {
  panic as "This project cannot be run standalone and must be run with the Cloudflare wrapper."
}

pub fn handle(
  req: chains.JsReq,
  env: chains.Env,
) -> promise.Promise(chains.JsResp) {
  let req = chains.js_req_to_http(req)
  use store <- promise.await(chains.bind_kv(env, "WIDGET_PROXY_CACHE"))
  let assert Ok(store) = store
  let #(now_seconds, _) =
    timestamp.system_time()
    |> timestamp.to_unix_seconds_and_nanoseconds()
  case uri.path_segments(req.path) {
    [id] -> handle_widget(store, id, now_seconds)
    _ -> not_found() |> promise.resolve
  }
}

fn handle_widget(
  store: chains.KvStore,
  id: String,
  now_seconds: Int,
) -> promise.Promise(chains.JsResp) {
  use cached <- promise.await(chains.kv_get(store, id))
  case cached {
    Ok(json) ->
      response.new(200)
      |> response.set_header("content-type", "application/json")
      |> response.set_header("x-proxy-cache", "HIT")
      |> response.set_body(json)
      |> chains.http_to_js_response
      |> promise.resolve

    _ -> fetch_and_cache(store, id, now_seconds + ttl_seconds)
  }
}

fn fetch_and_cache(
  store: chains.KvStore,
  id: String,
  now_seconds: Int,
) -> promise.Promise(chains.JsResp) {
  use resp <- promise.await(do_req(id))
  case resp {
    Ok(response.Response(status: 200, body:, ..)) -> {
      let _ = chains.kv_put_expiry(store, id, body, now_seconds)
      response.new(200)
      |> response.set_header("content-type", "application/json")
      |> response.set_header("x-proxy-cache", "MISS")
      |> response.set_header("x-cached-at", int.to_string(now_seconds))
      |> response.set_body(body)
      |> chains.http_to_js_response
      |> promise.resolve
    }
    Ok(response.Response(status:, body:, ..)) ->
      response.new(status)
      |> response.set_header("content-type", "application/json")
      |> response.set_body(body)
      |> chains.http_to_js_response
      |> promise.resolve
    Error(_) ->
      response.new(502)
      |> response.set_header("content-type", "application/json")
      |> response.set_body("{\"error\":\"upstream fetch failed\"}")
      |> chains.http_to_js_response
      |> promise.resolve
  }
}

fn do_req(id: String) -> promise.Promise(Result(response.Response(String), _)) {
  use resp <- promise.try_await(fetch.send(widget_req(id)))
  use resp <- promise.try_await(fetch.read_text_body(resp))
  promise.resolve(Ok(resp))
}

pub fn widget_req(server_id server_id: String) -> request.Request(String) {
  request.new()
  |> request.set_scheme(http.Https)
  |> request.set_host("discord.com")
  |> request.set_path("/api/v10/guilds/" <> server_id <> "/widget.json")
  |> request.set_header(
    "user-agent",
    "widget_proxy (https://widget-proxy.grphcrtv.com, 1.0.0)",
  )
}

fn not_found() -> chains.JsResp {
  response.new(404)
  |> response.set_header("content-type", "application/json")
  |> response.set_body("{\"error\":\"not found\"}")
  |> chains.http_to_js_response
}
