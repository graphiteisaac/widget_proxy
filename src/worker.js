import { handle } from "../build/dev/javascript/widget_proxy/widget_proxy.mjs";

export default {
	async fetch(req, env) {
		return handle(req, env);
	},
};
