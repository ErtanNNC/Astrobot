# Mobil kontroller

**Status:** implemented · **Updated:** 2026-11-18 · [GDD](../../GDD.md)

Telefonda oyun iki başparmakla, ekrana bakmadan oynanır. Sol başparmak yürütür, sağ başparmak zıplar ve yetenek kullanır; kamera kendiliğinden döndüğü için sağ başparmağın kamerayla uğraşması gerekmez (Pillar 4, D-002). Butonlar telefon oyunlarındaki yaygın düzende: ana eylem başparmağın doğal durduğu sağ alt köşede ve en büyük, ikinci eylem onun hemen sol üstünde, bir yay üzerinde.

## Yerleşim (yatay ekran, sağ el modu)
```
 ┌──────────────────────────────────────────────────────────┐
 │ (II)                                                     │
 │ duraklat                                                 │
 │                                                          │
 │   ← sol yarı: joystick nereye                (✦)         │
 │      dokunursan orada çıkar              yetenek         │
 │                                                          │
 │      ( ◯ )                                     ( ▲ )     │
 │    dinlenme yeri                               ZIPLA     │
 └──────────────────────────────────────────────────────────┘
   sağ yarıda butonların dışında kaydırma = kamerayı çevir
```

## Rules
1. **Joystick (sol):** ekranın sol %45'inde, üst %22'si hariç, nereye dokunulursa orada belirir (yüzen joystick). Parmak halkanın dışına çıkarsa halka parmağı izler; böylece yön hiç "takılmaz". Dokunulmazken sol altta silik bir joystick, nerede olduğunu hatırlatır.
2. **Zıpla (sağ alt):** en büyük buton. Basılı tutulursa yüksek, kısa basılırsa alçak zıplama ([hareket](../hareket/design.md)).
3. **Yetenek (Zıpla'nın sol üstü):** daha küçük ikinci buton. Yetenek yokken soluk görünür (M2'de kopyalama ile çalışacak, [kopyalama](../kopyalama/design.md)).
4. **Duraklat (sol üst):** küçük ama dokunma alanı en az 48 dp; ana eylemlerden uzak, yanlışlıkla basılmaz.
5. **Kamera:** sağ yarıda butonlara değmeyen kaydırma kamerayı çevirir; 2 sn sonra kamera kendiliğinden arkaya döner ([kamera](../kamera/design.md)).
6. Butonların dokunma alanı çiziminden %25 büyüktür; iki butonun alanı çakışırsa Zıpla kazanır.
7. Basılan buton küçülür ve parlar; Zıpla'da kısa bir titreşim olur (ayarlardan kapatılabilir).
8. Her şey telefonun güvenli alanının (çentik, yuvarlak köşe) içinde kalır.
9. Aynı anda joystick + Zıpla + kamera kaydırma çalışır (çoklu dokunma).
10. **Sol el modu:** joystick sağa, butonlar sola geçer (ayna). Duraklat sol üstte kalır.
11. Duraklatma açılınca basılı tüm tuşlar bırakılır, zıplama tamponu ve coyote sayaçları sıfırlanır. Telefon arka plana alınınca oyun kendiliğinden duraklar.
12. Klavye/gamepad ile oynanırken dokunmatik butonlar gizlidir (PC'de yalnızca dokunmatik ekran varsa görünür).

## Numbers
Ölçüler 720 piksel yükseklikteki ekrana göredir; daha büyük ekranlarda orantılı büyür.

| Ad | Değer | Birim | Testte neye bakılmalı |
|---|---|---|---|
| Joystick halka yarıçapı | 105 | px | kısa telefonda başparmak rahat mı |
| Joystick ölü bölgesi | 0,15 | × yarıçap | dururken Bip kıpırdıyor mu |
| Joystick bölgesi | sol %45, üst %22 hariç | ekran | |
| Zıpla yarıçapı | 88 | px | başparmak bakmadan buluyor mu |
| Zıpla merkezi, sağ alt köşeden | 165, 160 | px | |
| Yetenek yarıçapı | 64 | px | |
| Yetenek merkezi, Zıpla'ya göre | 150 sola, 140 yukarı | px | Zıpla'dan başparmak kaydırarak ulaşılıyor mu |
| Duraklat yarıçapı (dokunma) | 40 | px | |
| Dokunma alanı büyütmesi | 1,25 | × | |
| Buton boyutu ayarı | Küçük 0,85 / Orta 1,0 / Büyük 1,2 | × | |
| Buton saydamlığı | 0,8 | | oyun alanını kapatıyor mu |
| Zıpla titreşimi | 12 | ms | |

## Ayarlar (duraklatma menüsünde)
Buton boyutu, sol el modu, titreşim, müzik, efekt sesleri. Ayarlar `user://settings.cfg` dosyasına yazılır ve kayıt yuvalarından bağımsızdır ([ana menü](../ana-menu/design.md), [kayıt](../kayit/design.md)). Tam ayarlar ekranı M4'te ana menüyle gelecek.

## Kodda
- `scripts/ui/touch_controls.gd`: çizim ve dokunma (tüm sayılar `@export`).
- `scripts/ui/pause_menu.gd`: duraklatma menüsü ve ayarlar.
- `scripts/autoload/settings.gd`: ayar dosyası (autoload `Settings`).

## Open questions
- Butonları sürükleyerek yerini değiştirme (ana menü dokümanında var): M4'e bırakıldı.
- Yetenek butonu basılı tutunca yeteneği bırakma (kopyalama kural 6) M2'de bu butona bağlanacak.

## History
- 2026-11-18: tasarlandı ve uygulandı (D-008).
