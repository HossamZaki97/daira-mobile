"""Frame raw app screenshots into App Store images, ar/en:
iPhone 6.9" (1320x2868) and, with --ipad, iPad Pro 12.9"/13" (2048x2732).

    flutter test test/store --dart-define=STORE_SHOTS=true
    python tool/appstore_frames.py            # build/store_shots -> design/store/appstore-screenshots

    flutter test test/store --dart-define=STORE_SHOTS=true --dart-define=STORE_DEVICE=ipad
    python tool/appstore_frames.py --ipad     # build/store_shots_ipad -> design/store/ipad-screenshots

Same slides and look as tool/store_frames.py (Play), with an iPhone frame:
Dynamic Island, iOS status bar and home indicator. Output is RGB (no alpha), as App Store Connect wants.
Needs Python 3 with `playwright` (Chromium) and Pillow.
"""
import io
import pathlib
import sys

from PIL import Image
from playwright.sync_api import sync_playwright

from store_frames import AMBER, FONTS, NAVY, ROOT, SLIDES, _data_uri, _ring

SHOTS = ROOT / 'build' / 'store_shots'
OUT = ROOT / 'design' / 'store' / 'appstore-screenshots'

W, H = 1320, 2868
SCREEN_W = 974                      # 390 pt wide
PT = SCREEN_W / 390                 # pixels per iPhone point
SCREEN_H = round(844 * PT)          # a 390x844 pt iPhone screen
STATUS_H = round(47 * PT)           # iOS status bar over the app
BEZEL = 18
PHONE_TOP = 640

# iOS-style status icons (generic shapes), drawn in the app's ink colour.
STATUS_ICONS = f"""
<svg width="{round(17 * PT)}" height="{round(11 * PT)}" viewBox="0 0 66 30" fill="{NAVY}">
  <rect x="0" y="20" width="12" height="10" rx="2"/><rect x="18" y="14" width="12" height="16" rx="2"/>
  <rect x="36" y="7" width="12" height="23" rx="2"/><rect x="54" y="0" width="12" height="30" rx="2"/>
</svg>
<svg width="{round(17 * PT)}" height="{round(12 * PT)}" viewBox="0 0 34 24" fill="none" stroke="{NAVY}" stroke-width="4.2" stroke-linecap="round">
  <path d="M3 8.5a20 20 0 0 1 28 0"/><path d="M8.5 14a12 12 0 0 1 17 0"/><circle cx="17" cy="20" r="2.6" fill="{NAVY}" stroke="none"/>
</svg>
<svg width="{round(27 * PT)}" height="{round(13 * PT)}" viewBox="0 0 54 26">
  <rect x="1.5" y="1.5" width="45" height="23" rx="7" fill="none" stroke="{NAVY}" stroke-opacity=".4" stroke-width="3"/>
  <rect x="5.5" y="5.5" width="37" height="15" rx="4" fill="{NAVY}"/>
  <path d="M50 9v8a4 4 0 0 0 0-8z" fill="{NAVY}" fill-opacity=".4"/>
</svg>"""


def _screen(shot: pathlib.Path) -> tuple[str, str]:
    """The shot scaled to the screen width. The test leaves the status bar and home indicator areas clear."""
    im = Image.open(shot).convert('RGB')
    bar = '#%02x%02x%02x' % im.getpixel((4, 4))
    im = im.resize((SCREEN_W, round(im.height * SCREEN_W / im.width)), Image.LANCZOS)
    im = im.crop((0, 0, SCREEN_W, min(im.height, SCREEN_H)))
    buf = io.BytesIO()
    im.save(buf, 'PNG')
    import base64
    return 'data:image/png;base64,' + base64.b64encode(buf.getvalue()).decode(), bar


def _page(shot: pathlib.Path, lang: str, title: str, line: str) -> str:
    rtl = lang == 'ar'
    src, bar = _screen(shot)
    fonts = ''.join(
        f"@font-face{{font-family:Cairo;font-weight:{w};src:url({_data_uri(FONTS / f, 'font/ttf')})}}"
        for f, w in [('Cairo-Regular.ttf', 400), ('Cairo-SemiBold.ttf', 600), ('Cairo-Bold.ttf', 700)])
    pw, ph = SCREEN_W + 2 * BEZEL, SCREEN_H + 2 * BEZEL
    return f"""<!doctype html><html lang="{lang}"><head><meta charset="utf-8"><style>
{fonts}
*{{margin:0;box-sizing:border-box}}
html{{overflow:hidden}}
body{{width:{W}px;height:{H}px;overflow:hidden;font-family:Cairo,sans-serif;
  background:radial-gradient(120% 70% at 50% 0%, #2B3A63 0%, {NAVY} 55%, #141C33 100%);position:relative}}
.ring{{position:absolute;top:-200px;{'left' if rtl else 'right'}:-240px;transform:rotate({'-20' if rtl else '20'}deg)}}
.text{{position:absolute;top:168px;left:110px;right:110px;text-align:center;color:#fff}}
.dot{{width:78px;height:10px;border-radius:5px;background:{AMBER};margin:0 auto 40px}}
h1{{font-size:{94 if rtl else 86}px;font-weight:700;line-height:1.22}}
p{{margin-top:24px;font-size:44px;font-weight:400;line-height:1.5;color:rgba(255,255,255,.74)}}
.phone{{position:absolute;top:{PHONE_TOP}px;left:50%;width:{pw}px;height:{ph}px;transform:translateX(-50%);
  background:#0B1020;border-radius:{round(55 * PT) + BEZEL}px;padding:{BEZEL}px;
  box-shadow:0 60px 140px rgba(0,0,0,.5),0 0 0 4px #3A4460 inset,0 0 0 7px #0B1020 inset}}
.btn{{position:absolute;width:9px;background:#2A3350;border-radius:4px}}
.screen{{position:relative;width:{SCREEN_W}px;height:{SCREEN_H}px;border-radius:{round(55 * PT)}px;overflow:hidden;background:{bar}}}
.status{{position:absolute;top:0;left:0;right:0;z-index:1;height:{STATUS_H}px;display:flex;align-items:center;justify-content:space-between;
  padding:0 {round(30 * PT)}px 0 {round(38 * PT)}px;direction:ltr}}
.time{{font:600 {round(17 * PT)}px -apple-system,'Helvetica Neue',Arial,sans-serif;color:{NAVY};letter-spacing:-.5px}}
.icons{{display:flex;gap:{round(6 * PT)}px;align-items:center}}
.island{{z-index:2;position:absolute;left:50%;top:{round(11 * PT)}px;width:{round(125 * PT)}px;height:{round(37 * PT)}px;
  transform:translateX(-50%);background:#000;border-radius:{round(19 * PT)}px}}
.screen img{{display:block;width:{SCREEN_W}px}}
.home{{z-index:2;position:absolute;left:50%;bottom:{round(8 * PT)}px;width:{round(134 * PT)}px;height:{round(5 * PT)}px;
  transform:translateX(-50%);background:{NAVY};border-radius:9px}}
</style></head><body>
<div class="ring">{_ring(900)}</div>
<div class="text" dir="{'rtl' if rtl else 'ltr'}"><div class="dot"></div><h1>{title}</h1><p>{line}</p></div>
<div class="phone">
  <div class="btn" style="left:-8px;top:{round(0.17 * ph)}px;height:{round(0.04 * ph)}px"></div>
  <div class="btn" style="left:-8px;top:{round(0.24 * ph)}px;height:{round(0.08 * ph)}px"></div>
  <div class="btn" style="left:-8px;top:{round(0.34 * ph)}px;height:{round(0.08 * ph)}px"></div>
  <div class="btn" style="right:-8px;top:{round(0.27 * ph)}px;height:{round(0.12 * ph)}px"></div>
  <div class="screen">
    <div class="status"><span class="time">9:41</span><div class="icons">{STATUS_ICONS}</div></div>
    <div class="island"></div>
    <img src="{src}">
    <div class="home"></div>
  </div>
</div>
</body></html>"""


# On the iPad the circle page fits without scrolling, so its «payments» shot equals «circle»:
# the iPad set shows adding members instead.
IPAD_MEMBERS = ('create_members', 'ضيف الأعضاء بسهولة', 'بالاسم أو برقم الموبايل، واللي مش على دايرة تدعوه على واتساب',
                'Add members your way', 'By name or phone number; invite anyone not on Daira on WhatsApp')

# iPad Pro 12.9" (1024x1366 pt). The app fills the iPad screen, under an iPadOS status bar.
IW, IH = 2048, 2732
I_SCREEN_W = 1520
IPT = I_SCREEN_W / 1024
I_SCREEN_H = round(1366 * IPT)
I_STATUS_H = round(24 * IPT)
I_BEZEL = 44
I_TOP = 572


def _page_ipad(shot: pathlib.Path, lang: str, title: str, line: str) -> str:
    rtl = lang == 'ar'
    im = Image.open(shot).convert('RGB')
    bar = '#%02x%02x%02x' % im.getpixel((4, 4))
    im = im.resize((I_SCREEN_W, round(im.height * I_SCREEN_W / im.width)), Image.LANCZOS)
    im = im.crop((0, 0, I_SCREEN_W, min(im.height, I_SCREEN_H)))
    buf = io.BytesIO()
    im.save(buf, 'PNG')
    import base64
    src = 'data:image/png;base64,' + base64.b64encode(buf.getvalue()).decode()
    fonts = ''.join(
        f"@font-face{{font-family:Cairo;font-weight:{w};src:url({_data_uri(FONTS / f, 'font/ttf')})}}"
        for f, w in [('Cairo-Regular.ttf', 400), ('Cairo-SemiBold.ttf', 600), ('Cairo-Bold.ttf', 700)])
    icons = STATUS_ICONS.split('</svg>')
    wifi_battery = '</svg>'.join(icons[1:3]) + '</svg>'
    pw, ph = I_SCREEN_W + 2 * I_BEZEL, I_SCREEN_H + 2 * I_BEZEL
    return f"""<!doctype html><html lang="{lang}"><head><meta charset="utf-8"><style>
{fonts}
*{{margin:0;box-sizing:border-box}}
html{{overflow:hidden}}
body{{width:{IW}px;height:{IH}px;overflow:hidden;font-family:Cairo,sans-serif;
  background:radial-gradient(120% 70% at 50% 0%, #2B3A63 0%, {NAVY} 55%, #141C33 100%);position:relative}}
.ring{{position:absolute;top:-220px;{'left' if rtl else 'right'}:-260px;transform:rotate({'-20' if rtl else '20'}deg)}}
.text{{position:absolute;top:150px;left:160px;right:160px;text-align:center;color:#fff}}
.dot{{width:84px;height:10px;border-radius:5px;background:{AMBER};margin:0 auto 36px}}
h1{{font-size:{100 if rtl else 92}px;font-weight:700;line-height:1.2}}
p{{margin-top:18px;font-size:48px;font-weight:400;line-height:1.5;color:rgba(255,255,255,.74)}}
.pad{{position:absolute;top:{I_TOP}px;left:50%;width:{pw}px;height:{ph}px;transform:translateX(-50%);
  background:#0B1020;border-radius:{round(18 * IPT) + I_BEZEL}px;padding:{I_BEZEL}px;
  box-shadow:0 60px 140px rgba(0,0,0,.5),0 0 0 4px #3A4460 inset,0 0 0 8px #0B1020 inset}}
.cam{{position:absolute;left:50%;top:{I_BEZEL // 2 - 6}px;width:12px;height:12px;border-radius:50%;background:#2A3350;transform:translateX(-50%)}}
.screen{{position:relative;width:{I_SCREEN_W}px;height:{I_SCREEN_H}px;border-radius:{round(18 * IPT)}px;overflow:hidden;background:{bar}}}
.status{{position:absolute;top:0;left:0;right:0;z-index:1;height:{I_STATUS_H}px;display:flex;align-items:center;justify-content:space-between;
  padding:0 {round(20 * IPT)}px;direction:ltr;font:600 {round(13 * IPT)}px -apple-system,'Helvetica Neue',Arial,sans-serif;color:{NAVY}}}
.status svg{{height:{round(10 * IPT)}px;width:auto}}
.icons{{display:flex;gap:{round(6 * IPT)}px;align-items:center}}
.screen img{{display:block;width:{I_SCREEN_W}px}}
.home{{z-index:2;position:absolute;left:50%;bottom:{round(6 * IPT)}px;width:{round(200 * IPT)}px;height:{round(5 * IPT)}px;
  transform:translateX(-50%);background:{NAVY};border-radius:9px}}
</style></head><body>
<div class="ring">{_ring(1000)}</div>
<div class="text" dir="{'rtl' if rtl else 'ltr'}"><div class="dot"></div><h1>{title}</h1><p>{line}</p></div>
<div class="pad"><div class="cam"></div>
  <div class="screen">
    <div class="status"><span>9:41&nbsp;&nbsp;Tue Jan 9</span><div class="icons">{wifi_battery}</div></div>
    <img src="{src}">
    <div class="home"></div>
  </div>
</div>
</body></html>"""


def main() -> int:
    ipad = '--ipad' in sys.argv
    args = [a for a in sys.argv[1:] if a != '--ipad']
    shots = pathlib.Path(args[0]) if args else ROOT / 'build' / ('store_shots_ipad' if ipad else 'store_shots')
    out_root = ROOT / 'design' / 'store' / ('ipad-screenshots' if ipad else 'appstore-screenshots')
    w, h, page_of = (IW, IH, _page_ipad) if ipad else (W, H, _page)
    slides = [IPAD_MEMBERS if ipad and s[0] == 'circle' else s for s in SLIDES]
    missing = [f'{lang}/{name}' for lang in ('ar', 'en') for name, *_ in slides
               if not (shots / lang / f'{name}.png').exists()]
    if missing:
        print('Missing raw screenshots (run the store test first):', ', '.join(missing))
        return 1
    with sync_playwright() as pw:
        browser = pw.chromium.launch()
        page = browser.new_page(viewport={'width': w, 'height': h}, device_scale_factor=1)
        for lang in ('ar', 'en'):
            out = out_root / lang
            out.mkdir(parents=True, exist_ok=True)
            for i, (name, ar_t, ar_l, en_t, en_l) in enumerate(slides, 1):
                title, line = (ar_t, ar_l) if lang == 'ar' else (en_t, en_l)
                page.set_content(page_of(shots / lang / f'{name}.png', lang, title, line))
                page.wait_for_timeout(150)
                target = out / f'{i:02d}-{name}.png'
                Image.open(io.BytesIO(page.screenshot())).convert('RGB').save(target)
                print('wrote', target.relative_to(ROOT))
        browser.close()
    return 0


if __name__ == '__main__':
    sys.exit(main())
