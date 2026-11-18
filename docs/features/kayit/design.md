# Kayıt

**Status:** implemented · **Updated:** 2026-11-18 · [GDD](../../GDD.md)

Oyuncu hiçbir zaman ilerleme kaybetmekten korkmamalı. Oyun kontrol noktalarında kendiliğinden kaydeder; telefon aniden kapansa bile en fazla 90 saniyelik oynanış kaybolur (D-006). Üç kayıt yuvası, aynı cihazı paylaşan kardeşlerin ayrı oynamasına izin verir.

## Rules
1. Üç kayıt yuvası vardır. Yuvalar Atölye'deki üç şarj kapsülüdür ([ana menü](../ana-menu/design.md)).
2. Otomatik kayıt: her kontrol noktasında, alan geçişinde, bölüm bitince ve duraklatmadan "Atölye'ye dön" seçilince. Telefon arka plana alınınca da kaydedilir.
3. Kaydederken ekranın köşesinde Bip'in dönen anteni simgesi görünür; oyun durmaz.
4. Ayarlar ayrı bir dosyadadır ve tüm yuvalar için ortaktır.
5. Kayıt nesneleri değil veriyi saklar: kimlikler (ID), sayılar ve bayraklar.
6. Her kayıtta tam sayı bir `version` alanı vardır; eski sürüm kayıtlar adım adım yeni sürüme dönüştürülür, daha yeni sürümden gelen kayıt reddedilir.
7. Yazma güvenlidir: önce geçici dosyaya yazılır, eski kayıt `.bak` olarak saklanır, sonra yeni dosya yerine konur. Yükleme başarısız olursa `.bak` denenir ve oyuncuya bildirilir.
8. Yuva silme iki adımlı onay ister.

## Bir yuvada saklananlar
| Alan | Açıklama |
|---|---|
| `version` | kayıt biçimi sürümü |
| `chapter`, `checkpoint_id` | bulunulan bölüm ve son kontrol noktası |
| `ability` | kontrol noktasına ulaşıldığında taşınan yetenek |
| `unlocked_abilities` | açılmış yetenekler (Atölye oyuncak kutusu için) |
| `batteries` | toplanan pillerin kimlikleri (bölüme göre) |
| `golden_screws` | toplanan altın vidaların kimlikleri |
| `core_cells` | geri alınan Çekirdek Piller |
| `seen_cutscenes` | izlenen ara sahneler |
| `play_time`, `last_played` | toplam oyun süresi, son oynama tarihi |

Kapsül hologramında görünen tamamlanma yüzdesi bu verilerden hesaplanır, ayrıca saklanmaz.

## Numbers
| Ad | Değer | Birim | Testte neye bakılmalı |
|---|---|---|---|
| Kayıt yuvası | 3 | adet | |
| En fazla ilerleme kaybı | 90 | s oynanış | |
| İki otomatik kayıt arası en az | 10 [ASSUMPTION] | s | art arda kontrol noktalarında gereksiz yazma |
| Kayıt simgesi görünme süresi | 1,0 [ASSUMPTION] | s | |

## Edge cases
- Kayıt sırasında uygulama kapanırsa: bir sonraki açılışta ya yeni ya `.bak` dosyası yüklenir, hiçbir zaman yarım dosya.
- Disk dolu ya da yazma hatası: oyuncuya küçük bir uyarı gösterilir, oyun devam eder ve bir sonraki kontrol noktasında tekrar denenir.
- Bir güncellemeyle pil kimlikleri değişirse: dönüştürme adımı eski kimlikleri yenilere eşler.
- Ara sahne sırasında kaydedilmez.

## Open questions
- [ASSUMPTION] Bulut kaydı (Google Play / iCloud) ilk sürümde yok.

## Uygulama notları
- Kodda: `scripts/autoload/game_state.gd` (autoload `GameState`). Yuvalar `user://slot_0.json` … `slot_2.json`; yazma önce `.tmp`, eski dosya `.bak`, sonra yerine koyma. Okuma başarısızsa `.bak` denenir.
- Ayarlar ayrı: `user://settings.cfg` (`scripts/autoload/settings.gd`).
- Ekstra alanlar: `checkpoint_ability` (kontrol noktasındaki yetenek), `chapter`, `furthest` (ulaşılan en ileri alan), `robots` (kurtarılan robot kimlikleri: `<alan>_<kontrol noktası>`), `game_complete`.
- Kaydetme anları: kontrol noktası (en az 10 sn arayla), alan geçişi, Altın Vida, Çekirdek Pil, duraklatmadan Atölye'ye dönüş, telefon arka plana alınınca.

## History
- 2026-11-18: tasarlandı.
- 2026-11-18: uygulandı.
