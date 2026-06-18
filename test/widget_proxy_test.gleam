import gleam/bit_array
import gleam/fetch
import gleam/http/response
import gleam/javascript/promise
import gleam/list
import gleam/string
import gleeunit
import widget_proxy

// Overwatch Discord server - https://owdiscord.org
const test_server_id = "94882524378968064"

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn request_format_test() {
  let req = widget_proxy.widget_req(test_server_id)

  assert list.contains(req.headers, #(
    "user-agent",
    "widget_proxy (https://widget-proxy.grphcrtv.com, 1.0.0)",
  ))
  assert string.contains(req.path, test_server_id)
}

pub fn can_fetch_test() {
  let req = widget_proxy.widget_req(test_server_id)

  use resp <- promise.try_await(fetch.send(req))
  use resp <- promise.try_await(fetch.read_bytes_body(resp))

  // Ensure we are getting an OK response
  assert resp.status == 200

  // Ensure we're getting given JSON
  assert response.get_header(resp, "content-type") == Ok("application/json")

  // Ensure the body isn't empty
  assert resp.body != bit_array.from_string("")

  let assert Ok(body_string) = bit_array.to_string(resp.body)

  // Assert a couple of JSON keys exist. It's not worth actually parsing the JSON, since we don't even care for the content in the application, really.
  assert string.contains(body_string, "presence_count")

  promise.resolve(Ok(Nil))
}
