# ROMDisplay (FEB 2018)

This project illustrates one prototyped solution for a landscape-oriented large screen display at the Royal Ontario Museum.  The display plays videos with URLs obtained from a non-reliable REST api.

The project is implemented using XCode and the Swift language.

This app makes use of the Alamofire 4.0 pod, and thus, a pod install will be required.

Thus far, the app has been tested only using the iPhone 8 Plus simulator, and has not been tested on an actual iPhone. As such, we recommend this configuration when running.

# Approach

This app uses a MediaItemPopulator to asynchronously poll a non-reliable REST api (https://media-rest-service.herokuapp.com/media) for media item metadata.

The main queue is left responsible for playing media items.
