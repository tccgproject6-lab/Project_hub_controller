async function signIn(email,password){
  const {data,error}=await supabaseClient.auth.signInWithPassword({email,password});
  if(error) throw error;
  return data;
}
async function signUp(email,password,fullName){
  const {data,error}=await supabaseClient.auth.signUp({
    email,password,options:{data:{full_name:fullName}}
  });
  if(error) throw error;
  return data;
}
async function signOut(){
  const {error}=await supabaseClient.auth.signOut();
  if(error) throw error;
}
async function getSession(){
  const {data,error}=await supabaseClient.auth.getSession();
  if(error) throw error;
  return data.session;
}
async function getProfile(userId){
  const {data,error}=await supabaseClient.from("profiles").select("*").eq("id",userId).single();
  if(error) throw error;
  return data;
}
async function getMembership(userId){
  const {data,error}=await supabaseClient.from("memberships").select("*").eq("user_id",userId).single();
  if(error) throw error;
  return data;
}
async function listMembers(){
  const {data,error}=await supabaseClient.from("memberships")
    .select("id,user_id,role,permissions,profiles(full_name,avatar_url,is_active)")
    .order("created_at");
  if(error) throw error;
  return data||[];
}
async function updateMemberRole(id,role){
  const {data,error}=await supabaseClient.from("memberships").update({role}).eq("id",id).select().single();
  if(error) throw error;
  return data;
}
async function updateMemberPermissions(id,permissions){
  const {data,error}=await supabaseClient.from("memberships").update({permissions}).eq("id",id).select().single();
  if(error) throw error;
  return data;
}
