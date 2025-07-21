import 'package:dio/dio.dart';
import 'package:prudapp/models/advert/advert.dart';
import 'package:prudapp/singletons/i_cloud.dart';
import 'package:retrofit/retrofit.dart';

part 'advert_api.g.dart';

@RestApi(baseUrl: "$apiEndPoint/adverts") 
abstract class AdvertApiClient {
  factory AdvertApiClient(Dio dio, {String baseUrl}) = _AdvertApiClient;

  @GET("/")
  Future<List<Advert>> getAdverts(@Header("Authorization") String token);

  @GET("/{id}")
  Future<Advert> getAdvertById(@Path("id") String id, @Header("Authorization") String token);

  @POST("/")
  Future<Advert> createAdvert(@Body() Advert advert, @Header("Authorization") String token);

  @MultiPart()
  @POST("/upload_media")
  Future<HttpResponse<dynamic>> uploadAdvertMedia(
    @Part(name: "file") List<int> fileBytes,
    @Part(name: "filename") String filename,
    @Part(name: "advertId") String advertId,
    @Header("Authorization") String token,
  );

  @PUT("/{id}")
  Future<Advert> updateAdvert(@Path("id") String id, @Body() Advert advert, @Header("Authorization") String token);

  @DELETE("/{id}")
  Future<void> deleteAdvert(@Path("id") String id, @Header("Authorization") String token);

  @PATCH("/{id}/status")
  Future<Advert> updateAdvertStatus(@Path("id") String id, @Field("status") String status, @Header("Authorization") String token);

  // New: API endpoint to fetch advert costing options
  @GET("/costings")
  Future<List<AdvertCosting>> getAdvertCostings(@Header("Authorization") String token);
}