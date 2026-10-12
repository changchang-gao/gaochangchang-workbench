// Cloudflare Pages Function：把 /sb/* 反向代理到 Supabase
//
// 背景：部分网络（例如国内手机流量、某些公共 WiFi）无法直连 *.supabase.co，
// 浏览器只会报 "Load failed" / "Failed to fetch"，表现为登录失败。
// 这里提供一个同域名的代理入口，页面在直连失败时会自动切到这条备用线路。
//
// 部署：本文件随仓库一起部署到 Cloudflare Pages（functions/ 目录会被自动识别），
// 无需任何额外配置。访问 /sb/auth/v1/health 能返回 GoTrue 的 JSON 即表示生效。

const SUPABASE_HOST = 'fxbxytpczuvyjwmmfydh.supabase.co';

export async function onRequest(context) {
  const url = new URL(context.request.url);

  const target = new URL(context.request.url);
  target.protocol = 'https:';
  target.host = SUPABASE_HOST;
  target.port = '';
  // /sb/auth/v1/token -> /auth/v1/token
  target.pathname = url.pathname.replace(/^\/sb/, '');

  const upstream = new Request(target.toString(), context.request);

  const response = await fetch(upstream);

  const headers = new Headers(response.headers);

  // 顺带把上游返回的重定向地址改回本站，避免跳回 supabase.co
  const location = headers.get('location');
  if (location && location.indexOf('http') === 0) {
    const loc = new URL(location);
    if (loc.host === SUPABASE_HOST) {
      headers.set('location', url.origin + '/sb' + loc.pathname + loc.search);
    }
  }

  // 响应体会被运行时重新编码，这几个头必须去掉，否则可能出现内容截断
  headers.delete('content-encoding');
  headers.delete('content-length');
  headers.delete('transfer-encoding');

  return new Response(response.body, {
    status: response.status,
    statusText: response.statusText,
    headers
  });
}
