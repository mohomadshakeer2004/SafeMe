#!/usr/bin/env python3
"""Export SafeMe one-board UI wireframe to PNG."""

from __future__ import annotations

import os
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

# Brand (lib/Resources/colors.dart)
NAVY = (12, 33, 58)
WHITE = (255, 255, 255)
RED = (255, 0, 0)
GRAY_BG = (245, 245, 247)
GRAY_LINE = (200, 200, 205)
GRAY_TEXT = (90, 90, 95)
LIGHT_FILL = (230, 232, 238)
ACCENT_FILL = (220, 228, 240)
RED_FILL = (255, 230, 230)

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "docs" / "safeme-ui-wireframe.png"


def load_fonts():
    candidates = [
        "/System/Library/Fonts/Supplemental/Arial.ttf",
        "/System/Library/Fonts/Helvetica.ttc",
        "/Library/Fonts/Arial.ttf",
    ]
    path = next((p for p in candidates if os.path.exists(p)), None)
    if path:
        return {
            "title": ImageFont.truetype(path, 32),
            "h2": ImageFont.truetype(path, 22),
            "label": ImageFont.truetype(path, 13),
            "small": ImageFont.truetype(path, 11),
            "tiny": ImageFont.truetype(path, 9),
        }
    default = ImageFont.load_default()
    return {k: default for k in ("title", "h2", "label", "small", "tiny")}


def text_size(draw, text, font):
    if hasattr(draw, "textbbox"):
        b = draw.textbbox((0, 0), text, font=font)
        return b[2] - b[0], b[3] - b[1]
    return draw.textsize(text, font=font)


def draw_text(draw, xy, text, font, fill=(30, 30, 30)):
    draw.text(xy, text, fill=fill, font=font)


def rounded_rect(draw, box, radius, fill, outline=None, width=1):
    draw.rounded_rectangle(box, radius=radius, fill=fill, outline=outline, width=width)


def draw_arrow(draw, x, y, fonts):
    draw_text(draw, (x, y), "→", fonts["h2"], GRAY_TEXT)


def draw_section(draw, x, y, title, fonts):
    pad = 8
    tw, th = text_size(draw, title, fonts["label"])
    box = (x, y, x + tw + pad * 2, y + th + pad)
    rounded_rect(draw, box, 6, ACCENT_FILL, NAVY, 2)
    draw_text(draw, (x + pad, y + pad // 2), title, fonts["label"], NAVY)
    return box[3] + 12


def draw_phone(
    draw,
    x,
    y,
    w,
    title,
    route,
    zones,
    fonts,
    bottom_nav=None,
    drawer=False,
):
    """Draw phone wireframe; returns bottom y."""
    title_h = 36
    phone_h = int(w * 1.85)
    total_h = title_h + phone_h

    draw_text(draw, (x, y), title, fonts["label"], NAVY)
    draw_text(draw, (x, y + 16), route, fonts["tiny"], GRAY_TEXT)
    py = y + title_h

    outer = (x, py, x + w, py + phone_h)
    rounded_rect(draw, outer, 18, WHITE, NAVY, 2)

    # status bar
    sb = (x + 2, py + 2, x + w - 2, py + 22)
    rounded_rect(draw, sb, 8, LIGHT_FILL, GRAY_LINE, 1)
    tw, _ = text_size(draw, "9:41", fonts["tiny"])
    draw_text(draw, (x + w // 2 - tw // 2, py + 6), "9:41", fonts["tiny"], GRAY_TEXT)

    app_y = py + 24
    app_h = 40
    rounded_rect(draw, (x + 2, app_y, x + w - 2, app_y + app_h), 0, LIGHT_FILL, GRAY_LINE, 1)
    draw_text(draw, (x + 12, app_y + 12), "☰  Home" if not drawer else "←  Drawer", fonts["small"])

    nav_h = 48 if bottom_nav else 0
    content_top = app_y + app_h + 8
    content_bottom = py + phone_h - nav_h - 8

    cy = content_top
    for z in zones:
        zh = z.get("h", 40)
        if cy + zh > content_bottom:
            zh = max(24, content_bottom - cy)
        fill = RED_FILL if z.get("danger") else ACCENT_FILL if z.get("accent") else LIGHT_FILL
        outline = RED if z.get("danger") else GRAY_LINE
        box = (x + 10, cy, x + w - 10, cy + zh)
        rounded_rect(draw, box, 8 if z.get("danger") else 6, fill, outline, 1)
        draw_text(draw, (x + 16, cy + 6), z["label"], fonts["small"])
        if z.get("sub"):
            draw_text(draw, (x + 16, cy + 22), z["sub"], fonts["tiny"], GRAY_TEXT)
        cy += zh + 8

    if bottom_nav:
        ny = py + phone_h - nav_h
        draw.line([(x + 2, ny), (x + w - 2, ny)], fill=GRAY_LINE, width=1)
        half = w // 2
        draw_text(draw, (x + half // 2 - 20, ny + 14), bottom_nav[0], fonts["small"], NAVY)
        draw_text(draw, (x + half + half // 2 - 24, ny + 14), bottom_nav[1], fonts["small"], GRAY_TEXT)
        draw.line([(x + half, ny), (x + half, py + phone_h)], fill=GRAY_LINE, width=1)

    if drawer:
        dw = int(w * 0.78)
        rounded_rect(draw, (x + 2, app_y, x + dw, py + phone_h - nav_h), 0, (235, 235, 240), NAVY, 2)
        items = ["Avatar + Name", "Home", "Terms & Conditions", "Privacy Policy", "Logout"]
        iy = app_y + 12
        for item in items:
            rounded_rect(draw, (x + 10, iy, x + dw - 8, iy + 32), 4, WHITE, GRAY_LINE, 1)
            draw_text(draw, (x + 18, iy + 8), item, fonts["tiny"])
            iy += 38

    return y + total_h


def draw_tile(draw, x, y, size, label, fonts):
    box = (x, y, x + size, y + size)
    rounded_rect(draw, box, 16, WHITE, GRAY_LINE, 1)
    tw, _ = text_size(draw, label, fonts["small"])
    draw_text(draw, (x + (size - tw) // 2, y + 12), label, fonts["small"], NAVY)
    icon = (x + size // 2 - 20, y + 36, x + size // 2 + 20, y + 76)
    rounded_rect(draw, icon, 8, LIGHT_FILL, GRAY_LINE, 1)
    draw_text(draw, (x + size // 2 - 12, y + 52), "icon", fonts["tiny"], GRAY_TEXT)


def main():
    fonts = load_fonts()
    W = 2800
    H = 3400
    img = Image.new("RGB", (W, H), GRAY_BG)
    draw = ImageDraw.Draw(img)

    margin = 48
    y = margin

    draw_text(draw, (margin, y), "SafeMe — Complete UI Wireframe", fonts["title"], NAVY)
    y += 44
    sub = "Auth → Home shell → 7 services → Profile & Legal  |  Navy #0c213a  ·  119 red  ·  white cards"
    draw_text(draw, (margin, y), sub, fonts["small"], GRAY_TEXT)
    y += 40

    # --- Section 1 ---
    y = draw_section(draw, margin, y, "1 · Onboarding & Auth", fonts)
    x = margin
    pw = 200
    phones_s1 = [
        ("Loading", "loading.dart", [{"label": "SafeMe Logo", "h": 70, "accent": True}, {"label": "Session spinner", "h": 50}]),
        ("Language", "languageSelect.dart", [{"label": "Logo", "h": 50}, {"label": "English", "h": 44, "accent": True}, {"label": "Sinhala", "h": 44, "accent": True}]),
        ("Login", "LoginPage.dart", [{"label": "NIC", "h": 40}, {"label": "Password", "h": 40}, {"label": "Login", "h": 44, "accent": True}, {"label": "Forgot / Sign up", "h": 32}]),
        ("Signup", "signupPage1-3", [{"label": "Photo + NIC", "h": 90}, {"label": "Address", "h": 50}, {"label": "District + password", "h": 70}]),
    ]
    row_bottom = y
    for i, (title, route, zones) in enumerate(phones_s1):
        if i > 0:
            draw_arrow(draw, x - 28, y + 120, fonts)
        bottom = draw_phone(draw, x, y, pw, title, route, zones, fonts)
        row_bottom = max(row_bottom, bottom)
        x += pw + 56
    y = row_bottom + 36

    draw.line([(margin, y), (W - margin, y)], fill=GRAY_LINE, width=2)
    y += 28

    # --- Section 2 ---
    y = draw_section(draw, margin, y, "2 · App shell (logged in)", fonts)
    x = margin
    pw2 = 280
    bottom2 = draw_phone(
        draw, x, y, pw2, "HomeBase", "home_base.dart",
        [{"label": "Tab content", "sub": "Home OR Profile", "h": 120, "accent": True}],
        fonts, bottom_nav=["Home", "Profile"],
    )
    draw_arrow(draw, x + pw2 + 12, y + 160, fonts)
    draw_text(draw, (x + pw2 + 28, y + 150), "tab 0", fonts["tiny"], GRAY_TEXT)
    x2 = x + pw2 + 70
    bottom2b = draw_phone(
        draw, x2, y, pw2, "Home (hub)", "home.dart",
        [{"label": "119 Emergency", "sub": "tap dial 119", "h": 72, "danger": True},
         {"label": "Service grid 2x3", "h": 36}],
        fonts, bottom_nav=["Home", "Profile"],
    )
    # grid tiles beside home phone
    gx = x2 + pw2 + 24
    gy = y + 80
    ts = 118
    tiles = ["Complaint", "Safe Me", "Appointment", "Police Map", "Lost & Found", "Emergency Contact"]
    for i, t in enumerate(tiles):
        col, row = i % 2, i // 2
        draw_tile(draw, gx + col * (ts + 12), gy + row * (ts + 12), ts, t, fonts)
    shake_y = gy + 2 * (ts + 12) + 20
    rounded_rect(draw, (gx, shake_y, gx + 250, shake_y + 52), 8, RED_FILL, RED, 1)
    draw_text(draw, (gx + 10, shake_y + 8), "Shake on Home tab", fonts["small"], NAVY)
    draw_text(draw, (gx + 10, shake_y + 26), "emergency.mp3 + SafeMe dialog", fonts["tiny"], GRAY_TEXT)

    x3 = gx + 270
    bottom2c = draw_phone(
        draw, x3, y, pw2, "Drawer", "drawer.dart", [{"label": "(overlay)", "h": 40}],
        fonts, drawer=True,
    )
    y = max(bottom2, bottom2b, bottom2c, shake_y + 60) + 36

    draw.line([(margin, y), (W - margin, y)], fill=GRAY_LINE, width=2)
    y += 28

    # --- Section 3 ---
    y = draw_section(draw, margin, y, "3 · Modules from Home", fonts)
    x = margin
    pw3 = 260
    modules = [
        ("Complaints", "complaint_base", [
            {"label": "+ Place Complaint", "h": 48, "accent": True},
            {"label": "My list + delete", "h": 90},
            {"label": "Form + Terms links", "h": 60},
        ]),
        ("Safe Me", "safeMeBase", [
            {"label": "Emergency dialog", "h": 48, "danger": True},
            {"label": "Alerts list", "h": 80},
            {"label": "Form: audio, GPS", "h": 90},
        ]),
        ("Appointments", "appointment_base", [
            {"label": "+ Place Appointment", "h": 48, "accent": True},
            {"label": "History | Police tabs", "h": 44},
            {"label": "Cards list", "h": 90},
        ]),
        ("Lost & Found", "lost_Found.dart", [
            {"label": "Item + description", "h": 80},
            {"label": "Photo + location", "h": 70},
            {"label": "Submit", "h": 44, "accent": True},
        ]),
        ("Police Map", "policeMap.dart", [
            {"label": "Google Map", "h": 130, "accent": True},
            {"label": "Station list", "h": 80},
        ]),
        ("Emergency Contacts", "emergencyContact.dart", [
            {"label": "Contact cards / call", "h": 170, "accent": True},
        ]),
    ]
    col_x = [margin, margin + pw3 + 40, margin + 2 * (pw3 + 40)]
    row_y = y
    max_row_h = 0
    for i, (title, route, zones) in enumerate(modules):
        cx = col_x[i % 3]
        cy = row_y if i < 3 else row_y + max_row_h + 24
        if i == 3:
            row_y = cy
        bottom = draw_phone(draw, cx, cy, pw3, title, route, zones, fonts)
        max_row_h = max(max_row_h, bottom - cy) if i < 3 else max(max_row_h, bottom - row_y)
    y = row_y + max_row_h + 48

    draw.line([(margin, y), (W - margin, y)], fill=GRAY_LINE, width=2)
    y += 28

    # --- Section 4 ---
    y = draw_section(draw, margin, y, "4 · Profile & Legal", fonts)
    x = margin
    for title, route, zones in [
        ("Profile", "profile.dart", [
            {"label": "Avatar + name card", "h": 100, "accent": True},
            {"label": "NIC, phone, address", "h": 110},
            {"label": "Change password", "h": 44},
        ]),
        ("Terms", "legal_document_screen", [{"label": "EN / SI scroll", "h": 200, "accent": True}]),
        ("Privacy", "legal_document_screen", [{"label": "EN / SI scroll", "h": 200, "accent": True}]),
    ]:
        bottom = draw_phone(draw, x, y, pw3, title, route, zones, fonts,
                            bottom_nav=["Home", "Profile"] if title == "Profile" else None)
        x += pw3 + 40
    y = bottom + 40

    # Legend
    leg = (margin, y, W - margin, y + 120)
    rounded_rect(draw, leg, 10, WHITE, GRAY_LINE, 1)
    draw_text(draw, (margin + 16, y + 12), "UI patterns (all screens)", fonts["h2"], NAVY)
    lines = [
        "AppBar: menu · title · back arrow → HomeBase",
        "Lists: pull-to-refresh · EasyLoading on submit",
        "Forms: FormBuilder · district/city dropdowns",
    ]
    ly = y + 44
    for line in lines:
        draw_text(draw, (margin + 20, ly), "• " + line, fonts["small"], GRAY_TEXT)
        ly += 22

    y = leg[3] + 24
    # Crop to content
    img = img.crop((0, 0, W, min(H, y + margin)))
    OUT.parent.mkdir(parents=True, exist_ok=True)
    img.save(OUT, "PNG", optimize=True)
    print(f"Saved: {OUT}")
    print(f"Size: {img.size[0]} x {img.size[1]} px")


if __name__ == "__main__":
    main()
