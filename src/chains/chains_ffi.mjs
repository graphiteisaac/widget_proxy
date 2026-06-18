import { Result$Error, Result$Ok, List } from "../gleam.mjs";
import { Http, Https, parse_method } from "../../gleam_http/gleam/http.mjs";
import { Request$Request } from "../../gleam_http/gleam/http/request.mjs";
import { Option$None, Option$Some } from "../../gleam_stdlib/gleam/option.mjs";

export async function bind_kv(env, key) {
	const store = env[key];

	if (!store) return Result$Error(null);

	return Result$Ok(store);
}

export async function kv_put(kv, key, value) {
	try {
		await kv.put(key, value);
		return Result$Ok(null);
	} catch (e) {
		return Result$Error(null);
	}
}

export async function kv_put_expiry(kv, key, value, expiration) {
	try {
		await kv.put(key, value, { expiration });
		return Result$Ok(null);
	} catch (e) {
		return Result$Error(null);
	}
}

export async function kv_get(kv, key) {
	try {
		const value = await kv.get(key, { type: "text" });
		if (value === null) return Result$Error(null);
		return Result$Ok(value);
	} catch (e) {
		return Result$Error(null);
	}
}

export function js_req_to_gleam(req) {
	const url = new URL(req.url);

	const method = parse_method(req.method)[0];
	const headers = List.fromArray([...req.headers]);
	const body = req;
	const scheme = url.protocol === "https:" ? new Https() : new Http();
	const host = url.hostname;
	const port = url.port ? Option$Some(url.port) : Option$None();
	const path = url.pathname;
	const query = url.search.slice(1)
		? Option$Some(url.search.slice(1))
		: Option$None();

	return Request$Request(
		method,
		headers,
		body,
		scheme,
		host,
		port,
		path,
		query,
	);
}

export function http_to_js_response(res) {
	const body = res.body;
	const status = res.status;
	const headers = res.headers.toArray();

	return new Response(body, {
		status,
		headers,
	});
}
