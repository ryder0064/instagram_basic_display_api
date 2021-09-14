package com.ryderchen.plugins.instagram_basic_display_api.data

import android.content.Context
import android.util.Log
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import com.ryderchen.plugins.instagram_basic_display_api.data.model.UserInfoResponse
import com.ryderchen.plugins.instagram_basic_display_api.data.remote.ApiInstagramService
import com.ryderchen.plugins.instagram_basic_display_api.data.remote.GraphInstagramService
import com.ryderchen.plugins.instagram_basic_display_api.utils.Constants
import com.ryderchen.plugins.instagram_basic_display_api.utils.SharedPreferencesManagerImpl
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.net.UnknownHostException

class DataRepository(
    context: Context,
    private val apiInstagramService: ApiInstagramService,
    private val graphInstagramService: GraphInstagramService
) {
    private val preference = SharedPreferencesManagerImpl(context)

    private val TAG = javaClass.name
    private val _accessTokenResult = MutableLiveData<Boolean?>(null)
    val accessTokenResult: LiveData<Boolean?> = _accessTokenResult

    suspend fun getUserInfo(): UserInfoResponse {
        if (preference.getString(Constants.PREF_KEY_ACCESS_TOKEN, "").isNullOrEmpty()) {
            throw Exception("TOKEN_EMPTY")
        }
        if (!isTokenValid()) {
            throw Exception("TOKEN_EXPIRED")
        }
        return withContext(Dispatchers.IO) {
            return@withContext graphInstagramService.getUserInfo(
                fields = "id,username,account_type",
                accessToken = preference.getString(Constants.PREF_KEY_ACCESS_TOKEN, "")!!
            )
        }
    }

    suspend fun getMedias(): List<Map<String,Any>> {
        if (preference.getString(Constants.PREF_KEY_ACCESS_TOKEN, "").isNullOrEmpty()) {
            throw Exception("TOKEN_EMPTY")
        }
        if (!isTokenValid()) {
            throw Exception("TOKEN_EXPIRED")
        }
        return withContext(Dispatchers.IO) {
            return@withContext graphInstagramService.getMedias(
                fields = "id,caption,media_type,timestamp,permalink,media_url,thumbnail_url",
                accessToken = preference.getString(Constants.PREF_KEY_ACCESS_TOKEN, "")!!
            ).data
        }
    }

    suspend fun getAlbumDetail(albumId: String): List<Map<String, Any>> {
        if (preference.getString(Constants.PREF_KEY_ACCESS_TOKEN, "").isNullOrEmpty()) {
            throw Exception("TOKEN_EMPTY")
        }
        if (!isTokenValid()) {
            throw Exception("TOKEN_EXPIRED")
        }
        return withContext(Dispatchers.IO) {
            return@withContext graphInstagramService.getAlbumDetail(
                albumId = albumId,
                fields = "id,media_type,media_url,timestamp,thumbnail_url",
                accessToken = preference.getString(Constants.PREF_KEY_ACCESS_TOKEN, "")!!
            ).data
        }
    }

    suspend fun getMediaItem(mediaId: String): Map<String, Any> {
        if (preference.getString(Constants.PREF_KEY_ACCESS_TOKEN, "").isNullOrEmpty()) {
            throw Exception("TOKEN_EMPTY")
        }
        if (!isTokenValid()) {
            throw Exception("TOKEN_EXPIRED")
        }
        return withContext(Dispatchers.IO) {
            return@withContext graphInstagramService.getMediaItem(
                mediaId = mediaId,
                fields = "id,caption,media_type,timestamp,permalink,media_url,thumbnail_url",
                accessToken = preference.getString(Constants.PREF_KEY_ACCESS_TOKEN, "")!!
            ).body() ?: throw Exception("UNKNOWN_EXCEPTION")
        }
    }

    suspend fun logout(): UserInfoResponse {
        return withContext(Dispatchers.IO) {
            preference.clear()
            return@withContext UserInfoResponse("","","")
        }
    }

    suspend fun getAccessToken(
        clientId: String,
        clientSecret: String,
        code: String,
        redirectUri: String
    ) {
        withContext(Dispatchers.IO) {
            getShortAccessToken(
                clientId,
                clientSecret,
                code,
                redirectUri
            )
        }
    }

    private suspend fun getShortAccessToken(
        clientId: String,
        clientSecret: String,
        code: String,
        redirectUri: String
    ) {
        try {
            val shortAccessTokenInfo = apiInstagramService.getShortAccessTokenInfo(
                clientId = clientId,
                clientSecret = clientSecret,
                code = code,
                grantType = "authorization_code",
                redirectUri = redirectUri
            )

            Log.d(TAG, "shortAccessTokenInfo = $shortAccessTokenInfo")

            preference.set(Constants.PREF_KEY_INSTAGRAM_USER_ID, shortAccessTokenInfo.userId)

            val currentTimeMillis: Long = System.currentTimeMillis()

            getLongAccessToken(shortAccessTokenInfo.accessToken, clientSecret, currentTimeMillis)
        } catch (exception: UnknownHostException) { // Request Api when no internet
            exception.printStackTrace()
            Log.e(TAG, "shortAccessTokenInfo exception = $exception")
            _accessTokenResult.postValue(false)
        } catch (exception: Exception) {
            exception.printStackTrace()
            Log.e(TAG, "shortAccessTokenInfo exception = $exception")
            _accessTokenResult.postValue(false)
        }
    }

    private suspend fun getLongAccessToken(
        shortAccessToken: String,
        clientSecret: String,
        currentTimeMillis: Long
    ) {
        try {
            val longAccessTokenInfo = graphInstagramService.getLongAccessTokenInfo(
                grantType = "ig_exchange_token",
                clientSecret = clientSecret,
                accessToken = shortAccessToken
            )

            Log.d(TAG, "longAccessTokenInfo = $longAccessTokenInfo")

            val expiredTimeMillis = currentTimeMillis + longAccessTokenInfo.expiresIn
            Log.d(
                TAG,
                "currentTimeMillis = $currentTimeMillis, expiredTimeMillis = $expiredTimeMillis"
            )

            preference.set(Constants.PREF_KEY_EXPIRED_MILLISECONDS, expiredTimeMillis)
            preference.set(Constants.PREF_KEY_ACCESS_TOKEN, longAccessTokenInfo.accessToken)

            _accessTokenResult.postValue(true)

        } catch (exception: UnknownHostException) { // Request Api when no internet
            exception.printStackTrace()
            Log.e(TAG, "getLongAccessToken exception = $exception")
            _accessTokenResult.postValue(false)
        } catch (exception: Exception) {
            exception.printStackTrace()
            Log.e(TAG, "getLongAccessToken exception = $exception")
            _accessTokenResult.postValue(false)
        }
    }

    fun clear() {
        _accessTokenResult.value = null
    }

    private fun isTokenValid(): Boolean {
        val expiredMilliseconds = preference.getLong(Constants.PREF_KEY_EXPIRED_MILLISECONDS, 0)
        val currentTimeMillis: Long = System.currentTimeMillis()

        return currentTimeMillis < expiredMilliseconds
    }
}