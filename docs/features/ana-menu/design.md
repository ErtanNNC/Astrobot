# Ana menü

**Status:** implemented · **Updated:** 2026-11-18 · [GDD](../../GDD.md)

Menü de oyunun bir parçasıdır. Giriş ekranından sonra oyuncu klasik bir listeye değil, Bip'in kendi **Atölyesi**ne girer: Bip'i yürütüp nesnelere giderek oyuna başlar, ayarları açar, koleksiyonuna bakar (D-004). Böylece oyuncu ilk saniyeden kontrolleri ısıtır ve oyunun hissini alır. Aceleci oyuncular ve erişilebilirlik için aynı seçenekler her an tek dokunuşla bir **Hızlı Menü** listesinden de açılır.

## Ekran akışı
```
Açılış logoları → Giriş ekranı → Atölye (ana menü) ⇄ Ayarlar / Kayıt yuvaları / Koleksiyon / Sahneler
Atölye → Oyun ⇄ Duraklatma → (Ayarlar) → Atölye'ye dön
```
Ekranlar bir yığın (stack) gibi çalışır: üstteki ekran girdiyi alır, "Geri" bir öncekine döner.

## Giriş ekranı
- Gece, hafif yağmur. Bip şarj istasyonunda uyuyor, anteni yavaşça yanıp sönüyor; Pırıl etrafında dolaşıyor. Oyun logosu ekranın üstünde.
- "Başlamak için dokun / bir tuşa bas" yazısı yavaşça nefes alıp verir.
- Ekrana dokunmak Bip'i uyandırır (kısa animasyon, titreşim) ve kamera kesintisiz Atölye'ye kayar.
- 20 sn dokunulmazsa Pırıl, Bip'in antenine konup kıvılcım çıkarır; sevimli bir bekleme animasyonu.

## Atölye (ana menü)
**Alan Seç (2026-11-21):** kayıt kapsülünün panelinde "Alan Seç": o yuvada ulaşılan en uzak alana kadar bütün alanlar bölüm bölüm listelenir ve yeniden oynanabilir (eksik pil ve vidaları toplamak için). Ayarlar'daki **"Tüm alanlar açık (test)"** seçeneği geliştirici testi içindir; mağaza sürümünden önce kaldırılacak.

**Görünüş (2026-11-21):** KayKit Restaurant Bits ve Furniture Bits (CC0) parçalarıyla sıcak bir oda: alt duvarlar turkuaz lambri, üstte ahşap kaplama ve tavan kirişleri; kuzeyde gerçek kapı boşluğuna oturan kapı (oyna) ve yağmurlu bahçeye bakan açık pencere; çalışma tezgâhı, raflar, tablolar, halılar, ayaklı lambalar, koltuk. Modeller çarpışmasızdır, çarpışma görünmez kutulardadır. Üretici: `tools/level/hub.py`. Eski sürümde kapı duvardaki boşluğa oturmuyordu ve pencere düz mavi bir levhaydı.

Küçük, sıcak ışıklı bir oda. Bip oyun içindeki kontrollerle yürür ve zıplar. Bir nesnenin önüne gelince nesne parlar, üstünde ne yaptığını gösteren bir simge belirir; Yetenek tuşu seçer.

| Nesne | İşlev |
|---|---|
| **Büyük kapı** | Oyna: kayıt yuvası seçimini açar. Kayıt varsa üstünde "Devam" simgesi parlar ve son yuvayı direkt yükler. |
| **Üç şarj kapsülü** | Kayıt yuvaları ([kayıt](../kayit/design.md)). Her kapsülde o kayıttaki ilerleme küçük bir hologramla görünür. |
| **Eski televizyon** | Ayarlar; içinden "Sahneler" ile izlenen ara sahneler ([hikaye](../hikaye/design.md)). |
| **Vitrin** | Koleksiyon: toplanan altın vidalar, Çekirdek Piller ve her bölümün pil sayısı. |
| **Oyuncak kutusu** | Kopyalanabilir oyuncaklar: menüde dört yeteneği serbestçe deneme alanı (yalnızca açılmış yetenekler). |
| **Şalter** | Çıkış (yalnızca PC). |

- Telefonda bir nesneye dokunmak Bip'i oraya yürütür ve seçeneği açar; yani Atölye'de joystick kullanmak zorunlu değildir.
- Gamepad/klavyede yön tuşları nesneler arasında odak gezdirir; ilk odak her zaman büyük kapıdadır.
- Sağ üst köşedeki **≡ Hızlı Menü** düğmesi her zaman görünür: Devam, Yeni Oyun, Kayıtlar, Ayarlar, Koleksiyon, Çıkış listesini açar.
- Atölye, açılan bölümlerle gelişir: Çekirdek Pil geri getirildikçe ışıklar artar, vitrine yeni şeyler gelir.

## Ayarlar
Değişiklikler anında uygulanır ve kayıt yuvalarından bağımsız bir ayar dosyasına yazılır. "Varsayılana dön" her sekmede bulunur.

| Sekme | Seçenekler |
|---|---|
| **Ses** | Genel, Müzik, Efektler (0–100) |
| **Kontroller** | Dokunmatik buton boyutu (Küçük/Orta/Büyük), buton saydamlığı, buton yerlerini sürükleyip düzenleme, sol el modu (joystick sağda), titreşim açık/kapalı |
| **Kamera** | Hassasiyet, yatay/dikey ters çevirme, otomatik kamera dönüşü açık/kapalı |
| **Görüntü** | Kalite (Düşük/Orta/Yüksek), kare hızı sınırı (30/60), gölgeler açık/kapalı |
| **Erişilebilirlik** | Ekran sarsıntısı açık/kapalı, Pırıl ipuçları açık/kapalı, alt yazı boyutu (menü metinleri) |
| **Dil** | Türkçe, English (ilk açılışta cihaz diline göre seçilir) |

## Duraklatma menüsü
Oyun içinde Duraklat (telefon: sol üst düğme, PC: Esc). Seçenekler: Devam, Kontrol noktasından başla, Ayarlar, Atölye'ye dön. Arka planda oyun bulanıklaşır, Bip sabırla bekler. Telefon arka plana alınınca oyun otomatik duraklar.

## Rules
1. Her ekranda bir öğe seçili açılır; odak modal pencerelerin dışına kaçmaz.
2. Tüm önemli arayüz telefonun güvenli alanının (çentik, köşe yuvarlaklığı) içinde kalır.
3. Arayüz 1920×1080 referans çözünürlükte tasarlanır ve ölçeklenir; telefon dikey tutulursa "telefonu yan çevir" simgesi gösterilir.
4. "Yeni Oyun" dolu bir yuvanın üzerine yazacaksa onay ister.
5. Menüden oyuna geçiş 3 saniyeden kısa sürer (yükleme ekranında Bip koşar).

## Numbers
| Ad | Değer | Birim | Testte neye bakılmalı |
|---|---|---|---|
| Giriş → Atölye geçişi | 1,5 [ASSUMPTION] | s | |
| Bekleme animasyonu gecikmesi | 20 [ASSUMPTION] | s | |
| En küçük dokunma alanı | 48 [ASSUMPTION] | dp | küçük telefonda isabet |
| Menüden oyuna yükleme | < 3 | s | orta segment Android |

## Edge cases
- İlk açılışta kayıt yoksa büyük kapı doğrudan Yeni Oyun'u (boş yuva 1) başlatır.
- Atölye'de Bip bir köşeye sıkışamaz, odadan düşemez.
- Kayıt dosyası bozuksa kapsül "onarılıyor" animasyonu gösterir ve yedekten yükler; yedek de yoksa uyarı gösterir ([kayıt](../kayit/design.md)).

## Open questions
- [ASSUMPTION] Tuş atamayı değiştirme (PC/gamepad) ilk sürüme gerekli mi? Şimdilik hayır.

## Uygulama notları
- Kodda: `scripts/ui/hub.gd` (giriş + Atölye aynı sahne: `scenes/ui/hub.tscn`, üretici `tools/level/hub.py`), menü nesneleri `scripts/ui/menu_object.gd`, duraklatma `scripts/ui/pause_menu.gd`, ortak buton görünüşü `scripts/ui/ui_kit.gd`.
- Yapıldı: giriş ekranı (gece, yağmur penceresi, uyuyan Bip, dokununca uyanma), Atölye nesneleri (kapı, 3 kapsül + hologram, TV = ayarlar, vitrin = koleksiyon, oyuncak kutusu = açılmış yetenekleri deneme, şalter = çıkış/PC), ≡ Hızlı Menü, yuva paneli (devam / yeni oyun onaylı / sil iki adım), telefonda nesneye dokunarak seçme, duraklatma menüsü (Devam, Kontrol noktasından başla, Ayarlar, Atölye'ye dön).
- Ayarlarda: buton boyutu, sol el modu, titreşim, Pırıl ipuçları, ekran sarsıntısı, görüntü kalitesi, gölgeler; Genel/Müzik/Efektler ses kaydırıcıları (0–100).
- Kapı: kayıtta birden fazla alan açılmışsa "Nereye gidelim?" paneli açılır: Devam, En ileri nokta ve açılmış her alan (Altın Vidası alınmış alanlar ✓ ile). Kaçırılan vidalar için alanlar yeniden oynanır; kayıtta en ileri alan (`furthest`) ayrı tutulur.
- TV: Ayarlar + izlenen ara sahneler (Fırtına Gecesi, Işıklar Geri Geldi).
- Henüz yok: buton yerlerini sürükleme, kamera ve görüntü sekmeleri, dil seçimi, açılış logoları.

## History
- 2026-11-18: tasarlandı.
- 2026-11-18: uygulandı (eksikler yukarıda).

**Kolay mod (2026-11-22):** Ayarlar → "Kolay mod". Açıkken düşmek can götürmez ve her kontrol noktası canları doldurur. Yıldız ve rekorlar aynı sayılır (küçük oyuncular cezalandırılmasın). Kod: `Settings.easy_mode`, `area.gd` (`_fall`, `on_checkpoint`).
**Rekor hayaleti:** Ayarlar'dan kapatılabilir (`docs/features/geri-donme/design.md`). **Başarımlar:** Koleksiyon → Başarımlar.
**Büyük arayüz (2026-11-22):** Ayarlar → "Büyük arayüz". Bütün 2B arayüz (yazılar, butonlar, göstergeler, dokunmatik butonlar) %15 büyür (`Settings.ui_big`, pencerenin `content_scale_factor` değeri). 3B görüntü etkilenmez.
**Renk körlüğü:** oyunda bilgi yalnızca renkle verilmez: tehlikeler şekil ve hareketle de ayrılır (dikenler, dolan uyarı diski), gizli topların üstünde "?" işareti vardır. Ayrı bir renk modu yok.
**Alan haritası (2026-11-22):** Alan Seç'te bir bölüm seçilince liste yerine harita açılır: alanlar kıvrılan bir yol üstünde yuvarlak duraklardır (82 px; patron 92 px ve kırmızı, "!" işaretli). Bitirilen durak yeşil, açık ama bitirilmemiş mavi, kilitli soluk. Her durağın üstünde üç yıldız, altında adı ve rekor süresi. Kod: `hub._area_map`.
**Ayarlar penceresi (2026-11-22, geliştirici testinden):** ayar listesi kaydırılır (330 px yüksekliğinde); başlık ve alt düğmeler ("Oynanış kaydını kopyala", "Tüm ilerlemeyi sil", "Lisanslar", "Geri") hep görünür. Eskiden liste uzadıkça bütün pencere küçültülüyordu; telefonda bir ayar değişince küçültme bozuluyor, pencere büyüyüp "Geri" ekran dışına çıkıyordu. Her ayar değişiminden sonra pencere yeniden sığdırılır. Test: `tests/settings_test.tscn`.
