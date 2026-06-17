import gleam/http
import gleam/http/request
import gleam/io

pub fn main() -> Nil {
  io.println("Hello from widget_proxy!")
}

/// Create a new request type with our relevant headers (user-agent) and path.
pub fn req(server_id server_id: String) -> request.Request(String) {
  request.new()
  |> request.set_scheme(http.Https)
  |> request.set_host("discord.com")
  |> request.set_path("/api/v10/guilds/" <> server_id <> "/widget.json")
  // Should identify ourselves just so Discord can notify us if there's any issues
  |> request.set_header(
    "user-agent",
    "widget_proxy (https://widget-proxy.grphcrtv.com, 1.0.0)",
  )
}
