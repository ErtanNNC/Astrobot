# Oynanış kaydını çöz ve özetle. Kullanım: python3 tools/playlog/decode.py kayit.txt   (ya da metni stdin'den ver)
# Kayıt, oyunda Ayarlar → "Oynanış kaydını kopyala" ile panoya alınan "BIPLOG1:..." satırıdır.
import sys, json, gzip, base64, collections

text = (open(sys.argv[1]).read() if len(sys.argv) > 1 else sys.stdin.read()).strip()
i = text.find("BIPLOG1:")
if i < 0:
    sys.exit("BIPLOG1: bulunamadı")
data = json.loads(gzip.decompress(base64.b64decode("".join(text[i + 8:].split()))))
if "--json" in sys.argv:
    print(json.dumps(data, ensure_ascii=False, indent=1)); sys.exit()
print("sürüm %s · %s (%s) · ekran %s · kalite %s · gölge %s · %d tur" % (
    data.get("v"), data.get("dev"), data.get("os"), data.get("scr"), data.get("q"), data.get("shadows"), len(data["runs"])))
by = collections.OrderedDict()
for r in data["runs"]:
    by.setdefault(r["a"], []).append(r)
print("%-16s %4s %5s %5s %6s %5s %5s %7s %7s  %s" % ("alan", "tur", "bitti", "kayıp", "düşme", "hasar", "yıld.", "süre", "fps", "en çok düşülen yerler (x,z × kez)"))
for a, runs in by.items():
    done = [r for r in runs if r.get("end") == "done"]
    falls = [p for r in runs for p in r["falls"]]
    spots = collections.Counter((round(p[0] / 4) * 4, round(p[2] / 4) * 4) for p in falls).most_common(3)
    t = min((r["dur"] for r in done), default=0)
    fmin = min((r["fmin"] for r in runs if r["fmin"] > 0), default=0)
    favg = sum(r["favg"] for r in runs) / max(len(runs), 1)
    print("%-16s %4d %5d %5d %6d %5d %5s %6.0fs %3d/%-3d  %s" % (
        a, len(runs), len(done), sum(r["over"] for r in runs), len(falls), sum(len(r["hits"]) for r in runs),
        max((r.get("stars", 0) for r in done), default="-"), t, fmin, favg,
        " ".join("(%d,%d)×%d" % (s[0][0], s[0][1], s[1]) for s in spots)))
