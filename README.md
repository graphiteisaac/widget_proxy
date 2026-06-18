# Discord widget JSON proxy

Small, simple, Cloudflare worker script to proxy Discord widget JSON requests. This prevents us from 
smashing their API too much and also avoids the occasional CORS problems.

We cache the responses for 5 minutes in Cloudflare KV, which heavily reduces our API request count 
externally. Available for public use at https://widget-proxy.grphcrtv.com - but please *please* don't abuse it too heavily, lol.

## Usage:

```bash
GET https://widget-proxy.grphcrtv.com/{guild_id}
```

Built by me, who would appreciate a [small sponsorship via GitHub](https://github.com/sponsors/graphiteisaac) if you've found this project useful

Built with [Gleam](https://gleam.run). [Sponsor them too](https://github.com/sponsors/gleam-lang)!
