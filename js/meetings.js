const $=id=>document.getElementById(id);
let meetings=[
{id:"m1",title:"Weekly Development Meeting",project:"Hassaco Website",date:"2026-08-18",time:"10:00",type:"team",participants:8},
{id:"m2",title:"Client UI Review",project:"Hassaco Website",date:"2026-08-19",time:"14:00",type:"review",participants:5}
];
let stream=null,screenStream=null,mic=true,cam=true,chat=[];
function toast(m){$("toast").textContent=m;$("toast").classList.remove("hidden");setTimeout(()=>$("toast").classList.add("hidden"),2500)}
function renderMeetings(){
 $("meetingList").innerHTML=meetings.map(m=>`<article class="meeting glass">
 <div class="date"><b>${new Date(m.date+"T00:00:00").getDate()}</b><small>${new Date(m.date+"T00:00:00").toLocaleString("en",{month:"short"}).toUpperCase()}</small></div>
 <div class="meeting-info"><div class="eyebrow">${m.type.toUpperCase()}</div><h3>${m.title}</h3><p>${m.project||"Team workspace"} · ${m.time} · ${m.participants} participants</p></div>
 <div class="meeting-actions"><button class="join" data-id="${m.id}">Join</button><button class="more">⋮</button></div>
 </article>`).join("");
 document.querySelectorAll(".join").forEach(b=>b.onclick=()=>joinMeeting(b.dataset.id));
}
async function joinMeeting(id){
 const m=meetings.find(x=>x.id===id);
 $("roomTitle").textContent=m.title;$("roomMeta").textContent="1 participant · waiting for others";
 $("room").classList.remove("hidden");$("meetingList").classList.add("hidden");
 try{
   stream=await navigator.mediaDevices.getUserMedia({video:true,audio:true});
   $("localVideo").srcObject=stream;
   toast("Camera and microphone connected.");
 }catch(e){
   toast("Camera/microphone permission was not granted. You can still use the meeting room.");
 }
 renderParticipants();
}
function renderParticipants(){
 $("participants").innerHTML=["Asha","John","Mike"].map((x,i)=>`<div class="tile"><div class="fake-avatar">${x[0]}</div><span>${x}${i===0?" · muted":""}</span></div>`).join("");
 $("roomMeta").textContent="4 participants";
}
$("createBtn").onclick=()=>$("modal").classList.remove("hidden");
$("closeBtn").onclick=()=>$("modal").classList.add("hidden");
$("meetingForm").onsubmit=e=>{
 e.preventDefault();meetings.unshift({id:"m"+Date.now(),title:$("mTitle").value,project:$("mProject").value,date:$("mDate").value,time:$("mTime").value,type:$("mType").value,participants:1});
 $("modal").classList.add("hidden");e.target.reset();renderMeetings();toast("Meeting scheduled.");
};
$("micBtn").onclick=()=>{
 mic=!mic;if(stream)stream.getAudioTracks().forEach(t=>t.enabled=mic);
 $("micBtn").textContent=mic?"🎙 Mic":"🔇 Muted";
};
$("camBtn").onclick=()=>{
 cam=!cam;if(stream)stream.getVideoTracks().forEach(t=>t.enabled=cam);
 $("camBtn").textContent=cam?"📹 Camera":"🚫 Camera off";
};
$("shareBtn").onclick=async()=>{
 try{
   if(screenStream){screenStream.getTracks().forEach(t=>t.stop());screenStream=null;$("screenBadge").classList.add("hidden");$("shareBtn").textContent="🖥 Share screen";return}
   screenStream=await navigator.mediaDevices.getDisplayMedia({video:true});
   const track=screenStream.getVideoTracks()[0];
   $("screenBadge").classList.remove("hidden");$("shareBtn").textContent="⏹ Stop sharing";
   track.onended=()=>{screenStream=null;$("screenBadge").classList.add("hidden");$("shareBtn").textContent="🖥 Share screen"};
   toast("Screen sharing started.");
 }catch(e){toast("Screen sharing was cancelled or blocked.");}
};
$("chatBtn").onclick=()=>$("meetingChat").classList.toggle("hidden");
$("peopleBtn").onclick=()=>toast("Participant panel is open in the meeting room.");
$("endBtn").onclick=()=>{
 if(stream)stream.getTracks().forEach(t=>t.stop());
 if(screenStream)screenStream.getTracks().forEach(t=>t.stop());
 stream=null;screenStream=null;$("room").classList.add("hidden");$("meetingList").classList.remove("hidden");toast("Meeting ended.");
};
$("chatForm").onsubmit=e=>{
 e.preventDefault();let text=$("chatInput").value.trim();if(!text)return;
 chat.push({name:"You",text,time:new Date().toLocaleTimeString([],{hour:"2-digit",minute:"2-digit"})});
 $("chatMessages").innerHTML=chat.map(x=>`<div><b>${x.name}</b><p>${x.text}</p><small>${x.time}</small></div>`).join("");
 $("chatInput").value="";
};
$("theme").onclick=()=>{document.body.classList.toggle("light");localStorage.setItem("meeting-theme",document.body.classList.contains("light")?"light":"dark")};
if(localStorage.getItem("meeting-theme")==="light")document.body.classList.add("light");
renderMeetings();
