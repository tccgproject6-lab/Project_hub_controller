const $=id=>document.getElementById(id);
const defaultFiles={
"index.html":`<!doctype html>
<html>
<head><link rel="stylesheet" href="style.css"></head>
<body>
  <main class="card">
    <h1>Hello Team Hub</h1>
    <p>Edit the files and press Run.</p>
    <button onclick="sayHello()">Test JavaScript</button>
  </main>
  <script src="script.js"><\/script>
</body>
</html>`,
"style.css":`body{margin:0;font-family:system-ui;background:#09101c;color:#fff;display:grid;place-items:center;min-height:100vh}.card{padding:30px;border:1px solid #ffffff18;border-radius:18px;background:#111b2c}.card button{padding:10px 14px;border:0;border-radius:9px;background:#6ee7ff}`,
"script.js":`function sayHello(){console.log("Hello from Team Hub Code Studio");alert("JavaScript is running.");}`,
"README.md":"# Project\nEdit source files in Code Studio."
};
let files=JSON.parse(localStorage.getItem("hub-code-files")||"null")||defaultFiles;
let current="index.html";
function toast(x){$("toast").textContent=x;$("toast").classList.remove("hidden");setTimeout(()=>$("toast").classList.add("hidden"),1800)}
function load(){ $("editor").value=files[current]||"";$("tab").textContent=current;document.querySelectorAll(".file").forEach(x=>x.classList.toggle("active",x.dataset.file===current))}
function save(){files[current]=$("editor").value;localStorage.setItem("hub-code-files",JSON.stringify(files));$("saveState").textContent="Saved just now";toast("Saved locally. Connect Supabase for cloud persistence.")}
function build(){
 files[current]=$("editor").value;
 const html=files["index.html"]||"";
 const css=files["style.css"]||"";
 const js=files["script.js"]||"";
 const src=html.replace("</head>",`<style>${css.replace(/<\/style/gi,"")}</style></head>`).replace("</body>",`<script>console.log=(...a)=>parent.postMessage({type:"hub-console",args:a.map(String)},"*");${js.replace(/<\/script/gi,"")}<\/script></body>`);
 const blob=new Blob([src],{type:"text/html"});$("frame").src=URL.createObjectURL(blob);$("saveState").textContent="Preview built";toast("Preview updated");
}
window.addEventListener("message",e=>{if(e.data?.type==="hub-console"){$("logs").textContent+=`\n${e.data.args.join(" ")}`;$("logs").scrollTop=$("logs").scrollHeight}});
document.querySelectorAll(".file").forEach(b=>b.onclick=()=>{files[current]=$("editor").value;current=b.dataset.file;load()});
$("editor").oninput=()=>{$("saveState").textContent="Unsaved changes"};
$("save").onclick=save;$("run").onclick=build;$("refresh").onclick=build;$("clear").onclick=()=>$("logs").textContent="Ready.";
load();build();
