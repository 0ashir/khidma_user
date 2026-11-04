"""Google Play feature graphic (1024x500, 24-bit PNG, no alpha) for Khidma Plus.
Same canvas and type as the phone screenshots; the cards are the real home-screen
components (near_by_provider card, recommended_service card) from gen.py.
Run: python feature.py   -> ../feature_graphic_1024x500.png"""
import os
from pathlib import Path
from kit import *

FEATURE_CSS = """
@font-face{font-family:'Outfit';src:url('fonts/Outfit-Variable.ttf') format('truetype');font-weight:100 900;font-display:block}
*{box-sizing:border-box;margin:0;padding:0}
html,body{width:1024px;height:500px;overflow:hidden}
body{font-family:'Outfit',sans-serif;-webkit-font-smoothing:antialiased;color:#1A1A1A}
.row{display:flex;flex-direction:row} .col{display:flex;flex-direction:column}
.center{align-items:center} .top{align-items:flex-start} .grow{flex:1 1 auto;min-width:0}
.ell{white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.t11{font-size:11px;line-height:1.2} .t12{font-size:12px;line-height:1.25} .t14{font-size:14px;line-height:1.25} .t16{font-size:16px;line-height:1.25}
.w500{font-weight:500} .w600{font-weight:600} .w700{font-weight:700}
.ic{display:inline-block;flex:none;-webkit-mask-size:100% 100%;mask-size:100% 100%;-webkit-mask-repeat:no-repeat}
.dot{width:4px;height:4px;border-radius:50%;background:#EDEDED;flex:none;display:inline-block}
.dash{height:1px;width:100%;flex:none;background:repeating-linear-gradient(90deg,#BFBFBF 0 4px,transparent 4px 8px)}
.add-btn{display:flex;align-items:center;justify-content:center;border-radius:8px;background:#EEEFFF;border:1px solid #5465FF;color:#5465FF;font-size:14px;flex:none}

.canvas{position:relative;width:1024px;height:500px;overflow:hidden;
  background:radial-gradient(90% 120% at 88% 0%,#7B88FF 0%,rgba(123,136,255,0) 60%),
             linear-gradient(160deg,#5F6FFF 0%,#5465FF 40%,#3F4CE6 75%,#2E39C2 100%)}
.blob{position:absolute;border-radius:50%;background:rgba(255,255,255,.07)}
.ring{position:absolute;border-radius:50%;border:2px solid rgba(255,255,255,.10)}
.copy{position:absolute;left:84px;top:0;bottom:0;width:500px;display:flex;flex-direction:column;justify-content:center;color:#fff}
.mark{display:inline-flex;align-self:flex-start;padding:7px 18px;border-radius:999px;background:rgba(255,255,255,.14);
  border:1.5px solid rgba(255,255,255,.22);font-size:20px;font-weight:600;letter-spacing:.3px}
.h1{margin-top:20px;font-size:52px;line-height:1.02;font-weight:700;letter-spacing:-1.1px}
.h1 em{font-style:normal;color:#D9DDFF}
.sub{margin-top:16px;font-size:21px;line-height:1.35;color:rgba(255,255,255,.86)}
.card{position:absolute;transform-origin:center;border-radius:12px;background:#fff;
  box-shadow:0 26px 50px rgba(14,20,90,.38),0 8px 18px rgba(14,20,90,.20)}
"""


def service_card(img, title, price, minutes):
    """recommended_service ServiceCard (gen.service_card)."""
    return f"""<div style="padding:12px;display:flex;flex-direction:column;gap:12px">
  <div class="row top" style="gap:8px">
    <img src="img/{img}" style="width:55px;height:72px;border-radius:4px;object-fit:cover;flex:none">
    <div class="col grow">
      <div class="row"><span class="t14 w500 ell grow">{title}</span>{ic('dr_favorite', 24, ICON1)}</div>
      <div style="height:4px"></div>
      <div class="row center">{ic('users', 16, ICON2)}<span style="width:4px"></span><span class="t12" style="color:{TXT2}">1 Person</span>
        <span style="width:4px"></span><span class="dot"></span><span style="width:4px"></span>
        {ic('clock', 16, ICON2)}<span style="width:4px"></span><span class="t12" style="color:{TXT2}">{minutes} Minutes</span></div>
      <div style="height:8px"></div>
      <div class="row center"><span class="t11" style="color:{TXT2}">By&nbsp;</span><span class="t12" style="text-decoration:underline">bareeq plus</span></div>
    </div></div>
  <div class="dash"></div>
  <div class="row center"><div class="col grow" style="gap:4px"><span class="t14 w600">{price}</span><div style="height:16px"></div></div>
    <div class="add-btn" style="height:32px;padding:0 10px">ADD</div></div></div>"""


PROVIDER = f"""<div style="position:relative">
  <img src="img/s_10.jpg" style="display:block;width:100%;height:150px;object-fit:cover;border-radius:12px 12px 0 0">
  <div style="position:absolute;left:12px;right:12px;bottom:-17px;background:#fff;border-radius:8px;padding:12px;display:flex;align-items:center;gap:12px;box-shadow:0 8px 16px rgba(0,0,0,.06)">
    <img src="img/r_prov5.jpg" style="width:48px;height:48px;border-radius:6px;object-fit:cover;flex:none">
    <div class="col grow" style="gap:4px;min-width:0"><span class="t14 w500 ell">bareeq plus</span>
      <div class="row center" style="gap:4px">
        <div class="row center" style="gap:4px;padding:4px;border-radius:8px;background:{BRAND_SUBTLE}">{ic('map_pin_area', 16, BRAND)}<span class="t12" style="color:{BRAND}">25 km</span></div>
        <span class="dot"></span>{ic('service', 16, ICON2)}<span class="t12" style="color:{TXT2}">25 service</span></div></div></div></div>
<div class="col" style="gap:12px;padding:42px 12px 12px">
  <div class="t12 ell" style="background:{SUCCESS_SUBTLE};border-radius:4px;padding:4px 8px">Next Available : Today, 11:00 PM To 12:00 AM</div>
  <div class="dash"></div>
  <div class="row center" style="gap:16px"><div class="col grow" style="gap:4px"><span class="t12" style="color:{TXT2}">Starting From</span>
    <span class="t14 w600">AED75</span></div>
    <div style="padding:8px;border-radius:50%;background:{BG2};display:flex">{ic('back_arrow_ltr', 20, ICON1)}</div></div></div>"""

html = f"""<!doctype html><html><head><meta charset="utf-8"><style>{FEATURE_CSS}</style></head><body>
<div class="canvas">
  <span class="blob" style="width:420px;height:420px;right:-120px;top:-210px"></span>
  <span class="blob" style="width:300px;height:300px;left:-150px;bottom:-170px"></span>
  <span class="ring" style="width:560px;height:560px;left:380px;top:180px"></span>
  <div class="copy">
    <div class="mark">Khidma Plus</div>
    <div class="h1">Home services,<br><em>right where you are</em></div>
    <div class="sub">Car wash, maids &amp; more from<br>trusted providers near you</div>
  </div>
  <div class="card" style="left:588px;top:52px;width:305px;overflow:hidden;transform:rotate(2deg)">{PROVIDER}</div>
  <div class="card" style="left:660px;top:298px;width:305px;transform:rotate(-2.5deg)">{service_card('r_svc12.jpg', 'deep wash salon', 'AED249', 90)}</div>
</div></body></html>"""

if __name__ == "__main__":
    import sys
    sys.path.insert(0, HERE)
    src = Path(HERE) / "feature.html"
    src.write_text(html, encoding="utf-8")
    from render_feature import render
    render(src, Path(HERE).parent / "feature_graphic_1024x500.png")
