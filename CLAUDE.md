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
