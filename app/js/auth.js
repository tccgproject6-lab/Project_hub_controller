const AuthUI={
  async requireUser(){
    if(!window.TeamHubDB?.ready()) return {demo:true,user:null,profile:null};
    const user=await TeamHubDB.user();
    if(!user){location.href="login.html";return {demo:false,user:null,profile:null}}
    return {demo:false,user,profile:await TeamHubDB.profile()};
  },
  async signOut(){await TeamHubDB.signOut();location.href="login.html"}
};
