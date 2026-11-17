# Bip — Oyun Tasarım Dokümanı

**Sürüm:** 0.3 · **Güncelleme:** 2026-11-18 · [Özellikler](#feature-index) · [Kararlar](#decisions) · [Değişiklik kaydı](#change-log)

## Özet
Oyuncu, anteniyle dokunduğu nesnenin yeteneğini kopyalayan küçük robot Bip'i yönetir. Renkli, kısa ve sürprizlerle dolu 3D seviyelerde koşar, zıplar ve kopyaladığı yetenekleri (Yay, Balon, Mıknatıs, Kaya) yaratıcı biçimlerde kullanarak engelleri aşar, pil ve gizli altın vidalar toplar. Eğlencenin kaynağı sıkı kontroller ve her köşede yeteneğin yeni bir kullanımını keşfetmektir. Seviye, sonundaki patron yenilince biter.

| | |
|---|---|
| Tür ve kamera | 3D platform, oyuncuyu kendi kendine takip eden üçüncü şahıs kamera |
| Hedef kitle | 8 yaş ve üstü, rahat (casual) oyuncular ve platform sevenler |
| Platformlar ve kontrol | Android, iOS (dokunmatik); PC (klavye, gamepad) |
| Oturum | Bir bölüm 3–5 dk; ilk seviye toplam 10–15 dk [ASSUMPTION] |
| Motor | Godot 4, GDScript |
| Kapsam | Prototip → tek seviyelik dikey kesit (vertical slice) |
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
- **Dakikalar:** her bölüm bir yeteneği öğretir, sonra onu zorlaştırır; bölüm sonunda kontrol noktası.
- **Oturum:** son bölüm dört yeteneği birleştirir ve patronla biter; toplanan pil ve vida sayısı sonuç ekranında gösterilir.

## Feature index

| Feature | Status | Scope | Summary | Docs |
|---|---|---|---|---|
| Hareket | implemented | MVP | Koşma, değişken yükseklikte zıplama, coyote time, zıplama tamponu, havada kontrol | [design](features/hareket/design.md) |
| Kopyalama | designed | MVP | Antenle nesneden yetenek kopyalama; Yay, Balon, Mıknatıs, Kaya; hasar alınca yetenek kaybı | [design](features/kopyalama/design.md) |
| Kamera | implemented | MVP | Kendi kendine takip eden, duvardan kaçan, telefonda elle döndürme gerektirmeyen kamera | [design](features/kamera/design.md) |
| Can ve hasar | idea | MVP | 3 can; hasar önce yeteneği alır, yetenek yoksa can gider; kontrol noktasından devam | — |
| Toplanabilirler | idea | MVP | Piller (seviyeye dağılmış) ve 3 gizli altın vida | — |
| Düşmanlar | idea | MVP | 2–3 basit düşman türü; üstüne zıplayınca ya da Kaya ile ezilince yenilir | — |
| Mobil kontroller | in progress | MVP | Sol sanal joystick, sağda Zıpla ve Yetenek butonları, titreşim. M1'de test için geçici sürüm var (joystick, Zıpla, kamera kaydırma) | — |
| Seviye 1 | idea | MVP | 4 bölüm: Yay, Balon, Mıknatıs, Kaya; sonuncusu hepsini birleştirir | — |
| Patron | idea | MVP | Tüm yetenekleri kullanmayı gerektiren 3 aşamalı küçük patron | — |
| Arayüz ve menüler | idea | MVP | Başlangıç, duraklatma, sonuç ekranı; pil ve vida sayacı | — |
| Ses ve müzik | in progress | MVP | Her eyleme ses; bölüm müziği. Zıplama, iniş, adım, düşme sesleri ve test alanı müziği var | — |
| Kayıt sistemi | idea | later | Toplanan vidaların ve açılan seviyelerin kaydı | — |
| Yeni yetenekler | idea | later | Ör. Pervane, Buz, Lastik top | — |

## Milestones
1. **M1, greybox hareket + kamera:** hareket, kamera; basit küplerden bir test alanı · bitti sayılır: PC'de 2 m'lik bir boşluk ve 1,5 m'lik bir basamak ilk denemede rahatça aşılıyor.
2. **M2, kopyalama çekirdeği:** kopyalama (önce yalnızca Yay), can ve hasar · bitti sayılır: Yay olmadan ulaşılamayan bir platforma Yay kopyalanarak çıkılıyor, hasar alınca yetenek kayboluyor.
3. **M3, dört yetenek + Seviye 1 greybox:** Balon, Mıknatıs, Kaya; 4 bölüm; toplanabilirler; düşmanlar · bitti sayılır: seviye baştan sona greybox halinde oynanabiliyor.
4. **M4, telefon:** mobil kontroller, Android çıktısı · bitti sayılır: seviye bir Android telefonda 60 fps'ye yakın ve yalnızca dokunmatikle bitirilebiliyor.
5. **M5, cila:** Kenney/Quaternius asset'leri, ses, efektler, patron, menüler · bitti sayılır: ilk kez oynayan biri seviyeyi yazı okumadan bitirebiliyor.

## Direction
- **Sanat:** renkli low-poly, yumuşak ışık, sade dokular. Tehlikeli şeyler kırmızı/turuncu ve sivri; güvenli ve kopyalanabilir şeyler belirgin bir parıltıyla işaretli. Asset kaynakları ve lisans kuralları: `CLAUDE.md`.
- **Oyun hissi:** zıplama, iniş ve kopyalama her zaman görüntü + ses + (telefonda) titreşimle karşılık bulur; Bip zıplarken uzar, inerken ezilir.
- **Ton:** neşeli, sözsüz; Bip konuşmaz, tepkilerini animasyon ve seslerle verir.
- **Erişilebilirlik:** yazı gerektirmeyen öğretim; renk dışında şekille de ayrılan tehlikeler.

## Decisions

| ID | Tarih | Karar | Değerlendirilen alternatifler | Neden | Etkiler |
|---|---|---|---|---|---|
| D-001 | 2026-11-18 | Motor: Godot 4 | Unity; tarayıcı (three.js) | ücretsiz ve hafif, yeni başlayan için sade; sahne ve kod dosyaları düz metin olduğundan Claude Code ile iyi çalışıyor; Android/iOS/PC çıktısı var | tümü |
| D-002 | 2026-11-18 | Kamera kendi kendine takip eder, elle döndürme isteğe bağlı | Odyssey gibi tamamen serbest kamera | telefonda iki başparmakla oynanabilirlik (Pillar 4) | [kamera](features/kamera/design.md) |
| D-003 | 2026-11-18 | Aynı anda tek yetenek | birden fazla yetenek taşıma | her bulmacada doğru yeteneği seçme kararını anlamlı kılar (Pillar 2) | [kopyalama](features/kopyalama/design.md) |
| D-004 | 2026-11-18 | Godot 4.7.2; Android paket adı `io.github.ertannnc.bip`; her APK aynı anahtarla imzalanır, sürüm kodu = commit sayısı | her sürümde yeni paket adı | yeni APK telefondaki eskinin üstüne kurulur, kayıtlar silinmez | tümü (bkz. `tools/android/README.md`) |
| D-005 | 2026-11-18 | Geçici dokunmatik kontroller M1'e alındı | M4'e kadar beklemek | geliştirici her güncellemeyi telefonda deneyebilsin | mobil kontroller |
| D-006 | 2026-11-18 | Görsel ve sesler M5'ten öne çekildi: Bip = Quaternius Animated Robot, çevre = Quaternius Ultimate Platformer Pack, sesler = Kenney, müzik = OpenGameArt (hepsi CC0). Seviye zemini hâlâ ölçülü kutular; görünüşü shader'la veriliyor | asset'leri M5'te eklemek (CLAUDE.md'deki greybox kuralı) | geliştirici isteği: daha güzel görünen bir sürüm; ölçüler kutularda kaldığı için ayar yapmak hâlâ kolay | hareket, ses, seviye (bkz. CREDITS.md) |

## Open questions
- **Doğrulanacak varsayımlar:** oturum süreleri; tüm [ASSUMPTION] işaretli sayılar özellik dokümanlarında.
- **Riskler:**
  - Kopyalama mekaniği eğlenceli mi? → M2'de greybox ile oynanıp karar verilecek.
  - 3D platform telefonda rahat oynanıyor mu? → M4'te gerçek cihazda test.
  - Yeni başlayan geliştirici için kapsam büyük mü? → her kilometre taşı oynanabilir bitmeli; zaman aşılırsa Patron ve Mıknatıs ilk kesilecekler.

## Change log
**0.3 (2026-11-18):** görsel sürüm: robot model ve animasyonlar, çimenli adalar, ağaç/çalı/bulut süsleri, deniz, sesler ve müzik; D-006 eklendi.

**0.2 (2026-11-18):** M1 uygulandı: Godot projesi, Bip hareketi, takip kamerası, greybox test alanı, geçici dokunmatik kontroller, Android APK hattı; D-004, D-005 eklendi.

**0.1 (2026-11-18):** ilk taslak; hareket, kopyalama ve kamera tasarlandı; D-001–D-003 kaydedildi.
