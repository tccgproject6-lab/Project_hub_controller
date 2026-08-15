const roomsEl=document.getElementById("rooms"),messages=document.getElementById("messages"),input=document.getElementById("message"),typing=document.getElementById("typing");
let room="general",channel=null,user=null,typingTimer=null;
const rooms=[["general","General"],["development","Development"],["design","Design"],["qa","QA"]];
function toast(x){const t=document.getElementById("toast");t.textContent=x;t.classList.remove("hidden");setTimeout(()=>t.classList.add("hidden"),2200)}
function renderRooms(){roomsEl.innerHTML=rooms.map(r=>`<button class="room ${r[0]===room?"active":""}" data-room="${r[0]}"># ${r[1]}<small>Realtime</small></button>`).join("");document.querySelectorAll(".room").forEach(b=>b.onclick=()=>switchRoom(b.dataset.room))}
function add(m,own=false,read=false){const e=document.createElement("div");e.className="bubble "+(own?"own":"");e.innerHTML=`<b>${esc(m.body||"")}</b><small>${m.created_at?new Date(m.created_at).toLocaleTimeString([], {hour:"2-digit",minute:"2-digit"}):"now"} ${own?(read?"✓✓":"✓"):""}</small>`;messages.appendChild(e);messages.scrollTop=messages.scrollHeight}
async function switchRoom(r){room=r;messages.innerHTML="";typing.textContent="";renderRooms();document.getElementById("roomTitle").textContent=rooms.find(x=>x[0]===room)[1];if(!RT.client||!user){add({body:"Configure Supabase and sign in to enable realtime chat."});return}
 if(channel)await RT.client.removeChannel(channel);
 const {data}=await RT.client.from("chat_messages").select("id,user_id,body,created_at").eq("room_id",room).order("created_at",{ascending:true}).limit(100);
 (data||[]).forEach(m=>add(m,m.user_id===user.id,false));
 channel=RT.client.channel("room:"+room)
 .on("postgres_changes",{event:"INSERT",schema:"public",table:"chat_messages",filter:"room_id=eq."+room},p=>{if(p.new.user_id!==user.id)add(p.new,false,false)})
 .on("broadcast",{event:"typing"},p=>{if(p.payload.user_id!==user.id){typing.textContent=`${p.payload.name||"Someone"} is typing…`;clearTimeout(typingTimer);typingTimer=setTimeout(()=>typing.textContent="",1600)}})
 .on("postgres_changes",{event:"UPDATE",schema:"public",table:"chat_message_reads"},p=>{if(p.new.user_id===user.id){}});
 await channel.subscribe();
}
document.getElementById("composer").onsubmit=async e=>{e.preventDefault();const body=input.value.trim();if(!body)return;if(!RT.client||!user){add({body},true,false);input.value="";return}
 const {error}=await RT.client.from("chat_messages").insert({room_id:room,user_id:user.id,body});if(error)toast(error.message);else input.value="";
};
input.oninput=()=>{if(channel&&user)channel.send({type:"broadcast",event:"typing",payload:{user_id:user.id,name:user.user_metadata?.full_name||user.email?.split("@")[0]||"Member"}})};
document.getElementById("attach").onclick=()=>document.getElementById("file").click();
document.getElementById("file").onchange=()=>{if(document.getElementById("file").files[0])toast("Attachment selected. Upload it through Supabase Storage after bucket permissions are configured.")};
document.getElementById("call").onclick=()=>location.href="meeting.html?room="+encodeURIComponent(room);
(async()=>{renderRooms();user=await auth();document.getElementById("presence").textContent=RT.client?"Realtime ready":"Setup mode";await switchRoom(room)})();
