package com.ryderchen.plugins.instagram_basic_display_api

import android.util.Log
import androidx.annotation.NonNull
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel


class MethodCallHandlerImpl(private val instagramBasicDisplayApi: InstagramBasicDisplayApi) :
    MethodChannel.MethodCallHandler {

    private val TAG = javaClass.name
    private var channel: MethodChannel? = null

    init {
        instagramBasicDisplayApi.startListening(
            userUpdated = {
                channel?.invokeMethod("userUpdated", hashMapOf("ID" to it.id, "USER_NAME" to it.username, "ACCOUNT_TYPE" to it.accountType))
            },
            mediasUpdated = {
                channel?.invokeMethod("mediasUpdated", hashMapOf("DATA" to it))
            },
            albumDetailUpdated = {
                channel?.invokeMethod("albumDetailUpdated", hashMapOf("DATA" to it))
            },
            mediaItemUpdated = {
                channel?.invokeMethod("mediaItemUpdated", it)
            },
            errorUpdated = {
                channel?.invokeMethod("errorUpdated", hashMapOf("ERROR_TYPE" to it))
            }
        )
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
        when (call.method) {
            "getPlatformVersion" -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }
            "askInstagramToken" -> {
                instagramBasicDisplayApi.askInstagramToken()
                result.success(null)
            }
            "getInstagramUser" -> {
                instagramBasicDisplayApi.getInstagramUser()
                result.success(null)
            }
            "getMedias" -> {
                instagramBasicDisplayApi.getMedias()
                result.success(null)
            }
            "getAlbumDetail" -> {
                println("getAlbumDetail\n")
                val arguments = call.arguments as? HashMap<*, *> ?: return
                val albumId = arguments["albumId"] as String? ?: return
                println("getAlbumDetail albumId = $albumId")
                instagramBasicDisplayApi.getAlbumDetail(albumId)
                result.success(null)
            }
            "getMediaItem" -> {
                println("getMediaItem\n")
                val arguments = call.arguments as? HashMap<*, *> ?: return
                val mediaId = arguments["mediaId"] as String? ?: return
                println("getMediaItem mediaId = $mediaId")
                instagramBasicDisplayApi.getMediaItem(mediaId)
                result.success(null)
            }
            "logout" -> {
                instagramBasicDisplayApi.logout()
                result.success(null)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    fun startListening(messenger: BinaryMessenger?) {
        if (channel != null) {
            Log.wtf(TAG, "Setting a method call handler before the last was disposed.")
            stopListening()
        }
        channel = MethodChannel(messenger, "instagram_basic_display_api").apply {
            setMethodCallHandler(this@MethodCallHandlerImpl)
        }
    }

    fun stopListening() {
        if (channel == null) {
            Log.d(TAG, "Tried to stop listening when no MethodChannel had been initialized.")
            return
        }
        channel!!.setMethodCallHandler(null)
        channel = null
    }

//    private fun checkTokenValid(result: MethodChannel.Result) {
//        Log.d(TAG, "checkTokenValid")
//        instagramBasicDisplayApi.checkTokenValid(
//            object : InstagramBasicDisplayApi.AccessTokenStatusListener {
//                override fun getAccessTokenResult(status: InstagramBasicDisplayApi.TokenStatus) {
//                    Log.d(TAG, "TokenStatus = $status")
//                    when {
//                        status === InstagramBasicDisplayApi.TokenStatus.EXPIRED -> {
//                            result.error("EXPIRED", "Instagram token is expired.", null)
//                        }
//                        status === InstagramBasicDisplayApi.TokenStatus.ERROR_EXCEPTION -> {
//                            result.error(
//                                "ERROR_EXCEPTION", String.format("ERROR_EXCEPTION happens"),
//                                null
//                            )
//                        }
//                        else -> {
//                            result.success(true)
//                        }
//                    }
//                }
//            }
//        )
//    }
}