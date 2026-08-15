const cfg=window.HUB_CONFIG||{};
const ready=Boolean(cfg.supabaseUrl&&!cfg.supabaseUrl.includes("YOUR_SUPABASE")&&cfg.supabaseAnonKey&&!cfg.supabaseAnonKey.includes("YOUR_SUPABASE"));
const rt={ready,client:null,user:null};
if(ready&&window.supabase){rt.client=window.supabase.createClient(cfg.supabaseUrl,cfg.supabaseAnonKey,{auth:{persistSession:true,autoRefreshToken:true}})}
async function getSession(){if(!rt.client)return null;const {data}=await rt.client.auth.getSession();rt.user=data.session?.user||null;return rt.user}
