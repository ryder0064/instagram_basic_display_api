package com.ryderchen.plugins.instagram_basic_display_api.data.model

import com.squareup.moshi.Json

data class LongAccessTokenInfo(
    @Json(name = "access_token")
    val accessToken: String,
    @Json(name = "token_type")
    val tokenType: String,
    @Json(name = "expires_in")
    val expiresIn: Long
)