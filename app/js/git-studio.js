const $=id=>document.getElementById(id);
let branch="main",dirty=true;
const commits=[
{id:"a91f2c4",msg:"Improve responsive dashboard",author:"Asha",time:"Today 18:42"},
{id:"61bc8de",msg:"Add project health cards",author:"Ally",time:"Today 15:10"},
{id:"e8a4c21",msg:"Create Team Hub navigation",author:"John",time:"Yesterday"}
];
const changes=[
["app/index.html","Modified","+18 -6"],
["app/css/app.css","Modified","+42 -11"],
["app/js/app.js","Modified","+27 -9"],
["README.md","Modified","+6 -1"]
];
function toast(x){$("toast").textContent=x;$("toast").classList.remove("hidden");setTimeout(()=>$("toast").classList.add("hidden"),2200)}
function render(){
 $("history").innerHTML=commits.map(c=>`<button class="commitRow" data-id="${c.id}"><b>${c.msg}</b><small>${c.id} · ${c.author} · ${c.time}</small></button>`).join("");
 $("files").innerHTML=changes.map(c=>`<button class="change"><span class="dot"></span><div><b>${c[0]}</b><small>${c[1]}</small></div><em>${c[2]}</em></button>`).join("");
 $("state").textContent=dirty?"4 files changed":"Working tree clean";
}
document.querySelectorAll(".branchBtn").forEach(b=>b.onclick=()=>{document.querySelectorAll(".branchBtn").forEach(x=>x.classList.remove("active"));b.classList.add("active");branch=b.firstChild.textContent.trim();toast("Switched to "+branch)});
$("commit").onclick=()=>{if(!dirty){toast("Nothing to commit");return}commits.unshift({id:Math.random().toString(16).slice(2,9),msg:"Update project files",author:"You",time:"Just now"});dirty=false;render();toast("Commit created locally. Connect Git provider API for server-side push.")};
$("push").onclick=()=>toast("Push requires a server-side Git provider integration and secure OAuth token.");
$("newBranch").onclick=()=>{const n=prompt("Branch name");if(n){toast("Branch '"+n+"' created in UI. Persist it through the Git integration.");}};
document.addEventListener("click",e=>{const b=e.target.closest(".commitRow");if(b){const c=commits.find(x=>x.id===b.dataset.id);$("diffText").textContent=`commit ${c.id}\nAuthor: ${c.author}\nDate: ${c.time}\n\n    ${c.msg}\n\n+ dashboard improvements\n+ workflow updates\n- obsolete markup`;}}});
render();
