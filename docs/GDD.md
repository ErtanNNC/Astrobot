# Bip — Oyun Tasarım Dokümanı

**Sürüm:** 0.4 · **Güncelleme:** 2026-11-18 · [Özellikler](#feature-index) · [Kararlar](#decisions) · [Değişiklik kaydı](#change-log)

## Özet
Oyuncu, bir fırtınada anteni yıldırım çarpınca nesnelerin yeteneğini kopyalayabilen küçük tamir robotu Bip'i yönetir ve karanlığa gömülen Dişli Adası'na ışığı geri getirmeye çalışır ([hikaye](features/hikaye/design.md)). Renkli, kısa ve sürprizlerle dolu 3D seviyelerde koşar, zıplar ve kopyaladığı yetenekleri (Yay, Balon, Mıknatıs, Kaya) yaratıcı biçimlerde kullanarak engelleri aşar, pil ve gizli altın vidalar toplar. Eğlencenin kaynağı sıkı kontroller ve her köşede yeteneğin yeni bir kullanımını keşfetmektir. Her bölüm, sonundaki patron yenilip bir Çekirdek Pil geri alınınca biter.

| | |
|---|---|
| Tür ve kamera | 3D platform, oyuncuyu kendi kendine takip eden üçüncü şahıs kamera |
| Hedef kitle | 8 yaş ve üstü, rahat (casual) oyuncular ve platform sevenler |
| Platformlar ve kontrol | Android, iOS (dokunmatik); PC (klavye, gamepad) |
| Oturum | Bir alan 6–8 dk; Bölüm 1 ilk oynayışta yaklaşık 40 dk, gizlerle 50+ dk [ASSUMPTION] |
| Motor | Godot 4, GDScript |
| Kapsam | Prototip → Bölüm 1'in tamamı (dikey kesit) |
| Referanslar | Mario Odyssey (yetenek kopyalama, Cappy), Astro Bot (sürekli sürpriz, oyuncuya özel ilgi, takip kamerası), LittleBigPlanet (dokunsal, el yapımı his) |

## Pillars
1. **Önce his.** Her hareket anında tepki verir ve affedicidir; bir özellik kontrolleri yavaşlatıyorsa kesilir.
2. **Tek yetenek, bin kullanım.** Yeni bir mekanik eklemeden önce mevcut yeteneğin yeni bir kullanımı aranır. Aynı anda yalnızca bir yetenek taşınır.
3. **Her köşede küçük bir sürpriz.** 20–30 saniyede bir yeni bir şey görülür: saklı bir vida, tepki veren bir nesne, gülümseten bir animasyon.
4. **Telefonda tam oynanır.** İki başparmakla oynanabilmeyen bir mekanik ya da kamera hareketi tasarıma girmez.

## Core loop
```
keşfet → kopyalanabilir nesne bul → yeteneği kopyala → engeli/bulmacayı çöz → pil/vida ödülü → bir sonraki daha zor kullanım
```
- **Saniyeler:** koşma, zıplama, kopyalama ve yetenek kullanma ([hareket](features/hareket/design.md), [kopyalama](features/kopyalama/design.md)), her zaman doğru yere bakan kamera ([kamera](features/kamera/design.md)).
- **Dakikalar:** her alan bir yeteneği öğretir, sınar, sonra beklenmedik bir kullanımla şaşırtır; 60–90 saniyede bir kontrol noktası ve otomatik kayıt.
- **Oturum:** bölümün son alanı dört yeteneği birleştirir ve patronla biter; toplanan pil ve vida sayısı sonuç ekranında gösterilir.
- **Oturumlar arası:** ilerleme 3 kayıt yuvasında saklanır; atölyedeki vitrinde toplanan vidalar görünür ([kayıt](features/kayit/design.md), [ana menü](features/ana-menu/design.md)).

## Feature index

| Feature | Status | Scope | Summary | Docs |
|---|---|---|---|---|
| Hareket | implemented | MVP | Koşma, değişken yükseklikte zıplama, coyote time, zıplama tamponu, havada kontrol; ilerledikçe açılan kenara tutunma, dönme saldırısı, havada atılma, duvar zıplaması, çift zıplama (D-016) | [design](features/hareket/design.md) |
| Oyun hissi | in progress | MVP | Astro Bot / Mario Odyssey karşılaştırması: jet süzülme, pil çekimi, canlı süsler, sakin kamera; sırada seviye yoğunluğu | [design](features/oyun-hissi/design.md) |
| Kopyalama | implemented | MVP | Antenle nesneden yetenek kopyalama; Yay, Balon, Mıknatıs, Kaya; hasar alınca yetenek kaybı | [design](features/kopyalama/design.md) |
| Kamera | implemented | MVP | Kendi kendine takip eden, duvardan kaçan, telefonda elle döndürme gerektirmeyen kamera | [design](features/kamera/design.md) |
| Can ve hasar | implemented | MVP | 3 can; hasar önce yeteneği alır, yetenek yoksa can gider; kontrol noktasından devam | [bölüm 1](features/bolum-1/design.md) |
| Toplanabilirler | implemented | MVP | Piller (bölüm başına ~150) ve alan başına 1, toplam 5 gizli altın vida; kırılan sandıklar | [bölüm 1](features/bolum-1/design.md) |
| Düşmanlar | implemented | MVP | Vidaböcek (yürür), Zıpzıp (seker), Hurda Goblin (kovalar); üstüne zıplayınca ya da Kaya ile ezilince yenilir | [hikaye](features/hikaye/design.md) |
| Mobil kontroller | implemented | MVP | Sol yüzen joystick, sağ altta yay şeklinde Zıpla ve Yetenek butonları, sol üstte Duraklat, titreşim; buton boyutu ve sol el modu | [design](features/mobil-kontroller/design.md) |
| Bölüm 1 | implemented | MVP | Öğretici Uyanış Atölyesi + 4 alan (Yay, Balon, Mıknatıs, Kaya) + Hurdacı Vinç patronu | [design](features/bolum-1/design.md) |
| Hikaye | implemented | MVP | Sözsüz anlatım; açılış ve kapanış sahneleri; rehber drone Pırıl; karakterlerin hangi asset'le yapılacağı belli | [design](features/hikaye/design.md) |
| Ana menü | implemented | MVP | Giriş ekranı, oynanabilir atölye ana menüsü, ayarlar, duraklatma menüsü | [design](features/ana-menu/design.md) |
| Kayıt | implemented | MVP | 3 kayıt yuvası, kontrol noktalarında otomatik kayıt, ayrı ayar dosyası | [design](features/kayit/design.md) |
| Patron | implemented | MVP | Bölüm 1 sonunda Hurdacı Vinç (3 aşama); ayrıntı Bölüm 1 notunda | [bölüm 1](features/bolum-1/design.md) |
| Kayıp robotlar | implemented | MVP | Fırtınada kaybolan atölye robotları kontrol noktalarının yanında el sallar; dokununca Atölye'ye ışınlanır ve orada dans eder (toplam 37) | [ana menü](features/ana-menu/design.md) |
| HUD | implemented | MVP | Can, pil ve vida sayacı, taşınan yetenek simgesi, kayıt simgesi, sonuç ekranı | — |
| Ses ve müzik | in progress | MVP | Her eyleme ses; bölüm müziği. Zıplama, iniş, adım, düşme sesleri ve test alanı müziği var | — |
| Yeni yetenekler | implemented | later | Pervane (Bölüm 2) ve Buz (Bölüm 3) yapıldı; Lastik top fikir | [bölüm 2](features/bolum-2/design.md), [bölüm 3](features/bolum-3/design.md) |
| Bölüm 2 | implemented | later | Fırtına Limanı: 3 alan + Paslı Kaptan; yeni yetenek Pervane | [design](features/bolum-2/design.md) |
| Bölüm 3 | implemented | later | Buzul Tepesi: 3 alan + Kardan Dev; yeni yetenek Buz | [design](features/bolum-3/design.md) |
| Bölüm 4 | implemented | later | Fırtınanın Gözü: 2 alan + Statik (ikna edilir); final ve Emeği Geçenler | [design](features/bolum-4/design.md) |

## Milestones
1. ✅ **M1, greybox hareket + kamera:** hareket, kamera; basit küplerden bir test alanı · bitti sayılır: PC'de 2 m'lik bir boşluk ve 1,5 m'lik bir basamak ilk denemede rahatça aşılıyor.
2. ✅ **M2, kopyalama çekirdeği:** kopyalama (önce yalnızca Yay), can ve hasar · bitti sayılır: Yay olmadan ulaşılamayan bir platforma Yay kopyalanarak çıkılıyor, hasar alınca yetenek kayboluyor.
3. ✅ **M3, dört yetenek + Bölüm 1 greybox:** Balon, Mıknatıs, Kaya; öğretici dahil 5 alan; toplanabilirler; düşmanlar · bitti sayılır: Bölüm 1 baştan sona greybox halinde oynanabiliyor.
4. 🟡 **M4, telefon + menü + kayıt:** (gerçek telefonda test bekliyor) mobil kontroller, ana menü, ayarlar, kayıt, Android çıktısı · bitti sayılır: oyun telefonda kapatılıp açılınca son kontrol noktasından devam ediyor ve Bölüm 1 yalnızca dokunmatikle bitirilebiliyor.
5. 🟡 **M5, cila + hikaye:** (sahneler, sesler, patronlar yapıldı; yazısız ilk oynayış testi bekliyor) Kenney/Quaternius asset'leri, ses, efektler, açılış/kapanış sahneleri, patron · bitti sayılır: ilk kez oynayan biri öğreticiyi yazı okumadan 6 dakikada bitirebiliyor.

## Direction
- **Sanat:** renkli low-poly, yumuşak ışık, sade dokular. Tehlikeli şeyler kırmızı/turuncu ve sivri; güvenli ve kopyalanabilir şeyler belirgin bir parıltıyla işaretli. Asset kaynakları ve lisans kuralları: `CLAUDE.md`.
- **Oyun hissi:** zıplama, iniş ve kopyalama her zaman görüntü + ses + (telefonda) titreşimle karşılık bulur; Bip zıplarken uzar, inerken ezilir.
- **Ton:** neşeli, sözsüz; Bip konuşmaz, tepkilerini animasyon ve seslerle verir. Hikaye ve öğretim yazı yerine sahne, simge ve oyun alanıyla anlatılır.
- **Erişilebilirlik:** yazı gerektirmeyen öğretim; renk dışında şekille de ayrılan tehlikeler.

## Decisions

| ID | Tarih | Karar | Değerlendirilen alternatifler | Neden | Etkiler |
|---|---|---|---|---|---|
| D-001 | 2026-11-18 | Motor: Godot 4 | Unity; tarayıcı (three.js) | ücretsiz ve hafif, yeni başlayan için sade; sahne ve kod dosyaları düz metin olduğundan Claude Code ile iyi çalışıyor; Android/iOS/PC çıktısı var | tümü |
| D-002 | 2026-11-18 | Kamera kendi kendine takip eder, elle döndürme isteğe bağlı | Odyssey gibi tamamen serbest kamera | telefonda iki başparmakla oynanabilirlik (Pillar 4) | [kamera](features/kamera/design.md) |
| D-003 | 2026-11-18 | Aynı anda tek yetenek | birden fazla yetenek taşıma | her bulmacada doğru yeteneği seçme kararını anlamlı kılar (Pillar 2) | [kopyalama](features/kopyalama/design.md) |
| D-004 | 2026-11-18 | Ana menü, Bip'in yürüyerek gezdiği bir atölye sahnesi; yanında her zaman hızlı liste menüsü | yalnızca klasik liste menü | oyunun dünyasına ilk saniyeden sokar ve kontrolleri menüde ısıtır (Astro Bot'un merkez alanı gibi); hızlı liste, aceleci oyuncu ve erişilebilirlik için | [ana menü](features/ana-menu/design.md) |
| D-005 | 2026-11-18 | Öğretici yazısız: ortamla öğretme, simgeler yalnızca oyuncu takılınca | yazılı öğretici ekranları | sözsüz ton ve çocuk oyuncular; Pillar 1 ve 3 | [bölüm 1](features/bolum-1/design.md) |
| D-006 | 2026-11-18 | Yalnızca otomatik kayıt (kontrol noktaları), elle kaydetme yok | elle kayıt noktaları | telefonda oyun her an kapanabilir; ilerleme kaybı en fazla 90 sn | [kayıt](features/kayit/design.md) |
| D-007 | 2026-11-18 | Godot 4.7.2; Android paket adı `io.github.ertannnc.bip`; her APK aynı anahtarla imzalanır, sürüm kodu = commit sayısı | her sürümde yeni paket adı | yeni APK telefondaki eskinin üstüne kurulur, kayıtlar silinmez | tümü (bkz. `tools/android/README.md`) |
| D-008 | 2026-11-18 | Mobil kontroller M4'ten öne çekildi | M4'e kadar beklemek | geliştirici her güncellemeyi telefonda deneyebilsin; buton yerleşimi erken oturmalı (geliştirici isteği) | [mobil kontroller](features/mobil-kontroller/design.md) |
| D-009 | 2026-11-18 | Görsel ve sesler M5'ten öne çekildi: Bip = Quaternius Animated Robot, çevre = Quaternius Ultimate Platformer Pack, sesler = Kenney, müzik = OpenGameArt (hepsi CC0). Seviye zemini ölçülü kutular; görünüşü shader'la veriliyor | asset'leri M5'te eklemek | geliştirici isteği; ölçüler kutularda kaldığı için ayar yapmak hâlâ kolay | hareket, ses, seviye (bkz. `CREDITS.md`) |
| D-010 | 2026-11-18 | Karakterlerin görünüşü bulunabilen ücretsiz (CC0) asset'lere göre seçilir; doküman tarifi asset'e uyarlanır | her karakteri tarife göre özel modelletmek | ekipte 3D sanatçı yok; geliştirici isteği | [hikaye](features/hikaye/design.md) |
| D-011 | 2026-11-18 | Yeteneği bırakmak için basılı tutma 0,6 → 1,2 sn | ayrı bir bırakma tuşu | Yay'ın şarjlı zıplaması da basılı tutmayı kullanıyor; iki tuşla yetinmek (Pillar 4) | [kopyalama](features/kopyalama/design.md) |
| D-012 | 2026-11-18 | Bölüm 2 ve 3 birer yeni yetenekle (Pervane, Buz) gelir; bölümler 3 alan + patron | her bölüm yalnızca eski 4 yetenek | Astro Bot'taki gibi her bölümde yeni bir oyuncak sürprizi (Pillar 3); kapsam için alan sayısı 3 | [bölüm 2](features/bolum-2/design.md), [bölüm 3](features/bolum-3/design.md) |
| D-014 | 2026-11-18 | Son patron Statik yenilmez, Bip ona enerji vererek ikna eder (hikaye dokümanındaki varsayım onaylandı) | kötü adamı yenmek | 8+ yaş için sıcak ton; "tek yetenek bin kullanım": anten burada da kullanılır | [bölüm 4](features/bolum-4/design.md) |
| D-015 | 2026-11-18 | Kurtarılacak kayıp robotlar eklendi | yalnızca pil ve vida | Astro Bot'un en sevilen döngüsü: kurtarılan arkadaşlar merkez alanı (Atölye) canlandırır; ilerleme görünür olur | kayıt (`robots` alanı), Atölye |
| D-016 | 2026-11-18 | Ek hareketler ilerledikçe açılır: tutunma (baştan), dönme saldırısı (Atölye sonrası), havada atılma (Bölüm 1 sonu), duvar zıplaması (Bölüm 2 sonu), çift zıplama (Bölüm 3 sonu). Yeni "Vuruş" butonu | hareket kural 9: "çift zıplama yok, yükseklik yeteneklerden" | geliştirici isteği: Bip ilerledikçe güçlensin; açılma ilerlemeden hesaplandığı için eski kayıtlar da kazanır. Yetenekler hâlâ bulmacaların anahtarı, hareketler akıcılık verir | hareket, mobil kontroller, kayıt (`moves_seen`) |
| D-017 | 2026-11-18 | Astro Bot hissi: jet süzülme baştan açık, pil yakından kendiliğinden çekilir, süsler tepki verir, kamera daha az savrulur | önceki his ("farklı geliyor") | geliştirici oyun testi; iki referans oyun öğelerine ayrıldı ([oyun hissi](features/oyun-hissi/design.md)) | hareket, kamera, toplanabilirler |
| D-013 | 2026-11-18 | Seviyeler Python üretici betiklerle (`tools/level/*.py`) yazılır, ölçülü kutular + shader + süs | her seviyeyi elle editörde kurmak | ölçüler kesin kalır, Claude Code hızlı ve tekrarlanabilir kurar; elle düzenleme isteyen sahne için betik bir daha çalıştırılmaz | tüm seviyeler |

## Open questions
- **Doğrulanacak varsayımlar:** oturum süreleri; tüm [ASSUMPTION] işaretli sayılar özellik dokümanlarında.
- **Riskler:**
  - Kopyalama mekaniği eğlenceli mi? → M2'de greybox ile oynanıp karar verilecek.
  - 3D platform telefonda rahat oynanıyor mu? → M4'te gerçek cihazda test.
  - Yeni başlayan geliştirici için kapsam büyük mü? → her kilometre taşı oynanabilir bitmeli; zaman aşılırsa Patron ve Mıknatıs ilk kesilecekler.

## Change log
**0.4 (2026-11-18):** M2 + M3 büyük ölçüde: dört yetenek, can/hasar, düşmanlar, toplanabilirler, kayıt, giriş ekranı ve Atölye, açılış/kapanış, Bölüm 1 alanları ve Hurdacı Vinç; Bölüm 2 (Pervane) ve Bölüm 3 (Buz) tasarlandı; D-011–D-013.

**0.1 (2026-11-18):** ilk taslak; hareket, kopyalama ve kamera tasarlandı; D-001–D-003 kaydedildi.
**0.2 (2026-11-18):** ana menü, kayıt, hikaye ve Bölüm 1 tasarlandı; "Seviye 1" adı "Bölüm 1" oldu, iç kısımları "alan"; vida sayısı 3 → 5; D-004–D-006 kaydedildi.
**0.3 (2026-11-18):** M1 uygulandı (hareket, kamera, test alanı, Android APK hattı); görsel ve sesler eklendi; mobil kontroller ve duraklatma menüsü yapıldı; karakterlerin asset karşılıkları belirlendi; D-007–D-010 kaydedildi (uygulama sırasında D-004–D-006 numaralarıyla yazılan kararlar, tasarımcının D-004–D-006'sıyla çakışmasın diye yeniden numaralandı).
