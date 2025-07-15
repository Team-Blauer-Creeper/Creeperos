-- Creeper OS v2.0 für LuaDroid / Termux (mit mpv für Sound)

-- 📦 Auto-Setup beim ersten Start
local setup_flag = os.getenv("HOME") .. "/.creeper_installed"
local f = io.open(setup_flag, "r")
if not f then
  print("🔧 Erster Start – Setup wird durchgeführt...")
  os.execute("pkg install -y mpv figlet toilet")
  local done = io.open(setup_flag, "w")
  done:write("done")
  done:close()
  print("✅ Setup abgeschlossen. Starte neu...")
  os.execute("sleep 2")
end
if f then f:close() end

-- 🔊 Beep-Funktion (nutzt mpv statt termux-api)
function beep()
  os.execute("play beep.mp3")
end

-- 🟩 Bootlogo
function boot_logo()
  for i = 1, 10 do print() end
  print([[
⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⡟⠉⠉⠉⠉⢻⣿⣿⣿⣿⡟⠉⠉⠉⠉⢻⣿⣿⣿
⣿⣿⣿⡇⠀⠀⠀⠀⢸⣿⣿⣿⣿⡇⠀⠀⠀⠀⢸⣿⣿⣿
⣿⣿⣿⣇⣀⣀⣀⣀⡸⠿⠿⠿⠿⢇⣀⣀⣀⣀⣸⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⠉⠉⠁⠀⠀⠀⠀⠈⠉⠉⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⠀⠀⣶⣶⣶⣶⣶⣶⠀⠀⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣶⣾⣿⣿⣿⣿⣿⣿⣷⣶⣿⣿⣿⣿⣿⣿
⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿
]])
  io.write("\nSystem wird geladen")
  for i = 1, 5 do io.write("."); io.flush(); os.execute("sleep 0.4") end
  print("\nFertig!")
  os.execute("sleep 1")
end

-- 🧱 Bildschirm leeren
function clear() os.execute("clear") end

-- 🕒 Uhr im Kopfbereich
function uhr_header()
  local zeit = os.date("%H:%M:%S")
  print("🟩 Creeper OS    Uhr: "..zeit)
  print("----------------------------------------\n")
end

-- ⌛ Pause
function pause()
  io.write("\n[Enter drücken] ")
  io.read()
end

-- 💻 Terminal
function terminal()
  clear()
  uhr_header()
  print("💻 Creeper-Terminal (Lua)")
  print("Gib Lua-Code ein. 'exit' zum Beenden.\n")
  while true do
    io.write("> ")
    local input = io.read()
    if input == "exit" then break end
    local func, err = load("return "..input)
    if not func then func, err = load(input) end
    if func then
      local ok, result = pcall(func)
      if ok and result ~= nil then print(result) end
    else
      print("Fehler: "..err)
    end
  end
end

-- 🧮 Rechner
function rechner()
  clear()
  uhr_header()
  print("🧮 Rechner\n")
  io.write("Zahl 1: ") local a = tonumber(io.read())
  io.write("Operator (+ - * /): ") local op = io.read()
  io.write("Zahl 2: ") local b = tonumber(io.read())
  if not a or not b then print("❌ Ungültige Zahl.") pause() return end
  local erg
  if op == "+" then erg = a + b
  elseif op == "-" then erg = a - b
  elseif op == "*" then erg = a * b
  elseif op == "/" then
    if b == 0 then print("❌ Division durch 0!") pause() return end
    erg = a / b
  else
    print("❌ Ungültiger Operator.") pause() return
  end
  print("Ergebnis: "..erg)
  pause()
end

-- ⏱️ Stoppuhr
function stoppuhr()
  clear()
  uhr_header()
  print("⏱️  Stoppuhr\n")
  print("Drücke [Enter] zum Start...")
  io.read()
  local start = os.time()
  print("Läuft... Drücke [Enter] zum Stoppen.")
  io.read()
  local ende = os.time()
  local sekunden = ende - start
  local min = math.floor(sekunden / 60)
  local sek = sekunden % 60
  print("Gestoppte Zeit: "..min.." Min, "..sek.." Sek")
  beep()
  pause()
end

-- 🔔 Alarm
function alarm()
  clear()
  uhr_header()
  print("🔔 Alarm setzen (Format HH:MM)")
  io.write("Zeit: ")
  local eingabe = io.read()
  local hh, mm = eingabe:match("^(%d+):(%d+)$")
  hh = tonumber(hh)
  mm = tonumber(mm)
  if not hh or not mm or hh > 23 or mm > 59 then
    print("❌ Ungültige Uhrzeit.") pause() return
  end
  print("Warte auf "..string.format("%02d:%02d", hh, mm).."...")
  while true do
    local now = os.date("*t")
    if now.hour == hh and now.min == mm then
      clear()
      uhr_header()
      print("🔔🔔🔔 ALARM! 🔔🔔🔔")
      for i = 1, 5 do
        beep()
        print("‼️  BEEP ‼️")
        os.execute("sleep 1")
      end
      break
    end
    os.execute("sleep 5")
  end
  pause()
end

-- ⌚ Uhr-Anzeige
function uhr_app()
  while true do
    clear()
    uhr_header()
    print("\nAktuelle Uhrzeit:\n   "..os.date("%H:%M:%S"))
    os.execute("sleep 1")
  end
end

-- 📂 Programme öffnen
function programme()
  clear()
  uhr_header()
  os.execute("mkdir -p programme")
  local list = {}
  for line in io.popen("ls programme"):lines() do table.insert(list, line) end
  if #list == 0 then print("Keine Programme gefunden.") pause() return end
  print("Programme:")
  for i, f in ipairs(list) do print(i..") "..f) end
  io.write("\nNummer: ")
  local wahl = tonumber(io.read())
  if not wahl or not list[wahl] then print("❌ Ungültig.") pause() return end
  dofile("programme/"..list[wahl])
  pause()
end

-- ✍️ Programm-Editor
function editor()
  clear()
  uhr_header()
  io.write("Name des Programms (ohne .lua): ")
  local name = io.read()
  local path = "programme/"..name..".lua"
  os.execute("mkdir -p programme")
  print("Zeilen eingeben. Schreibe 'ENDE' zum Speichern.")
  local lines = {}
  while true do
    io.write("> ")
    local line = io.read()
    if line == "ENDE" then break end
    table.insert(lines, line)
  end
  local file = io.open(path, "w")
  for _, l in ipairs(lines) do file:write(l.."\n") end
  file:close()
  print("✅ Gespeichert unter "..path)
  pause()
end

-- 🏁 Hauptmenü
function hauptmenue()
  while true do
    clear()
    uhr_header()
    print("📋 Hauptmenü")
    print("[1] Terminal")
    print("[2] Rechner")
    print("[3] Stoppuhr")
    print("[4] Alarm setzen")
    print("[5] Uhr anzeigen")
    print("[6] Programme öffnen")
    print("[7] Programm erstellen")
    print("[0] Beenden")
    io.write("\nAuswahl: ")
    local wahl = io.read()
    if wahl == "1" then terminal()
    elseif wahl == "2" then rechner()
    elseif wahl == "3" then stoppuhr()
    elseif wahl == "4" then alarm()
    elseif wahl == "5" then uhr_app()
    elseif wahl == "6" then programme()
    elseif wahl == "7" then editor()
    elseif wahl == "0" then break
    else print("❌ Ungültige Auswahl.") os.execute("sleep 1") end
  end
end

-- 🚀 Startsystem
boot_logo()
hauptmenue()
clear()
print("🔚 Creeper OS beendet.")