# Kopyalama

**Status:** designed · **Updated:** 2026-11-18 · [GDD](../../GDD.md)

Oyunun kancası. Bip, anteniyle kopyalanabilir bir nesneye dokunarak onun yeteneğini alır; yetenek bir sonraki kopyalamaya ya da hasara kadar kalır. Her bölüm bir yeteneği öğretip sonra zorlaştırır; son bölüm dördünü birleştirir. "Tek yetenek, bin kullanım" pillar'ına hizmet eder.

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
| Yetenek bırakmak için basılı tutma | 0,6 [ASSUMPTION] | s | yanlışlıkla bırakılıyor mu |
| Yay zıplama yüksekliği | 5,0 [ASSUMPTION] | m | normal zıplamadan net farklı mı |
| Yay şarjlı zıplama yüksekliği | 6,5 [ASSUMPTION] | m | |
| Balon süzülme düşüş hızı | 1,5 [ASSUMPTION] | m/s | |
| Balon süzülme süresi | 3,0 [ASSUMPTION] | s | yere inince yenilenir |
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
