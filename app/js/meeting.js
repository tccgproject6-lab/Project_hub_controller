const local=document.getElementById("local"),state=document.getElementById("meetingState");let stream=null;
async function start(){
 try{stream=await navigator.mediaDevices.getUserMedia({video:true,audio:true});local.srcObject=stream;state.textContent="Camera and microphone ready";}catch(e){state.textContent="Media permission required: "+e.message}
}
document.getElementById("mic").onclick=()=>{if(stream)stream.getAudioTracks().forEach(t=>t.enabled=!t.enabled)};
document.getElementById("camera").onclick=()=>{if(stream)stream.getVideoTracks().forEach(t=>t.enabled=!t.enabled)};
document.getElementById("share").onclick=async()=>{try{const s=await navigator.mediaDevices.getDisplayMedia({video:true});local.srcObject=s;s.getVideoTracks()[0].onended=()=>{if(stream)local.srcObject=stream}}catch(e){}};
document.getElementById("invite").onclick=async()=>{await navigator.clipboard?.writeText(location.href);state.textContent="Meeting invite copied"};
document.getElementById("leave").onclick=()=>{stream?.getTracks().forEach(t=>t.stop());location.href="chat.html"};
start();
