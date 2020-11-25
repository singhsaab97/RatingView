# RatingView
An easy to use rating control view that can be updated on runtime, in addition to setting a predetermined rating. It offers a choice between static user interface and subtle animations.:star_struck: 

### Introduction
This was more of an improvement on the developers' side that I though of while working on one of the core features of an app. Earlier, we used filled, unfilled and half-filled star images to indicate rating given to a user and there was no way we could be precise enough to show floating point ratings (say 4.2) to the end-user. I thought this system could be improved a lot and reused at numerous places in the app. Hope you like how it came out to be.:nerd_face: 

### What it looks like?
**Mixed Bag - 1** | **Mixed Bag - 2** | **Predetermined Ratings** | **User Ratings**
------------------------------- | ------------------- | -------------------- | ---------------- 
![](RatingViewExamples/Gifs/RatingView2.gif) | ![](RatingViewExamples/Gifs/RatingView1.gif) | ![](RatingViewExamples/Gifs/RatingView3.gif) | ![](RatingViewExamples/Gifs/RatingView4.gif)

### Configurables
1. **type**: Determines if rating is already known or user input is required.
2. **fillColor**: Solid fill color of star.
3. **spacing**: Spacing between consecutive stars.
4. **numberOfCorners**: Number of corners of star.
5. **outlineColor**: Outline color of the star.
6. **radius**: Determines the radius of the circumcircle of star.

### How to use
```
// initialize properties
let properties: RatingView.Properties = .init(
    type: .rated(4.8, config: (animated: true, duration: 0.3)),
    fillColor: .systemYellow,
    spacing: 10,
    star: .init(
        numberOfCorners: 5,
        outlineColor: .systemYellow,
        radius: 20
    )  
)

// initialize rating view
let ratingView: RatingView = .init(properties: properties)

// add rating view and set constraints
view.addSubview(ratingView)
ratingView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
ratingView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
ratingView.widthAnchor.constraint(equalToConstant: ratingView.optimalSize.width).isActive = true
ratingView.heightAnchor.constraint(equalToConstant: ratingView.optimalSize.height).isActive = true
```
That's it!:partying_face:It is **recommended** to use **optimalSize** property to set proper constraints for the rating view, however, it'll also work fine if you set a custom width and height.:wink:

>Pass a listener in the initializer of your rating view by conforming the parent class to `RatingViewListener` to receive user rating events.

### Show some appreciation
Hey if you like this project and consider using it in your app, I'd like if you give it a star and show some love.:star::heavy_heart_exclamation:
