const cfg=window.HUB_CONFIG||{};
const configured=Boolean(cfg.supabaseUrl&&!cfg.supabaseUrl.includes("YOUR_SUPABASE")&&cfg.supabaseAnonKey&&!cfg.supabaseAnonKey.includes("YOUR_SUPABASE"));
const RT={configured,client:null,user:null};
if(configured&&window.supabase)RT.client=window.supabase.createClient(cfg.supabaseUrl,cfg.supabaseAnonKey,{auth:{persistSession:true,autoRefreshToken:true,detectSessionInUrl:true}});
async function auth(){if(!RT.client)return null;const {data}=await RT.client.auth.getSession();RT.user=data.session?.user||null;return RT.user}
function esc(s){const d=document.createElement("div");d.textContent=s;return d.innerHTML}
