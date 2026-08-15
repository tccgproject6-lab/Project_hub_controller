const $=id=>document.getElementById(id);
const checks=[
["Lint & formatting","Passed","green"],["Unit tests","Passed · 128/128","green"],["Integration tests","Passed · 46/46","green"],
["Security/RLS","Passed","green"],["Build","Passed","green"],["E2E smoke","Passed","green"],["Accessibility","Passed","green"],["Performance","Warning · 1 budget","yellow"]
];
const stages=["Checkout","Install","Lint","Unit tests","Build","Deploy staging","Smoke test","Approval"];
const releases=[["v1.8.0","staging","94%","Just now"],["v1.7.2","production","100%","Yesterday"],["v1.7.1","production","100%","3 days ago"]];
function toast(x){$("toast").textContent=x;$("toast").classList.remove("hidden");setTimeout(()=>$("toast").classList.add("hidden"),2200)}
$("checks").innerHTML=checks.map(x=>`<div class="row"><div><b>${x[0]}</b><small>${x[1]}</small></div><span class="${x[2]}">${x[2]==="green"?"✓":"!"}</span></div>`).join("");
$("pipeline").innerHTML=stages.map((x,i)=>`<div class="stage"><span>${i<7?"✓":i+1}</span><b>${x}</b></div>`).join("");
$("releases").innerHTML=releases.map(r=>`<div class="release"><div><b>${r[0]}</b><small>${r[1]} · ${r[3]}</small></div><strong>${r[2]}</strong></div>`).join("");
$("deploy").onclick=()=>toast("Production approval must be authorized server-side and should trigger the CI/CD workflow.");
$("rollback").onclick=()=>toast("Rollback request created. Production rollback must run through the protected CI/CD pipeline.");
