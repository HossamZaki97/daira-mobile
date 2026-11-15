"""Frame raw app screenshots into store images (1080x1920, ar/en).

Input:  build/store_shots/<lang>/<name>.png   (from test/store/store_screenshots_test.dart)
Output: design/store/screenshots/<lang>/<nn>-<name>.png

    python tool/store_frames.py

Needs Python 3 with `playwright` (Chromium) and Pillow.
"""
import base64
import pathlib
import sys

from PIL import Image
from playwright.sync_api import sync_playwright

ROOT = pathlib.Path(__file__).resolve().parent.parent
SHOTS = ROOT / 'build' / 'store_shots'
OUT = ROOT / 'design' / 'store' / 'screenshots'
FONTS = ROOT / 'assets' / 'fonts'

NAVY, AMBER = '#1E2A4A', '#F0A202'

# Order on the store page. (screen, Arabic headline, Arabic line, English headline, English line)
SLIDES = [
    ('home', 'كل اللي عليك.. قدامك', 'دورك الجاي، والأقساط المطلوبة منك، في شاشة واحدة',
     'Know what to do next', 'Your next turn and what you owe, on one screen'),
    ('payments', 'أكّد الأقساط بضغطة', 'المنظّم يشوف مين دفع ويأكّد أو يرفض بسبب',
     'Confirm payments in one tap', 'Organizers see who paid and confirm or decline'),
    ('circle', 'كل دور واضح', 'المبلغ المجمّع، والمتبقي، ومين عليه الدور',
     'Every round, crystal clear', 'Collected, remaining, and whose turn it is'),
    ('create_order', 'رتّبوا الأدوار براحتكم', 'اعمل الجمعية في دقيقة وحدد ترتيب القبض',
     'Set the turn order your way', 'Create a circle in a minute and order the payouts'),
    ('notifications', 'تنبيه في وقته', 'تذكير قبل ميعاد القسط وإشعار عند كل تأكيد',
     'Reminders right on time', 'Before each due date and after every confirmation'),
    ('activity', 'سجل لكل حركة', 'كل دفعة وتأكيد وتسليم متسجل بالوقت والاسم',
     'A record of every step', 'Every payment, confirmation and payout, logged'),
    ('circles', 'كل جمعياتك في مكان واحد', 'العائلة، الشغل، الأصحاب.. وتابع التقدم',
     'All your circles together', 'Family, work, friends: progress at a glance'),
]

# Ring segments of the Daira mark (A2), used as a faint background motif.
SEGMENTS = 7


def _data_uri(path: pathlib.Path, mime: str) -> str:
    return f'data:{mime};base64,{base64.b64encode(path.read_bytes()).decode()}'


def _ring(size: int) -> str:
    import math
    cx = cy = size / 2
    r_out, r_in = size * 0.47, size * 0.28
    gap = math.radians(3.6)
    parts = []
    for i in range(SEGMENTS):
        a0 = -math.pi / 2 + i * 2 * math.pi / SEGMENTS + gap
        a1 = -math.pi / 2 + (i + 1) * 2 * math.pi / SEGMENTS - gap
        p = lambda r, a: f'{cx + r * math.cos(a):.1f},{cy + r * math.sin(a):.1f}'
        color = AMBER if i == 0 else '#FFFFFF'
        opacity = 0.9 if i == 0 else 0.06
        parts.append(
            f'<path d="M{p(r_out, a0)} A{r_out:.1f},{r_out:.1f} 0 0 1 {p(r_out, a1)} '
            f'L{p(r_in, a1)} A{r_in:.1f},{r_in:.1f} 0 0 0 {p(r_in, a0)} Z" fill="{color}" fill-opacity="{opacity}"/>')
    return f'<svg width="{size}" height="{size}" viewBox="0 0 {size} {size}">{"".join(parts)}</svg>'


def _page(shot: pathlib.Path, lang: str, title: str, line: str) -> str:
    rtl = lang == 'ar'
    top = Image.open(shot).convert('RGB').getpixel((4, 4))
    bar = '#%02x%02x%02x' % top
    fonts = ''.join(
        f"@font-face{{font-family:Cairo;font-weight:{w};src:url({_data_uri(FONTS / f, 'font/ttf')})}}"
        for f, w in [('Cairo-Regular.ttf', 400), ('Cairo-SemiBold.ttf', 600), ('Cairo-Bold.ttf', 700)])
    return f"""<!doctype html><html lang="{lang}"><head><meta charset="utf-8"><style>
{fonts}
*{{margin:0;box-sizing:border-box}}
html{{overflow:hidden}}
body{{width:1080px;height:1920px;overflow:hidden;font-family:Cairo,sans-serif;
  background:radial-gradient(120% 70% at 50% 0%, #2B3A63 0%, {NAVY} 55%, #141C33 100%);position:relative}}
.ring{{position:absolute;top:-170px;{'left' if rtl else 'right'}:-200px;transform:rotate({'-20' if rtl else '20'}deg)}}
.text{{position:absolute;top:150px;left:90px;right:90px;text-align:center;color:#fff}}
.dot{{width:64px;height:8px;border-radius:4px;background:{AMBER};margin:0 auto 34px}}
h1{{font-size:{76 if rtl else 70}px;font-weight:700;line-height:1.25}}
p{{margin-top:22px;font-size:36px;font-weight:400;line-height:1.5;color:rgba(255,255,255,.74)}}
.phone{{position:absolute;top:560px;left:50%;width:820px;transform:translateX(-50%);
  background:#0B1020;border-radius:96px;padding:22px 22px 0;
  box-shadow:0 50px 120px rgba(0,0,0,.45),0 0 0 3px rgba(255,255,255,.08) inset}}
.screen{{border-radius:76px 76px 0 0;overflow:hidden;background:{bar}}}
.status{{height:90px;display:flex;align-items:center;justify-content:space-between;padding:0 56px;
  direction:ltr;font:600 32px Cairo,sans-serif;color:#1E2A4A;position:relative}}
.cam{{position:absolute;left:50%;top:26px;width:38px;height:38px;border-radius:50%;background:#0B1020;transform:translateX(-50%)}}
.icons{{display:flex;gap:12px;align-items:center}}
.icons i{{display:block;background:#1E2A4A;border-radius:3px}}
.screen img{{display:block;width:776px}}
</style></head><body>
<div class="ring">{_ring(760)}</div>
<div class="text" dir="{'rtl' if rtl else 'ltr'}"><div class="dot"></div><h1>{title}</h1><p>{line}</p></div>
<div class="phone"><div class="screen">
  <div class="status"><span>9:41</span><div class="cam"></div>
    <div class="icons"><i style="width:8px;height:14px"></i><i style="width:8px;height:20px"></i><i style="width:8px;height:26px"></i>
      <i style="width:44px;height:22px;border-radius:6px;margin-inline-start:10px"></i></div></div>
  <img src="{_data_uri(shot, 'image/png')}">
</div></div>
</body></html>"""


def main() -> int:
    missing = [f'{lang}/{name}' for lang in ('ar', 'en') for name, *_ in SLIDES
               if not (SHOTS / lang / f'{name}.png').exists()]
    if missing:
        print('Missing raw screenshots (run the store test first):', ', '.join(missing))
        return 1
    with sync_playwright() as pw:
        browser = pw.chromium.launch()
        page = browser.new_page(viewport={'width': 1080, 'height': 1920}, device_scale_factor=1)
        for lang in ('ar', 'en'):
            out = OUT / lang
            out.mkdir(parents=True, exist_ok=True)
            for i, (name, ar_t, ar_l, en_t, en_l) in enumerate(SLIDES, 1):
                title, line = (ar_t, ar_l) if lang == 'ar' else (en_t, en_l)
                page.set_content(_page(SHOTS / lang / f'{name}.png', lang, title, line))
                page.wait_for_timeout(150)
                target = out / f'{i:02d}-{name}.png'
                page.screenshot(path=str(target))
                print('wrote', target.relative_to(ROOT))
        browser.close()
    return 0


if __name__ == '__main__':
    sys.exit(main())
