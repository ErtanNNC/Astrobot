# Kopyalama

**Status:** implemented · **Updated:** 2026-11-18 · [GDD](../../GDD.md)

Oyunun kancası. Bip, anteniyle kopyalanabilir bir nesneye dokunarak onun yeteneğini alır; yetenek bir sonraki kopyalamaya ya da hasara kadar kalır. Bölüm 1'in her alanı bir yeteneği öğretip sonra zorlaştırır; son alan dördünü birleştirir ([Bölüm 1](../bolum-1/design.md)). "Tek yetenek, bin kullanım" pillar'ına hizmet eder.

## Rules
1. Kopyalanabilir nesneler hafifçe parlar; Bip yaklaşınca anteninde bir ışık yanar.
2. **Yetenek tuşu** (PC: E, telefon: Yetenek butonu) bağlama göre çalışır: menzilde kopyalanabilir nesne varsa kopyalar; yoksa taşınan yeteneğin aktif eylemini yapar.
3. Kopyalama kısa bir animasyondur (anten nesneye uzanır); bu sırada Bip hareket edebilir.
4. Aynı anda tek yetenek taşınır; yenisi kopyalanınca eskisi kaybolur (D-003). Bip'in rengi ve üstündeki küçük bir simge taşınan yeteneği gösterir.
5. Hasar alındığında önce yetenek kaybolur (can gitmez); yetenek yokken alınan hasar can götürür.
6. Yetenek tuşu basılı tutulursa yetenek bilerek bırakılır.
7. Kopyalanabilir nesneler kopyalanınca yok olmaz; sınırsız kopyalanabilir.

### Yetenekler
| Yetenek | Kaynak nesne | Pasif etki | Aktif eylem (Yetenek tuşu) |
|---|---|---|---|
| **Yay** | yay / trambolin | normal zıplama yerine yaylı süper zıplama | yerdeyken basılı tutup bırakınca daha yüksek "şarjlı" zıplama [ASSUMPTION] |
| **Balon** | balon | — | havadayken zıplamayı basılı tutunca süzülme |
| **Mıknatıs** | mıknatıs | küçük metal nesneler Bip'e çekilir | menzildeki en yakın metal yüzeye çekilip yapışma; zıplayınca ayrılma |
| **Kaya** | kaya | daha ağır ve yavaş; ağır butonlara basar, rüzgârdan etkilenmez | havada yere çakılma (ground pound): çatlak zemini kırar, düşmanı ezer |

## Numbers
| Ad | Değer | Birim | Testte neye bakılmalı |
|---|---|---|---|
| Kopyalama menzili | 1,8 [ASSUMPTION] | m | nesneye "dokunur gibi" mi hissettiriyor |
| Kopyalama animasyonu | 0,25 [ASSUMPTION] | s | akışı bölüyor mu |
| Yetenek bırakmak için basılı tutma | 1,2 (eskiden 0,6) | s | yanlışlıkla bırakılıyor mu; Yay şarjıyla karışmıyor mu |
| Yay şarj süresi (tam) | 0,5 [ASSUMPTION] | s | |
| Yay zıplama yüksekliği | 5,0 [ASSUMPTION] | m | normal zıplamadan net farklı mı |
| Yay şarjlı zıplama yüksekliği | 6,5 [ASSUMPTION] | m | |
| Balon süzülme düşüş hızı | 1,5 [ASSUMPTION] | m/s | |
| Balon süzülme süresi | 3,0 [ASSUMPTION] | s | yere inince yenilenir; yukarı esen rüzgârın içinde harcanmaz (2026-11-20) |
| Balon havada yatay hız | 5,0 [ASSUMPTION] | m/s | |
| Mıknatıs menzili | 7,0 [ASSUMPTION] | m | |
| Mıknatıs çekilme hızı | 12 [ASSUMPTION] | m/s | |
| Kaya hız çarpanı | 0,6 [ASSUMPTION] | × koşu hızı | çok mu yavaş |
| Kaya zıplama yüksekliği | 1,2 [ASSUMPTION] | m | |
| Kaya çakılma hızı | 25 [ASSUMPTION] | m/s | |

## Edge cases
- Menzilde iki kopyalanabilir nesne varsa Bip'in baktığı yöne en yakın olan seçilir.
- Taşınan yetenekle aynı nesne kopyalanırsa bir şey değişmez, yalnızca küçük bir ses çalar.
- Süzülme veya yapışma sırasında hasar: yetenek kaybolur, Bip normal düşüşe geçer.
- Kaya ile suya girilirse Bip batar ve kontrol noktasına döner [ASSUMPTION].
- Kontrol noktasından yeniden başlarken Bip, kontrol noktasına ulaştığı andaki yetenekle başlar [ASSUMPTION].

## Uygulama notları
- Kodda: `scripts/player/bip.gd` (tüm sayılar `@export`, "Kopyalama", "Yay", "Balon", "Mıknatıs", "Kaya", "Pervane", "Buz" grupları), kopyalanabilir nesne `scripts/abilities/copy_source.gd`, görünüşler `scripts/abilities/ability_models.gd`.
- Bırakma süresi 0,6 → 1,2 sn yapıldı (D-011): Yay'ın şarjlı zıplaması da Yetenek tuşunu basılı tutmayı kullanıyor; 0,6 sn'de şarj daha bitmeden yetenek bırakılıyordu. HUD'daki yetenek simgesinin etrafında dolan halka bırakmaya ne kadar kaldığını gösterir.
- Mıknatıs: menzildeki metal yüzeylerden en yakın ve tercihen yukarıdaki seçilir; az önce bırakılan yüzey 1,5 sn boyunca atlanır. Böylece "zıpla → Yetenek → bir üstteki bloğa çekil" zinciriyle tırmanılır.
- Su: Bip normalde yüzer; Kaya ile batar ve dipte yürür (Bölüm 1 tasarımındaki "suyun altındaki yol"). Edge case'teki "batar ve kontrol noktasına döner" kuralı bunun yerine kaldırıldı.
- Kopyalanabilir nesne yakınken anten hızlı yanıp söner ve telefonda Yetenek butonu nabız gibi atar.
- Bölüm 2 ve 3'te iki yeni yetenek eklendi: **Pervane** ve **Buz** (bkz. [Bölüm 2](../bolum-2/design.md), [Bölüm 3](../bolum-3/design.md)).

## Interactions
| Özellik | Etki |
|---|---|
| [Hareket](../hareket/design.md) | Yay ve Kaya zıplama yüksekliğini, Kaya koşu hızını değiştirir |
| [Kamera](../kamera/design.md) | Yay zıplamasında kamera yukarıyı göstermek için hafifçe uzaklaşır |
| Can ve hasar | Yetenek ilk hasarı emer |

## Open questions
- [ASSUMPTION] Yetenek süresiz kalır; zaman sınırı yok.
- Kopyalama tuşla mı, nesneye değince otomatik mi? Şimdilik tuşla (yanlışlıkla kopyalamayı önler); M2'de ikisi denenebilir.

## History
- 2026-11-18: tasarlandı.
- 2026-11-18: "bölüm" yerine "alan" terimi (GDD 0.2).
- 2026-11-18: dört yetenek ve Pervane, Buz uygulandı; bırakma süresi 1,2 sn (D-011); otomatik testler: `tests/m2_test.tscn`, `tests/abilities_test.tscn`, `tests/boss_test.tscn`.
