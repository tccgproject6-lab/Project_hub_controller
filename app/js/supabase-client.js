const cfg=window.HUB_CONFIG||{};
const configured=Boolean(cfg.supabaseUrl && cfg.supabaseAnonKey &&
  !cfg.supabaseUrl.includes("YOUR_SUPABASE") &&
  !cfg.supabaseAnonKey.includes("YOUR_SUPABASE"));
window.HUB={configured,client:null,user:null,profile:null,role:"member"};
if(configured && window.supabase){
  window.HUB.client=window.supabase.createClient(cfg.supabaseUrl,cfg.supabaseAnonKey,{
    auth:{persistSession:true,autoRefreshToken:true,detectSessionInUrl:true}
  });
}
