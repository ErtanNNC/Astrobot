# Ana menü

**Status:** designed · **Updated:** 2026-11-18 · [GDD](../../GDD.md)

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

## History
- 2026-11-18: tasarlandı.
