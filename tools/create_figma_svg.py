# Script to generate Figma-compatible SVG wireframe with 3 Mobile Frames (375x812)
svg_content = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1285 852" width="1285" height="852" fill="none">
  <defs>
    <style>
      .ph-bg { fill: #F8FAFC; }
      .ph-border { stroke: #CBD5E1; stroke-width: 1.5; stroke-dasharray: 4 3; }
      .ph-solid-border { stroke: #E2E8F0; stroke-width: 1.5; }
      .ph-box { fill: #F1F5F9; stroke: #94A3B8; stroke-width: 1; stroke-dasharray: 3 3; }
      .ph-line { fill: #CBD5E1; rx: 4; }
      .ph-title { font-family: Inter, -apple-system, sans-serif; font-size: 13px; font-weight: 700; fill: #1E293B; }
      .ph-text { font-family: Inter, -apple-system, sans-serif; font-size: 10px; font-weight: 600; fill: #64748B; }
      .ph-btn-text { font-family: Inter, -apple-system, sans-serif; font-size: 11px; font-weight: 700; fill: #475569; }
      .ph-tag { fill: #E2E8F0; rx: 4; }
    </style>
  </defs>

  <!-- ================= FRAME 1: EXAM LIST (375 x 812) ================= -->
  <g id="Frame_01_Exam_List" transform="translate(20, 20)">
    <!-- Phone Container -->
    <rect width="375" height="812" rx="36" class="ph-bg" stroke="#94A3B8" stroke-width="2"/>
    
    <!-- Notch / Status Bar -->
    <rect x="0" y="0" width="375" height="36" rx="0" fill="#FFFFFF"/>
    <text x="24" y="23" font-family="Inter" font-size="11" font-weight="600" fill="#94A3B8">--:--</text>
    <text x="310" y="23" font-family="Inter" font-size="10" font-weight="600" fill="#94A3B8">[STATUS]</text>
    <line x1="0" y1="36" x2="375" y2="36" stroke="#E2E8F0" stroke-width="1"/>

    <!-- App Header -->
    <rect x="20" y="52" width="180" height="18" rx="6" fill="#94A3B8"/>
    <circle cx="340" cy="61" r="15" fill="#E2E8F0" stroke="#94A3B8" stroke-width="1"/>

    <!-- Hero Banner Placeholder -->
    <rect x="16" y="86" width="343" height="96" rx="14" fill="#EEF2F6" stroke="#94A3B8" stroke-width="1.5" stroke-dasharray="4 3"/>
    <rect x="32" y="104" width="120" height="12" rx="4" fill="#94A3B8"/>
    <rect x="32" y="124" width="220" height="8" rx="4" fill="#CBD5E1"/>
    <rect x="32" y="138" width="160" height="8" rx="4" fill="#CBD5E1"/>
    <text x="171" y="165" text-anchor="middle" class="ph-text">[ HERO BANNER PLACEHOLDER ]</text>

    <!-- Card 1 Placeholder -->
    <rect x="16" y="196" width="343" height="150" rx="16" fill="#FFFFFF" class="ph-border"/>
    <rect x="32" y="214" width="160" height="14" rx="4" fill="#94A3B8"/>
    <rect x="280" y="212" width="60" height="18" rx="6" fill="#E2E8F0"/>
    <rect x="32" y="236" width="200" height="8" rx="4" fill="#CBD5E1"/>
    <rect x="32" y="254" width="70" height="20" rx="6" fill="#E2E8F0"/>
    <rect x="110" y="254" width="70" height="20" rx="6" fill="#E2E8F0"/>
    <!-- Button -->
    <rect x="32" y="286" width="311" height="42" rx="10" fill="#E2E8F0" stroke="#64748B" stroke-width="1.5" stroke-dasharray="3 3"/>
    <text x="187" y="312" text-anchor="middle" class="ph-btn-text">[ BUTTON: VÀO THI NGAY ]</text>

    <!-- Card 2 Placeholder -->
    <rect x="16" y="360" width="343" height="150" rx="16" fill="#FFFFFF" class="ph-border"/>
    <rect x="32" y="378" width="180" height="14" rx="4" fill="#94A3B8"/>
    <rect x="280" y="376" width="60" height="18" rx="6" fill="#E2E8F0"/>
    <rect x="32" y="400" width="170" height="8" rx="4" fill="#CBD5E1"/>
    <rect x="32" y="418" width="70" height="20" rx="6" fill="#E2E8F0"/>
    <rect x="110" y="418" width="70" height="20" rx="6" fill="#E2E8F0"/>
    <!-- Button -->
    <rect x="32" y="450" width="311" height="42" rx="10" fill="#E2E8F0" stroke="#64748B" stroke-width="1.5" stroke-dasharray="3 3"/>
    <text x="187" y="476" text-anchor="middle" class="ph-btn-text">[ BUTTON: VÀO THI NGAY ]</text>

    <!-- Card 3 Placeholder -->
    <rect x="16" y="524" width="343" height="150" rx="16" fill="#FFFFFF" class="ph-border"/>
    <rect x="32" y="542" width="150" height="14" rx="4" fill="#94A3B8"/>
    <rect x="280" y="540" width="60" height="18" rx="6" fill="#E2E8F0"/>
    <rect x="32" y="564" width="190" height="8" rx="4" fill="#CBD5E1"/>
    <rect x="32" y="582" width="70" height="20" rx="6" fill="#E2E8F0"/>
    <rect x="110" y="582" width="70" height="20" rx="6" fill="#E2E8F0"/>
    <!-- Button -->
    <rect x="32" y="614" width="311" height="42" rx="10" fill="#E2E8F0" stroke="#64748B" stroke-width="1.5" stroke-dasharray="3 3"/>
    <text x="187" y="640" text-anchor="middle" class="ph-btn-text">[ BUTTON: VÀO THI NGAY ]</text>

    <!-- Bottom Nav -->
    <line x1="0" y1="750" x2="375" y2="750" stroke="#CBD5E1" stroke-width="1" stroke-dasharray="3 3"/>
    <circle cx="65" cy="780" r="12" fill="#CBD5E1"/>
    <circle cx="187" cy="780" r="12" fill="#CBD5E1"/>
    <circle cx="310" cy="780" r="12" fill="#CBD5E1"/>
  </g>

  <!-- ================= FRAME 2: EXAM ROOM (SPLIT VIEW) ================= -->
  <g id="Frame_02_Exam_Room_SplitView" transform="translate(455, 20)">
    <!-- Phone Container -->
    <rect width="375" height="812" rx="36" class="ph-bg" stroke="#94A3B8" stroke-width="2"/>
    
    <!-- Notch -->
    <rect x="0" y="0" width="375" height="36" fill="#FFFFFF"/>
    <text x="24" y="23" font-family="Inter" font-size="11" font-weight="600" fill="#94A3B8">--:--</text>
    <text x="310" y="23" font-family="Inter" font-size="10" font-weight="600" fill="#94A3B8">[STATUS]</text>
    <line x1="0" y1="36" x2="375" y2="36" stroke="#E2E8F0" stroke-width="1"/>

    <!-- Room Topbar -->
    <circle cx="30" cy="56" r="12" fill="#E2E8F0" stroke="#94A3B8" stroke-width="1"/>
    <rect x="140" y="42" width="95" height="28" rx="6" fill="#F1F5F9" stroke="#94A3B8" stroke-width="1" stroke-dasharray="3 3"/>
    <text x="187" y="61" text-anchor="middle" font-family="monospace" font-size="12" font-weight="700" fill="#334155">[ 75:00 ]</text>
    <rect x="270" y="42" width="88" height="28" rx="6" fill="#FEF3C7" stroke="#F59E0B" stroke-width="1.5"/>
    <text x="314" y="60" text-anchor="middle" font-family="Inter" font-size="10" font-weight="800" fill="#B45309">[ NỘP BÀI ]</text>

    <!-- SPLIT TOP (45%): Reading Passage Box -->
    <rect x="14" y="80" width="347" height="250" rx="14" fill="#FFFFFF" class="ph-solid-border"/>
    <rect x="26" y="94" width="130" height="12" rx="4" fill="#94A3B8"/>
    <text x="345" y="104" text-anchor="end" font-family="Inter" font-size="9" font-weight="700" fill="#94A3B8">[TOP: 45% PASSAGE]</text>
    <rect x="26" y="118" width="323" height="8" rx="4" fill="#CBD5E1"/>
    <rect x="26" y="134" width="280" height="8" rx="4" fill="#CBD5E1"/>
    <rect x="26" y="150" width="323" height="8" rx="4" fill="#CBD5E1"/>
    <!-- Blank marker -->
    <rect x="26" y="166" width="60" height="8" rx="4" fill="#CBD5E1"/>
    <rect x="94" y="162" width="45" height="16" rx="4" fill="#DBEAFE" stroke="#3B82F6" stroke-width="1"/>
    <text x="116" y="174" text-anchor="middle" font-family="Inter" font-size="9" font-weight="700" fill="#1E40AF">[ 131 ]</text>
    <rect x="147" y="166" width="190" height="8" rx="4" fill="#CBD5E1"/>
    <rect x="26" y="188" width="310" height="8" rx="4" fill="#CBD5E1"/>
    <rect x="26" y="204" width="240" height="8" rx="4" fill="#CBD5E1"/>
    <rect x="26" y="220" width="323" height="8" rx="4" fill="#CBD5E1"/>
    <text x="187" y="275" text-anchor="middle" class="ph-text">[ READING PASSAGE SCROLL AREA ]</text>

    <!-- SPLIT BOTTOM (55%): Question Box -->
    <rect x="14" y="340" width="347" height="400" rx="14" fill="#FFFFFF" class="ph-solid-border"/>
    <rect x="26" y="356" width="100" height="14" rx="4" fill="#94A3B8"/>
    <text x="345" y="367" text-anchor="end" font-family="Inter" font-size="9" font-weight="700" fill="#94A3B8">[BOTTOM: 55% QUESTIONS]</text>
    <rect x="26" y="380" width="323" height="8" rx="4" fill="#CBD5E1"/>
    <rect x="26" y="396" width="220" height="8" rx="4" fill="#CBD5E1"/>

    <!-- Option A -->
    <rect x="26" y="420" width="323" height="44" rx="10" fill="#F8FAFC" stroke="#E2E8F0" stroke-width="1.5"/>
    <circle cx="46" cy="442" r="8" fill="#FFFFFF" stroke="#94A3B8" stroke-width="1.5"/>
    <rect x="66" y="438" width="160" height="8" rx="4" fill="#CBD5E1"/>
    <text x="330" y="446" text-anchor="end" class="ph-text">[A]</text>

    <!-- Option B (Selected) -->
    <rect x="26" y="472" width="323" height="44" rx="10" fill="#EFF6FF" stroke="#3B82F6" stroke-width="1.5"/>
    <circle cx="46" cy="494" r="8" fill="#3B82F6" stroke="#1D4ED8" stroke-width="1.5"/>
    <circle cx="46" cy="494" r="3" fill="#FFFFFF"/>
    <rect x="66" y="490" width="190" height="8" rx="4" fill="#3B82F6"/>
    <text x="330" y="498" text-anchor="end" font-family="Inter" font-size="10" font-weight="700" fill="#1E40AF">[B] Selected</text>

    <!-- Option C -->
    <rect x="26" y="524" width="323" height="44" rx="10" fill="#F8FAFC" stroke="#E2E8F0" stroke-width="1.5"/>
    <circle cx="46" cy="546" r="8" fill="#FFFFFF" stroke="#94A3B8" stroke-width="1.5"/>
    <rect x="66" y="542" width="140" height="8" rx="4" fill="#CBD5E1"/>
    <text x="330" y="550" text-anchor="end" class="ph-text">[C]</text>

    <!-- Option D -->
    <rect x="26" y="576" width="323" height="44" rx="10" fill="#F8FAFC" stroke="#E2E8F0" stroke-width="1.5"/>
    <circle cx="46" cy="598" r="8" fill="#FFFFFF" stroke="#94A3B8" stroke-width="1.5"/>
    <rect x="66" y="594" width="170" height="8" rx="4" fill="#CBD5E1"/>
    <text x="330" y="602" text-anchor="end" class="ph-text">[D]</text>

    <!-- Nav Bottom inside Room -->
    <rect x="26" y="675" width="110" height="42" rx="10" fill="#F1F5F9" stroke="#94A3B8" stroke-width="1" stroke-dasharray="3 3"/>
    <text x="81" y="700" text-anchor="middle" class="ph-btn-text">[ PREV ]</text>

    <rect x="146" y="675" width="83" height="42" rx="10" fill="#F1F5F9" stroke="#94A3B8" stroke-width="1" stroke-dasharray="3 3"/>
    <text x="187" y="700" text-anchor="middle" class="ph-btn-text">[ 🔢 100 ]</text>

    <rect x="239" y="675" width="110" height="42" rx="10" fill="#F1F5F9" stroke="#94A3B8" stroke-width="1" stroke-dasharray="3 3"/>
    <text x="294" y="700" text-anchor="middle" class="ph-btn-text">[ NEXT ]</text>
  </g>

  <!-- ================= FRAME 3: EXAM RESULT (375 x 812) ================= -->
  <g id="Frame_03_Exam_Result" transform="translate(890, 20)">
    <!-- Phone Container -->
    <rect width="375" height="812" rx="36" class="ph-bg" stroke="#94A3B8" stroke-width="2"/>
    
    <!-- Notch -->
    <rect x="0" y="0" width="375" height="36" fill="#FFFFFF"/>
    <text x="24" y="23" font-family="Inter" font-size="11" font-weight="600" fill="#94A3B8">--:--</text>
    <text x="310" y="23" font-family="Inter" font-size="10" font-weight="600" fill="#94A3B8">[STATUS]</text>
    <line x1="0" y1="36" x2="375" y2="36" stroke="#E2E8F0" stroke-width="1"/>

    <!-- Result Title -->
    <rect x="20" y="52" width="170" height="18" rx="6" fill="#94A3B8"/>
    <circle cx="340" cy="61" r="15" fill="#E2E8F0" stroke="#94A3B8" stroke-width="1"/>

    <!-- Score Card -->
    <rect x="16" y="86" width="343" height="150" rx="16" fill="#FFFFFF" stroke="#94A3B8" stroke-width="1.5" stroke-dasharray="4 3"/>
    <circle cx="187" cy="142" r="32" fill="#F0F9FF" stroke="#0284C7" stroke-width="2" stroke-dasharray="4 2"/>
    <text x="187" y="147" text-anchor="middle" font-family="Inter" font-size="14" font-weight="800" fill="#0284C7">--.- / 10</text>
    <rect x="117" y="186" width="140" height="22" rx="11" fill="#FEF3C7" stroke="#F59E0B" stroke-width="1"/>
    <text x="187" y="201" text-anchor="middle" font-family="Inter" font-size="10" font-weight="800" fill="#B45309">[ TOEIC: --- / 495 ]</text>
    <text x="187" y="226" text-anchor="middle" class="ph-text">[ SCORE HERO CARD PLACEHOLDER ]</text>

    <!-- 3 Metrics Badges -->
    <g transform="translate(16, 250)">
      <rect x="0" y="0" width="107" height="52" rx="10" fill="#DCFCE7" stroke="#22C55E" stroke-width="1.5"/>
      <text x="53" y="24" text-anchor="middle" font-family="Inter" font-size="14" font-weight="800" fill="#15803D">[ -- ]</text>
      <text x="53" y="40" text-anchor="middle" font-family="Inter" font-size="9" font-weight="700" fill="#166534">ĐÚNG</text>

      <rect x="118" y="0" width="107" height="52" rx="10" fill="#FEE2E2" stroke="#EF4444" stroke-width="1.5"/>
      <text x="171" y="24" text-anchor="middle" font-family="Inter" font-size="14" font-weight="800" fill="#B91C1C">[ -- ]</text>
      <text x="171" y="40" text-anchor="middle" font-family="Inter" font-size="9" font-weight="700" fill="#991B1B">SAI</text>

      <rect x="236" y="0" width="107" height="52" rx="10" fill="#F1F5F9" stroke="#94A3B8" stroke-width="1.5"/>
      <text x="289" y="24" text-anchor="middle" font-family="Inter" font-size="14" font-weight="800" fill="#475569">[ -- ]</text>
      <text x="289" y="40" text-anchor="middle" font-family="Inter" font-size="9" font-weight="700" fill="#334155">BỎ QUA</text>
    </g>

    <!-- Review Card 1 Skeleton -->
    <rect x="16" y="320" width="343" height="150" rx="14" fill="#FFFFFF" class="ph-border"/>
    <rect x="30" y="336" width="80" height="12" rx="4" fill="#94A3B8"/>
    <rect x="280" y="334" width="65" height="16" rx="4" fill="#DCFCE7"/>
    <rect x="30" y="360" width="315" height="8" rx="4" fill="#CBD5E1"/>
    <rect x="30" y="374" width="260" height="8" rx="4" fill="#CBD5E1"/>
    <rect x="30" y="394" width="315" height="28" rx="8" fill="#F8FAFC" stroke="#CBD5E1" stroke-width="1"/>
    <text x="42" y="412" class="ph-text">[ SELECTED OPTION PLACEHOLDER ]</text>
    <!-- Hint Box -->
    <rect x="30" y="428" width="315" height="30" rx="6" fill="#FEF3C7" stroke="#FCD34D" stroke-width="1"/>
    <text x="40" y="447" font-family="Inter" font-size="9" font-weight="700" fill="#B45309">💡 [ HINT / EXPLANATION PLACEHOLDER ]</text>

    <!-- Review Card 2 Skeleton -->
    <rect x="16" y="482" width="343" height="150" rx="14" fill="#FFFFFF" class="ph-border"/>
    <rect x="30" y="498" width="80" height="12" rx="4" fill="#94A3B8"/>
    <rect x="280" y="496" width="65" height="16" rx="4" fill="#DCFCE7"/>
    <rect x="30" y="522" width="315" height="8" rx="4" fill="#CBD5E1"/>
    <rect x="30" y="536" width="240" height="8" rx="4" fill="#CBD5E1"/>
    <rect x="30" y="556" width="315" height="28" rx="8" fill="#F8FAFC" stroke="#CBD5E1" stroke-width="1"/>
    <text x="42" y="574" class="ph-text">[ SELECTED OPTION PLACEHOLDER ]</text>
    <rect x="30" y="590" width="315" height="30" rx="6" fill="#FEF3C7" stroke="#FCD34D" stroke-width="1"/>
    <text x="40" y="609" font-family="Inter" font-size="9" font-weight="700" fill="#B45309">💡 [ HINT / EXPLANATION PLACEHOLDER ]</text>

    <!-- Return Button -->
    <rect x="16" y="740" width="343" height="46" rx="12" fill="#E2E8F0" stroke="#64748B" stroke-width="1.5" stroke-dasharray="3 3"/>
    <text x="187" y="768" text-anchor="middle" class="ph-btn-text">[ BUTTON: VỀ TRANG CHỦ ]</text>
  </g>
</svg>
"""

with open("docs/figma_wireframe_all_screens.svg", "w", encoding="utf-8") as f:
    f.write(svg_content)

print("Created docs/figma_wireframe_all_screens.svg successfully!")
