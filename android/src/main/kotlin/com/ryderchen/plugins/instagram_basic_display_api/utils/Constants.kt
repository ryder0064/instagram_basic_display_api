package com.ryderchen.plugins.instagram_basic_display_api.utils

import org.koin.core.KoinComponent
import org.koin.core.inject

object Constants {
    const val PREF_NAME: String = "com.ryderchen.plugins.instagram_basic_display_api.prefs"
    const val PREF_KEY_EXPIRED_MILLISECONDS: String = "prefs_expired_milliseconds"
    const val PREF_KEY_INSTAGRAM_USER_ID: String = "prefs_instagram_user_id"
    const val PREF_KEY_ACCESS_TOKEN = "prefs_access_token"

    const val API_INSTAGRAM_URL = "https://api.instagram.com/"
    const val GRAPH_INSTAGRAM_URL = "https://graph.instagram.com/"

    const val REQUEST_CODE_FOR_ACCESS_TOKEN = 100
    const val GET_ACCESS_TOKEN_RESULT = "get_access_token_result"

//    val EXPIRED_MILLISECONDS = longPreferencesKey("expired_milliseconds")
//    val INSTAGRAM_USER_ID = stringPreferencesKey("instagram_user_id")
}

inline fun <reified T> getKoinInstance(): T {
    return object : KoinComponent {
        val value: T by inject()
    }.value
}