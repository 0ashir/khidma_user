"""Renders a 1024x500 feature graphic HTML file to a 24-bit PNG (RGB, no alpha)."""
from playwright.sync_api import sync_playwright
from PIL import Image


def render(html, dest):
    with sync_playwright() as p:
        try:
            browser = p.chromium.launch(channel="chrome")
        except Exception:
            browser = p.chromium.launch()
        page = browser.new_page(viewport={"width": 1024, "height": 500}, device_scale_factor=1)
        page.goto(html.as_uri(), wait_until="networkidle")
        page.evaluate("document.fonts.ready")
        if not page.evaluate("document.fonts.check('600 16px Outfit')"):
            raise SystemExit("Outfit font did not load")
        missing = page.evaluate("Array.from(document.images).filter(i=>!i.complete||!i.naturalWidth).map(i=>i.src)")
        if missing:
            raise SystemExit(f"missing images {missing}")
        page.screenshot(path=str(dest))
        browser.close()
    Image.open(dest).convert("RGB").save(dest)
    with Image.open(dest) as v:
        assert v.size == (1024, 500) and v.mode == "RGB", (v.size, v.mode)
    print("rendered", dest, "1024x500 RGB")
