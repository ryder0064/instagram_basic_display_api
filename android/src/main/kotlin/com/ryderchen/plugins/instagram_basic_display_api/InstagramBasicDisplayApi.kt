package com.ryderchen.plugins.instagram_basic_display_api

import android.app.Activity
import android.content.Intent
import android.util.Log
import com.ryderchen.plugins.instagram_basic_display_api.data.DataRepository
import com.ryderchen.plugins.instagram_basic_display_api.ui.AccessTokenActivity
import com.ryderchen.plugins.instagram_basic_display_api.utils.Constants.GET_ACCESS_TOKEN_RESULT
import com.ryderchen.plugins.instagram_basic_display_api.utils.Constants.REQUEST_CODE_FOR_ACCESS_TOKEN
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.PluginRegistry

class InstagramBasicDisplayApi(
    private val repository: DataRepository
) : PluginRegistry.ActivityResultListener {

    private val TAG = javaClass.name

    private var activity: Activity? = null
    private var listener: AccessTokenStatusListener? = null

    private lateinit var clientId: String
    private lateinit var clientSecret: String
    private lateinit var redirectUri: String

    fun setActivityPluginBinding(binding: ActivityPluginBinding) {
        binding.addActivityResultListener(this)
        activity = binding.activity
    }

    fun detachActivity() {
        activity = null
    }

    fun checkTokenValid(listener: AccessTokenStatusListener) {
        this.listener = listener

        if (activity == null) {
            listener.getAccessTokenResult(TokenStatus.ERROR_EXCEPTION)
            return
        }

        if (repository.isTokenValid()) {
            listener.getAccessTokenResult(TokenStatus.VALID)
            return
        }

        try {
            clientId = BuildConfig.INSTAGRAM_CLIENT_ID
            clientSecret = BuildConfig.INSTAGRAM_CLIENT_SECRET
            redirectUri = BuildConfig.REDIRECT_URI

            val intent = AccessTokenActivity.createIntent(
                activity!!, clientId, clientSecret, redirectUri
            )
            activity!!.startActivityForResult(intent, REQUEST_CODE_FOR_ACCESS_TOKEN)
        } catch (e: Exception) {
            Log.e(TAG, "ERROR_EXCEPTION, Need to set instagram client information first")
            listener.getAccessTokenResult(TokenStatus.ERROR_EXCEPTION)
        }
    }

    enum class TokenStatus {
        VALID,
        EXPIRED,
        ERROR_EXCEPTION
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        Log.d(
            TAG,
            "requestCode = $requestCode, resultCode = $resultCode, data = $data"
        )
        if (requestCode == REQUEST_CODE_FOR_ACCESS_TOKEN && resultCode == Activity.RESULT_OK) {
            if (data != null && data.getBooleanExtra(GET_ACCESS_TOKEN_RESULT, false)) {
                listener?.getAccessTokenResult(TokenStatus.VALID)
            } else {
                listener?.getAccessTokenResult(TokenStatus.EXPIRED)
            }
            return true
        }
        listener?.getAccessTokenResult(TokenStatus.EXPIRED)
        return false
    }

    interface AccessTokenStatusListener {
        fun getAccessTokenResult(status: TokenStatus)
    }
}