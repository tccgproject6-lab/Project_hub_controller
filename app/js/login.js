const form=document.getElementById("login"),msg=document.getElementById("msg");
form.onsubmit=async e=>{
 e.preventDefault();msg.textContent="Signing in…";
 if(!TeamHubDB.ready()){msg.textContent="Configure Supabase URL and anon key first.";return}
 const {error}=await TeamHubDB.client().auth.signInWithPassword({email:email.value.trim(),password:password.value});
 if(error){msg.textContent=error.message;return}
 location.href="index.html";
};
