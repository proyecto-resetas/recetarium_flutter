package com.example.resetas

import androidx.security.crypto.EncryptedSharedPreferences
import androidx.security.crypto.MasterKeys
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.Base64

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.recetarium/security"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getEncryptionKey" -> {
                    try {
                        val key = getOrCreateMasterKey()
                        result.success(key)
                    } catch (e: Exception) {
                        result.error("SECURE_KEY_ERROR", "Error obtaining or creating security key: ${e.message}", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun getOrCreateMasterKey(): ByteArray {
        val masterKeyAlias = MasterKeys.getOrCreate(MasterKeys.AES256_GCM_SPEC)
        val sharedPrefs = EncryptedSharedPreferences.create(
            "secure_hive_prefs",
            masterKeyAlias,
            applicationContext,
            EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
            EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
        )

        val keyHex = sharedPrefs.getString("hive_master_key", null)
        return if (keyHex == null) {
            // Generar clave segura si no existe (32 bytes para AES-256)
            val secureKey = ByteArray(32)
            java.security.SecureRandom().nextBytes(secureKey)
            
            // Guardarla cifrada
            val encodedKey = Base64.getEncoder().encodeToString(secureKey)
            sharedPrefs.edit().putString("hive_master_key", encodedKey).apply()
            secureKey
        } else {
            Base64.getDecoder().decode(keyHex)
        }
    }
}
