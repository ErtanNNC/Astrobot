# Kamera

**Status:** implemented (M1) · **Updated:** 2026-11-18 · [GDD](../../GDD.md)

Kamera oyuncunun dikkatini dağıtmadan hep doğru yeri gösterir. Astro Bot'taki gibi kendi kendine takip eder; oyuncu telefonda kamerayla uğraşmak zorunda kalmaz (D-002). "Telefonda tam oynanır" pillar'ının temelidir.

## Rules
1. Kamera Bip'i arkadan ve hafif yukarıdan, yumuşak bir gecikmeyle takip eder.
2. Bip'in hareket yönünde biraz ileriyi gösterir (look-ahead).
3. Bip zıplarken kamera yüksekliği hemen takip etmez; Bip yeni bir zemine inince ya da ekranın üst/alt sınırına yaklaşınca yükselir veya alçalır. Böylece her zıplamada ekran sarsılmaz.
4. Kamera ile Bip arasına duvar girerse kamera duvarın önüne yaklaşır (`SpringArm3D`).
5. Seviye tasarımında belirli alanlara kamera bölgeleri konabilir; bu bölgeler kameranın açısını ve uzaklığını sabitler [ASSUMPTION].
6. PC'de fare veya sağ çubukla, telefonda ekranın sağ yarısında parmak kaydırarak kamera elle döndürülebilir; bir süre girdi olmazsa kamera kendiliğinden Bip'in arkasına döner.

## Numbers
| Ad | Değer | Birim | Testte neye bakılmalı |
|---|---|---|---|
| Uzaklık | 7,0 [ASSUMPTION] | m | Bip ve önündeki yol birlikte görünüyor mu |
| Yükseklik açısı | 25 [ASSUMPTION] | derece aşağı | zemindeki boşluklar okunuyor mu |
| Takip yumuşatma | 6 [ASSUMPTION] | 1/s | gecikme baş döndürüyor mu |
| İleriye bakış | 1,5 [ASSUMPTION] | m | |
| Otomatik geri dönüş gecikmesi | 2,0 [ASSUMPTION] | s | |
| Görüş açısı (FOV) | 60 [ASSUMPTION] | derece | telefonda yeterince geniş mi |
| Dikey sınır (yukarı) | 2,5 [ASSUMPTION] | m, son zeminin üstü | yüksek zıplamada Bip ekrandan çıkıyor mu |
| Dikey sınır (aşağı) | 0,5 [ASSUMPTION] | m, son zeminin altı | düşerken kamera geç mi kalıyor |
| Dikey yumuşatma | 4 [ASSUMPTION] | 1/s | iniş sonrası kamera yükselişi rahat mı |
| Kendiliğinden dönme hızı | 0,9 [ASSUMPTION] (1,6 idi; Astro gibi daha sakin, D-017) | 1/s | yana koşarken kamera arkaya geçiyor mu, başı döndürüyor mu |
| Saydamlaşma başlangıcı / tam saydam | 2,0 / 0,8 [ASSUMPTION] | m | |

## Edge cases
- Bip kameraya doğru koşarken kamera hızla dönmemeli; yalnızca geri çekilir.
- Kamera Bip'in içinden geçmemeli; çok yaklaşınca Bip saydamlaşır [ASSUMPTION].
- Ölümden sonra kamera kontrol noktasına sıçrar, kaymaz.

## Open questions
- [ASSUMPTION] Elle kamera kontrolü telefonda gerekli mi? M4'te gerçek cihazda karar verilecek.

## Uygulama notları (M1)
- Kodda: `scripts/camera/follow_camera.gd`, sahne `scenes/camera/follow_camera.tscn`; kamera bölgesi `scripts/level/camera_zone.gd` (Area3D).
- Kural 3'teki "ekranın üst/alt sınırı", son basılan zemine göre metre cinsinden iki sınırla yapıldı (yukarıdaki tablo).
- Kendiliğinden dönme: Bip yana ya da ileri koşarken kamera hızla orantılı olarak arkasına geçer; Bip kameraya doğru koşarken (açı > ~110°) dönmez, yalnızca takip eder.
- Elle döndürme: PC'de oyun penceresine tıklayınca fare yakalanır (Esc bırakır), ok tuşları ve sağ çubuk da çalışır; telefonda ekranın sağ yarısında kaydırma.

## History
- 2026-11-18: tasarlandı.
- 2026-11-18: M1'de uygulandı; dikey sınır, dönme hızı ve saydamlık sayıları eklendi.
