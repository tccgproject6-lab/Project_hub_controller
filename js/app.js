const $=id=>document.getElementById(id);
const projects=[
{name:"Hassaco Website",client:"Hassaco Tuition Center",progress:72,status:"Development",risk:"medium"},
{name:"TCC Project Hub",client:"TCC",progress:91,status:"Testing",risk:"low"},
{name:"EAMS Portal",client:"Education Management",progress:58,status:"UI/UX",risk:"medium"},
{name:"League Manager",client:"Sports Project",progress:34,status:"Requirements",risk:"high"}
];
const insights=[
["⚠","Resolve 1 high-priority bug","A release blocker is affecting production readiness.","danger"],
["◷","6 tasks are due soon","Review assignments and redistribute work if needed.","warn"],
["✦","Project momentum is strong","TCC Project Hub is 91% complete and ready for QA.","good"],
["●","Meeting preparation needed","Weekly development meeting starts in 30 minutes.","info"]
];
const activity=[
["A","Asha","completed UI review","Hassaco Website","8 min ago"],
["J","John","pushed a new build","TCC Project Hub","21 min ago"],
["M","Mike","reported a bug","Hassaco Website","32 min ago"],
["A","Admin","approved a workflow stage","EAMS Portal","1 hr ago"]
];
function toast(m){$("toast").textContent=m;$("toast").classList.remove("hidden");setTimeout(()=>$("toast").classList.add("hidden"),2500)}
function renderProjects(){
$("projects").innerHTML=projects.map(p=>`<div class="project"><div class="project-top"><div><b>${p.name}</b><small>${p.client}</small></div><span class="risk ${p.risk}">${p.risk}</span></div><div class="bar"><span style="width:${p.progress}%"></span></div><div class="meta"><small>${p.status}</small><small>${p.progress}%</small></div></div>`).join("");
}
function renderInsights(){
$("insights").innerHTML=insights.map(x=>`<div class="insight ${x[3]}"><span>${x[0]}</span><div><b>${x[1]}</b><small>${x[2]}</small></div></div>`).join("");
}
function renderActivity(){
$("activity").innerHTML=activity.map(x=>`<div class="activity"><span class="avatar">${x[0]}</span><div><b>${x[1]} <em>${x[2]}</em></b><small>${x[3]} · ${x[4]}</small></div></div>`).join("");
}
$("theme").onclick=()=>{document.body.classList.toggle("light");localStorage.setItem("control-theme",document.body.classList.contains("light")?"light":"dark")};
if(localStorage.getItem("control-theme")==="light")document.body.classList.add("light");
$("notify").onclick=()=>$("notifyPanel").classList.toggle("hidden");
$("closeNotify").onclick=()=>$("notifyPanel").classList.add("hidden");
$("lang").onclick=()=>{let en=$("lang").textContent==="EN";$("lang").textContent=en?"SW":"EN";toast(en?"Language switched to Swahili preview.":"Language switched to English preview.")};
$("openQA").onclick=()=>toast("QA Center navigation will be connected in final integration.");
renderProjects();renderInsights();renderActivity();
