package com.ryderchen.plugins.instagram_basic_display_api.utils

import android.content.Context
import android.content.SharedPreferences
import androidx.security.crypto.EncryptedSharedPreferences
import androidx.security.crypto.MasterKeys
import com.ryderchen.plugins.instagram_basic_display_api.utils.SharedPreferencesUtils.clear
import com.ryderchen.plugins.instagram_basic_display_api.utils.SharedPreferencesUtils.remove
import com.ryderchen.plugins.instagram_basic_display_api.utils.SharedPreferencesUtils.set

class SharedPreferencesManagerImpl(context: Context) : SharedPreferencesManager {

    private var prefs: SharedPreferences

    init {
        val masterKeyAlias = MasterKeys.getOrCreate(MasterKeys.AES256_GCM_SPEC)
        prefs = EncryptedSharedPreferences.create(
            Constants.PREF_NAME,
            masterKeyAlias,
            context,
            EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
            EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
        )
    }

    override fun <T : Any?> set(key: String, value: T) {
        prefs.set(key, value)
    }

    override fun getString(key: String, defaultValue: String?): String? {
        val value = getValue(key, defaultValue)
        return value as String?
    }

    override fun getInt(key: String, defaultValue: Int): Int {
        val value = getValue(key, defaultValue)
        return value as Int
    }

    override fun getBoolean(key: String, defaultValue: Boolean): Boolean {
        val value = getValue(key, defaultValue)
        return value as Boolean
    }

    override fun getLong(key: String, defaultValue: Long): Long {
        val value = getValue(key, defaultValue)
        return value as Long
    }

    override fun getFloat(key: String, defaultValue: Float): Float {
        val value = getValue(key, defaultValue)
        return value as Float
    }

    private fun getValue(key: String, defaultValue: Any?): Any? {
        var value = prefs.all[key]
        value = value ?: defaultValue
        return value
    }

    override fun contains(key: String): Boolean {
        return prefs.contains(key)
    }

    override fun remove(key: String) {
        prefs.remove(key)
    }

    override fun clear() {
        prefs.clear()
    }
}