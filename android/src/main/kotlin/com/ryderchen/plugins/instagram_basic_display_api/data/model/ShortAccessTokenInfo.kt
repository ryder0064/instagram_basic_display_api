package com.ryderchen.plugins.instagram_basic_display_api.data.model

import com.squareup.moshi.Json

data class ShortAccessTokenInfo(
    @Json(name = "access_token")
    val accessToken: String,
    @Json(name = "user_id")
    val userId: String
)