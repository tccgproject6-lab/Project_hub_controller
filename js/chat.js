const $=id=>document.getElementById(id);let active=null;let demoConvos=[
{id:"team",name:"Development Team",type:"group",status:"8 members",avatar:"D",messages:[["Asha","Frontend build is ready for review.","10:32"],["You","Great. I'll check the responsive version.","10:34"],["John","API endpoint is also ready.","10:36"]]},
{id:"john",name:"John Mwangi",type:"direct",status:"Online",avatar:"J",messages:[["John","Can you review the login flow?","09:48"],["You","Yes, sending feedback shortly.","09:51"]]},
{id:"asha",name:"Asha Hassan",type:"direct",status:"Online",avatar:"A",messages:[["Asha","I uploaded the latest UI revision.","Yesterday"]]},
{id:"project",name:"Hassaco Website",type:"group",status:"Project group · 6 members",avatar:"H",messages:[["Admin","Development milestone starts today.","Mon"]]}
];
function toast(m){$("toast").textContent=m;$("toast").classList.remove("hidden");setTimeout(()=>$("toast").classList.add("hidden"),2400)}
function renderList(filter=""){let data=demoConvos.filter(x=>x.name.toLowerCase().includes(filter.toLowerCase()));$("conversationList").innerHTML=data.map(x=>`<button class="conv ${active===x.id?"active":""}" data-id="${x.id}"><span class="avatar">${x.avatar}</span><span><b>${x.name}</b><small>${x.messages.at(-1)?.[1]||"No messages"}</small></span><i>${x.messages.at(-1)?.[2]||""}</i></button>`).join("");document.querySelectorAll(".conv").forEach(b=>b.onclick=()=>openConversation(b.dataset.id))}
function openConversation(id){active=id;let c=demoConvos.find(x=>x.id===id);$("chatName").textContent=c.name;$("chatStatus").textContent=c.status;$("chatAvatar").textContent=c.avatar;$("messageInput").disabled=false;$("messageInput").placeholder="Message "+c.name+"…";$("messages").innerHTML=c.messages.map(m=>`<div class="msg ${m[0]==="You"?"mine":""}"><div><b>${m[0]}</b><p>${escapeHtml(m[1])}</p><small>${m[2]} ✓✓</small></div></div>`).join("");$("messages").scrollTop=$("messages").scrollHeight;renderList($("search").value)}
function escapeHtml(s){return s.replace(/[&<>"']/g,c=>({"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#039;"}[c]))}
$("messageForm").onsubmit=e=>{e.preventDefault();if(!active)return;let text=$("messageInput").value.trim();if(!text)return;let c=demoConvos.find(x=>x.id===active);c.messages.push(["You",text,new Date().toLocaleTimeString([], {hour:"2-digit",minute:"2-digit"})]);$("messageInput").value="";openConversation(active);toast("Message sent");if(!CHAT_DEMO)sendRealtimeMessage(text)};
$("search").oninput=e=>renderList(e.target.value);
$("newGroup").onclick=()=>$("groupModal").classList.remove("hidden");$("close").onclick=()=>$("groupModal").classList.add("hidden");
$("groupForm").onsubmit=e=>{e.preventDefault();let name=$("groupName").value.trim();demoConvos.unshift({id:"g"+Date.now(),name,type:"group",status:"New group",avatar:name[0].toUpperCase(),messages:[]});$("groupModal").classList.add("hidden");e.target.reset();renderList();toast("Group created")};
$("theme").onclick=()=>{document.body.classList.toggle("light");localStorage.setItem("chat-theme",document.body.classList.contains("light")?"light":"dark")};if(localStorage.getItem("chat-theme")==="light")document.body.classList.add("light");
function sendRealtimeMessage(text){/* Phase 5 database hook is in supabase/chat_schema.sql. */}
// Demo fallback is intentional until Supabase credentials are configured.
renderList();openConversation("team");
