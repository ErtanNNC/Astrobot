# Bip — 3D Platform Oyunu (Godot)

## Proje özeti
- Motor: Godot 4 (güncel kararlı sürüm), dil: GDScript.
- Tür: Astro Bot / Mario Odyssey tarzı 3D platform oyunu.
- Platformlar: Android, iOS, PC (ve istenirse Web).
- Geliştirici yeni başlıyor: her adımı küçük tut, Godot editöründe ne yapacağını basit Türkçe ile anlat, her adımın sonunda test etmesini iste.

## Tasarım dokümanları
- Oyunun tasarımı `docs/GDD.md` dosyasında; her özelliğin kuralları ve sayıları `docs/features/<özellik>/design.md` içinde. Kod yazmadan önce ilgili dokümanı oku.
- Sayıları (hız, zıplama yüksekliği vb.) dokümandan al ve kodda tek bir yerde (`@export` değişkenleri ya da bir ayar dosyası) tut.
- Kod tasarımdan farklı olursa ya da oyun testinden sonra bir sayı değişirse, ilgili `design.md` dosyasını ve GDD'deki durum sütununu güncelle.
- Kilometre taşlarını (M1, M2, ...) GDD'deki sırayla uygula; her biri oynanabilir bitmeli.

## Geliştiricinin kalıcı istekleri
- **Karakterler bulunabilen asset'lere göre:** karakter ve düşman görünüşleri için doküman tarifine birebir uymak gerekmez. Önce aşağıdaki kaynaklardan uygun hazır (tercihen animasyonlu) bir model bul, tarifi ona uyarla ve `docs/features/hikaye/design.md` içindeki "Karakterlerin görünüşü" tablosunu güncelle.
- **Telefon kontrolleri önemli:** butonlar telefon oyunlarındaki gibi başparmakların doğal durduğu yerde, büyük ve hızlı ulaşılır olmalı. Kurallar ve ölçüler `docs/features/mobil-kontroller/design.md` içinde; yeni bir buton eklerken oraya uy.
- **APK'lar güncellenebilir olmalı:** her APK `tools/android/build_apk.sh` ile, aynı anahtarla ve artan sürüm koduyla üretilir; yeni sürüm telefondaki eskinin üstüne kurulur.
- **Bu çalışma ortamında erişilebilen kaynaklar:** quaternius.com ve quaternius.itch.io, kaylousberg.itch.io, opengameart.org, Kenney'nin GitHub'ı (github.com/KenneyNL). kenney.nl, Poly Haven, ambientCG, Freesound, Poly Pizza erişilemiyor.

## Proje durumu ve mimari (2026-11-21)
- **Oyun:** giriş + Atölye ana menüsü (Kostüm Dolabı, Alan Seç), 4 bölüm (15 alan + 4 patron) + final sonrası bonus Bölüm 5 (4 alan, patronsuz), açılış/kapanış/final, Emeği Geçenler, pille açılan 7 kostüm, 6 yetenek (Yay, Balon, Mıknatıs, Kaya, Pervane, Buz), ilerledikçe açılan 5 hareket (`GameState.MOVES`: tutunma, dönme/Vuruş, atılma, duvar zıplaması, çift zıplama), kurtarılacak robotlar, 3 kayıt yuvası.
- **Autoload'lar:** `GameState` (kayıt, can, yetenek, bölüm listesi `CHAPTERS`), `Settings`, `Sfx`, `Fx`, `Scenes` (geçiş), `TouchInput`, `Haptics`.
- **Oyuncu:** `scripts/player/bip.gd` (hareket + tüm yetenekler, sayılar `@export`), `bip_visuals.gd` (animasyon, ses, renk, iniş gölgesi).
- **Seviyeler** Python üreticilerle yazılır: `tools/level/lvl.py` kütüphanesi + her alan için `tools/level/chN_*.py` → `scenes/chapterN/*.tscn`. `L.top()` ile yazılan zeminlerin üstü KayKit karolarıyla kaplanır (görsel; `scripts/level/kit_batch.gd` MultiMesh ile çizer), `L.kit(model, x, y, z)` KayKit süsü ekler; `L.model(yol, ...)` assets/models altındaki herhangi bir glTF/GLB/FBX'i çarpışmasız ekler, `L.solid(...)` görünmez çarpışma kutusu, `L.scatter(...)` süs serpiştirir. Kar/bulut zeminlerinin kenarları otomatik süslenir (`_edge_dress`). Katmanlı kaya için `strata`/`qstrata` temaları, taş kale için `castle`. Bir alanı değiştirmek için betiği düzenle ve `python3 tools/level/<betik>.py` çalıştır; sahneyi editörde elle düzenlediysen betiği bir daha çalıştırma.
- **Her alanın kökü** `scripts/level/area.gd` (kontrol noktası, düşme, alan sonu, patron kancaları); ortak oyun düzeneği `scenes/common/game_rig.tscn` (Bip, kamera, Pırıl, HUD, dokunmatik, duraklatma).
- **Varlıklar** `scripts/entities/` (pil, vida, kontrol noktası, düşman, tuzak, rüzgâr, metal, çatlak, buton, kapı, su/lav (`water_zone` `lava=true`), platformlar, `prop` süsleri: balon, yunus, kar, model...), patronlar `scripts/boss/`. Düşman görünüşü bölüme göre değişir (`enemy.gd` `CHAPTER_SKINS`). Yan rüzgâr yerdeki Bip'i de iter (`bip.gd` `_wind_push`).
- **Asset paketleri (hepsi CC0):** `assets/models/kaykit/{platformer,restaurant,furniture,forest,spacebase,medieval,holiday}`, `kenney/{platformer,factory,holiday}`, `quaternius/{platformer,enemies,easy_enemies,fish,pirate}`, `pixabay/bip` (Bip). Ayrıntı CREDITS.md.
- **Testler** (`godot --headless --path . tests/<ad>.tscn`): `compile_check`, `m2_test`, `abilities_test`, `boss_test`, `ch1_areas_test`, `ch2_test`, `ch3_test`, `ch4_test`, `ch5_test`, `chapter_flow_test` (dört bölüm + final + bonus açılışı), `moves_test` (ilerledikçe açılan hareketler), `hub_touch_test` (Atölye'de dokunmatik; xvfb ile çalıştırılır), `soak_test` (rastgele girdi; çıktıda ERROR olmamalı). Bir değişiklikten sonra hepsini çalıştır.
- **Dokunmatik tuzak:** telefondaki butonlar `Input.action_press` kullanır, giriş olayı üretmez. Tuşları `_unhandled_input` olaylarıyla değil, `Input.is_action_just_pressed` ile her karede kontrol et.
- **Çarpışma katmanları:** 1 = dünya (zemin, duvar, metal), 2 = küçük süsler/sandıklar (Bip çarpar, kamera kolu çarpmaz), 4 = düşmanlar, 8 = Atölye menü nesneleri (dokunma ışını).
- **Bu ortamda Godot:** Godot 4.7.2 ve şablonlar oturum geçici klasöründe; yoksa github.com/godotengine/godot/releases'ten indir. Android SDK indirilemiyor; `tools/android/build_apk.sh` yer tutucu SDK ile imzasız APK alıp `ApkSign.java` ile imzalar.

## Ücretsiz asset kaynakları
Öncelik sırası: önce CC0 (ücretsiz, ticari kullanım serbest, isim vermek zorunlu değil) kaynaklar. Godot için 3D modellerde GLB/glTF formatını tercih et.

### 3D modeller
| Kaynak | Adres | Lisans | Ne için |
|---|---|---|---|
| Kenney | kenney.nl | CC0 | Platform Kit, Nature Kit, Factory Kit vb. Tutarlı stil, GLB/glTF. İlk tercih. |
| Kenney All-in-1 | kenney.itch.io/kenney-game-assets | CC0 | Tüm Kenney paketleri tek indirmede |
| Quaternius | quaternius.com | CC0 (ham asset olarak yeniden satılamaz) | Animasyonlu low-poly karakterler, düşmanlar, Universal Animation Library |
| KayKit (Kay Lousberg) | kaylousberg.itch.io | Ücretsiz paketler CC0 | Rig'li/animasyonlu karakterler, doğa, prop'lar. Mobil için optimize |
| Poly Pizza | poly.pizza | Model başına CC0 veya CC-BY | 10.000+ low-poly model; lisans filtresi kullan |
| Sketchfab | sketchfab.com | Model başına karışık | Sadece CC0 / CC-BY filtresiyle; CC-BY-NC kullanma |
| itch.io | itch.io/game-assets/free/tag-3d | Paket başına karışık | Her sayfada lisansı kontrol et; lisans yazmıyorsa kullanma |
| OpenGameArt | opengameart.org | Karışık (CC0, CC-BY, GPL) | CC0 olanları tercih et |

### Doku, gökyüzü (HDRI), malzeme
| Kaynak | Adres | Lisans |
|---|---|---|
| Poly Haven | polyhaven.com | CC0 |
| ambientCG | ambientcg.com | CC0 |

### Ses ve müzik
| Kaynak | Adres | Lisans | Not |
|---|---|---|---|
| Kenney Audio | kenney.nl (Audio kategorisi) | CC0 | Arayüz, zıplama, toplama sesleri |
| Sonniss GDC Bundle | sonniss.com/gameaudiogdc | Telifsiz, ticari serbest | Büyük stüdyo kalitesinde SFX arşivi; AI eğitiminde kullanılamaz |
| Freesound | freesound.org | Ses başına (CC0 / CC-BY / CC-BY-NC) | CC0 filtresi kullan; CC-BY-NC kullanma |
| Pixabay Music | pixabay.com/music | Pixabay Lisansı | İsim vermeden müzik |
| Incompetech | incompetech.com | CC-BY 4.0 | İsim vermek zorunlu |

## Asset kuralları
- Kullanılan her asset için `CREDITS.md` dosyasına şunları yaz: dosya adı, kaynak adresi, yazar, lisans, tarih.
- CC-BY olanlar için oyun içi "Emeği Geçenler" ekranına isim ekle.
- CC-BY-NC, CC-BY-ND veya lisansı belirtilmemiş hiçbir şeyi kullanma.
- Asset'leri `assets/models`, `assets/textures`, `assets/audio` altında, kaynağa göre alt klasörlerde tut.
- Prototipte önce basit şekillerle (greybox) çalış; asset'leri mekanik eğlenceli olunca ekle.
- Ekleme sonrası modelin ölçeğini, pivot noktasını ve çarpışma şeklini oyun içinde kontrol et.
