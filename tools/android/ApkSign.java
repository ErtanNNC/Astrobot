// APK imzalayıcı (Android SDK'daki apksigner'ın yerine).
// Google'ın apksig kütüphanesini kullanır (Maven Central: com.android.tools.build:apksig).
// Kullanım:
//   java -cp apksig.jar tools/android/ApkSign.java <keystore.p12> <şifre> <alias> <girdi.apk> <çıktı.apk>
import com.android.apksig.ApkSigner;
import com.android.apksig.ApkVerifier;
import java.io.File;
import java.io.FileInputStream;
import java.security.KeyStore;
import java.security.PrivateKey;
import java.security.cert.X509Certificate;
import java.util.Collections;

public class ApkSign {
    public static void main(String[] a) throws Exception {
        if (a.length != 5) {
            System.err.println("kullanım: ApkSign <keystore> <şifre> <alias> <girdi.apk> <çıktı.apk>");
            System.exit(2);
        }
        char[] pass = a[1].toCharArray();
        KeyStore ks = KeyStore.getInstance("PKCS12");
        try (FileInputStream in = new FileInputStream(a[0])) { ks.load(in, pass); }
        PrivateKey key = (PrivateKey) ks.getKey(a[2], pass);
        X509Certificate cert = (X509Certificate) ks.getCertificate(a[2]);
        ApkSigner.SignerConfig cfg = new ApkSigner.SignerConfig.Builder(
                "BIP", key, Collections.singletonList(cert)).build();
        File out = new File(a[4]);
        new ApkSigner.Builder(Collections.singletonList(cfg))
                .setInputApk(new File(a[3]))
                .setOutputApk(out)
                .setV1SigningEnabled(false) // v1 eski JDK iç sınıflarına bağlı; minSdk 24 için v2 yeterli
                .setV2SigningEnabled(true)
                .build()
                .sign();
        ApkVerifier.Result r = new ApkVerifier.Builder(out).build().verify();
        if (!r.isVerified()) {
            System.err.println("İMZA DOĞRULANAMADI: " + r.getErrors());
            System.exit(1);
        }
        System.out.println("İmzalandı ve doğrulandı (v1=" + r.isVerifiedUsingV1Scheme()
                + ", v2=" + r.isVerifiedUsingV2Scheme() + "): " + out);
        java.security.MessageDigest md = java.security.MessageDigest.getInstance("SHA-256");
        StringBuilder sb = new StringBuilder();
        for (byte b : md.digest(cert.getEncoded())) sb.append(String.format("%02X", b));
        System.out.println("Sertifika SHA-256: " + sb);
    }
}
