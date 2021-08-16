package com.ryderchen.plugins.instagram_basic_display_api.data.remote

import com.ryderchen.plugins.instagram_basic_display_api.data.model.ShortAccessTokenInfo
import retrofit2.http.Field
import retrofit2.http.FormUrlEncoded
import retrofit2.http.POST

interface ApiInstagramService {

    @FormUrlEncoded
    @POST("oauth/access_token")
    suspend fun getShortAccessTokenInfo(
        @Field("client_id") clientId: String,
        @Field("client_secret") clientSecret: String,
        @Field("code") code: String,
        @Field("grant_type") grantType: String,
        @Field("redirect_uri") redirectUri: String
    ): ShortAccessTokenInfo
}