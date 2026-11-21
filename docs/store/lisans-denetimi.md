# Lisans denetimi (2026-11-21)

Amaç: mağazaya çıkmadan önce oyundaki her asset'in ticari kullanıma uygun olduğunu doğrulamak. Liste `CREDITS.md` ile aynı sırada.

## Sonuç
Engel yok. Hiçbir asset CC-BY-NC, CC-BY-ND ya da lisanssız değil. İsim vermek zorunlu olan tek şey yazı tipi (OFL: lisans metni oyunla birlikte dağıtılmalı; `assets/fonts/nunito/OFL.txt` pakette).

| Grup | Lisans | Nasıl doğrulandı | Durum |
|---|---|---|---|
| OpenGameArt müzikleri (9 parça) | CC0 | 2026-11-21'de her sayfa yeniden açıldı; hepsinde yalnızca "CC0" yazıyor | uygun |
| OpenGameArt ortam ve adım sesleri (7 kaynak) | CC0 | eklerken sayfadaki lisans okundu | uygun |
| OpenGameArt'taki Kenney ve Quaternius paketleri (Holiday Kit, Factory Kit, Game Icons, Pirate Pack) | CC0 | sayfalar yeniden açıldı; paketlerdeki lisans dosyaları klasörlerde | uygun |
| KayKit paketleri (itch.io) | CC0 | paketlerle gelen lisans dosyaları klasörlerde | uygun |
| Quaternius paketleri (quaternius.com) | CC0 | paket lisans dosyaları | uygun; ham model olarak yeniden satılamaz (satmıyoruz) |
| Kenney sesleri ve arayüzü | CC0 | lisans dosyaları `assets/audio/kenney/` içinde | uygun |
| Nunito yazı tipi | SIL OFL 1.1 | `OFL.txt` | uygun; Emeği Geçenler'de adı var |
| Bip modeli ve Paslı Kaptan modeli (Pixabay) | Pixabay Content License | lisans özeti okundu; pixabay.com bu ortamdan açılamadığı için model sayfaları yeniden kontrol edilemedi | uygun, aşağıdaki notlarla |
| Bip'in animasyonları (Mixamo) | Adobe Mixamo koşulları | SSS: oyunlarda ticari kullanım serbest, telifsiz | uygun |
| Godot Engine | MIT | | uygun; lisans metni oyunda gösterilmeli (aşağıda) |

## Dikkat edilecekler
1. **Pixabay modelleri:** lisans oyunda kullanmaya izin verir ama modeli tek başına dağıtmayı yasaklar. Ham `.fbx/.glb` dosyaları repoda durduğu için **repo özel kalmalı** (şu an özel). Geliştirici iki model sayfasını tarayıcıda açıp lisansın hâlâ "Pixabay Content License" olduğunu ve yükleyenin adını `CREDITS.md`'ye not etmeli (şu an "Pixabay kullanıcısı" yazıyor).
2. **Ana karakter hazır bir model:** aynı robot başka oyunlarda da kullanılabilir. Hukuki engel değil, marka açısından zayıflık; ileride özgün bir model yaptırmak iyi olur.
3. **Godot lisans metni:** MIT lisansı metnin ürünle birlikte verilmesini ister. Emeği Geçenler'de "Motor: Godot Engine" yazıyor; tam MIT metni ve üçüncü taraf bildirimleri Emeği Geçenler'in sonuna eklendi (`credits.gd`, `Engine.get_license_text()`). Motorun içindeki üçüncü taraf kitaplıkların bildirimleri (`Engine.get_copyright_info()`) eklenmedi; mağaza öncesi ayarlara bir "Lisanslar" sayfası olarak konmalı.
4. **Sonniss / Freesound / Incompetech:** kullanılmıyor.
5. **Yapay zekâ:** oyunda yapay zekâyla üretilmiş görsel ya da ses yok; kod bir yapay zekâ yardımcısıyla yazıldı (mağaza formlarında sorulursa).
