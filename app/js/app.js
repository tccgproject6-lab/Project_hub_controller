const $=id=>document.getElementById(id);
const state={page:"dashboard",dark:localStorage.getItem("hub-theme")!=="light",language:localStorage.getItem("hub-language")||"English"};
const pages={
 dashboard:["Command Dashboard","INTELLIGENT CONTROL CENTER"],
 projects:["Projects & Workflow","WEBSITE DELIVERY"],
 tasks:["Tasks","TEAM EXECUTION"],
 team:["Team & Admin Control","ROLES & PERMISSIONS"],
 chat:["Team Chat","REAL-TIME COMMUNICATION"],
 meetings:["Live Meetings","LIVE COLLABORATION"],
 code:["Code Studio","BUILD & PREVIEW"],
 qa:["Testing & QA","QUALITY CENTER"],
 deploy:["Deployment & Launch","RELEASE CENTER"]
};
function toast(x){$("toast").textContent=x;$("toast").classList.remove("hidden");setTimeout(()=>$("toast").classList.add("hidden"),2300)}
async function initAuth(){
 if(!window.HUB?.configured || !window.HUB.client){
   $("roleLabel").textContent="Setup mode";
   $("connection").textContent="● Supabase not configured";
   return;
 }
 const {data:{session}}=await HUB.client.auth.getSession();
 if(!session){$("roleLabel").textContent="Guest";$("connection").textContent="● Signed out";return}
 HUB.user=session.user;
 const {data:profile}=await HUB.client.from("profiles").select("*").eq("id",session.user.id).maybeSingle();
 HUB.profile=profile;
 HUB.role=profile?.role||"member";
 $("roleLabel").textContent=HUB.role;
 $("connection").textContent="● Supabase connected";
}
function dashboard(){
return `<div class="welcome"><div><div class="eyebrow">INTELLIGENT CONTROL CENTER</div><h2>Everything your team needs, in one place.</h2><p>One workspace for projects, tasks, team control, chat, meetings, code, QA and deployment.</p></div><div class="health"><span>Workspace health</span><b>Healthy</b><small>Connect Supabase to load live workspace metrics.</small></div></div>
<div class="cards"><article><span>Active projects</span><b id="projectCount">—</b><small>Live database metric</small></article><article><span>Open tasks</span><b>—</b><small>Live database metric</small></article><article><span>Team members</span><b>—</b><small>Live database metric</small></article><article><span>Release readiness</span><b>—</b><small>Live QA metric</small></article></div>
<div class="grid"><div class="panel"><div class="head"><h3>Connected modules</h3></div>${["Projects & Workflow","Tasks","Team & Admin","Realtime Chat","Live Meetings","Code Studio","Testing & QA","Deployment"].map(x=>`<div class="project"><b>${x}</b><small>Integrated entry point</small></div>`).join("")}</div><div class="panel"><div class="head"><h3>Production status</h3></div><div class="item good"><b>Authentication</b><small>Session-aware client enabled.</small></div><div class="item good"><b>Role enforcement</b><small>Database/RLS remains the security boundary.</small></div><div class="item info"><b>Realtime</b><small>Subscribe only after an authenticated session exists.</small></div><div class="item warning"><b>Provider deployment</b><small>Connect CI/CD credentials only on the server.</small></div></div></div>`;
}
function modulePage(title,desc,items){
return `<div class="module-hero"><div class="eyebrow">${pages[state.page][1]}</div><h2>${title}</h2><p>${desc}</p></div><div class="module-grid">${items.map(x=>`<button class="module-card" onclick="toast('${x[2]}')"><span>${x[0]}</span><b>${x[1]}</b><small>Open module</small></button>`).join("")}</div>`;
}
function render(){
 const p=pages[state.page];$("pageTitle").textContent=p[0];
 document.querySelectorAll(".nav[data-page]").forEach(n=>n.classList.toggle("active",n.dataset.page===state.page));
 let h="";
 if(state.page==="dashboard")h=dashboard();
 else if(state.page==="projects")h=modulePage("Projects & Workflow","Create and manage website delivery stages.",[["▣","Projects","Projects module opened"],["🗺","Workflow","Workflow opened"],["📊","Project health","Health metrics opened"]]);
 else if(state.page==="tasks")h=modulePage("Tasks","Assign, prioritize and track work.",[["✓","Task board","Task board opened"],["⚠","Due soon","Deadline view opened"],["↗","Assignments","Assignments opened"]]);
 else if(state.page==="team")h=modulePage("Team & Admin Control","Manage delegated Admins and member permissions.",[["👑","Role control","Role control opened"],["👥","Members","Member management opened"],["📝","Audit log","Permission audit opened"]]);
 else if(state.page==="chat")h=modulePage("Team Chat","Realtime direct and group communication.",[["💬","Private chat","Chat opened"],["👥","Groups","Group chat opened"],["🔎","Search","Message search opened"]]);
 else if(state.page==="meetings")h=modulePage("Live Meetings","Meet, share screen and collaborate.",[["🎥","Meeting room","Meeting room opened"],["🖥","Screen share","Screen sharing opened"],["👥","Participants","Participant controls opened"]]);
 else if(state.page==="code")h=modulePage("Code Studio","Edit and safely preview HTML/CSS/JS.",[["⌘","Editor","Editor opened"],["▶","Run","Sandbox preview opened"],["📁","Files","File explorer opened"]]);
 else if(state.page==="qa")h=modulePage("Testing & QA","Test cases, bugs and release gates.",[["✓","Test suite","Test suite opened"],["🐛","Bug tracker","Bug tracker opened"],["🚦","Release gate","Release gate opened"]]);
 else h=modulePage("Deployment & Launch","Approve and prepare production releases.",[["🚀","Releases","Release center opened"],["🔐","Approval","Approval gate opened"],["📈","Maintenance","Maintenance opened"]]);
 $("page").innerHTML=h;
}
document.querySelectorAll(".nav[data-page]").forEach(n=>n.onclick=()=>{state.page=n.dataset.page;render()});
$("theme").onclick=()=>{state.dark=!state.dark;document.body.classList.toggle("light",!state.dark);localStorage.setItem("hub-theme",state.dark?"dark":"light")};
if(!state.dark)document.body.classList.add("light");
$("language").onclick=()=>{state.language=state.language==="English"?"Swahili":"English";$("language").querySelector("span").textContent=state.language;localStorage.setItem("hub-language",state.language);toast(`Language: ${state.language}`)};
$("help").onclick=()=>$("modal").classList.remove("hidden");$("closeModal").onclick=()=>$("modal").classList.add("hidden");
$("notifications").onclick=()=>toast("Notification center is ready for realtime Supabase subscriptions.");
render();initAuth();
