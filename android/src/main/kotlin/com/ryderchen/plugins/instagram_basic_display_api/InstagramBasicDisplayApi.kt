package com.ryderchen.plugins.instagram_basic_display_api

import android.app.Activity
import android.content.Intent
import android.util.Log
import com.ryderchen.plugins.instagram_basic_display_api.data.DataRepository
import com.ryderchen.plugins.instagram_basic_display_api.data.model.UserInfoResponse
import com.ryderchen.plugins.instagram_basic_display_api.ui.AccessTokenActivity
import com.ryderchen.plugins.instagram_basic_display_api.utils.Constants.GET_ACCESS_TOKEN_RESULT
import com.ryderchen.plugins.instagram_basic_display_api.utils.Constants.REQUEST_CODE_FOR_ACCESS_TOKEN
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.PluginRegistry
import kotlinx.coroutines.runBlocking

class InstagramBasicDisplayApi(
    private val repository: DataRepository
) : PluginRegistry.ActivityResultListener {

    private val TAG = javaClass.name

    private var activity: Activity? = null

    private lateinit var clientId: String
    private lateinit var clientSecret: String
    private lateinit var redirectUri: String

    private lateinit var userUpdated: (UserInfoResponse) -> Unit
    private lateinit var mediasUpdated: (List<Map<String, Any>>) -> Unit
    private lateinit var albumDetailUpdated: (List<Map<String, Any>>) -> Unit
    private lateinit var errorUpdated: (String) -> Unit

    fun setActivityPluginBinding(binding: ActivityPluginBinding) {
        binding.addActivityResultListener(this)
        activity = binding.activity
    }

    fun detachActivity() {
        activity = null
    }

    fun askInstagramToken(){
        if (activity == null) {
            errorUpdated("ERROR_EXCEPTION")
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
            errorUpdated("ERROR_EXCEPTION")
        }
    }

    fun getInstagramUser(){
        runBlocking {
            try {
                userUpdated(repository.getUserInfo())
            } catch (e: Exception) {
                Log.e("getInstagramUser fail", "e = $e")
                errorUpdated("tokenInvalid")
            }
        }
    }

    fun getMedias(){
        runBlocking {
            try {
                mediasUpdated(repository.getMedias())
            } catch (e: Exception) {
                Log.e("getMedias fail", "e = $e")
                errorUpdated("tokenInvalid")
            }
        }
    }

    fun getAlbumDetail(albumId: String){
        runBlocking {
            try {
                albumDetailUpdated(repository.getAlbumDetail(albumId))
            } catch (e: Exception) {
                Log.e("getAlbumDetail fail", "e = $e")
                errorUpdated("tokenInvalid")
            }
        }
    }

    fun logout(){
        runBlocking {
            try {
                userUpdated(repository.logout())
            } catch (e: Exception) {
                Log.e("logout fail", "e = $e")
                errorUpdated("ERROR_EXCEPTION")
            }
        }
    }

    fun startListening(userUpdated: (UserInfoResponse) -> Unit,
                       mediasUpdated: (List<Map<String,Any>>) -> Unit,
                       albumDetailUpdated: (List<Map<String,Any>>) -> Unit,
                       errorUpdated: (String) -> Unit){
        this.userUpdated = userUpdated
        this.mediasUpdated = mediasUpdated
        this.albumDetailUpdated = albumDetailUpdated
        this.errorUpdated = errorUpdated
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        Log.d(
            TAG,
            "requestCode = $requestCode, resultCode = $resultCode, data = $data"
        )
        if (requestCode == REQUEST_CODE_FOR_ACCESS_TOKEN && resultCode == Activity.RESULT_OK) {
            if (data != null && data.getBooleanExtra(GET_ACCESS_TOKEN_RESULT, false)) {
                runBlocking {
                    try {
                        userUpdated(repository.getUserInfo())
                    } catch (e: Exception) {
                        Log.e("getUserInfo fail", "e = $e")
                        errorUpdated("tokenInvalid")
                    }
                }
            } else {
                errorUpdated("tokenInvalid")
            }
            return true
        }
        errorUpdated("tokenInvalid")
        return false
    }
}